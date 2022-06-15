#########################
#########################
#########################
##functions for LRT
#########################
#########################
#########################
#(1) data prep for LRT
#function to change input format wrt to each cell type, to get ready for LRT
changeinput<-function(dc, iK){
  K = dc$K
  X.tmp1 = dc$X
  X.tmp2 = X.tmp1[,-(K+iK)]
  dc$X = X.tmp2
  return(dc)
}


#(2) LRT function in Unix and Windows
###function to implement EM algorithm in ISLET algorithm
#ipc is the index of parallel computing; datuse is the harmonized data from the previous step
islet.lrt.unix<-function(ipc, datuse, ktest){
  exp_case = as.matrix(datuse$exp_case)
  exp_ctrl = as.matrix(datuse$exp_ctrl)
  X = datuse$X
  A = datuse$A
  K = datuse$K
  NS = datuse$NS
  NU = datuse$NU


  #initialization of parameters parameter estimation storage
  B_est=NULL
  Sig0_est = NULL
  SigU_est = NULL
  E_U_est = NULL
  llk = NULL
  ##
  Y=c(exp_case[ipc,],exp_ctrl[ipc,])
  #  Y=log2(Y+1)

  ####1. Initialization of parameters
  #1.1 cell type profiles AND csDE B parameters
  #B_0 = solve(X,Y)
  B_0 = solve(t(X) %*% X) %*% t(X) %*% Y

  #1.2 error terms
  #sig = mean((Y-X%*%B_0)^2)
  sig = 20

  #1.3 missing values
  U_0 = rep(0, NU*K)

  B_t = B_0
  #sig_t = rep(sig, 7)
  U_t = U_0
  sig0_t = rep(sig, 1)
  sigK_t = rep(sig, K)

  iem = 1
  diff1 = diff2 = 100
  pp = 1
  Sig_U = diag(rep(sigK_t, each = NU))
  invSig_U=diag(rep(1/sigK_t, each = NU))
  Sig_p=solve(t(A) %*% A/sig0_t+invSig_U)
  E_Up=mu_p=Sig_p %*% t(A)%*% (Y - X %*% B_t)/sig0_t


  while(diff2>0.05 & iem<100){
    # cat("iteration=", iem, "\n")
    iem = iem + 1
    ####2. E-step
    #observed data COV(Y) = V

    #V = A%*%Sig_U%*%t(A) + diag(rep(sig0_t, 5*600))

    #2.1 E[U|Y]: missing data [U|Y] given observed data
    #invV = solve(V)
    # E_U = mu_p = t(Sig_U) %*% t(A) %*% invV %*% (Y - X %*% B_t)
    # Sig_p = Sig_U - crossprod(Sig_U,t(A)) %*% invV %*% A %*% Sig_U

    # Estimate from last iteration
    E_U=mu_p =E_Up

    #2.2 E[t(S)S|Y]
    E_StS = sum(diag(A%*%Sig_p%*%t(A))) + sum((A%*%mu_p + X%*%B_t - Y)^2)

    #2.3 E[U_k^T U_k|Y]
    mutra_split = split(diag(Sig_p), ceiling(seq_along(diag(Sig_p))/NU))
    mu_split = split(E_U, ceiling(seq_along(E_U)/NU))

    E_UkTUk = unlist(lapply(mutra_split, sum)) + unlist(lapply(mu_split, ss))

    ####3. M-step
    #3.1 B
    B_tp = solve(t(X)%*%X)%*%t(X)%*%(Y-A%*%E_U)

    #make correction in case B[1:K]<0 or B_tp[(K+1):2K]<0
    #important to bound the estimation to positive values
    paradrop = (seq_len(K))[-ktest]
    B_tp[seq_len(K),] = ifelse(B_tp[seq_len(K),]<0, 0, B_tp[seq_len(K),])
    B_tp[-(seq_len(K)),] = ifelse(B_tp[paradrop,]+B_tp[-(seq_len(K)),]<0, -B_tp[paradrop,], B_tp[-(seq_len(K)),])

    #3.2 sigma_0^2
    sig0_tp = E_StS/(NS)

    #3.3 sigma_k^2
    sigK_tp = E_UkTUk/(NU)

    ####4. Stopping criteria
    diff1 = sum(abs(B_tp - B_t)) + abs(sig0_tp - sig0_t) + sum(abs(sigK_tp - sigK_t))

    n1 = sum(abs(B_tp - B_t))/length(B_tp)
    n2 = sum(abs(B_tp))/length(B_tp)
    pp = n1/n2
    #cat("B_sum_val=", n2, "\n")
    #cat("B_change_val=", n1, "\n")
    #cat("B_change_prop=", pp*100,"% \n")

    ####5. Update params
    B_t=B_tp
    sig0_t = sig0_tp
    sigK_t = sigK_tp

    Sig_U = diag(rep(sigK_t, each = NU))
    invSig_Up=diag(rep(1/sigK_t, each = NU))
    Sig_p=solve(t(A) %*% A/sig0_t+invSig_Up)
    E_Up=Sig_p %*% t(A)%*% (Y - X %*% B_t)/sig0_t
    diff2 = sum(abs(E_Up - E_U))/length(E_U)
    #cat("Random effect diff2=", diff2, "\n")

  }
  # Estimate of fixed effect
  B_est=cbind(B_est,B_t)
  # Estimate of random effect
  E_U_est=cbind(E_U_est,E_Up)
  # Estimate of variance Sigma_U, Sigma_0
  Sig0_est = cbind(Sig0_est, sig0_t)
  SigU_est = cbind(SigU_est, sigK_t)

  #calculate LLK
  Sig=A%*%Sig_U%*%t(A)+diag(sig0_t,nrow = nrow(A))
  l=determinant(Sig)$modulus+t(Y-X%*%B_t)%*%solve(Sig)%*%(Y-X%*%B_t)
  llk=c(llk,-as.numeric(l))

  #make the estimation results ready for return list
  #(1) the mean for case and control, for all cell types. 2 vectors of length K.
  #case.m = B_est[1:K]+B_est[(K+1):length(B_est)]
  #ctrl.m = B_est[1:K]

  #(2) the individual value for case and control, for all cell types. 2 matrices of NU by K.
  #rel = split(E_U_est, ceiling(seq_along(E_U_est)/NU))
  #re = do.call(cbind, rel)

  #case.indv = re[1:datuse$case_num,] + rep(case.m, each = datuse$case_num)
  #ctrl.indv = re[(datuse$case_num+1):nrow(re),] + rep(ctrl.m, each = datuse$ctrl_num)

  #(3) Variance for K cell types. 1 vector of length K.
  #'SigU_est' is already to be rendered.

  #(4) Variance for grand residuals. 1 scalar.
  #'Sig0_est' is already to be rendered.

  #(5) the model likelihood. 1 scalar.
  #'llk' is already to be rendered.

  #compile return list
  #rval = list(LLK = llk)
  #return(rval)
  LLK = llk
  return(LLK)

  #cat("Complete: LRT calculation for one cell type.")
}




