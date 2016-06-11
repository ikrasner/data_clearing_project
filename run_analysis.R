#Data reading
data_path <- "UCI HAR Dataset"
act_labels_path<-file.path(data_path, "activity_labels.txt")
features_path<-file.path(data_path, "features.txt")
acts <- readLines(act_labels_path)
features <- readLines(features_path)

action_labels <-split(unlist(strsplit(acts, " ")), 1:2)[[2]]
feature_labels <-split(unlist(strsplit(features, " ")), 1:2)[[2]]


test_path <- file.path(data_path, "test", "X_test.txt")
test_acts_path<-file.path(data_path, "test", "y_test.txt")
test_subj_path<-file.path(data_path, "test", "subject_test.txt")

train_path<- file.path(data_path, "train", "X_train.txt")
train_acts_path<-file.path(data_path, "train", "y_train.txt")
train_subj_path<-file.path(data_path, "train", "subject_train.txt")


test_subj<-as.numeric(readLines(test_subj_path))
test_acts<-as.numeric(readLines(test_acts_path))

train_subj<-as.numeric(readLines(train_subj_path))
train_acts<-as.numeric(readLines(train_acts_path))

train_data<-read.csv(train_path, header=FALSE, sep="")
test_data<-read.csv(test_path, header=FALSE, sep="")

#Data transformation
names(test_data)<-feature_labels
names(train_data)<-feature_labels
mean_and_std_labels<-feature_labels[grepl("std|mean\\(", feature_labels)]
test_mean_and_std<-test_data[mean_and_std_labels]
train_mean_and_std<-train_data[mean_and_std_labels]


test_mean_and_std$action.labels<-action_labels[test_acts]
train_mean_and_std$action.labels<-action_labels[train_acts]
test_mean_and_std$subject<-test_subj
train_mean_and_std$subject<-train_subj
merged<-rbind(test_mean_and_std, train_mean_and_std)

variable = mean_and_std_labels[[1]]
cur_data<-tapply(merged[[variable]], list(merged$action.labels, merged$subject), mean)
final_frame<-expand.grid(subject=colnames(cur_data), activity=rownames(cur_data))
final_frame[variable]<-c(t(cur_data))

#Data transformation
for (variable in mean_and_std_labels[-1]) 
{
  cur_data<-tapply(merged[[variable]], list(merged$action.labels, merged$subject), mean)
  cur_frame<-expand.grid(subject=colnames(cur_data), activity=rownames(cur_data))
  cur_frame[variable]<-c(t(cur_data))
  final_frame<-merge(final_frame, cur_frame, by = c("subject","activity"))
}

#Make new names
n<-names(final_frame)
n<-tolower(n)
n<-sub("^t", "time.", n, perl = TRUE )
n<-sub("^f", "freq.", n, perl = TRUE )
n<-gsub("body", "body.", n)
n<-sub("gyro", "gyro.", n)
n<-sub("jerk", "jerk.", n)
n<-sub("std", "std.", n)
n<-sub("mean", "mean.", n)
n<-sub("mag", "mag.", n)
n<-sub("acc", "acc.", n)
n<-sub("gravity", "gravity.", n)
n<-gsub("\\(\\)", "", n)
n<-gsub("-", "", n)
names(final_frame)<-n

#Save tidy dataset
write.csv(final_frame, file="processed_data.csv", row.names = FALSE)

