\name{GE600age}
\alias{GE600age}
\alias{GE600age_se}


\docType{data}
\title{
ISLET example datasets for slope variable testing in csDE
}
\description{
\code{GE600age} contains the example input datasets for ISLET's slope testing function. It has the gene expression values, in the form of RNA-seq raw read counts, for 10 genes by 520 sample, with 83 cases and 89 controls, and multiple repeated measurements (i.e. time points) per subject. Temporal measures are at different age, with an \code{age} variable stored in the metadata. This is the main variable-of-interest in downstream testing. Data were combined by case/control status, into one \code{SummarizedExperiment} object. These example datasets will need to be converted by the \code{dataPrep} function, and then they will be ready for downstream deconvolution (function \code{isletSolve}) and/or differentially expressed gene testing (function \code{isletTest}).


}
\usage{data(GE600age)}
\format{
  One \code{SummarizedExperiment} object containing the following elements:
  \describe{
    \item{\code{counts}}{A gene expression value dataset, in the form of RNA-seq raw read counts, of 10 genes by 520 sample, with 83 cases and 89 controls, and multiple repeated measurements (i.e. time points) per subject.}
    \item{\code{colData}}{Sample meta-data. The first column is the case/ctrl group status, the second column is the subject ID, shows the relationship between the samples IDs and their subject IDs. The third column is the age variable for each sample, which is the main variable in downstream testing. The remaining 6 columns (i.e. column 4-9) are the cell type proportions of all samples by their 6 cell types.}
  }
}

\value{
One \code{SummarizedExperiment} object.
}

\examples{
data(GE600age)
ls()
## [1] "GE600age_se"

#show GE600age_se details
GE600age_se
#An object of class "SummarizedExperiment"

#Then, we can proceed to data preparation step, function 'dataPrep' for ISLET.
##The rest of the csDE testing on age(slope) effect will then follow.
}
\keyword{datasets}
