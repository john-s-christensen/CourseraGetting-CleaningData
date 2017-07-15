Getting & Cleaning Data - Programming Assignment CodeBook
================
John Christensen
July 15, 2017

Instructions
------------

> You will be required to submit: 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md.

The Data
--------

The data in the dataset 'MovementVarMeansBySubject&Activity' contains 88 variables and 180 obserations. The "grain" of the observations, the rows, are each activity (i.e. sitting, standing, walking, etc.) per subject who participated in the study. The 88 variables are a calculation of a summary mean for a particular subject doing a particular activity. The underlying variables themselves, from which the means were calculated, are described in the section below.

The Variables
-------------

Of the 561 features that were originally collected or derived in the raw dataset, I only kept 86 that dealt with a mean or standard deviation. This quote from the 'features\_info.txt' file explains how the raw variables I used were processed/created. Below in the 'Transformations' section I describe the few transformations I made to the variables to produce the dataset 'MovementVarMeansBySubject&Activity'.

> The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a corner frequency of 0.3 Hz.

> Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag).

> Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals).

> These signals were used to estimate variables of the feature vector for each pattern:
> '-XYZ' is used to denote 3-axial signals in the X, Y and Z directions.

Transformations/Work to Clean Up Data
-------------------------------------

All of the code used to make transformations/cleanings is located in the file, 'run\_analysis.R'. The 10 steps I took to create the 'MovementVarMeansBySubject&Activity' dataset are as follows:

1.  I installed & loaded the packages "dplyr" & "readr"

        install.packages("dplyr")
        library(dplyr)
        install.packages("readr")
        library(readr)

2.  I imported the train text files, as well as the reference files into R.
    -   trainData &lt;- X\_train.txt
    -   trainActivityID &lt;- Y\_train.txt
    -   trainSubjectID &lt;- subject\_train.txt
    -   refActivityLabels &lt;- activity\_labels.txt
    -   refFeatureLabels &lt;- features.txt

3.  I made the feature names valid R variable names using the make.names() function.

        refFeatureLabels$featureDSC <- make.names(names = refFeatureLabels$featureDSC)

4.  I made the valid 561 descriptive feature labels the variable names of the training data.

        names(trainData) <- refFeatureLabels$featureDSC

5.  I joined the 6 descriptive activity labels to the activity data.

        trainActivities <- inner_join(x = trainActivityID, y = refActivityLabels, by = c("activityID" = "activityID"))

6.  I bound activities & subjectID's to trainData, keeping only mean or standard deviation columns

        trainData <- trainSubjectID %>% 
          bind_cols(trainActivities, trainData) %>%
          select(subjectID:activityDSC, contains("mean"), contains("std"))

7.  I repeated steps 2-6 above (with the exception of re-importing the reference files) to recreate the test dataset.
    -   testData &lt;- X\_test.txt
    -   testActivityID &lt;- Y\_test.txt
    -   testSubjectID &lt;- subject\_test.txt

8.  I combined the training and test sets to make full dataset - 'movementData'

        movementData <- trainData %>% 
          union_all(testData) %>% 
          arrange(subjectID, activityID)

9.  I created a second tidy dataset - means grouped by subject & activity - called 'meanBySubjectActivity'

        meanBySubjectActivity <- movementData %>% 
          select(-activityID) %>% 
          group_by(subjectID, activityDSC) %>% 
          summarize_all(.funs = mean) %>% 
          arrange(subjectID, activityDSC)

10. I exported/wrote this dataset as a .csv file.

        write_csv(x = meanBySubjectActivity, path = "./MovementVarMeansBySubject&Activity")
