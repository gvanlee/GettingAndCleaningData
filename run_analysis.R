# run_analysis.R
#
# Course assignment for Getting and Cleaning data, wk4
#

require(downloader)
require(dplyr)

localFile <- 'dataset.zip'
remoteFile <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'

# Cache remote file locally for speed

if (! file.exists(localFile)) {
  download(remoteFile,
           destfile = localFile)
}

# Make sure training data and test data are present and process
if (! file.exists('UCI HAR Dataset/train/X_train.txt') | ! file.exists('UCI HAR Dataset/test/X_test.txt')) {
  # Extract files from archive
  unzip(localFile)
}

# Load support tables
dataActlabels <- read.table("UCI HAR Dataset/activity_labels.txt", stringsAsFactors = FALSE)
dataFeatures <- read.table("UCI HAR Dataset/features.txt", stringsAsFactors = FALSE)

# Find colunns we need and clean out unnecessary chars
dataColumns <- grep("std|mean", dataFeatures$V2)

columnNames <- dataFeatures[dataColumns, 2]
columnNames <- gsub('-mean', 'Mean', columnNames, fixed = TRUE)
columnNames <- gsub('-std', 'Std', columnNames, fixed = TRUE)
columnNames <- gsub('()', '', columnNames, fixed = TRUE)

# Add subject and activity
columnNames <- c('Subject', 'Activity', columnNames)

# Read training data
dataTrainRaw <- read.table("UCI HAR Dataset/train/X_train.txt")
dataTrainAct <- read.table("UCI HAR Dataset/train/Y_train.txt")
dataTrainSub <- read.table("UCI HAR Dataset/train/subject_train.txt")
dataTrainRaw <- dataTrainRaw[, dataColumns]
dataTrain <- cbind(dataTrainSub, dataTrainAct, dataTrainRaw)

rm('dataTrainAct', 'dataTrainSub', 'dataTrainRaw')

# Read test data
dataTestRaw <- read.table("UCI HAR Dataset/test/X_test.txt")
dataTestAct <- read.table("UCI HAR Dataset/test/Y_test.txt")
dataTestSub <- read.table("UCI HAR Dataset/test/subject_test.txt")
dataTestRaw <- dataTestRaw[, dataColumns]
dataTest <- cbind(dataTestSub, dataTestAct, dataTestRaw)

rm('dataTestAct', 'dataTestSub', 'dataTestRaw')

# Combine datasets for training and test
dataFull <- rbind(dataTrain, dataTest)
colnames(dataFull) <- columnNames

# Fill activity and subject fields
dataFull$Activity = factor(dataFull$Activity, 
                           levels = dataActlabels$V1,
                           labels = dataActlabels$V2)

# Group all data by Activity and Subject and take mean of variables
dataFullGrp <- group_by(tbl_df(dataFull), Activity, Subject)
dataSummary <- summarise_all(dataFullGrp, mean)

# Write data to tidy.txt
write.table(dataSummary,
            file = 'tidy.txt',
            sep = ";",
            row.names = FALSE)

