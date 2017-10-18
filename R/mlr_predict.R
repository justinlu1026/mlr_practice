# Two ways to pass the data
# 1. Pass the Task via the `task` argument or
# 2. ass a `data.frame` via the `newdata` argument
# First method is preferable

# predict function has a subset argument
# thus you can set aside different portions of the data
# for training and prediction

## Sample code ----

# Example 1

n <- getTaskSize(bh.task)
train.set <- seq(1, n, by = 2)
test.set <- seq(2, n, by = 2)
lrn <- makeLearner("regr.gbm", n.trees = 100)
mod <- train(lrn, bh.task, subset = train.set)

task.pred <- predict(mod, task = bh.task, subset = test.set)
task.pred

# Example 2

n <- nrow(iris)
iris.train <- iris[seq(1, n, by = 2), -5]
iris.test <- iris[seq(2, n, by = 2), -5]
task <- makeClusterTask(data = iris.train)
mod <- train("cluster.kmeans", task)

newdata.pred <- predict(mod, newdata = iris.test)
newdata.pred


## Accessing the prediction ----

as_tibble(task.pred)
as_tibble(newdata.pred)

# Acess the true and redicted values of the target variables
getPredictionTruth(task.pred)
getPredictionResponse(task.pred)


## Regression: Extracting standard errors ----

# Find learners which provide standard errors for prediction
# By assigning `FALSE` to `check.packages` learners from packages
# which are not installed will be included
listLearners(
  "regr",
  check.packages = FALSE,
  properties = "se"
  ) %>% select(class, name) %>% View

# train a linear regression model on the Boston Housing dataset
lrn.lm <- makeLearner("regr.lm", predict.type = 'se')
mod.lm <- train(lrn.lm, bh.task, subset = train.set)
task.pred.lm <- predict(mod.lm, task = bh.task, subset = test.set)
task.pred.lm

getPredictionSE(task.pred.lm)


## Classification and clustering: Extracting probabilities ----

lrn <- makeLearner("cluster.cmeans", predict.type = "prob")
mod <- train(lrn, mtcars.task)
pred <- predict(mod, task = mtcars.task)
getPredictionProbabilities(pred) %>% head()



# Linear discriminant analysis on the iris data set

mod <- train("classif.lda", task = iris.task)
pred <- predict(mod, task = iris.task)
pred

lrn <- makeLearner("classif.rpart", predict.type = "prob")
mod <- train(lrn, iris.task)
pred <- predict(mod, newdata = iris)
head(as.data.frame(pred))


## Classification: Confusion matrix ----

calculateConfusionMatrix(pred)
conf.matrix <- calculateConfusionMatrix(pred, relative = TRUE)
conf.matrix
conf.matrix$relative.row

calculateConfusionMatrix(pred, relative = TRUE, sums = TRUE)


## Classification: Adjusting the decision threshold ----

# If we set the threshold for the positive class to .9
# It means the example s assigned to the positive class if
# its posterior probability exceeds .9

lrn <- makeLearner("classif.rpart", predict.type = "prob")
mod <- train(lrn, task = sonar.task)

# Lable of the positive class
getTaskDesc(sonar.task)$positive

# Default threshold
pred1 <- predict(mod, sonar.task)
pred1$threshold

# Set the threshold value for the positive class
pred2 <- setThreshold(pred1, .9)
pred2$threshold

calculateConfusionMatrix(pred1)
calculateConfusionMatrix(pred2)

# In the binary case getPredictionProbabilities()
# extracts the posterior probabilities of the positve class only
getPredictionProbabilities(pred1) %>% head
# But we can change that
getPredictionProbabilities(pred1, cl = c("M", "R")) %>% head


# It works similarly for multiclass classification

lrn = makeLearner("classif.rpart", predict.type = "prob")
mod = train(lrn, iris.task)
pred = predict(mod, newdata = iris)
pred$threshold

pred = setThreshold(pred, c(setosa = 0.01, versicolor = 50, virginica = 1))
pred$threshold
table(as.data.frame(pred)$response)               


## Visualizing the prediction ----

lrn = makeLearner("classif.rpart", id = "CART")
plotLearnerPrediction(lrn, task = iris.task)

lrn = makeLearner("cluster.kmeans")
plotLearnerPrediction(lrn, task = mtcars.task, features = c("disp", "drat"), cv = 0)

plotLearnerPrediction("regr.lm", features = "lstat", task = bh.task)
plotLearnerPrediction("regr.lm", features = c("lstat", "rm"), task = bh.task)
