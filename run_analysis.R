## download files and read in data tables
readData <- function(download = FALSE, fileUrl = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"){

    library(data.table)
    
    ## check if data folder exists
    if(!file.exists("data")) {
        dir.create("data")
    }
    
    ## if user input download = TRUE, files are downloaded even if it already exists
    ## then check if zip file is already in folder and unzip. If the file does not exist
    ## the files will be downloaded even if the user input download = FALSE
    if(download == TRUE) {
        download.file(fileUrl, destfile="./data/wearableData.zip")
    }
    if(file.exists("./data/wearableData.zip")) {
        files <- unzip("./data/wearableData.zip", exdir="./data")
    } else {
        download.file(fileUrl, destfile="./data/wearableData.zip")
    }

    ## read files
    ## use data.table's fread for fast table reading
    labelsActivities <- fread("./data/UCI HAR Dataset/activity_labels.txt")
    labelsData <- fread("./data/UCI HAR Dataset/features.txt")
    testSubjects <- fread("./data/UCI HAR Dataset/test/subject_test.txt")
    testActivities <- fread("./data/UCI HAR Dataset/test/y_test.txt")
    testMeasures <- fread("./data/UCI Har Dataset/test/X_test.txt")
    trainSubjects <- fread("./data/UCI HAR Dataset/train/subject_train.txt")
    trainActivities <- fread("./data/UCI HAR Dataset/train/y_train.txt")
    trainMeasures <- fread("./data/UCI Har Dataset/train/X_train.txt")
    
    ## store data tables in list which can be passed to a new function
    phoneData <- list(labelsActivities=labelsActivities, labelsData=labelsData, 
                      testSubjects=testSubjects, testActivities=testActivities,
                      testMeasures=testMeasures, trainSubjects=trainSubjects, 
                      trainActivities=trainActivities, trainMeasures=trainMeasures)
    
    return(phoneData)
}


## read in list of data tables and join data into master dataset
joinData <- function(download = FALSE, fileUrl = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"){

    library(dplyr)
    library(stringr)
    
    ## read in list of data tables from readData function and extract data tables
    phoneData <- readData(download, fileUrl)
    
    labelsData <- phoneData[["labelsData"]]
    testSubjects <- phoneData[["testSubjects"]]
    testActivities <- phoneData[["testActivities"]]
    testMeasures <- phoneData[["testMeasures"]]
    trainSubjects <- phoneData[["trainSubjects"]]
    trainActivities <- phoneData[["trainActivities"]]
    trainMeasures <- phoneData[["trainMeasures"]]
  
    
    ## join subject and activity columns to test and training data
    ## since columns do not have distint names yet, use.names=FALSE argument to prevent 
    ## matching by column name and force matching by order that columns appear
    testData <- bind_cols(testSubjects, testActivities, testMeasures)
    trainData <- bind_cols(trainSubjects, trainActivities, trainMeasures)
    combineData <- rbindlist(list(testData, trainData), use.names=FALSE)
    
    
    ## prep the list of column names to remove duplicate names and make them more human-readable
    labelsData$V2 <- ifelse(duplicated(labelsData$V2), paste(labelsData$V2, labelsData$V1), labelsData$V2)
    labelsData$V2 <- gsub("Acc", "-accelerometer",labelsData$V2)
    labelsData$V2 <- gsub("Gyro", "-gyroscope",labelsData$V2)
    labelsData$V2 <- gsub("Jerk", "-jerk",labelsData$V2)
    labelsData$V2 <- gsub("Mag", "-magnitude ",labelsData$V2)
    labelsData$V2 <- gsub("-X", "-x-axis", labelsData$V2)
    labelsData$V2 <- gsub("-Y", "-y-axis", labelsData$V2)
    labelsData$V2 <- gsub("-Z", "-z-axis", labelsData$V2)
    labelsData$V2 <- gsub("meanF", "mf", labelsData$V2)
    labelsData$V2 <- gsub("-mean\\(\\)", "-mean", labelsData$V2)
    labelsData$V2 <- gsub("-std\\(\\)", "-sd", labelsData$V2)
    labelsData$V2 <- gsub("tB", "b", labelsData$V2)
    labelsData$V2 <- gsub("tG", "g", labelsData$V2)
    labelsData$V2 <- gsub("fBodyB", "frequency-b", labelsData$V2)
    labelsData$V2 <- gsub("fB", "frequency-b", labelsData$V2)
    labelsData$V2 <- tolower(str_trim(labelsData$V2))
    
    setnames(combineData, c("subject", "activity", labelsData$V2))
    return(combineData)

}

## make tidy data set and save output
tidyData <- function(download = FALSE, fileUrl = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"){
    
    library(tidyr)
    
    ## read in master dataset from joinData function as a data frame
    ## allows for a simpler join (compared to data.table) in next step without having to set new keys
    combineData <- tbl_df(joinData(download, fileUrl))
    
    ## read activity labels from file since we don't want to run phoneData all over again
    labelsActivities <- fread("./data/UCI HAR Dataset/activity_labels.txt")

    ## daisy chain commands to get to wide format tidy data set
    tidyData <- combineData %>%                               
        left_join(labelsActivities, by = c("activity" = "V1")) %>%          ## add activity names as new column (V2)
        select(subject, V2, matches("-mean|-sd", ignore.case = FALSE)) %>%  ## select only columns with MEAN or STD -- equivalent to mean() & std() from original set
                                                                            ## note, Activity column has been excluded in favour of V2
        rename(activity = V2) %>%                                           ## rename the V2 column as the new Activity column                                        
        group_by(subject, activity) %>%                                     ## set group_by for summarize_each in next step
        summarize_each(funs(mean)) %>%                                      ## takes the mean of all variables and groups by subject and activity
        gather(feature, value, 3:68)                                        ## convert wide form tidy data into long form tidy data
        
    ## check if data folder exists
    if(!file.exists("output")) {
        dir.create("output")
    }
    
    ## write to file
    write.table(tidyData, "./output/tidyData.txt", row.names = FALSE)

}