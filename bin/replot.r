#!/usr/bin/env Rscript
#
# Program: replot.r
# Purpose: Re-plot coverage from a data matrix that has already been calculated.
# Arguments: text matrix file, output image name.
#
# -- by Li Shen, MSSM
#    Jan 2012
#

# Deal with command line arguments.
cmd.help <- function(){
	cat("\nUsage: replot.r -M matrix_file -O image_name\n")
	cat("\n")
	cat("-M     The matrix *.txt file generated by ngs.plot.r.\n")
	cat("-O     Output image name.\n")
	cat("         Do NOT append suffix, a .pdf will be added to the file name.\n")
	cat("\n")
}

args <- commandArgs(T)
progpath <- Sys.getenv('NGSPLOT')
if(progpath == ""){
	stop("Set environment variable NGSPLOT before run the program. See README for details.\n")
}else{
	if(substr(progpath, nchar(progpath), nchar(progpath)) != '/'){	# add trailing slash.
		progpath <- paste(progpath, '/', sep='')
	}
}
source(paste(progpath, 'lib/parse.args.r', sep=''))
source(paste(progpath, 'lib/plotmat.r', sep=''))
args.tbl <- parse.args(args, c('-M', '-O'))
if(is.null(args.tbl)){
	cmd.help()
	stop('Error in parsing command line arguments. Stop.\n')
}
matfile <- args.tbl['-M']
basename <- args.tbl['-O']

# Read parameter settings from matrix file.
para.max <- 20	# maximum parameter line number.
p.settings <- readLines(matfile, para.max)
p.settings <- p.settings[grep('^(\\s*)#([.\\w]+):([.\\w]+)$', p.settings, perl=T)]
p.settings <- unlist(strsplit(p.settings, ':'))
p.names <- p.settings[seq(1, length(p.settings)-1, 2)]
p.names <- sub('#', '', p.names)
p <- p.settings[seq(2, length(p.settings), 2)]
names(p) <- p.names
reg2plot <- p['reg2plot']
flanksize <- as.integer(p['flanksize'])
intsize <- as.integer(p['intsize'])
flankfactor <- as.numeric(p['flankfactor'])
shade.alp <- as.numeric(p['shade.alp'])
rnaseq.gb <- as.logical(p['rnaseq.gb'])
if('width' %in% names(p)){
	plot.width <- as.integer(p['width'])
}else{
	plot.width <- 2000
}
if('height' %in% names(p)){
	plot.height <- as.integer(p['height'])
}else{
	plot.height <- 1800
}
regcovMat <- as.matrix(read.delim(matfile, comment.char='#', check.names=F))
title2plot <- colnames(regcovMat)

sefile <- gsub(".txt", "_stderror.txt", matfile)
if(file.exists(sefile)){
	confiMat <- as.matrix(read.delim(sefile, comment.char='#', check.names=F))
}else{
	confiMat <- NULL
}

# Plot into image file.
out.plot <- paste(basename, '.pdf', sep='')
plotmat(out.plot, plot.width, plot.height, 48, 
	reg2plot, flanksize, intsize, flankfactor, shade.alp, rnaseq.gb,
	regcovMat, title2plot, confiMat)
