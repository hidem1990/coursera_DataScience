library(dplyr)
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url,destfile = "./data",method = "curl")
unzip("data")

##read local data
setwd("./UCI HAR Dataset")
setwd("../")
setwd("./train")
subject_train <- read.csv("subject_train.txt", stringsAsFactors = FALSE,header = FALSE)
X_train <- read.table("X_train.txt", stringsAsFactors = FALSE, header = FALSE)
y_train <- read.csv("y_train.txt", stringsAsFactors = FALSE, header = FALSE)
df_subject_train <- tbl_df(subject_train)
df_y_train <- tbl_df(y_train)
train <- bind_cols(df_subject_train, df_y_train, X_train)

setwd("../")
setwd("./test")
subject_test <- read.csv("subject_test.txt", stringsAsFactors = FALSE,header = FALSE)
X_test <- read.table("X_test.txt", stringsAsFactors = FALSE, header = FALSE)
y_test <- read.csv("y_test.txt", stringsAsFactors = FALSE, header = FALSE)
df_subject_test <- tbl_df(subject_test)
df_y_test <- tbl_df(y_test)
test <- bind_cols(df_subject_test, df_y_test, X_test)

## merge train and test, and rename column
setwd("../")
mydata <- bind_rows(test,train)
col_name <- read.table("features.txt",stringsAsFactors = FALSE,header = FALSE)
colnames(mydata) <- c("subject", "activity", col_name$V2)

## frequenct of the same column name →remove the same column names
names_freq <- as.data.frame(table(names(mydata)))
names_freq[names_freq$Freq > 1, ]
mydata1 <- mydata[,!(duplicated(colnames(mydata)))]
## extract the measurements on the meam and SD
select_data <- select(mydata1, subject,contains("mean"), contains("std"))

## activity names
setwd("../")
activity_name <- read.table("activity_labels.txt",sep = " ", stringsAsFactors = FALSE, header = FALSE)
colnames(activity_name) <- c("activity", "descriptive_activity")
mydata2 <- merge(activity_name, select_data)

## group-by
mydata3 <- group_by(mydata2,subject)%>%
  group_by(descriptive_activity, add = TRUE)
## summarize
tidy_Data <-summarize_each(mydata3,mean)
write.table(tidy_Data,"tidy_data.csv",row.names = FALSE)
