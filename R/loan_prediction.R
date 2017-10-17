####################################################################################################
#### Hackaton: loan prediction 
#### demo of mlr to predictive loan

#### load libraries
library(tidyverse)
library(mlr)

#### load the data
train <- read_csv("data/loan prediction/train_u6lujuX_CVtuZ9i.csv", na = c("", " ", NA))
test <- read_csv("data/loan prediction/test_Y3wMUE5_7gLdaTN.csv", na = c("", " ", NA))

#### exploring data
summarizeColumns(train)
summarizeColumns(test)

## Findings:
## 1. 12 variables, Loan_Status is the dependent variable, rest are independent variables
## 2. Train data has 614 observatons, test data hs 367 observations
## 3. 6 variables has missing values: Gender, Dependents, Self_employed, LoanAmount, Loan_Amount_term, Credit_History
## 4. ApplicantIncome and CoapplicantIncome are highly skewed
## 5. LoanAmount, ApplicantIncome, CoaplicantIncome has outlier values
## 6. Credit_History should be converted to factor


## verify 4 and 5
ApplicantIncome_p <- ggplot(aes(x = ApplicantIncome), data = train)
CoapplicantIncome_p <- ggplot(aes(x = CoapplicantIncome), data = train)

## Verify skewness
ApplicantIncome_p + geom_histogram(bins = 300)
CoapplicantIncome_p + geom_histogram(bins = 300)

## Verify outlier


# ggplot(aes(y = ApplicantIncome), data = train) + geom_boxplot()


train$Credit_History <- as.factor(train$Credit_History)
test$Credit_History <- as.factor(test$Credit_History)

summary(train)
summary(test)

##
train
