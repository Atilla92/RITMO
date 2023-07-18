library(ggplot2)
library(sjPlot)
library(sjlabelled)
library(sjmisc)
library(dplyr)
library(lme4)
library(lmerTest)
data_raw <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/all_experiments_07072023_095/12072023_ELAN_no_CDRS.csv')

#Remove duplicates 
data <- data_raw %>% distinct(Name,Participant,number, .keep_all = TRUE)

# If you want to fetch only Dancers or Only Guitairsts
data_P <- data[grepl("P", data$Participant),] #only dancers
data_G <- data[grepl("G", data$Participant),] #only dancers


data_subset <-subset(data, number == 0)



# Factors
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


# Check whether subset data has the same number as Macro dataset
# Seems its a bit off
# -2 for most guitarists because D0 has not been annotated in ELAN
# For now it actually looks good

participant_counts <- table(data_subset$Participant[data_subset$Q1a != ""])
sorted_counts <- sort(participant_counts, decreasing = TRUE)
print(sorted_counts)


# Double check distribution for one question
# Looks god, a bit skewed to the right
plot.new()
Q1a_counts <- table(data_subset$Q3a)
sorted_Q1a_counts <- sort(Q1a_counts)
barplot(Q1a_counts, main = "Number of Data Points per Participant",
        xlab = "Participants", ylab = "Data Points", col = "blue")

# Check distribution for all subjective questions except Q2a
all_responses <- unlist(data_subset[, c("Q1a", "Q1b", "Q3a", "Q3b", "Q4a", "Q4b", "Q5a", "Q5b","Q4c", "Q6a", "Q6b")])
response_counts <- table(all_responses)
barplot(response_counts, main = "Number of Responses for Q1, Q3, Q4, Q5, Q6",
        xlab = "Number", ylab = "Response Count", col = "blue")


# Check dsitribution LZ
barplot(data$LZ, col = data$Artist, xlab = "Index", ylab = "LZ values")



# For fun lets test a model
# What is it we would want to correlate here?
# We do not have flow or improvisation subjective. Yet we have... MI. DI
library(lme4)
library(lmerTest)

model_entropy_1  = lmer(LZ_avg ~   Dance_Imp + (1 | Participant) + (1 | Pair)  , data = data ) #this performs better
summary(model_entropy_1)






