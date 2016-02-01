if(!file.exists(".data")){dir.create((".data")}
fileUrl<- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip?accessType=DPWNLOAD"


training <- read.csv("./data/UCI HAR Dataset/train/X_train.txt", sep="", header=FALSE)
training[,562]<- read.csv("./data/UCI HAR Dataset/train/Y_train.txt", sep="", header=FALSE)
training[,563] <- read.csv("./data/UCI HAR Dataset/train/subject_train.txt", sep="", header=FALSE)

testing <- read.csv("./data/UCI HAR Dataset/test/X_test.txt", sep="", header=FALSE)
testing[,562] <- read.csv("./data/UCI HAR Dataset/test/Y_test.txt", sep="", header=FALSE)
testing[,563]<- read.csv("./data/UCI HAR Dataset/test/subject_test.txt", sep="", header=FALSE)

activityLabels <- read.csv("./data/UCI HAR Dataset/activity_labels.txt", sep="", header=FALSE)

# Read features and make the feature names better suited for R with some substitutions
features <- read.csv("./data/UCI HAR Dataset/features.txt", sep="", header=FALSE)
features[,2] <- gsub('-mean', 'Mean', features[,2])
features[,2]<- gsub('-std', 'Std', features[,2])
features[,2] <- gsub('[-()]', '', features[,2])

# Merge training and test sets together
mergedData <- rbind(training, testing)

# Get only the data on mean and standard deviation
fileteredcols <- grep(".*Mean.*|.*Std.*", features[,2])
# First reduce the features table to the columns needed
features <- features[fileteredcols,]
# Now add the last two columns (subject and activity)
fileteredcols <- c(fileteredcols, 562, 563)
# And remove the unwanted columns from mergedData
mergedData<- mergedData[,fileteredcols]
# Add the column names (features) to mergedData
colnames(mergedData) <- c(features$V2, "Activity", "Subject")
colnames(mergedData) <- tolower(colnames(mergedData))

currentActivity = 1
for (currentActivityLabel in activityLabels$V2) {
  mergedData$activity <- gsub(currentActivity, currentActivityLabel, mergedData$activity)
  currentActivity <- currentActivity + 1
}

mergedData$activity <- as.factor(mergedData$activity)
mergedData$subject <- as.factor(mergedData$subject)

tidy = aggregate(mergedData, by=list(activity = mergedData$activity, subject=mergedData$subject), mean)
# Remove the subject and activity column, since a mean of those has no use
tidy[,90] = NULL
tidy[,89] = NULL
write.table(tidy, "tidy.txt", sep="\t")
