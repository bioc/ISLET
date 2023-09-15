
setMethod("show", "inputSet",
          function(object){
              cat("First couple of elements from cases and controls:", "\n")
              print(object@exp_case[seq_len(3), seq_len(6)])
              print(object@exp_ctrl[seq_len(3), seq_len(6)])
              cat("Design matrices hidded.", "\n")
              cat("Total cell type number:", "\n")
              print(object@K)
              cat("Cell type categories:", "\n")
              print(object@CT)
              cat("Total sample number and subject number:", "\n")
              print(c(object@NS, object@NU))
              cat("Total case number and ctrl number:","\n")
              print(c(object@case_num, object@ctrl_num))
              cat("First several subject ID for the samples:", "\n")
              print(object@SubjectID[seq_len(10)])
              cat("Data preparation type (intercept/slope):", "\n")
              print(object@type)
          }
)


setMethod("show", "outputSol",
          function(object){
              cat("For cell type 1, the first several individual-specific reference from the case group:", "\n")
              print(object@case.ind.ref[[1]][seq_len(3), seq_len(5)])
              cat(paste0(nrow(object@case.ind.ref[[1]]), " by ", ncol(object@case.ind.ref[[1]]),
                         " (Gene by Individual) reference panel is repeated for all ", length(object@case.ind.ref), " cell types." ), "\n")
              cat("For cell type 1, the first several individual-specific reference from the control group:", "\n")
              print(object@ctrl.ind.ref[[1]][seq_len(3), seq_len(5)])
              cat(paste0(nrow(object@ctrl.ind.ref[[1]]), " by ", ncol(object@ctrl.ind.ref[[1]]),
                         " (Gene by Individual) reference panel is repeated for all ", length(object@ctrl.ind.ref), " cell types." ), "\n")
              cat("First several Log-likelihoods stored for downstream test:", "\n")
              print(object@mLLK[seq_len(3)])
          }
)

###############
setMethod("show", "implyS4",
          function(object){
            cat("First couple of elements from samples:", "\n")
            print(object@raw_count[seq_len(10), seq_len(10)])
            cat("Total cell type number:", "\n")
            print(object@K)
            cat("Cell type categories:", "\n")
            print(colnames(object@ini.prop))
            cat("Total case subjects and ctrl subjects:","\n")
            print(c(object@case_num, object@ctrl_num))
            cat("Total sample number and subject number:", "\n")
            print(c(object@NS, object@NU))
            cat("First couple initial cell proportion, ideally solved by CIBERSORT:", "\n")
            print(head(object@ini.prop))
            cat("First and last few group labels and subject IDs samples:", "\n")
            print(rbind(head(object@metadata),
                        tail(object@metadata)))
          }
)
###################


caseEst<-function(res.sol){
    est <- res.sol@case.ind.ref
    return(est)
}


ctrlEst<-function(res.sol){
    est <- res.sol@ctrl.ind.ref
    return(est)
}
