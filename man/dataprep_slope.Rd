\name{dataPrepSlope}
\alias{dataPrepSlope}
\title{Data preparation function specifically for slope effect testing}
\description{
This function, \code{dataPrepSlope}, is a necessary step to make your data ready and acceptable to ISLET slope effect testing. It takes one \code{SummarizedExperiment} objects containing both case and control group as the input, and produce a list ready to be feed into ISLET downstream deconvolution (function \code{isletSolve}) and/or differentially expressed gene testing (function \code{isletTest}).
}
\usage{
dataPrepSlope(dat_se)
}

\arguments{
  \item{dat_se}{
A \code{SummarizedExperiment} object containing both case and control group. It should contain the observed feature by sample matrix, group label (case or ctrl) for each sample, subject IDs for each sample, a slope variable for each sample, and cell type proportions for each sample. The feature by sample matrix is stored in the \code{count} assay, while the remaining components are stored in the colData slot. In the colData slot, the group label (case or ctrl) take the first column, subject IDs take the second column, the slope variable takes the third column, and the cell type proportions take the remaining columns. Subject IDs need to be sorted before using the \code{dataPrepSlope} function.
}
}

\details{
This is the initial step for using ISLET, to prepare your data input ready for downstream cell-type-specific differentially expressed gene testing (function \code{isletTest}) with respect to the slope variable. The input data matrices must follow requirements listed above, and samples/subjects must be ordered and match across matrices.
}

\value{
\code{dataPrepSlope} returns a S4 object, containing elements ready to serve as the input for cell-type-specific differentially expressed gene testing (function \code{isletTest}).
}

\author{
Hao Feng <hxf155@case.edu>
}


\examples{
data(GE600age)
ls()
## [1] "GE600age_se"

#(1) Data preparation
study456input <- dataPrepSlope(dat_se=GE600age_se)

#(2) [Downstream] Test for slope effect(i.e. age) difference in csDE testing
#result.test <- isletTest(input=study456input)

}