###function to implement EM algorithm in ISLET algorithm
#function here for windows only, using lapply, no parallel computing
islet.lrt.win<-function(yvec, datuse, ktest){
  #exp_case = as.matrix(datuse$exp_case)
  #exp_ctrl = as.matrix(datuse$exp_ctrl)
  X = datuse$X
  A = datuse$A
  K = datuse$K
  NU = datuse$NU
  NS = datuse$NS


  #initialization of parameters parameter estimation storage
  B_est=NULL
  Sig0_est = NULL
  SigU_est = NULL
  E_U_est = NULL
  llk = NULL
  ##
  Y=as.numeric(yvec)
  #  Y=log2(Y+1)

  ####1. Initialization of parameters
  #1.1 cell type profiles AND csDE B parameters
  #B_0 = solve(X,Y)
  B_0 = solve(t(X) %*% X) %*% t(X) %*% Y

  #1.2 error terms
  #sig = mean((Y-X%*%B_0)^2)
  sig = 20

  #1.3 missing values
  U_0 = rep(0, NU*K)

  B_t = B_0
  #sig_t = rep(sig, 7)
  U_t = U_0
  sig0_t = rep(sig, 1)
  sigK_t = rep(sig, K)

  iem = 1
  diff1 = diff2 = 100
  pp = 1
  Sig_U = diag(rep(sigK_t, each = NU))
  invSig_U=diag(rep(1/sigK_t, each = NU))
  Sig_p=solve(t(A) %*% A/sig0_t+invSig_U)
  E_Up=mu_p=Sig_p %*% t(A)%*% (Y - X %*% B_t)/sig0_t


  while(diff2>0.05 & iem<100){
    #cat("iteration=", iem, "\n")
    iem = iem + 1
    ####2. E-step
    #observed data COV(Y) = V

    #V = A%*%Sig_U%*%t(A) + diag(rep(sig0_t, 5*600))

    #2.1 E[U|Y]: missing data [U|Y] given observed data
    #invV = solve(V)
    # E_U = mu_p = t(Sig_U) %*% t(A) %*% invV %*% (Y - X %*% B_t)
    # Sig_p = Sig_U - crossprod(Sig_U,t(A)) %*% invV %*% A %*% Sig_U

    # Estimate from last iteration
    E_U=mu_p =E_Up

    #2.2 E[t(S)S|Y]
    E_StS = sum(diag(A%*%Sig_p%*%t(A))) + sum((A%*%mu_p + X%*%B_t - Y)^2)

    #2.3 E[U_k^T U_k|Y]
    mutra_split = split(diag(Sig_p), ceiling(seq_along(diag(Sig_p))/NU))
    mu_split = split(E_U, ceiling(seq_along(E_U)/NU))

    E_UkTUk = unlist(lapply(mutra_split, sum)) + unlist(lapply(mu_split, ss))

    ####3. M-step
    #3.1 B
    B_tp = solve(t(X)%*%X)%*%t(X)%*%(Y-A%*%E_U)

    #make correction in case B[1:K]<0 or B_tp[(K+1):2K]<0
    #important to bound the estimation to positive values
    paradrop = (seq_len(K))[-ktest]
    B_tp[seq_len(K),] = ifelse(B_tp[seq_len(K),]<0, 0, B_tp[seq_len(K),])
    B_tp[-(seq_len(K)),] = ifelse(B_tp[paradrop,]+B_tp[-(seq_len(K)),]<0, -B_tp[paradrop,], B_tp[-(seq_len(K)),])

    #3.2 sigma_0^2
    sig0_tp = E_StS/(NS)

    #3.3 sigma_k^2
    sigK_tp = E_UkTUk/(NU)

    ####4. Stopping criteria
    diff1 = sum(abs(B_tp - B_t)) + abs(sig0_tp - sig0_t) + sum(abs(sigK_tp - sigK_t))

    n1 = sum(abs(B_tp - B_t))/length(B_tp)
    n2 = sum(abs(B_tp))/length(B_tp)
    pp = n1/n2
    #cat("B_sum_val=", n2, "\n")
    #cat("B_change_val=", n1, "\n")
    #cat("B_change_prop=", pp*100,"% \n")

    ####5. Update params
    B_t=B_tp
    sig0_t = sig0_tp
    sigK_t = sigK_tp

    Sig_U = diag(rep(sigK_t, each = NU))
    invSig_Up=diag(rep(1/sigK_t, each = NU))
    Sig_p=solve(t(A) %*% A/sig0_t+invSig_Up)
    E_Up=Sig_p %*% t(A)%*% (Y - X %*% B_t)/sig0_t
    diff2 = sum(abs(E_Up - E_U))/length(E_U)
    #cat("Random effect diff2=", diff2, "\n")

  }
  # Estimate of fixed effect
  B_est=cbind(B_est,B_t)
  # Estimate of random effect
  E_U_est=cbind(E_U_est,E_Up)
  # Estimate of variance Sigma_U, Sigma_0
  Sig0_est = cbind(Sig0_est, sig0_t)
  SigU_est = cbind(SigU_est, sigK_t)

  #calculate LLK
  Sig=A%*%Sig_U%*%t(A)+diag(sig0_t,nrow = nrow(A))
  l=determinant(Sig)$modulus+t(Y-X%*%B_t)%*%solve(Sig)%*%(Y-X%*%B_t)
  llk=c(llk,-as.numeric(l))

  #make the estimation results ready for return list
  #(1) the mean for case and control, for all cell types. 2 vectors of length K.
  #case.m = B_est[1:K]+B_est[(K+1):length(B_est)]
  #ctrl.m = B_est[1:K]

  #(2) the individual value for case and control, for all cell types. 2 matrices of NU by K.
  #rel = split(E_U_est, ceiling(seq_along(E_U_est)/NU))
  #re = do.call(cbind, rel)

  #case.indv = re[1:datuse$case_num,] + rep(case.m, each = datuse$case_num)
  #ctrl.indv = re[(datuse$case_num+1):nrow(re),] + rep(ctrl.m, each = datuse$ctrl_num)

  #(3) Variance for K cell types. 1 vector of length K.
  #'SigU_est' is already to be rendered.

  #(4) Variance for grand residuals. 1 scalar.
  #'Sig0_est' is already to be rendered.

  #(5) the model likelihood. 1 scalar.
  #'llk' is already to be rendered.

  #compile return list
#  rval = list(LLK = llk)
  LLK = llk
    return(LLK)

  #cat("Complete: LRT calculation for one cell type.")
}


