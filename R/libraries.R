if(!require(easypackages)) install.packages("easypackages")
require(easypackages)

lib_list <-
  c(
    "tidyverse",
    "purrr",
    "stringr",
    "mlr"
  )

packages(lib_list, prompt = FALSE)
