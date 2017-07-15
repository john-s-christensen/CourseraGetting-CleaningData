# | -------------------------------------------------------------------------- |
# | Getting & Cleaning Data - Prograamming Assignment - John Christensen
# | -------------------------------------------------------------------------- |


# | -------------------------------------------------------------------------- |
# | Instructions
# | -------------------------------------------------------------------------- |
# The purpose of this project is to demonstrate your ability to collect, work with, 
# and clean a data set.
# 
# Review criteria
### The submitted data set is tidy.
### The Github repo contains the required scripts.
### GitHub contains a code book that modifies and updates the available codebooks with 
### the data to indicate all the variables and summaries calculated, along with units, 
### and any other relevant information.
### The README that explains the analysis files is clear and understandable.
### The work submitted for this project is the work of the student who submitted it.
#
# Getting and Cleaning Data Course Projectless 
### The purpose of this project is to demonstrate your ability to collect, work with, 
### and clean a data set. The goal is to prepare tidy data that can be used for later analysis. 
### You will be graded by your peers on a series of yes/no questions related to the project. 
### You will be required to submit: 1) a tidy data set as described below, 2) a link 
### to a Github repository with your script for performing the analysis, and 3) a 
### code book that describes the variables, the data, and any transformations or 
### work that you performed to clean up the data called CodeBook.md. You should also 
### include a README.md in the repo with your scripts. This repo explains how all of 
### the scripts work and how they are connected.
# 
# One of the most exciting areas in all of data science right now is wearable 
# computing - see for example this article . Companies like Fitbit, Nike, and 
# Jawbone Up are racing to develop the most advanced algorithms to attract new users. 
# The data linked to from the course website represent data collected from the 
# accelerometers from the Samsung Galaxy S smartphone. A full description is 
# available at the site where the data was obtained:
#   
#   http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
# 
# Here are the data for the project:
#   
#   https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
# 
# You should create one R script called run_analysis.R that does the following.
#### Merges the training and the test sets to create one data set.
#### Extracts only the measurements on the mean and standard deviation for each measurement.
#### Uses descriptive activity names to name the activities in the data set
#### Appropriately labels the data set with descriptive variable names.
#### From the data set in step 4, creates a second, independent tidy data set with 
#### the average of each variable for each activity and each subject.
# Good luck!


# | -------------------------------------------------------------------------- |
# | Prep
# | -------------------------------------------------------------------------- |
getwd()
setwd("C:/Users/john.christensen/Box Sync/John Christensen/Data Science/Coursera Data Science Specialization/3) Getting & Cleaning Data/ProgrammingAssignment")

install.packages("dplyr")
library(dplyr)
install.packages("readr")
library(readr)


# | -------------------------------------------------------------------------- |
# | Preparing training data
# | -------------------------------------------------------------------------- |
# loading training data:
trainData <- read_table2(file = "./UCI HAR Dataset/train/X_train.txt", col_names = FALSE)
# loading activityID's:
trainActivityID <- read_fwf("./UCI HAR Dataset/train/y_train.txt", col_positions = fwf_widths(widths = 1, col_names = "activityID"))
#loading subjectID's:
trainSubjectID <- read_table2(file = "./UCI HAR Dataset/train/subject_train.txt", col_names = "subjectID")

# loading activity labels: 
refActivityLabels <- read_fwf("./UCI HAR Dataset/activity_labels.txt"
  , col_positions = fwf_positions(start = c(1,3), end = c(1,NA), col_names = c("activityID", "activityDSC")))
# loading feature labels: 
refFeatureLabels <- read_table2(file = "./UCI HAR Dataset/features.txt", col_names = c("featureID", "featureDSC"))
# making feature labels valid variable names (no "(", ")", or "-" allowed in variable names)
refFeatureLabels$featureDSC <- make.names(names = refFeatureLabels$featureDSC)
# Add feature labels to trainingData:
names(trainData) <- refFeatureLabels$featureDSC

# Join activity labels to activity data: 
trainActivities <- inner_join(x = trainActivityID, y = refActivityLabels, by = c("activityID" = "activityID"))

# Bind activities & subjectID's to trainData; keep only mean or std columns:
trainData <- trainSubjectID %>% 
  bind_cols(trainActivities, trainData) %>%
  select(subjectID:activityDSC, contains("mean"), contains("std"))

# Just to clean up unneeded data objects:
rm(list = c("trainActivities", "trainActivityID", "trainSubjectID"))


# | -------------------------------------------------------------------------- |
# | Preparing test data using same steps as above
# | -------------------------------------------------------------------------- |
testData <- read_table2(file = "./UCI HAR Dataset/test/X_test.txt", col_names = FALSE)
testActivityID <- read_fwf("./UCI HAR Dataset/test/y_test.txt", col_positions = fwf_widths(widths = 1, col_names = "activityID"))
testSubjectID <- read_table2(file = "./UCI HAR Dataset/test/subject_test.txt", col_names = "subjectID")
testActivities <- inner_join(x = testActivityID, y = refActivityLabels, by = c("activityID" = "activityID"))
names(testData) <- refFeatureLabels$featureDSC
testData <- testSubjectID %>% 
  bind_cols(testActivities, testData) %>% 
  select(subjectID, activityID, activityDSC, contains("mean"), contains("std"))
rm(list = c("testActivities", "testActivityID", "testSubjectID", "refActivityLabels", "refFeatureLabels"))


# | -------------------------------------------------------------------------- |
# | Combine train and test to make full dataset - "movementData"
# | -------------------------------------------------------------------------- |
movementData <- trainData %>% 
  union_all(testData) %>% 
  arrange(subjectID, activityID)


# | -------------------------------------------------------------------------- |
# | 2nd tidy dataset - means grouped by subject & activity
# | -------------------------------------------------------------------------- |
# From the data set in step 4, creates a second, independent tidy data set with 
# the average of each variable for each activity and each subject.

# Wow! This did it! Dplyr is awesome!
meanBySubjectActivity <- movementData %>% 
  select(-activityID) %>% 
  group_by(subjectID, activityDSC) %>% 
  summarize_all(.funs = mean) %>% 
  arrange(subjectID, activityDSC)


# | -------------------------------------------------------------------------- |
# | 2nd tidy dataset - exported to CSV
# | -------------------------------------------------------------------------- |
write_csv(x = meanBySubjectActivity, path = "./MovementVarMeansBySubject&Activity")