###Wrap function to run ISLET LRT, using parallel computing
#ipc is the index of parallel computing for
islet.test<-function(input){

  if(.Platform$OS.type == "unix") {
    ## do some parallel computation under Unix
    G = nrow(input$exp_case)
    mf = bplapply(seq_len(G), islet.est.bp, datuse = input)
    #use islet.lrt.unix
    test.res = matrix(NA, nrow = G, ncol = input$K)
    for(iTest in seq_len(input$K)){
      inputnew = changeinput(dc = input, iK = iTest)
      tmp1 = bplapply(seq_len(G), islet.lrt.unix, datuse = inputnew, ktest = iTest)
      tmp2 = unlist(tmp1)
      tmp3 = unlist(lapply(mf, '[[' , 7))
      ###obtain the p-values from each cell type
      tmp4 = LRT(tmp3, tmp2, df = 1)
      test.res[,iTest] = tmp4
      cat("csDE testing finished on cell type ", iTest, "\n")
    }
    colnames(test.res) = colnames(input$X[,seq_len(input$K)])
  }
  else {
    ## This will be windows
    ## Use serial param or do not use any parallel functions, just use ‘lapply’
    ## result should be of the same “type” from both the if and else statements.
    Yall=as.matrix(cbind(input$exp_case, input$exp_ctrl))
    #make Yall a list
    Yall.list <- split(t(Yall), rep(seq_len(ncol(t(Yall))), each = nrow(t(Yall))))
    #res = lapply(X = Yall.list, FUN = islet.est.win, datuse = input)
    nworkers=min(detectCores()-1,15)
    cl <- makeCluster(nworkers)
    clusterExport(cl,list('ss'))
#    clusterEvalQ(cl, {
#      require(Matrix)})
    mf = parLapply(cl, X=Yall.list, islet.est.win, datuse = input)

    test.res = matrix(NA, nrow = G, ncol = input$K)

    for(iTest in seq_len(input$K)){
      inputnew = changeinput(input, iTest)
      tmp1 = parLapply(cl, X=Yall.list, islet.lrt.win, datuse = inputnew, ktest = iTest)
      tmp2 = unlist(tmp1)
      tmp3 = unlist(lapply(mf, '[[' , 7))
      ###obtain the p-values from each cell type
      tmp4 = LRT(tmp3, tmp2, df = 1)
      test.res[,iTest] = tmp4
      cat("csDE testing finished on cell type ", iTest, "\n")
    }
    stopCluster(cl)
    colnames(test.res) = colnames(input$X[,seq_len(input$K)])
  }

  return(test.res)
}


