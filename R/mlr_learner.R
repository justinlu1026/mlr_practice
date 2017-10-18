## Construct a learner ----

# 1. set hyperparameters
# 2. Control the output for later prediction e.g. response or prob for classification
# 3. Set an ID to name to object

# Classification tree, set it up for predicting probability
classif.lrn <- makeLearner(
  "classif.randomForest",
  predict.type = "prob",
  fix.factors.prediction = TRUE)

# Regression gradient boosting machine, specify hyperarameters via a list
regr.lrn <- makeLearner("regr.gbm",
                        par.vals = list(n.trees = 500,
                                        interaction.depth = 3))

# Cox proportional hazards model with custom name
surv.lrn <- makeLearner("surv.coxph", id = "cph")

# K-means with 5 clusters
cluster.lrn <- makeLearner("cluster.kmeans", centers = 5)

# Multilabel Random Ferns classification algorithm
multilabel.lrn <- makeLearner("multilabel.rFerns")

# Hyperparameter values can be specified either via the ... argument
# or as a list via par.vals

# Fix the problem for factor features when fewer levels are present
# in the test data set than in the training data set: 
# fix.factors.prediction = TRUE

classif.lrn
surv.lrn

# currently no special learner class for cost-sensitive classification
# ordinary misclassification costs: Use standard classification method
# example-dependent costs: Multiple ways, check https://mlr-org.github.io/mlr-tutorial/devel/html/cost_sensitive_classif/index.html


## Accessing a learner ----

# Get the configured hyperparameter setting that deviates from the default
cluster.lrn$par.vals

# Get the set of hyperparameters
classif.lrn$par.set
# $par.set is an object of class [ParamSet](https://www.rdocumentation.org/packages/ParamHelpers/versions/1.10/topics/makeParamSet)

# Get the type of prediction
regr.lrn$predict.type

## Alternative ways to access current hyperparameter setting
#  Particular useful in case of wrapped Learners, 
#  A learner fused with a feature selection strategy,
#  both of which have hyperparameters
#  [wrapper](https://mlr-org.github.io/mlr-tutorial/devel/html/wrapper/index.html)

# getHyperPars(), getLearnerParVals()
# Access current hyperparameter setting of a Learner
getHyperPars(cluster.lrn)

# getParamSet()
# Get a description of all possible settings
getParamSet(classif.lrn)

# getParamSet(), getLearnerParamSet()
# Overview about the available hyperparameters and defaults of learning method
# without explicitly constructing it
getParamSet("classif.randomForest")

# Access a Learner's meta information

# Get object's id
getLearnerId(surv.lrn)

# Get the short name
getLearnerShortName(classif.lrn)

# Get the type of the learner
getLearnerType(multilabel.lrn)

# Get required(packages)
getLearnerPackages(cluster.lrn)


## Modifying a learner ----

# Change the ID
surv.lrn <- setLearnerId(surv.lrn, "CoxModel")
surv.lrn

# Change the prediction type, predict a factor with 
# class labels instead of probabilities
classif.lrn <- setPredictType(classif.lrn, "response")

# Chagne hyperparameter values
cluster.lrn <- setHyperPars(cluster.lrn, centers = 4)

# Go back to default hyperparameter values
regr.lrn <- removeHyperPars(regr.lrn, c("n.trees", "interaction.depth"))


## Listing learners ----

# List everything in mlr
lrns <- listLearners()
lrns %>% select(class, package) %>% View

# List classifiers that can output probabilities
lrns <- listLearners("classif", properties = "prob")
lrns %>% select(class, package) %>% View

# List classifiers that can be applied to iris (i.e. multiclass) and output probabilities
lrns <- listLearners(iris.task, properties = "prob")
lrns %>% select(class, package) %>% View

# You may also return learner objects
listLearners("cluster", create = TRUE) %>% head()
