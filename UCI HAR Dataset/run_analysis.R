# run_anlysis.R script is developed as an assignment for Getting and Cleaning Data Course Project in Coursera
# The script is expected to perform the foll. steps from the given data set :for data set refer to Coursera
# course project

# 1.Merges the training and the test sets to create one data set.
# 2.Extracts only the measurements on the mean and standard deviation for each measurement.
# 3.Uses descriptive activity names to name the activities in the data set
# 4.Appropriately labels the data set with descriptive variable names.
#
# 5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

###########################################################################################################
# The run_analyis.R uses 2 utility functions for cleaning up the feature lables ref:: #4 above
#         replace_all () -- that finds a specific occurrence of a string and replaces all such occurences
#         with the replacement string
#         features_to_table() a function that leverages on "white spaces" to split the features' names into columns'
#       The script assumes that all the data files are in the current working directory
############################################################################################################

        library(plyr)
        library(stringr)
        library(stringi)
        library(dplyr)


        # utility function1 : to replace all occurences of a pattern and clean up the features.txt file and return the dataframe

        replace_all <- function(df, pattern, replacement) {
                char <- vapply(df, function(x) is.factor(x) || is.character(x), logical(1))
                df[char] <- lapply(df[char], str_replace_all, pattern, replacement)
                return (df)


        }
        # utility function2 : to split the feature names by white spaces and then the
        #split features' names are concatenated to form a single variable name
        features_to_table <- function(df,splitchar) {
                return (stri_split_fixed(df[,2], splitchar, simplify = TRUE))
        }


        #make an activity table and add column names

        actDT<-read.table("activity_labels.txt",row.names=NULL,col.names=c("activity_id","activity"))


        #start creating the train data test data set with the acitvities performed and measurements captured

        subDT_train<-read.table("train//subject_train.txt",row.names=NULL, col.names=c("subject"))
        subDT_test<-read.table("test//subject_test.txt",row.names=NULL,col.names=c("subject"))
        subjDataMerge<-rbind(subDT_train,subDT_test)

        #read the activity labels for the subjects
        labelDT_train<-read.table("train//y_train.txt",row.names=NULL,col.names=c("activity_id"))
        labelDT_test<-read.table("test//y_test.txt",row.names=NULL,col.names=c("activity_id"))
        #merge train and test subjects' activities
        ActTrnTstMerge<-rbind(labelDT_train,labelDT_test)

        #add the activity name to the  Train and Test subjects:-
        #get the corresponding names from second column of activity data table "actDT"

        ActTrnTstMerge$activityLbl<-actDT[ActTrnTstMerge$activity_id,2]

        #combine subject vs. activity tables
        subActTbl<-cbind(subjDataMerge,ActTrnTstMerge)

        #now start reading the measurement data for training set and test sets

        trnMesDT<-read.table("train//X_train.txt")
        testMesDT <-read.table("test//X_test.txt")

        #STEP1:

        #merge the train and test measurement datasets and
        #impose the column names from the tidied feature set
        allMesDT<-rbind(trnMesDT,testMesDT)

        #STEP3:
        #read the feature set a nd tidy the feature set
        bigFeatureSet<-read.table("features.txt")

        #cleanup the variables in BigDf
        tidyFeatureNames<-replace_all(bigFeatureSet,"BodyBody","Body")

        tidyFeatureExpr<-replace_all(tidyFeatureNames,'\\(|\\)|\\-', " ")
        tidyFineTuneNames<-replace_all(tidyFeatureExpr,'\\,'," ")

        #break the variables by "space" char and distribute them to columns
        tidyFeatureTbl<-features_to_table(tidyFineTuneNames," ")

        #combine all cols now, single string variable names will be formed for e.g "fbody mean X 12 34"
        tidyCols<-do.call(paste, as.data.frame(tidyFeatureTbl, stringsAsFactors=FALSE))

        #now remove the extra spaces so that we get "fbodymeanX1234", now assume that all feature names are tidied
        tidyAllFeatures<-replace_all(tidyCols," ","")


        #STEP3,STEP4
        colnames(allMesDT)<-tidyAllFeatures

        #merge the subject-activity and measurement data sets

        tidyMesrmtTbl<-cbind(subActTbl,allMesDT)

        #STEP2:

        #subset for columns with mean and std in their names
        #for all subjects with their corresponding activities
        fewrMesTbl<-subset(tidyMesrmtTbl, select = grepl("subject|Lbl|mean|std", names(tidyMesrmtTbl)))

        #STEP5
        #compute measurements' mean for each subject for each activity performed
        subActWiseMeanData<-ddply(fewrMesTbl, c( "activityLbl","subject"), numcolwise(mean))

        #write the data to a txt file with write.table
        write.table(subActWiseMeanData,"sub_act_mean_data.txt",row.names=FALSE)








