## R by default does not make use of parallelization
## Integration `parallelMap` into `mlr` to activate parallel computing capabilities
## already supporte by `mlr`

## `parallelMap` works with all major parllelization backends:
## local multicore execution using `parallel`
## socket and MPI clusters using `snow`
## makeshift SSH-clusters using `BatchJobs`
## high performance computing clusters also use `BatchJobs`

# Starting parallelization in mode = socket with cpus =2
parallelStartSocket(2)

rdesc <- cv3 
r <- resample("classif.lda", iris.task, rdesc)

# Stopped parallelization. All cleaned up
parallelStop()


## Parallelization levels ----
## Offers fine grained control over the parallelization

# E.g. If you do not want to parallelize the `benchmark` function for very few iterations
# but want to parallelize th `resampling` of each learner instead
# You can specifically pass the `level` `"mlr.resample"` to the `parallelStart()` function 

# Current supported parallelization levels
parallelGetRegisteredLevels()

## Custom learners and parallelization ----

# If you have implemented a custom learner, locally, you need to export this to slave
# I.e. if you see error after calling, e.g. a parallelized version of `resample` like this:
# no applicable method for 'trainLearner' applied to an object of class <my_new_learner>
# Add the following line after calling `parallelStart()`:
parallelExport("trainLearner.<my_new_learner>", "predictLearner.<my_new_learner>")


