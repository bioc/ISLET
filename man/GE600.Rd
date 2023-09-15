\name{GE600}
\alias{GE600}
\alias{GE600_se}

\docType{data}
\title{
ISLET deconvolution example raw input data
}
\description{
\code{GE600} contains the raw example datasets for ISLET. It has the gene expression values, in the form of RNA-seq raw read counts, for 10 genes by 520 sample, with 83 cases and 89 controls, and multiple repeated measurements (i.e. time points) per subject. Data were combined by case/control status, into one single \code{SummarizedExperiment} object. These raw example datasets will need to be converted by the \code{dataPrep} function, and then they will be ready for downstream deconvolution (function \code{isletSolve}) and/or differentially expressed gene testing (function \code{isletTest}).
}
\usage{data(GE600)}
\format{
  One \code{SummarizedExperiment} object containing the following elements:
  \describe{
    \item{\code{counts}}{A gene expression value dataset, in the form of RNA-seq raw read counts, of 10 genes by 520 sample, with 83 cases and 89 controls, and multiple repeated measurements (i.e. time points) per subject.}
    \item{\code{colData}}{Sample meta-data. The first column is the group status (i.e. case/ctrl), the second column is the subject ID, shows the relationship between the samples IDs and their subject IDs. The remaining 6 columns (i.e. column 3-8) are the cell type proportions of all samples by their 6 cell types.}
  }
}

\value{
One \code{SummarizedExperiment} object.
}

\examples{
data(GE600)
ls()
## [1] "GE600_se"

#show GE600_se details
GE600_se
#An object of class "SummarizedExperiment"

#Then, we can proceed to data preparation step, function 'dataPrep' for ISLET.
##The rest of the deconvolution/csDE analysis will then follow.
}
\keyword{datasets}
