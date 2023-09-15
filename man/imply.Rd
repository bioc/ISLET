\name{imply}
\alias{imply}
\title{
\emph{\bold{imply}}: \emph{\bold{imp}}roving ce\emph{\bold{l}}l-t\emph{\bold{y}}pe deconvolution using personalized reference
}
\description{
This core function, \code{imply}, plays a central role in the imply algorithm. It takes the output from data preparation function \code{implyDataPrep}, and utilizes linear mixed-effects models to solve for individual-specific and cell-type-specific reference panels. It has parallel computing implemented to enhance computational efficiency.
}
\usage{
imply(dat123)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{dat123}{
  The list object output from data preparation function \code{implyDataPrep}.
}
}

\details{
  \code{imply} is a two-step algorithm to enhance cell deconvolution results by employing subject-specific and cell-type-specific (personalized) reference panels.

  In step I, personalized reference panels are generated for each subject using linear mixed-effects models. These personalized references are tailored to individual subjects.

  In step II, these personalized reference panels replace the population-level signature matrix, typically used in traditional reference-based deconvolution methods. This substitution enables a personalized deconvolution process across all subjects, by employing the non-negative least squares algorithm.

  The function returns a list containing personalized reference panels and improved cell deconvolution results.
}

\value{
  A list with the estimated components of the \code{imply} algorithm:
  \item{p.ref}{The estimated subject-specific and cell-type-specific reference panels. It is an array of dimension \emph{G} by \emph{K} by \emph{N}, where \emph{G} is the total number of genetic features, \emph{K} is the total number of cell types, and \emph{N} is the total number of subjects.
  }
  \item{imply.prop}{The improved cell deconvolution results based on personalized reference panels from \code{p.ref}. It is a data.frame of \emph{T} by \emph{K}, where \emph{T} is the total number of samples across all subjects. Each subject can have a different number of repeatedly measured samples.
  }
}

\author{
Guanqun Meng <gxm324@case.edu>
}

\examples{
data(GE600)
ls()
## [1] "GE600_se"

#(1) Data preparation
dat123 <- implyDataPrep(sim_se=GE600_se)

#(2) improved and personalized cell deconvolution
result <- imply(dat123)
str(result)
#List of 2
# $ p.ref     : num [1:10, 1:6, 1:172] 0 0 0.952 13.438 19.007 ...
#  ..- attr(*, "dimnames")=List of 3
#  .. ..$ : chr [1:10] "gene1" "gene2" "gene3" "gene4" ...
#  .. ..$ : chr [1:6] "Bcells" "Tcells_CD4" "Tcells_CD8" "NKcells" ...
#  .. ..$ : chr [1:172] "210298" "223361" "228055" "229203" ...
# $ imply.prop:'data.frame':	520 obs. of  6 variables:
#  ..$ Bcells    : num [1:520] 0.4806 0.1912 0.0843 0.2177 0 ...
#  ..$ Tcells_CD4: num [1:520] 0 0 0 0 0 ...
#  ..$ Tcells_CD8: num [1:520] 0 0 0.2129 0.0507 0.2584 ...
#  ..$ NKcells   : num [1:520] 0.1114 0.2487 0.153 0 0.0543 ...
#  ..$ Mono      : num [1:520] 0.0547 0.0271 0 0 0.343 ...
#  ..$ Others    : num [1:520] 0.353 0.533 0.55 0.732 0.344 ...
}

