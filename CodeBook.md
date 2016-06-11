#Variables
variables' names are generated from original names. Original names were converted to lower case and splitted by dots also the "()-" symbols were removed.
 "t" and "f" prefixes were replaced to "time" and "freq" respectively. For example, name "fBodyBodyGyroJerkMag-std()" is transformed to freq.body.body.gyro.jerk.mag.std"
Two new columns "subject" and "activity" were added 
 
#Transformations
Original values were grouped by unique pairs (activity, subject) and mean was calculated for each column in each group 
