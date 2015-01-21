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
        tidyCols<-do.call(paste, as.data.frame(tidyFeatureTbl, stringsAsFactors=FALSE))
        tidyAllFeatures<-replace_all(tidyCols," ","")

        #make an activity table and add column names

        actDT<-read.table("activity_labels.txt",row.names=NULL,col.names=c("activity_id","activity"))


        #start creating the train data test data set with the acitvities performed and measurements captured

        subDT_train<-read.table("train//subject_train.txt",row.names=NULL, col.names=c("subject"))
        subDT_test<-read.table("test//subject_test.txt",row.names=NULL,col.names=c("subject"))
        subjDataMerge<-rbind(subDT_train,subDT_test)

        #read the activity labels for the subjects
        labelDT_train<-read.table("train//y_train.txt")
        labelDT_test<-read.table("test//y_test.txt")
        ActTrnTstMerge<-rbind(labelDT_train,labelDT_test)

        #add the activity name to the subjects Train and Test subjects
        for (i in 1:nrow(ActTrnTstMerge)){
                for(j in 1:nrow(actDT)){
                        #match the ids and add the activityname
                        if (ActTrnTstMerge[i,1]== actDT[j,1]){
                                ActTrnTstMerge[i,2] = actDT[j,2]
                        }
                }
        }
        colnames(ActTrnTstMerge)<-c("act_id","activity")


        subActTbl<-cbind(subjDataMerge,ActTrnTstMerge)

        trnMesDT<-read.table("train//X_train.txt")
        testMesDT <-read.table("test//X_test.txt")

        allMesDT<-rbind(trnMesDT,testMesDT)
        colnames(allMesDT)<-tidyAllFeatures

        tidyMesrmtTbl<-cbind(subActTbl,allMesDT)

        #subset for columns with mean and std in their names
        fewrMesTidyTbl<-subset(tidyMesrmtTbl, select = grepl("subject|activity|mean|std", names(tidyMesrmtTbl)))





