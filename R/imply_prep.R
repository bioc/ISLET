
implyDataPrep <- function(sim_se){
  message("Begin: working on data preparation as the input for imply.")
  if (!is(sim_se, "SummarizedExperiment"))
    stop("The input dataset must be a SummarizedExperiment object.")
  if (length(unique(colData(sim_se)$group)) != 2)
    stop("There must be two groups (case/ctrl) in the input SummarizedExperiment object.")
  if (unique(colData(sim_se)$group)[1] != "case" || unique(colData(sim_se)$group)[2] != "ctrl")
    stop("The names for the two groups in comparison should be labeled as
             `case` and `ctrl` in the input SummarizedExperiment object.")

  raw_count <- assays(sim_se)$counts
  #separate cases and controls
  idx <- which(colData(sim_se)$group == "case")
  case_dat_se <- SummarizedExperiment(assays=list(counts=raw_count[, idx]),
                                      colData=colData(sim_se)[idx, -1])
  ctrl_dat_se <- SummarizedExperiment(assays=list(counts=raw_count[, -idx]),
                                      colData=colData(sim_se)[-idx, -1])

  #K = number of cell types
  K <- ncol(colData(case_dat_se))-1
  #N1 = number of samples for group 1
  N1 <- ncol(assays(case_dat_se)$counts)
  #N1 = number of samples for group 2
  N2 <- ncol(assays(ctrl_dat_se)$counts)
  #NS = total number of Samples for group 1&2
  NS <- N1 + N2
  #NU = total number of Unique subjects for group 1&2
  caseUN <- length(unique(colData(case_dat_se)[, 1]))
  ctrlUN <- length(unique(colData(ctrl_dat_se)[, 1]))
  NU <- caseUN + ctrlUN
  #obtain the initial proporiton
  initial_prop <- as.matrix(colData(sim_se)[,3:(2+K)])
  #obtain a vector of unique subject IDs, for all, to use later
  sub_id <- c(colData(case_dat_se)[, 1], colData(ctrl_dat_se)[, 1])
  metadata <- data.frame(group = c(rep(1, N1), rep(0, N2)),
                        subject_ID = sub_id)

  dat123 <- implyS4(raw_count = raw_count, K = K, NS = NS,
                    case_num = caseUN, ctrl_num = ctrlUN, NU = NU,
                    ini.prop = initial_prop,
                    metadata = metadata)
  message("Complete: data preparation for imply.")
  return(dat123)
}

