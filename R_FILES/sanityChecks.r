#Sanity checks on dataset 10.07.2023
#Load libraries
library(lme4)
library(lmerTest)

#dataMICRO <- read.csv("~/CODE/RITMO/ENTROPY/output/main/all_experiments_07072023_095/07072023_all_experiments_drums_guitar_zd.csv")
data <- read.csv("~/CODE/RITMO/FILES/Subjective/DuringExperiments_Andalucia_10072023_DropW.csv")
data_P <- data[!grepl("G", data$Participant),] #only dancers
data_G <- data[!grepl("P", data$Participant),] #only dancers

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


plot.new()
library(ggplot2)
library(sjPlot)
library(sjlabelled)
library(sjmisc)
ggplot(data, aes(x = Imp_avg, y = Dance_mode))+ geom_point() + scale_x_continuous(1:8) + facet_wrap(~Participant)


# MACRO Check

# Check whether dataset has right amount of repsonses
# G1,P6 lack one response, as one condition was not done due to lack of time. 

participant_counts <- table(data$Participant[data$Q1a != ""])
sorted_counts <- sort(participant_counts, decreasing = TRUE)
print(sorted_counts)


Q1a_counts <- table(data$Q3a)
sorted_Q1a_counts <- sort(Q1a_counts)
barplot(Q1a_counts, main = "Number of Data Points per Participant",
        xlab = "Participants", ylab = "Data Points", col = "blue")

all_responses <- unlist(data[, c("Q1a", "Q1b", "Q3a", "Q3b", "Q4a", "Q4b", "Q5a", "Q5b","Q4c", "Q6a", "Q6b")])
response_counts <- table(all_responses)
barplot(response_counts, main = "Number of Responses for Q1, Q3, Q4, Q5, Q6",
        xlab = "Number", ylab = "Response Count", col = "blue")

#Check chronback alpha for these columns
library('psych')
# Count the number of NA values in each column
na_counts <- colSums(is.na(selected_columns))
# Print the NA counts
print(na_counts)
selected_columns <- data[, c("Q1a", "Q1b", "Q3b", "Q3a", "Q4a", "Q4b", "Q5a", "Q5b","Q4c", "Q6a", "Q6b")]
alpha_result <- alpha(selected_columns)
chronbach_alpha <- alpha_result$alpha
print(chronbach_alpha)



library(performance)
library(tidyverse)
library(ggplot2)
library(patchwork)
library(sjPlot)

ggplot(data, aes(Q1a, Q3a ))+geom_point(aes(group=Condition,color=factor(Condition)))+facet_wrap(~Participant)
ggplot(data, aes(Q1a, Q3a ))+geom_point(aes(group=Participant,color=factor(Participant)))+guides(color=FALSE)+facet_wrap(~Pair) +
  geom_smooth(method="lm", size=1.5, color="black", se=FALSE)

ggplot(data, aes(Q1b, Q3b )) +
  geom_smooth(aes(x= Q1b, y= Q3b, group = Pair, color=factor(Pair)),method="lm" ,se=FALSE) 
  #geom_smooth(data, aes(Q1a, Q3a, group=Participant,color=factor(Participant))) 



