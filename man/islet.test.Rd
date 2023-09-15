\name{isletTest}
\alias{isletTest}
\title{
Testing for cell-type-specific Differential Expression (csDE) genes
}
\description{
This function, \code{isletTest}, can take the output from data preparation function \code{dataPrep}, and test for csDE genes. It uses Likelihood Ratio Test (LRT), iterating all cell types. The output is a matrix of p-values from LRT. It has parallel computing implemented to speed up the EM algorithm application.
}
\usage{
isletTest(input, BPPARAM=bpparam() )
}

\arguments{
  \item{input}{
The list object output from data preparation function \code{dataPrep}.
}
 \item{BPPARAM}{
An instance of \code{BiocParallelParam} class, e.g. MulticoreParam, SnowParam, SerialParam, to facilitate parallel computing. If using Unix, MulticoreParam is recommended. Customized options within \code{BiocParallelParam} class is allowed. If not specified, the default back-end is retrieve.
}

}
\details{
This function implement a LRT, and run individually for each cell type, and then aggregate the results together into a matrix.
}
\value{
 A p-value matrix, in the dimension of feature by cell type. Each element is the LRT p-value, by contrasting case group and control group, for one feature in one cell type.
}


\author{
Hao Feng <hxf155@case.edu>
}


\examples{
data(GE600)
ls()
## [1] "GE600_se"

#(1) Data preparation
study123input <- dataPrep(dat_se=GE600_se)

#(2) [optional for csDE genes testing] Individual-specific and cell-type-specific deconvolution
#result.solve <- isletSolve(input=study123input)

#(3) Test for csDE genes
result.test <- isletTest(input=study123input)
}
