#Getting and Cleaning Data Course Project

#create list of filenames, from UCI HAR Dataset, including in subfolders
#full names false so that the whole path isn't shown
file_path <- "/Users/alexhumfrey/Documents/Data Science Coursera/Scripts/CleanDataWk4Assignment/
                  Cleaning-Data-Wk4-Assignment/UCI HAR Dataset/Data_to_Merge"
list_of_files <- list.files(path = file_path, recursive = TRUE, pattern = "\\.txt$", full.names = FALSE) 

#load data.table and dlpyr packages
library(data.table)
library(dplyr)

#Set Working Directory to read the data
#setwd("/Users/alexhumfrey/Documents/Data Science Coursera/Scripts/
      #CleanDataWk4Assignment/Cleaning-Data-Wk4-Assignment/UCI HAR Dataset/Data_to_Merge")

# Read the training and test set files and create a data frame for each (train_df & test_df)

#read in test files
#read in subject_id file, set variable name to "subject_id"
#read in test labels, set variable name to "activity"
#read in test set file
subject_test <- read.table("test/subject_test.txt", col.names = "subject_id") 
test_labels <- read.table("test/Y_test.txt", col.names = "activity") 
test_set <- read.table("test/X_test.txt") 

#read in training files
#read in subject id file, set variable name to "subject_id"
#read in train labels, set variable name to "activity"
#read in training set file
subject_train <- read.table("train/subject_train.txt", col.names = "subject_id") 
train_labels <- read.table("train/Y_train.txt", col.names = "activity")
train_set <- read.table("train/X_train.txt") 

#bind test data columns and train data columns
#then bind test_df and train_df rows to create one dataset
train_df <- cbind(subject_train, train_labels, train_set)
test_df <- cbind(subject_test, test_labels, test_set)
complete_df <- rbind(test_df,train_df)

#remove unnecessary dataframes from global environment
rm("subject_test", "subject_train", "test_labels", "train_labels", "test_set", "train_set", "train_df", "test_df")

#replace activity values with descriptive character strings
complete_df$activity <- factor(complete_df$activity, levels = c(1,2,3,4,5,6),
                               labels = c("walking","walking_upstairs", "walking_downstairs",
                                          "sitting", "standing", "laying"))

#read in "features.txt" to get the descriptive names for each variable
features <- read.table("/Users/alexhumfrey/Documents/Data Science Coursera/Scripts/CleanDataWk4Assignment/
                        Cleaning-Data-Wk4-Assignment/UCI HAR Dataset/Data_to_Merge/features.txt")

#rename columns in features dataset
features <- rename(features, variable_id = "V1", variable_name = "V2")


#find variables w/ "mean()" or "std()" in the variable name, FIXED = TRUE for exact match
#then bind features1 and features2 to create a dataset of all the mean() and std() calculations
features1 <-features[grep("mean()", features$variable_name, fixed = TRUE),]
features2 <-features[grep("std()", features$variable_name, fixed = TRUE),]
features3 <- rbind(features1,features2)

#create integer vector with the variables we want to select
index <- features3[,1]

#change column names of dataset, numbering sequentially from 1:561
colnames(complete_df) <- c("subject_id","activity", 1:561)

#subset  mean and std variables from dataset using the index vector containing
# the index of the variables we want to keep
select_variables <- complete_df[,c("subject_id", "activity", index )]

#rename variables with descriptive titles
var_names <- as.character(features3[,2])
colnames(select_variables) <- c("subject_id", "activity", var_names )

#select_variables is our first tidy dataset
#str(select_variables)

# group data by subject_id and activity
new_data <- group_by(select_variables, subject_id, activity)

# calculate average for each variable for each subject and each activity
group_averages <- summarise_at(new_data, .vars= vars("tBodyAcc-mean()-X":"fBodyBodyGyroJerkMag-std()"), mean)
#str(Group_Averages)

rm("features", "features1", "features2", "features3", "complete_df", "new_data")

