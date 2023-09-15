\name{implyDataPrep}
\alias{implyDataPrep}
\title{
Data preparation step utility function before using imply
}

\description{
This \code{implyDataPrep} function serves a necessary step in preparing your data for imply. It takes a single input, a \code{SummarizedExperiment} object, and generateds a formated S4 object that can be used as input for personalized deconvolution (\code{imply}).
}

\usage{
implyDataPrep(sim_se)
}

\arguments{
  \item{sim_se}{
A \code{SummarizedExperiment} object should include both case and control groups, in that order. It should contain the observed feature-by-sample matrix, with corresponding group labels (either "case" or "ctrl"), subject IDs, and cell type proportions for each sample (solved by CIBERSORT). The feature-by-sample matrix is stored in the `assay` slot, while the remaining components are stored in the `colData` slot. Within the`colData` slot, ensure that the group label is stored as `group` in the first column, subject IDs are stored as `subject_ID` in the second column, and the cell type proportions occupy the remaining columns. Please note that subject IDs must be sorted before utilizing the \code{implyDataPrep} function.
}
}
\details{
This is the initial step for preparing your input data for the imply algorithm, making it ready for personalized deconvolution using the \code{imply} function. Ensure that your input data adheres to the requirements listed below.
}
\value{
\code{implyDataPrep} returns an S4 object containing elements that are prepared to serve as input for downstream deconvolution using the \code{imply} function.
}

\author{
Guanqun Meng <gxm324@case.edu>
}


\examples{
data(GE600)
ls()
## [1] "GE600_se"

dat123 <- implyDataPrep(sim_se=GE600_se)
}

