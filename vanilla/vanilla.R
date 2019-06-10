# This is an example how to use vanilla R.

infile <- Sys.getenv(c("IN_FILE"))
outfile <- Sys.getenv(c("OUT_FILE"))
matFrom <- matrix( scan( infile, skip=0, sep=',' ), ncol=54675, byrow=TRUE )
res <- cor(t(matFrom))
write.table(matFrom, file = outfile, row.names = FALSE, col.names = FALSE, sep = ",")
