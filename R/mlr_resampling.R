## Defining the resampling strategy ----

# Supported resampling strategies are:
# Cross-validation ("CV")
# Leave-one-out cross-validation ("LOO")
# Repeated cross-validation ("RepCV")
# Out-of-bag bootstrap and other variants like b632 ("Bootstrap")
# Subsampling, also called Monte-Carlo cross-validation ("Subsample")
# Holdout (training/test) ("Holdout")

# 3-fold cross-validation
rdesc <- makeResampleDesc("CV", iter = 3)
rdesc

# Holdout estimation
rdesc <- makeResampleDesc("Holdout")
rdesc

# Pre-defined resampling descriptions for common strategies

# holdout
hout
#cross-validation with different numbers of folders
cv5
cv10

## Performing the resampling ----

# Example: bh.task

rdesc <- cv3
r <- resample("regr.lm", bh.task, rdesc)
r
# result `r` is an object of class `ResampleResult`
# it contains performance results for learner, runtime, predicted values and 
# optionally the models fitted in single resampling iterations
names(r)
r$aggr
r$measures.test

# Example: sonar.task

# Subsampling with 5 iterations and default split ratio 2/3
rdesc <- makeResampleDesc("Subsample", iters = 5)

# Subsampling with 5 iterations and 4/5 training data
rdesc <- makeResampleDesc("Subsample", iters = 5, split = 4/5)

# Classification tree with information splitting criterion
lrn <- makeLearner("classif.rpart", parms = list(split = "information"))

# Calculate the performance measures
r <- resample(lrn, sonar.task, rdesc, measures = list(mmce, fpr, fnr, timetrain))

# Add further measures afterwards using addRRMeasure

# Add balanced error rate (ber) and time used to predict
addRRMeasure(r, list(ber, timepredict))

# For convenience, we can specify the learner as a string and pass any learner
# parameters via the ... argument of `resample`
r <- resample("classif.rpart", 
              parms = list(split = "information"), 
              sonar.task, 
              rdesc,
              measures = list(mmce, fpr, fnr, timetrain),
              show.info = FALSE)
r


## Accessing resample results ----

## Predictions

## Learner models

## The extract option


## Stratification and blocking ----

## Stratification w.r.t target variable(s)

## Stratification w.r.t explanatory variables

## Blocking


## Resample descriptions and resample instances ----


## Aggregating performance values

## Example: One measure with different aggregations

## Example: Calculating the training error

## Example: Bootstrap


## Convenience functions ----