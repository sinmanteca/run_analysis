Getting & Cleaning Data Course Project
==========

The [*Human Activity Recognition Using Smartphones Data Set*](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones) is freely available from the Machine Learning Repository. For this project, the raw data were downloaded from a [mirror location](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip). The data provides measurements of human movement using the accelerometer and gyroscope from a smartphone. Volunteers between the ages of 19 and 64 years performed six activities (walking, walking upstairs, walking downstairs, sitting, standing, and lying) and data were sampled at 50Hz for each subject and by each activity. The subjects were   randomly divided to produce a training (70%) and test (30%) set.

### Goals

The run_analysis.R code was written to achieve the following data processing goals:

1. Merge the training and the test sets to create one data set.
2. Extract only the measurements on the mean and standard deviation for each measurement. 
3. Use descriptive activity names to name the activities in the data set.
4. Appropriately label the data set with descriptive variable names. 
5. Create a tidy data set with the average of each variable for each activity and each subject.

### How the code works

The code provides the tidyData(*download*, *fileUrl*) function which calls two other functions and outputs the tidyData.txt file. 

The *download* argument takes TRUE or FALSE and allows the user to specify whether the raw data should be downloaded. This is helpful if the user wishes to re-run the code but does not wish to download the file again. The default argument is FALSE; although, the function will attempt to download the file again if it does not exist in the expected location.

The *fileUrl* argument takes a URL to the file location. The default location is the URL provided in the course project outline. Therefore, the user only needs to enter a URL if a new download destination is required. The URL should be enclosed with double quotes.

To call the tidyData function with the default arguments, the user may enter *tidyData()* at the prompt.

This code executes the following steps:

1. Download the file if required by the user or if the file does not exist
2. Unzip the files to the *data* folder
3. Combine the "subject" and "activity" files with the "features" data to produce complete training and test data sets (column binding)
4. Merge the training and test data sets (row binding)
5. Modify the "features" labels to make them more human-readable and append them as column names to the merged data set
6. Replace activity IDs with activity descriptions in the data itself
7. Take a subset of features that provide only mean and standard deviation measurements
8. Calculate the average means and standard deviations by subject and activity
9. Convert the wide form tidy data set into a long form tidy data set
10. Write the final data output to *tidyData.txt* and save in the *output* folder


### Assumptions
A couple of assumptions have been made in interpreting the data processing requirements for the course project:

1. A long form tidy data set has been presented. According to the grading rubric, either a wide or long form of the data is acceptable.
2. Only features with both a mean and standard deviation have been subsetted from the larger data set. This is essentially features that included the string "mean()" and "std()" in the feature name. Features such as *angle(X,gravityMean)* or *fBodyAcc-meanFreq()-X* have been excluded.

### Output
The tidyData.txt file that was uploaded to Coursera can be viewed in R using the following code:

```
address <- "https://s3.amazonaws.com/coursera-uploads/user-69cc1e0edb271505d1a5634c/975118/asst-3/19523740915e11e5a4654306ac580867.txt"
address <- sub("^https", "http", address)
data <- read.table(url(address), header = TRUE) 
View(data)
```
Thanks to David Hood, Community TA, for [this suggestion](https://thoughtfulbloke.wordpress.com/2015/09/09/getting-and-cleaning-the-assignment/) 

### Development environment

The code was developed using R, 3.2.2 for Windows, RStudio, 0.99.484, running on Windows 10 64-bit. The code was run repeatedly to confirm the results.