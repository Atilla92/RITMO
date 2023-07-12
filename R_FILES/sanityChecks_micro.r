


data_raw <- read.csv("~/CODE/RITMO/ENTROPY/output/main/all_experiments_07072023_095/10072023_all_experiments_drums_guitar_zd.csv")
#drop duplicates
data <- data %>% distinct(Name,Participant,number, .keep_all = TRUE)


data_P <- data[grepl("P", data$Participant),] #only dancers
data_G <- data[grepl("G", data$Participant),] #only dancers

# ALl analysis
data$Dance_mode <- as.factor(data$Dance_mode)
data$Condition <- as.factor(data$Condition)
data$Condition <- relevel(data$Condition, "D6_M6")
data$Dance_mode <- factor(data$Dance_mode, levels = c("D6", 'D5', 'D1'))
data$Condition <- factor(data$Condition, levels = c('D6_M6', 'D5_M6', 'D1_M6', 'D5_M5', 'D1_M1'))
#data$Condition_order <- as.factor(data$Condition_order)
data$Palo <- as.factor(data$Palo)
data$Music_mode <- as.factor(data$Music_mode)
data$Music_mode <- factor(data$Music_mode, levels = c("M6",'M5','M1'))
data$Participant <- as.factor(data$Participant)
data$Pair <- as.factor(data$Pair)
data$Artist <- as.factor(data$Artist)


# Check general stats
plot.new()
library(ggplot2)
library(sjPlot)
library(sjlabelled)
library(sjmisc)


participant_counts <- table(data$Participant[data$Q1a != ""])
sorted_counts <- sort(participant_counts, decreasing = TRUE)
print(sorted_counts)



library(dplyr)

# Count number of unique responses per participant and list unique names
participant_unique_names <- data %>%
  group_by(Participant) %>%
  summarise(Unique_Names = paste(unique(Name), collapse = ", "))
print(participant_unique_names)


# Count the number of unique names per participant
participant_name_counts <- data %>%
  group_by(Participant) %>%
  summarise(Unique_Name_Count = n_distinct(Name))
# Print the participant name counts
print(participant_name_counts)


# Create a subset with one unique name per participant
subset_dataset <- data %>%
  group_by(Participant) %>%
  filter(n_distinct(Name) == 1)
print(subset_dataset)



# Print the subset dataset
print(subset_dataset)

subset_data <- subset(data, number == 0)


participant_name_counts <- subset_data %>%
  group_by(Participant) %>%
  summarise(Unique_Name_Count = n_distinct(Name))
print(participant_name_counts)


participant_counts <- table(subset_data$Participant[subset_data$Q1a != ""])
sorted_counts <- sort(participant_counts, decreasing = TRUE)
print(sorted_counts)

#Seems there is still double. 

df2 <- subset_data %>% distinct(Name,Participant, .keep_all = TRUE)
print(df2)
participant_counts <- table(df2$Participant[df2$Q1a != ""])
sorted_counts <- sort(participant_counts, decreasing = TRUE)
print(sorted_counts)




df3 <- data %>% distinct(Name,Participant,number, .keep_all = TRUE)




