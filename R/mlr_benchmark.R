## Benchmark experiments 
## Different learning methods are applied to one or several data sets
## with the aim to compare and rank the algorithms

## A benchmark experiment can be conducted by calling function
## `benchmark` on a list of `learners` and a list of `tasks`
## by executing `resample` for each combination of `learner` and `task`

## Benchmark experiments ----

# Example: Two learners to be compared
lrns <- list(
  makeLearner("classif.lda"),
  makeLearner("classif.rpart")
)


# Choose the resampling strategy
rdesc <- makeResampleDesc("Holdout")

# Conduct the benchmark experiment
bmr <- benchmark(lrns, 
                 sonar.task,
                 rdesc)
bmr
class(bmr)
attributes(bmr)

## Making experiments reproducible

# `mlr` obeys the `set.seed` function, and it should be set at the beginning
# Note you may need to adjust how you cll `set.seed` depending on usecase

## Access benchmark results ----

## Learner performances

getBMRPerformances(bmr)
getBMRAggrPerformances(bmr)

getBMRPerformances(bmr, drop = TRUE)
getBMRAggrPerformances(bmr, as.df = TRUE)

## Predictions
## You may set `keep.pred = FALSE` when calling `benchmark`
## to drop learner predictions

getBMRPredictions(bmr)
head(getBMRPredictions(bmr, as.df = TRUE))

## IDs
getBMRTaskIds(bmr)
getBMRLearnerIds(bmr)
getBMRMeasureIds(bmr)

## Fitted models
#  Set `models = FALSE` if you do not want to keep fitted models
#  when calling benchmark

getBMRModels(bmr)
getBMRModels(bmr, drop = TRUE)
getBMRModels(bmr, learner.ids = "classif.lda")

## Learners and measures

getBMRLearners(bmr)
getBMRMeasures(bmr)


## Merging benchmark results

# Example
# In the benchmark experiment above we applied `lda` and `rpart`
# to the `sonar.task`. We now perofrm a second experiment using a
# `random forest` and `quadratic discriment analysis (qda)` and 
# merge the results

# First benchmark result
bmr

# Benchmark experiemtn for the additional learners
lrns2 = list(
  makeLearner("classif.randomForest"),
  makeLearner("classif.qda")
)
bmr2 <- benchmark(lrns2, 
                  sonar.task,
                  rdesc, 
                  show.info = FALSE)
bmr2

# Merge the results
mergeBenchmarkResults(list(bmr, bmr2))

# Differing training/test set pairs across learners makes it
# hard to detect actual performance differences between learners
# Therefore,
#
# Solution 1: work with `ResampleInstance`s
# from the start
# Solution 2: Extract the `ResampleInstances` and pass these to
# further `benchmark` calls
rin <- getBMRPredictions(bmr)[[1]][[1]]$instance
rin

# Benchmark experiment for the additional random forest
bmr3 <- benchmark(lrns2, sonar.task, rin, show.info = FALSE)

# merge the results
mergeBenchmarkResults(list(bmr, bmr3))

## Behcnmark analysis and visualization ----

## Example: Comparing lda, rpart and random forest

# Create a list of learners
lrns <- list(
  makeLearner("classif.lda", id = "lda"),
  makeLearner("classif.rpart", id = "rpart"),
  makeLearner("classif.randomForest", id = "randomForest")
)

# Get additional Tasks from package mlbench
ring.task <- convertMLBenchObjToTask("mlbench.ringnorm", n = 600)
wave.task <- convertMLBenchObjToTask("mlbench.waveform", n = 600)

tasks = list(iris.task, sonar.task, pid.task, ring.task, wave.task)
rdesc = makeResampleDesc("CV", iters = 10)
meas = list(mmce, ber, timetrain)
bmr = benchmark(lrns, tasks, rdesc, meas, show.info = FALSE)
bmr

perf = getBMRPerformances(bmr, as.df = TRUE)
head(perf)

## Integrated plots ----

## Visualizing performances
plotBMRBoxplots(bmr, measure = mmce)

plotBMRBoxplots(bmr, measure = ber, style = "violin", pretty.names = FALSE) +
  aes(color = learner.id) +
  theme(strip.text.x = element_text(size = 8))

mmce$name
mmce$id
getBMRLearnerIds(bmr)
getBMRLearnerShortNames(bmr)

plt = plotBMRBoxplots(bmr, measure = mmce)
head(plt$data)

levels(plt$data$task.id) = c("Iris", "Ringnorm", "Waveform", "Diabetes", "Sonar")
levels(plt$data$learner.id) = c("LDA", "CART", "RF")

plt + ylab("Error rate")

## Visualizing aggregated performances
plotBMRSummary(bmr)

## Calculating and visualizing ranks
m <- convertBMRToRankMatrix(bmr, mmce)
m
plotBMRRanksAsBarChart(bmr, pos = "tile")

