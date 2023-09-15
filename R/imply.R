imply <- function(dat123){
  ini.prop <- dat123@ini.prop
  metadata <- dat123@metadata
  count <- dat123@raw_count
  input <- data.frame(metadata,ini.prop,
                      Prop.gp = ini.prop*metadata$group)

  K <- ncol(ini.prop)
  N.total <- length(unique(metadata$subject_ID))

  # Prepare for lmer formula.
  formula_str <- lme_fml(ini.prop)
  # lmer personalized ref. recovery process
  Ref_pred <- bplapply(seq_len(nrow(count)), lmer_deconv,
                       count, input, N.total, K, formula_str)
  Ref_pred <- abind(Ref_pred, along=3)
  dimnames(Ref_pred) <- list(unique(metadata$subject_ID),
                             colnames(ini.prop), rownames(count))
  Ref_pred <- aperm(Ref_pred, c(3,2,1))
  message("Personalized Panel recovered by lmer.")

  # personalized deconvolution
  ss.ind <- cbind(metadata$subject_ID, seq_len(length(metadata$subject_ID)))
  unique.sub.id <- unique(metadata$subject_ID)
  re_est <- lapply(seq_len(N.total), function(i){
    sub.sample.set <- unique(metadata$subject_ID)[i]
    sub.samp <- ss.ind[ss.ind[,1]==sub.sample.set,2]
    est2_CT_prop <- t(apply(as.matrix(count[,sub.samp]), 2,
                            function(y) nnls(Ref_pred[,,i],y)$x))
    est2_CT_prop <- est2_CT_prop/rowSums(est2_CT_prop)
    return(as.data.frame(est2_CT_prop))
  })
  est_CT_prop2 <- map_df(re_est, rbind)
  colnames(est_CT_prop2) <- colnames(ini.prop)
  message("Personalized deconvolution done!")

  # Return results as a list
  imply_result <- list(p.ref = Ref_pred, imply.prop = est_CT_prop2)
  return(imply_result)
}

