inputSet <- setClass("inputSet", slots=c(exp_case="data.frame",
                                         exp_ctrl="data.frame",
                                         X="Matrix",
                                         A="Matrix",
                                         K="numeric",
                                         NS="integer",
                                         NU="numeric",
                                         case_num="numeric",
                                         ctrl_num="numeric",
                                         CT="character",
                                         SubjectID="numeric",
                                         type="character"
                                         )
                     )




outputSol <- setClass("outputSol", slots=c(case.ind.ref="list",
                                           ctrl.ind.ref="list",
                                           mLLK="numeric"
                                           )
                      )
### imply add
implyS4 <- setClass("implyS4",slots = c(raw_count = "data.frame",
                                        K="numeric",
                                        NS="integer",
                                        case_num="numeric",
                                        ctrl_num="numeric",
                                        NU="numeric",
                                        ini.prop = "matrix",
                                        metadata = 'data.frame'))