# or
plotBMRSummary(bmr, trafo = "rank", jitter = 0)

# Draw stacked bar charts (the default) or bar charts with juxtaosed bars (pos = "dodge")

plotBMRRanksAsBarChart(bmr)
plotBMRRanksAsBarChart(bmr, pos = "dodge")


## Comparing learners using hypothesis tests ----

## Non-parametric tests are better suited for hypothesis testing based benchmarks

# Non pareametric tests often do have less power than thair parametric counterparts but 
# less assumptions about underlying distributions have to be made
# This often means many *data sets* are needed to show significant differences at reasonable
# significance level

# Non-parametric tests used in `mlr` are *Overall Friedman test* and *Friedman-Nemenyi post hoc test*
# While the *ad hoc Friedman test* based on friedman.test from the stats package is testing the 
# hypothesis whether there is a significant difference between the employed learners, 
# the *post hoc Friedman-Nemenyi test* tests for significant differences between all pairs of learner


friedmanTestBMR(bmr)

friedmanPostHocTestBMR(bmr, p.value = 0.1)

## Critical differences diagram ----

# In order to visualize differently performing learners, 
# a critical differences diagram can be plotted, 
# using either the Nemenyi test (test = "nemenyi") or the Bonferroni-Dunn test (test = "bd").

# The mean rank of learners is displayed on the x-axis.

# Choosing test = "nemenyi" compares all pairs of Learners to each other, 
# thus the output are groups of not significantly different learners. 
# The diagram connects all groups of learners where the mean ranks do not differ by more than the critical differences. 
# Learners that are not connected by a bar are significantly different, 
# and the learner(s) with the lower mean rank can be considered "better" at the chosen significance level.

# Choosing test = "bd" performs a pairwise comparison with a baseline. 
# An interval which extends by the given critical difference in both directions is drawn around the Learner chosen as baseline, 
# though only comparisons with the baseline are possible. All learners within the interval are not significantly different, 
# while the baseline can be considered better or worse than a given learner which is outside of the interval.

# CD = q_a * sqrt(k(k + 1) / 6N)
# N := number of tasks
# k := number of learners
# q_a comes from the studentized range statistic divided by sqrt(2)

# Nemenyi test
g = generateCritDifferencesData(bmr, p.value = 0.1, test = "nemenyi")
plotCritDifferences(g) + coord_cartesian(xlim = c(-1,5), ylim = c(0,2))

# Bonferroni-Dunn test
g = generateCritDifferencesData(bmr, p.value = 0.1, test = "bd", baseline = "randomForest")
plotCritDifferences(g) + coord_cartesian(xlim = c(-1,5), ylim = c(0,2))

## Customer plots ----

perf = getBMRPerformances(bmr, as.df = TRUE)

## Density plots for two tasks
qplot(mmce, colour = learner.id, facets = . ~ task.id,
      data = perf[perf$task.id %in% c("iris-example", "Sonar-example"),], geom = "density") +
  theme(strip.text.x = element_text(size = 8))

## Compare mmce and timetrain
df = reshape2::melt(perf, id.vars = c("task.id", "learner.id", "iter"))
df = df[df$variable != "ber",]
head(df)

qplot(variable, value, data = df, colour = learner.id, geom = "boxplot",
      xlab = "measure", ylab = "performance") +
  facet_wrap(~ task.id, nrow = 2)

#  Assess if learner performances in single resampling iterations 

perf = getBMRPerformances(bmr, task.id = "Sonar-example", as.df = TRUE)
df = reshape2::melt(perf, id.vars = c("task.id", "learner.id", "iter"))
df = df[df$variable == "mmce",]
df = reshape2::dcast(df, task.id + iter ~ variable + learner.id)
head(df)
GGally::ggpairs(df, 3:5)

## Further comments ---- 

# Note that for supervised classification mlr offers some more plots that operate on BenchmarkResult objects and 
# allow you to compare the performance of learning algorithms. See for example the tutorial page on *ROC curves* and 
# functions *generateThreshVsPerfData*, *plotROCCurves*, and *plotViperCharts* as well as the page about classifier 
# calibration and function *generateCalibrationData*

# In the examples shown in this section we applied "raw" learning algorithms, but often things are more complicated. 
# At the very least, many learners have hyperparameters that need to be tuned to get sensible results. Reliable performance 
# estimates can be obtained by nested resampling, i.e., by doing the tuning in an inner resampling loop while estimating 
# the performance in an outer loop. Moreover, you might want to combine learners with pre-processing steps like 
# imputation, scaling, outlier removal, dimensionality reduction or feature selection and so on. 
# All this can be easily done using mlr's wrapper functionality. The general principle is explained in the section about 
# wrapped learners in the Advanced part of this tutorial. There are also several sections devoted to common pre-processing steps.
# Benchmark experiments can very quickly become computationally demanding. mlr offers some possibilities for parallelization.