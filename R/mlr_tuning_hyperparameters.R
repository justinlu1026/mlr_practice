## Tuning hyperparameters ----

# In order to tune a machine learning algorithm, you have to specify
# 1. Search space
# 2. Optimization algorithm (a.k.a tuning method)
# 3. Evaluation method, i.e. a resampling strategy and a performance measure

# ex: create a search space for te C hyperparameter from 0.01 to 0.1
ps <- makeParamSet(
  makeNumericParam("C", lower = .01, upper = .1)
)

# ex: random search with 100 iterations
ctrl <- makeTuneControlRandom(maxit = 100L)

# ex: 3-fold CV using accuracy as performance measure
rdesc <- makeResampleDesc("CV", iters = 3L)
measure = acc

## Specifying the search space ----

# discrete parameter space

discrete_ps <- makeParamSet(
  makeDiscreteParam("C", values = c(0.5, 1.0, 1.5, 2.0)),
  makeDiscreteParam("sigma", values = c(0.5, 1.0, 1.5, 2.0))
)

print(discrete_ps)

# continuous parameter space

num_ps <- makeParamSet(
  makeNumericParam("C", lower = -10, upper = 10, trafo = function(x) 10^x),
  makeNumericParam("sigma", lower = -10, upper = 10, trafo = function(x) 10^x)
)


## Specifying the optimization algorithm ----

## Grid search - usually slow

# discrete case grid search
ctrl <- makeTuneControlGrid()

# continuous case grid search
# grid search by default will create a grid using
# 10 equally sized steps
# Number of steps can be changed with `resolution` argument
ctrl <- makeTuneControlGrid(resolution = 15L)

# Check [TuneControl](https://www.rdocumentation.org/packages/mlr/versions/2.10/topics/TuneControl)

## Random search

# discrete_ps
ctrl <- makeTuneControlRandom(maxit = 10L)

# num_ps: Increase amount of iterations to ensure space coverage
ctrl <- makeTuneControlRandom(maxit = 200L)

## Performing the tuning ----

# discrete_ps

discrete_ps = makeParamSet(
  makeDiscreteParam("C", values = c(0.5, 1.0, 1.5, 2.0)),
  makeDiscreteParam("sigma", values = c(0.5, 1.0, 1.5, 2.0))
)
ctrl = makeTuneControlGrid()
rdesc = makeResampleDesc("CV", iters = 3L)
res = tuneParams("classif.ksvm", task = iris.task, resampling = rdesc,
                 par.set = discrete_ps, control = ctrl)

res


## Accessing the tuning result

res$x
res$y

# Generate a Learner with optimal hyperparameter settings
lrn <- setHyperPars(makeLearner("classif.ksvm"), par.vals = res$x)

# Then you can proceed as usual
m <- train(lrn, iris.task)
predict(m, task = iris.task)


## Investigating hyperparameter tuning effects ----
## Inspect all points evaluated using generateHyperParsEffectData()

# parameter 
generateHyperParsEffectData(res)

generateHyperParsEffectData(res, trafo = TRUE)

rdesc2 = makeResampleDesc("Holdout", predict = "both")
res2 = tuneParams(
  "classif.ksvm", 
  task = iris.task, 
  resampling = rdesc2, 
  par.set = num_ps,
  control = ctrl, 
  measures = list(acc, setAggregation(acc, train.mean)), 
  show.info = FALSE
  )

generateHyperParsEffectData(res2)

# Visualize the points evaluated by using `plotHyperParsEffect`
res = tuneParams("classif.ksvm", task = iris.task, resampling = rdesc, par.set = num_ps,
                 control = ctrl, measures = list(acc, mmce), show.info = FALSE)
data = generateHyperParsEffectData(res)
plotHyperParsEffect(data, x = "iteration", y = "acc.test.mean",
                    plot.type = "line")

## Further comments ----

# Tuning works for all tasks like regression, survival analysis and so on
# Check on.learner.error in `configureMlr`
# To ensure unbaised performance estimation, using `nested resampling`,
# where we embed the whole model selection process into an outer resampling loop
