###function to obtain sum of squares
ss<-function(x){
  a<-sum(x^2)
  return(a)
}

###function to obtain sum of squares
colss<-function(x){
    a<-colSums(x^2)
    return(a)
}

###function to make the design matrix [A] for random effect
#updated on 05/31/2022 to reflect the change in ID order
#user should sort their data by subject ID
#makea <- function(onectprop, ind_id = sub_id, datX = X, aNU = NU){
makea <- function(onectprop, ind_id, datX , aNU){
   lp <- split(onectprop, ind_id)
  a1 <- matrix(0, nrow=nrow(datX), ncol=aNU)
#  ct_sub=table(sub_id)[as.character(unique(sub_id))]
#  lp=lp[names(ct_sub)]
  chk <- unique(ind_id) #chk should have the length of NU
  lp<-lp[as.character(chk)]
  count <- rep(0, length(chk))
  for(i in seq_len(aNU)){
    tmp <- sum(ind_id == chk[i])
    count[i] <- tmp
  }

  for(i in seq_len(aNU)){
    s <- 1+sum(count[0:(i-1)])
    e <- sum(count[seq_len(i)])
    a1[s:e, i] <- lp[[i]]
  }
  return(a1)
}


LRT<-function(llk_f, llk_0, df){
    test.stat<-llk_f-llk_0
    p<-pchisq(as.numeric(test.stat), df, lower.tail=FALSE)
    return(p)
}


#clexp<-function(){
#    #clusterExport(cl, list('colss'))
#    clusterEvalQ(cl,  {
#        library(Matrix)})
#}



### imply add
# used for lme formulation set-up
lme_fml <- function(prop.i){
  cell_type_columns <- colnames(prop.i)
  prop_gp_columns <- paste0("Prop.gp.", cell_type_columns)
  formula_str <- "y ~ 0"
  for (i in seq_along(cell_type_columns)) {
    formula_str <- paste0(formula_str," + ", cell_type_columns[i], " + (0 + ",
                          cell_type_columns[i], " | subject_ID)")
  }
  formula_str <- paste0(formula_str, " + ",
                        paste(prop_gp_columns, collapse = " + "))
  return(formula_str)
}

lmer_deconv <- function(i,RNAseq_final_count,input,N.total,K,formula_str){
  y <- as.matrix(RNAseq_final_count)[i,] # fit for each gene independently
  input <- cbind(input, y)

  control <- lmerControl( check.conv.singular = "ignore")
  res <- lmer(formula = formula_str, data = input, control = control)
  re <- ranef(res)$subject_ID
  feout <- fixef(res)
  fe <- matrix(rep(feout,each=N.total),nrow=N.total)
  colnames(fe) <- names(feout)
  outcome_nodup <- unique(subset(input,select = c(2:1)))
  re <- re[match(outcome_nodup$subject_ID, rownames(re)),]
  #pull out main effect
  ref_pred_main <- fe[,seq_len(K)]+re
  #pull out interaction; some columns might drop out due to rank dificiency;
  #therefore need further manipulation
  ref_pred_intact <- fe[,-(seq_len(K))]*outcome_nodup$group
  intact.name <- strsplit(colnames(ref_pred_intact), "[.]")
  colnames(ref_pred_intact) <- vapply(intact.name, tail,
                                      FUN.VALUE = character(1), n = 1)

  #add up main and interaction coeeficients
  ref_pred <- ref_pred_main
  mcol <- match(colnames(ref_pred_intact),colnames(ref_pred_main))
  ref_pred[,mcol] <- ref_pred[,mcol]+ref_pred_intact

  ref_pred[ref_pred < 0] <- 0
  return(as.data.frame(ref_pred))
}
