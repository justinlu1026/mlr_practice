## Available performance measures ----

# [performance measures](https://mlr-org.github.io/mlr-tutorial/devel/html/measures/index.html)

# Performance measures for classification with multiple classes
listMeasures("classif", properties = "classif.multi")

# Performance measure suitable for the iris classificationo task
listMeasures(iris.task)

# Get default measure for iris.task
getDefaultMeasure(iris.task)

# Get the default measure for linear regression
getDefaultMeasure(makeLearner("regr.lm"))


## Calculate performance measures ----

n <- getTaskSize(bh.task)
lrn <- makeLearner("regr.gbm", n.trees = 1000)
mod <- train(lrn, task = bh.task, subset = seq(1, n, 2))
pred <- predict(mod, task = bh.task, subset = seq(2, n, 2))

performance(pred)

performance(pred, measure = medse)

performance(pred, measures = list(mse, medse, mae))

## Requirements of performance measures ----

performance(pred, measures = timetrain, model = mod)

lrn <- makeLearner("cluster.kmeans", centers = 3)
mod <- train(lrn, mtcars.task)
pred <- predict(mod, measures = dunn, task = mtcars.task)

# Some measures require a certain type of prediction
# For example in binary classification, auc can only be
# calculated after posterior probablities are predicted
lrn = makeLearner("classif.rpart", predict.type = "prob")
mod = train(lrn, task = sonar.task)
pred = predict(mod, task = sonar.task)

performance(pred, measures = auc)

## Access a performance measure ----
str(mmce)


## Binary classification ----

## Plot performance versus threshold

lrn <- makeLearner("classif.lda", predict.type = "prob")
n <- getTaskSize(sonar.task)
mod <- train(lrn, task = snar.task, subset = seq(1, n, by = 2))
pred <- predict(mod, task = sonar.task, subset = seq(2, n, by = 2))

## Performance for the default threshold 0.5
performance(pred, measures = list(fpr, fnr, mmce))
d = generateThreshVsPerfData(pred, measures = list(fpr, fnr, mmce))
plotThreshVsPerf(d)
plotThreshVsPerfGGVIS(d)

## ROC measure ----

# Details of [ROC](https://en.wikipedia.org/wiki/Receiver_operating_characteristic)
r <- calculateROCMeasures(pred)
r
