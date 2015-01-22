        library(plyr)
        library(stringr)
        library(stringi)
        library(dplyr)
        library("reshape2")

        #clean up the features.txt file and return the dataframe

        replace_all <- function(df, pattern, replacement) {
                char <- vapply(df, function(x) is.factor(x) || is.character(x), logical(1))
                df[char] <- lapply(df[char], str_replace_all, pattern, replacement)
                return (df)


        }

        #split features' names are concatenated to form a single variable name
        features_to_table <- function(df,splitchar) {
                return (stri_split_fixed(df[,2], splitchar, simplify = TRUE))
        }


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

        ActTrnTstMerge$activity<-actDT[ActTrnTstMerge$activity_id,2]

        #combine subject vs. activity tables
        subActTbl<-cbind(subjDataMerge,ActTrnTstMerge)

        #now start reading the measurement data for training set and test sets

        trnMesDT<-read.table("train//X_train.txt")
        testMesDT <-read.table("test//X_test.txt")

        #merge the train and test measurement datasets and
        #impose the column names from the tidied feature set
        allMesDT<-rbind(trnMesDT,testMesDT)
        colnames(allMesDT)<-tidyAllFeatures

        #merge the subject-activity and measurement data sets

        tidyMesrmtTbl<-cbind(subActTbl,allMesDT)

        #subset for columns with mean and std in their names
        #for all subjects with their corresponding activities
        fewrMesTidyTbl<-subset(tidyMesrmtTbl, select = grepl("subject|activity|mean|std", names(tidyMesrmtTbl)))





