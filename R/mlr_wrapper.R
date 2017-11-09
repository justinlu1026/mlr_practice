## Example ----

data(iris)
task <- makeClassifTask(data = iris, target = "Species", weights = as.integer(iris$Species))

## use `makeBaggingWrapper` to create the base learners and bagged learner

# choose equivalent of `ntree`: 100 base learner and `mtry`: proportion of randomly selected features

base.lrn <- makeLearner("classif.rpart")
wrapped.lrn <- makeBaggingWrapper(base.lrn, bw.iters = 100, bw.feats = 0.5)
print(wrapped.lrn)

benchmark(tasks = task, learners = list(base.lrn, wrapped.lrn))

## Tune hyperparameters of both decision trees and bagging wrapper

getParamSet(wrapped.lrn)

# Choose to tune the paramters `minsplit` and `bw.feats` for the `mmce` using a `random search` in a 3-fold CV

ctrl <- makeTuneControlRandom(maxit = 10)
rdesc <- makeResampleDesc("CV", iters = 3)
par.set <- makeParamSet(
  makeIntegerParam("minsplit", lower = 1, upper = 10),
  makeNumericParam("bw.feats", lower = .25, upper = 1)
)
tuned.lrn <- makeTuneWrapper(wrapped.lrn, rdesc, mmce, par.set, ctrl)
print(tuned.lrn)

## The train method of the newly constructed learner performs the following steps
# 1. The tuning wraper sets parameters for the underlying model in slot `$next.learner` and calls its train method
# 2. Next learner is the bagging wrapper. The passed down argument `bw.feats` is used in the bagging wraper training function,
# the argument `minsplit` gets passed down to $next.learner. The base wrapper function calls the base learner
# `bw.iters` times and stores the resulting models
# 3. The bagged models are evaluated using the mean `mmce` and new parameters are selected using the tuning method
# 4. Repeated until the tuner terminates.

lrn <- train(tuned.lrn, task = task)
