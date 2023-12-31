% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/CellScore.R
\name{CellScore}
\alias{CellScore}
\title{CellScore evaluates the identity of cells undergoing cell type transition}
\usage{
CellScore(
  transitions,
  data = NULL,
  scores.onoff = NULL,
  scores.cosine = NULL,
  pdata = NULL
)
}
\arguments{
\item{transitions}{a data frame containing three columns, one for the
start (donor) test and target cell type. Each row of the data.
frame describes one transition from the start to a target cell type.}

\item{data}{a SummarizedExperiment or ExpressionSet containing data matrices of normalized
expression data, present/absent calls, a gene annotation data frame and a
phenotype data frame.}

\item{scores.onoff}{a data.frame of OnOff Scores for all samples in the
expression matrix as generated by the function OnOff().}

\item{scores.cosine}{a numeric matrix of cosine similarity between
general groups, subgroups and individual samples as calculated by the
function CosineSimScore().}

\item{pdata}{a data frame with samples as rows, variables as columns.}
}
\value{
The function returns a data frame with 29 columns and M*N rows,
  where M is the number of unqiue start and target cell types pairs listed in
  the cell.change argument, while N is the number of all samples in the
  input dataset eset. The columns include sample phenotype features and all
  score (components), including the on/off score, cosine similarity and
  CellScore.
}
\description{
This function will calculate the CellScore (summary score) for a cell that
is undergoing a transition in cell identity from a starting cell type to a
target cell type. `transitions` is mandatory, and either `data` or all three of
`scores.onoff`, `scores.cosine` and `pdata` are as well. If you provide `data`,
then `scores.onoff`, `scores.cosine` and `pdata` will override the respective
calculations only.
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
   sel.samples <- pdata$general_cell_type \%in\% c("ESC", "EC", "FIB", "KER")
   eset.sub <- eset[, sel.samples]
   cs <- CosineSimScore(eset.sub, cell.change, iqr.cutoff=0.1)

   ## Generate the on/off scores for the combined data
   individ.OnOff <- OnOff(eset.sub, cell.change, out.put="individual")

   ## Generate the CellScore values for all samples
   cellscore <- CellScore(cell.change, data = eset.sub, scores.onoff = individ.OnOff$scores,
                          scores.cosine = cs$cosine.samples)
}
}
\seealso{
\code{\link[CellScore]{CosineSimScore}, \link[CellScore]{OnOff}} for
  details on specfic score calculations, and
  \code{\link[hgu133plus2CellScore]{hgu133plus2CellScore}} for details on the
  specific expressionSet object that shoud be provided as an input.
}
\keyword{cellscore}
\keyword{cosine}
\keyword{similarity}
