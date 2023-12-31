% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/CellScoreReport.R
\name{CellScoreReport}
\alias{CellScoreReport}
\title{Generate a CellScore report}
\usage{
CellScoreReport(cellscore, cell.change, marker.genes, eset)
}
\arguments{
\item{cellscore}{a data.frame of CellScore values, as calculated by
CellScore().}

\item{cell.change}{a data frame containing three columns, one for the
start (donor) test and target cell type. Each row of the data
frame describes one transition from the start to a target cell type.}

\item{marker.genes}{a data.frame of marker genes as generated by function OnOff()}

\item{eset}{an ExpressionSet containing data matrices of normalized
expression data, present/absent calls, a gene annotation data.frame and
a phenotype data.frame.}
}
\value{
This function outputs the plots on the active graphical device
  and returns invisibly NULL.
}
\description{
This function will generates a CellScore report for each study and
transition that can be saved as a pdf. The report includes:
1) scatterplot of the donor-like and target-like scores of relevant
test samples and the standards;
2) a density plot of the test and standard cellscores;
3) a rugplot of the cellscores, focussing on the test samples;
4) a heatmap of the OnOff Marker genes for all standards and test samples.
}
\examples{
## Load the expression set for the standard cell types
library(Biobase)
library(hgu133plus2CellScore) # eset.std

## Locate the external data files in the CellScore package
rdata.path <- system.file("extdata", "eset48.RData", package = "CellScore")
tsvdata.path <- system.file("extdata", "cell_change_test.tsv",
                             package = "CellScore")

if (file.exists(rdata.path) && file.exists(tsvdata.path)) {

   ## Load the expression set with normalized expressions of 48 test samples
   load(rdata.path)

   ## Import the cell change info for the loaded test samples
   cell.change <- read.delim(file= tsvdata.path, sep="\t",
                             header=TRUE, stringsAsFactors=FALSE)

   ## Combine the standards and the test data
   eset <- combine(eset.std, eset48)

   ## Generate cosine similarity for the combined data
   ## NOTE: May take 1-2 minutes on the full eset object
   ## so we subset it for 4 cell types
   pdata <- pData(eset)
   sel.samples <- pdata$general_cell_type \%in\% c("ESC", "EC", "FIB", "KER", 
                 "ASC", "NPC", "MSC", "iPS", "piPS")
   eset.sub <- eset[, sel.samples]
   cs <- CosineSimScore(eset.sub, cell.change, iqr.cutoff=0.1)

   ## Generate the on/off scores for the combined data
   individ.OnOff <- OnOff(eset.sub, cell.change, out.put="individual")

   ## Generate the CellScore values for all samples
   cellscore <- CellScore(data=eset.sub, transitions=cell.change, scores.onoff=individ.OnOff$scores,
                          scores.cosine=cs$cosine.samples)

   ## Generate the group on/off scores for the combined data
   group.OnOff <- OnOff(eset.sub, cell.change, out.put="marker.list")

   ## Make a report and save it the current working directory
   pdf("TestReport.pdf", width=8, height=12)
   CellScoreReport(cellscore, cell.change, group.OnOff$markers, eset.sub)
   dev.off()
}
}
\seealso{
\code{\link[CellScore]{CellScore}} for details on CellScore, and
  \code{\link[hgu133plus2CellScore]{hgu133plus2CellScore}} for details on the
  specific ExpressionSet object that shoud be provided as an input.
}
\keyword{cellscore}
\keyword{report}
