library(SparkR)
sparkR.session(master = "spark://spark1:7077", sparkConfig = list(spark.driver.memory = "8g")) 
#, sparkEnvir = list(spark.driver.memory="2g",)
#setwd('/data/')
Sys.setenv('SPARKR_SUBMIT_ARGS'='"--packages" "com.databricks:spark-csv_2.10:1.2.0" "sparkr-shell"')

# [input] set work number
nodesNum <- as.numeric(Sys.getenv(c("NODE_NUM")))
averFloor <- floor((nodesNum + 1)/2)
averCeiling <- ceiling((nodesNum + 1)/2)
# [input] set sample number
patientNum <- as.numeric(Sys.getenv(c("CALC_NUM")))
# [input] set probe number
probesNum <- as.numeric(Sys.getenv(c("PROBE_NUM")))
bufSize <- ceiling(patientNum / nodesNum)
cormethod <- "pearson"
lastoneNum <- patientNum - (nodesNum - 1) * bufSize
# [input] set data location with prefix
dataFile <- Sys.getenv(c("DATA_FILE_PRE"))
resultFile <- Sys.getenv(c("RES_FILE_PRE"))

geneCor <- function(x) {
		x <- as.numeric(x)
		if (x < averFloor - 1) {
			matFrom <- matrix( scan( paste(dataFile, x, sep=""), skip=0, sep=',' ), ncol=probesNum, byrow=TRUE )
			
			matTo <- matrix(ncol = bufSize, nrow = bufSize * averCeiling)
			for (j in 1:averCeiling) {
				#print(j)
				matTmp <- matrix( scan( paste(dataFile, x + j - 1, sep=""), skip=0, sep=',' ), ncol=probesNum, byrow=TRUE )
				matTo[((j - 1) * bufSize + 1) : (j * bufSize), ] <- cor(t(matFrom), t(matTmp), method=cormethod)
				write.table(matTo[((j - 1) * bufSize + 1) : (j * bufSize), ], file = paste(resultFile, x, x + j - 1, sep="_"), row.names = FALSE, col.names = FALSE, sep = ",")
			}
			return(matTo)
		}
	
		else if (x >= averFloor - 1 && x <= averCeiling - 1) {
			matFrom <- matrix( scan( paste(dataFile, x, sep=""), skip=0, sep=',' ), ncol=probesNum, byrow=TRUE )
			
			matTo <- matrix(ncol = bufSize, nrow = bufSize * (nodesNum - x))
			for (j in 1:(nodesNum - x)) {
				#print(j)
				matTmp <- matrix( scan( paste(dataFile, x + j - 1, sep=""), skip=0, sep=',' ), ncol=probesNum, byrow=TRUE )
				if ((x + j) * bufSize + 1 > patientNum) {
					matTo[((j - 1) * bufSize + 1) : ((j - 1) * bufSize + lastoneNum), ] <- cor(t(matFrom), t(matTmp), method=cormethod)
					write.table(matTo[((j - 1) * bufSize + 1) : ((j - 1) * bufSize + lastoneNum), ], file = paste(resultFile, x, x + j - 1, sep="_"), row.names = FALSE, col.names = FALSE, sep = ",")
				} else {
					matTo[((j - 1) * bufSize + 1) : (j * bufSize), ] <- cor(t(matFrom), t(matTmp), method=cormethod)
					write.table(matTo[((j - 1) * bufSize + 1) : (j * bufSize), ], file = paste(resultFile, x, x + j - 1, sep="_"), row.names = FALSE, col.names = FALSE, sep = ",")
				}
				
			}
			return(matTo)
		}
		
		else if (x > averCeiling - 1) {
			condFrom <- (x + 1) * bufSize + 1 > patientNum
			matFrom <- matrix( scan( paste(dataFile, x, sep=""), skip=0, sep=',' ), ncol=probesNum, byrow=TRUE )
			
			matTo <- matrix(ncol = bufSize, nrow = bufSize * averFloor)
			for (j in 1:averFloor) {
				print(j)
				condTo <- (x + j) %% (nodesNum + 1) * bufSize + 1 > patientNum
				
				matTmp <- matrix( scan( paste(dataFile, (x + j - 1) %% (nodesNum), sep=""), skip=0, sep=',' ), ncol=probesNum, byrow=TRUE )
				if (condTo && condFrom) {			
					matTo[((j - 1) * bufSize + 1) : ((j - 1) * bufSize + lastoneNum), 1 : lastoneNum] <- cor(t(matFrom), t(matTmp), method=cormethod)
					write.table(matTo[((j - 1) * bufSize + 1) : ((j - 1) * bufSize + lastoneNum), 1 : lastoneNum], file = paste(resultFile, x, (x + j - 1) %% (nodesNum), sep="_"), row.names = FALSE, col.names = FALSE, sep = ",")
				} else if (condTo && !condFrom) {
					matTo[((j - 1) * bufSize + 1) : ((j - 1) * bufSize + lastoneNum), ] <- cor(t(matFrom), t(matTmp), method=cormethod)
					write.table(matTo[((j - 1) * bufSize + 1) : ((j - 1) * bufSize + lastoneNum), ], file = paste(resultFile, x, (x + j - 1) %% (nodesNum), sep="_"), row.names = FALSE, col.names = FALSE, sep = ",")
				} else if (!condTo && condFrom) {
					matTo[((j - 1) * bufSize + 1) : (j * bufSize), 1 : lastoneNum] <- cor(t(matFrom), t(matTmp), method=cormethod)
					write.table(matTo[((j - 1) * bufSize + 1) : (j * bufSize), 1 : lastoneNum], file = paste(resultFile, x, (x + j - 1) %% (nodesNum), sep="_"), row.names = FALSE, col.names = FALSE, sep = ",")
				} else {
					matTo[((j - 1) * bufSize + 1) : (j * bufSize), ] <- cor(t(matFrom), t(matTmp), method=cormethod)
					write.table(matTo[((j - 1) * bufSize + 1) : (j * bufSize), ], file = paste(resultFile, x, (x + j - 1) %% (nodesNum), sep="_"), row.names = FALSE, col.names = FALSE, sep = ",")
				}				
			}
			return(matTo)
		}
}

system.time(out<-spark.lapply(0 : (nodesNum - 1), geneCor))
