
###function to run ISLET, using parallel computing

isletSolve<-function(input, BPPARAM=bpparam() ){
    # islet.solve only runs on the model without age effect.
    if(input@type == 'slope'){
        stop('Input should be prepared by dataPrep()')
    }


    #make Yall a list
    G <- nrow(input@exp_case)
    Yall<-as.matrix(cbind(input@exp_case, input@exp_ctrl))
    aval.nworkers<-BPPARAM$workers
    block.size<-max(ceiling(G/aval.nworkers), 5)
    Yall.list <- split(as.data.frame(Yall), ceiling(seq_len(G)/block.size))

#    if(.Platform$OS.type == "unix") {
    ## do some parallel computation under Unix
#        multicoreParam <- MulticoreParam(workers = ncores)
      res <- bplapply(X=Yall.list, islet.solve.block, datuse=input, BPPARAM=BPPARAM)
#  }
#  else {
    ## This will be windows
    ## Use serial param or do not use any parallel functions, just use ‘lapply’
    ## result should be of the same “type” from both the if and else statements.
#    nworkers<-length(Yall.list)
#    cl <- makeCluster(nworkers)

    ## Remove clusterExport(), clusterEvalQ() if use devtools::install() to build package
#    clusterExport(cl,list('colss'))
#    clusterEvalQ(cl,{
#        library(Matrix)
#        library(BiocGenerics)})

#    res <-parLapply(cl, X=Yall.list, islet.solve.block, datuse=input)
#    stopCluster(cl)
#
#  }

  # Organize estimated individual reference
  K<-input@K
  SubjectID<-unique(input@SubjectID)
  case_num<-input@case_num
  case.indv.merge<-lapply(seq_len(K), function(k){
      case.indv.all<-lapply(res, '[[', 3)
      case.indv.ctk<-t(do.call(cbind, lapply(case.indv.all, '[[', k)))
      case.indv.ctk<-ifelse(as.matrix(case.indv.ctk)<0, 0, case.indv.ctk)
      dimnames(case.indv.ctk)<-list(rownames(input@exp_case), SubjectID[seq_len(case_num)])
      return(case.indv.ctk)
  })
  ctrl.indv.merge<-lapply(seq_len(K), function(k){
      ctrl.indv.all<-lapply(res, '[[', 4)
      ctrl.indv.ctk<-t(do.call(cbind, lapply(ctrl.indv.all, '[[', k)))
      ctrl.indv.ctk<-ifelse(as.matrix(ctrl.indv.ctk)<0, 0, ctrl.indv.ctk)
      dimnames(ctrl.indv.ctk)<-list(rownames(input@exp_ctrl), SubjectID[-seq_len(case_num)])
      return(ctrl.indv.ctk)
  })

  names(case.indv.merge)<-input@CT
  names(ctrl.indv.merge)<-input@CT
  llk<-unlist(lapply(res, '[[', 7))

  rval<-outputSol(case.ind.ref=case.indv.merge,
            ctrl.ind.ref=ctrl.indv.merge,
            mLLK=llk)

  return(rval)
}

