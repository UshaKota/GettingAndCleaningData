GettingAndCleaningData/csoursera course/project
Coursera Getting And Cleaning Data Course Projects
run_anlysis.R script is developed as an assignment for Getting and Cleaning Data Course Project in Coursera
The script is expected to perform the foll. steps from the given data set :for data set refer to Coursera
course project requirements
1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

The run_analyis.R uses 2 utility functions for cleaning up the feature lables ref::4 above :
1. replace_all () -- that finds a specific occurrence of a string and replaces all such occurences with the replacement string
2. features_to_table() a function that leverages on "white spaces" to split the features' names into columns'
The script assumes that all the data files are in the current working directory

The R script follows the order mentioned in the course project requirements
Separate dataasets are created from .txt files for the set of subjects (persons who took the activities to be measured by accelerometer on the
phone) who are identified to be contributing to "training" set and "testing set"
Both these datasets are merged using rbind() call to form a huge data set of 531 unnamed features(measurements): some of them 
could have been autocomputed from the  3-axial measurements of accelerometer and gyroscope for the 
subject
Activity labels are attached to each subject using a data.frame[], creating a mapping of activity code to activity labels as specified
in the activity_labels.txt

The features.txt contained names for each of the 531 measurements : some of them are not well formed :
The variable names contained patterns such as :
1. "()" -- which could be misleading to function names
2. "-"
3."num,char : 34,X -- which made the feature names not very meaningful

The utility functions are used "rename" the features to "somewhat meaningful" names, although a lot more cleaning can be 
acheived
These features names are then projected to train + test data columns to replace the "unnamed' columns from step1
Subjects and corresponding activities column data of each subject are then appended to this merged data making the the features
as 534 using cbind() -- by the end of this step the huge data set is considered "tidy"
Out of 534 variables of this data set, a subset of feature related to measurements such as "mean and standard deviation" are extra
cted for each subject thus reducing the required tidy data set to 180 variables of 80 observations
The result is then written to a .txt file for persistent storage
