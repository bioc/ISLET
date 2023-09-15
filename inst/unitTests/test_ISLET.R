##Unit Test using RUnit

#test dataPrep
test_dataPrep <- function() {
    data("GE600")
    s1 = dataPrep(dat_se=GE600_se)

    checkEquals(s1@type, "intercept")
    checkEquals(s1@K, 6)
    checkEquals(s1@case_num, 83)
    checkEquals(s1@ctrl_num, 89)
    checkEquals(s1@NS, 520)
    checkEquals(s1@NU, 172)

    checkTrue(length(unique(s1@SubjectID))==172)

 #   checkEqualsNumeric(divideBy(4, 1.2345), 3.24, tolerance=1.0e-4)
}


#test dataPrepSlope
test_dataPrepSlope <- function() {
    data("GE600age")
    s1 = dataPrepSlope(dat_se=GE600age_se)

    checkEquals(s1@type, "slope")
    checkEquals(s1@K, 6)
    checkEquals(s1@case_num, 83)
    checkEquals(s1@ctrl_num, 89)
    checkEquals(s1@NS, 520)
    checkEquals(s1@NU, 172)

    checkTrue(length(unique(s1@SubjectID))==172)

    #   checkEqualsNumeric(divideBy(4, 1.2345), 3.24, tolerance=1.0e-4)
}


################add test for ISLET testing
test_ISLETtest <- function() {
    data("GE600")
    study123input <- dataPrep(dat_se=GE600_se)

    #(2) [optional for csDE genes testing] Individual-specific and cell-type-specific deconvolution
    #result.solve <- isletSolve(input=study123input)

    #(3) Test for csDE genes
    r1 <- isletTest(input=study123input)

    checkEquals(nrow(r1), 10)
    checkEquals(ncol(r1), 6)
    checkEquals(sum(r1<=1), 10*6)
    checkEquals(sum(r1>=0), 10*6)

    checkTrue(r1[7, 6]<0.003)
  #  checkTrue(r1[9, 1]<0.015)
    checkTrue(r1[8, 2]<0.035)

  #  checkEqualsNumeric(r1[4, 6], 1, tolerance=1.0e-2)

    #   checkEqualsNumeric(divideBy(4, 1.2345), 3.24, tolerance=1.0e-4)
}


test_ISLETtestAge <- function() {
    data("GE600age")

    #(1) Data preparation
    study456input <- dataPrepSlope(dat_se=GE600age_se)

    #(2) Test for slope effect(i.e. age) difference in csDE testing
    r2 <- isletTest(input=study456input)

    checkEquals(nrow(r2), 10)
    checkEquals(ncol(r2), 6)
    checkEquals(sum(r2<=1), 10*6)
    checkEquals(sum(r2>=0), 10*6)

    checkEqualsNumeric(r2[1, 1], 1, tolerance=1.0e-2)
   # checkEqualsNumeric(r2[9, 1], 1, tolerance=1.0e-2)

    # checkTrue(r2[7, 1]<0.02)
    checkTrue(r2[7, 6]<0.007)
    checkTrue(r2[1, 5]<0.03)
}


test_ISLETsolve <- function() {
    data("GE600")
    study123input <- dataPrep(dat_se=GE600_se)

    #(2) [optional for csDE genes testing] Individual-specific and cell-type-specific deconvolution
    s1 <- isletSolve(input=study123input)

    checkEquals(length(s1@case.ind.ref), 6)
    checkTrue(s1@case.ind.ref$Bcells[5, 2]>30)
    checkTrue(s1@case.ind.ref$Tcells_CD8[8, 5]>60)
    checkTrue(s1@case.ind.ref$Tcells_CD8[10, 6]>9)

    checkTrue(s1@ctrl.ind.ref$NKcells[5, 1]>370)
}





