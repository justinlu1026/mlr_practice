## Task types ----

# RegrTask - regression
# ClassifTask - binary and multi-class classification (
#               including cost-sensitive classification)
# SurvTask - survival analysis
# ClusterTask - cluster analysis
# MultilabelTask - multilabel classification
# CostSensTask - general cost-sensitive classification (
#                with example-specific costs)

## Regression ----

data(BostonHousing, package = "mlbench")
regr.task <- makeRegrTask(
  id = "bh",
  data = BostonHousing,
  target = "medv"
)
regr.task

## Classification ----

data(BreastCancer, package = "mlbench")
df <- BreastCancer
df$Id <- NULL
classif.task <- makeClassifTask(
  id = "BreatCancer",
  data = df,
  target = "Class")
classif.task
# makeClassifTask by default selects the first factor level of the target variable as the positive class
classif.task <- makeClassifTask(
  id = "BreatCancer",
  data = df,
  target = "Class",
  positive = "malignant")

## Survival analysis ----

data(lung, package = "survival")
lung$status <- (lung$status == 2)
surv.task <- makeSurvTask(data = lung, target = c("time", "status"))
surv.task
# type of censoring can be specified via the argument censoring

## Multilabel classification ----
#  Each object can belong to more than one category

yeast <- getTaskData(yeast.task)

labels <- colnames(yeast)[1:14]
yeast.task <- makeMultilabelTask(id = "multi",
                                 data = yeast,
                                 target = labels)
yeast.task


## Cluster analysis ----
data(mtcars, package = "datasets")
cluster.task <- makeClusterTask(data = mtcars)
cluster.task


## Cost-sensitive classification ----

df <- iris
cost <- matrix(runif(150 * 3, 0, 2000), 150) *
  (1-diag(3))[df$Species, ]
df$Species <- NULL

costsens.task <- makeCostSensTask(
  data = df, 
  cost = cost
)
costsens.task

## Further setting ----

# blocking:
# some observations "belong together" and should not be
# separated when splitting the data into training and test sets for resampling


# weight:
# You only use this option if the weights belong to the task.
# mlr offers other ways to set observation or class weights for
# supervised classification if you plan to train algorithm with 
# different weight
# See function makeWeightedClassesWrapper

## Accessing a learning task ----

getTaskDesc(classif.task)

# or access frequently requried elemtns directly

getTaskId(classif.task)
getTaskType(classif.task)
getTaskTargetNames(classif.task)
getTaskSize(classif.task)
getTaskNFeats(classif.task)
getTaskClassLevels(classif.task)

# Functions to extract data from task
getTaskData(classif.task)
getTaskFeatureNames(cluster.task)
head(getTaskTargets(surv.task))

## Modifying a learning task ----

# Select observations and/or features
cluster.task <- subsetTask(cluster.task, subset = 4:17)

# Remove constant features
removeConstantFeatures(cluster.task)

# Remove selected features
dropFeatures(surv.task, c("meal.cal", "wt.loss"))

# Standardize numerical features
task <- normalizeFeatures(cluster.task, method = "range")
summary(getTaskData(task))

## Example tasks ----

# https://mlr-org.github.io/mlr-tutorial/devel/html/example_tasks/index.html

## Generate tasks from mlbench ----

# convertMLBenchObjToTask() 
