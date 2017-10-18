
## Generate thee task
task <- makeClassifTask(
  data = iris,
  target = "Species"
)

## Generate the learner
lrn <- makeLearner("classif.lda")

## Train the learner
mod <- train(lrn, task)
mod

## Note:
## In the above example, creating the learner is not necessary
## unless you want to change any defaults
## Equivalent expressions:
mod <- train("classif.lda", task)

mod <- train("surv.coxph", lung.task)

## Accessing learner models ----

# Function train returns an object of class WrappedModel
# [WrappedModel](https://www.rdocumentation.org/packages/mlr/versions/2.10/topics/makeWrappedModel)

# Retrieve the fitted model in slot $learner.model of the WrappedModel
getLearnerModel(mod)

# Example of clustering
data(ruspini, package = "cluster")
plot(y ~ x, ruspini)

# Generate the task
ruspini.task <- makeClusterTask(data = ruspini)

# Generate the learner
lrn <- makeLearner("cluster.kmeans", centers = 4)

# Train the learner
mod <- train(lrn, ruspini.task)
mod

mod$learner
mod$features
mod$time

# Extract the fitted model
getLearnerModel(mod)


## Assigning weights in model training ----

# Get the number of observations
n <- getTaskSize(bh.task)

# Use 1/3 of the observations for training
train.set <- sample(n, size = n/3)

# Train the learner
mod <- train("regr.lm", bh.task, subset = train.set)
mod

# If the learner supports, you can specify observation /weight/
# Weights can be used in many regards, e.g.
# 1. Express the reliability of the training observations
# 2. Reduce the influence of outliers
# 3. Increase the influence of recent data
# 4. In supervised classification weights can be used to incorporate
# isclassification csts or account for class imbalance

# example - assign weight according to the inverse class frequencies

# Calculate the observation weights
target <- getTaskTargets(bc.task)
tab <- as.numeric(table(target))
w <- 1 / tab[target]

train("classif.rpart", task = bc.task, weights = w)

# General rule of assigining weight
# Specify weight in make*Task if the weights really "belong" to the task
# Otherwise, pass them to train
# Weights in train take precedence over the weights in Task