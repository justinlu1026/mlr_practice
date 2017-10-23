## Some examples ----

lrn <- makeLearner("classif.lda", predict.type = "prob")
n <- getTaskSize(sonar.task)
mod <- train(lrn, task = sonar.task, subset = seq(1, n, by = 2))
pred <- predict(mod, task = sonar.task, subset = seq(2, n, by = 2))
d <- generateThreshVsPerfData(pred, measures = list(fpr, fnr, mmce))

class(d)
head(d$data)
plotThreshVsPerf(d)

# Note that by default the Measure `name` are used to annotate the panels
fpr$name
fpr$id


## Customizing plots ----

## Example 1

plt <- plotThreshVsPerf(d, pretty.names = FALSE)

# Reshaped version of the underlying data d
head(plt$data)
levels(plt$data$measure)

# Rename and reorder factor levels
plt$data$measure = factor(plt$data$measure, levels = c("mmce", "fpr", "fnr"),
                          labels = c("Error rate", "False positive rate", "False negative rate"))
plt = plt + xlab("Cutoff") + ylab("Performance")
plt

# Rename using `labeller()` function in `facet_wrap`(or `facet_grid`)
plt <- plotThreshVsPerf(d, pretty.names = FALSE)

measure_names <- c(
  fpr = "False positive rate",
  fnr = "False negative rate",
  mmce = "Error rate"
)

plt <- plt + facet_wrap(~ measure, 
                         labeller = labeller(measure = measure_names), ncol = 2)
plt <- plt + xlab("Decision threshold") + ylab("Performance")
plt

ggplot(d$data, aes(threshold, fpr)) + geom_line()


## Example 2 

sonar <- getTaskData(sonar.task)
pd <- generatePartialDependenceData(mod, sonar, "V11")
plt <- plotPartialDependence(pd)
plt
plot(Probability ~ Value, data = plt$data, type = "b", xlab = plt$data$Feature[1])


## Available generation and plotting functions
## See the table at the [bottom of the page](https://mlr-org.github.io/mlr-tutorial/devel/html/visualization/index.html)