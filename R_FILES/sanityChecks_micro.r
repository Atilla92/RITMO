
library(ggplot2)
library(sjPlot)
library(sjlabelled)
library(sjmisc)
library(dplyr)


data_raw <- read.csv("~/CODE/RITMO/ENTROPY/output/main/all_experiments_07072023_095/20072023_all_experiments_drums_guitar_zd.csv")
data_raw_2 <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/all_experiments_07072023_095/20072023_ELAN_no_CDRS.csv')
data_raw_dt <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/22_Aug_2023/23082023_ELAN_no_CDRS_onset_dt_LZ.csv')
data_lag <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/22_Aug_2023/23082023_ELAN_no_CDRS_onset_dt_LZ_sync.csv')
data_lag_1s <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/24_Aug_2023/23082023_ELAN_no_CDRS_onset_dt_LZ_1s_sync.csv')
#drop duplicates
data <- data_lag_1s %>% distinct(Name,Participant,number, .keep_all = TRUE)
data <- data_lag %>% distinct(Name,Participant,number, .keep_all = TRUE)
data <- data_raw_dt %>% distinct(Name,Participant,number, .keep_all = TRUE)
data <- data_raw_2 %>% distinct(Name,Participant,number, .keep_all = TRUE)
data <- data_raw %>% distinct(Name,Participant,number, .keep_all = TRUE)

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


# MACRO Additional 
data$Q1 <- (data$Q1a + data$Q1b) / 2
data$Q3 <- (data$Q3a + data$Q3b) / 2
data$Q6 <- (data$Q6a + data$Q6b) /2
data$Q5 <-  (data$Q5a + data$Q5b) /2
data$Q4 <- (data$Q4a + data$Q4b + data$Q4c) /3


# Subset data
subset_data <- subset(data, number == 0)

# Check
participant_name_counts <- subset_data %>%
  group_by(Participant) %>%
  summarise(Unique_Name_Count = n_distinct(Name))
print(participant_name_counts)

subsetdata_P <- subset_data[grepl("P", subset_data$Participant),] #only dancers



# Check general stats
plot.new()


participant_counts <- table(data$Participant[data$Q1a != ""])
sorted_counts <- sort(participant_counts, decreasing = TRUE)
print(sorted_counts)





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


# SUBSET DATA MACRO

m01 = lmer(Q3 ~   Q6a + Q5b + Q4c + (1 | Participant), data = subset_data )
m02 = lmer(Q3 ~   Q6a + Q5b + Q4c + Q1b + (1 | Participant), data = subset_data )
m03 = lmer(Q3 ~   Q6a  + Q4c + Q1b + (1 | Participant), data = subset_data )
m04 = lmer(Q3 ~   Q6a  + Q1b + (1 | Participant), data = subset_data )
m05 = lmer(Q3 ~   Q6a  + Q4c + (1 | Participant), data = subset_data )
m06 = lmer(Q3 ~   Q6a  + Q4c  +  Q1b + (1 | Participant), data = subset_data )
m07 = lmer(Q3 ~   Q6 + Q4a +  Q1b + (1 | Participant), data = subset_data )
tab_model(m01, m02, m03, m04, m05,m06, m07,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07"), digits = 5 )

m01 = lmer(LZ_avg ~   Q6a + Q5b + Q4c + (1 | Participant), data = subset_data )
m02 = lmer(Q3b ~   Q6a + Q5b + Q4c + Q1b + (1 | Participant), data = subset_data )
m03 = lmer(Q3b ~   Q6a  + Q4c + Q1b + (1 | Participant), data = subset_data )
m04 = lmer(Q3b ~   Q6a  + Q1b + (1 | Participant), data = subset_data )
m05 = lmer(Q3b ~   Q6a  + Q4c + Q3a + (1 | Participant), data = subset_data )
m06 = lmer(Q3b ~   Q6a  + Q4c + Q3a +  Q1b + (1 | Participant), data = subset_data )
m07 = lmer(Q3b ~   Q6a  + Q3a +  Q1b + (1 | Participant), data = subset_data )
tab_model(m01, m02, m03, m04, m05,m06, m07,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07"), digits = 5 )


m01  = lmer(LZ_avg ~   1 + (1 | Participant) + (1 | Pair)  , data = subset_data )
m02  = lmer(LZ_avg ~   1 + (1 | Participant) , data = subset_data )
m03  = lmer(LZ_avg ~   1 + (1 | Pair) , data = subset_data )
m04  = lmer(LZ_avg ~   1 + (1 | Pair:Participant) , data = subset_data )
m05  = lmer(LZ_avg ~   1 + (1 | Pair/Participant) , data = subset_data )
m06 =  lmer(LZ_avg ~   1 + (1 | Artist) , data = subset_data )

tab_model(m01, m02, m03, m04, m05,m06, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06"), digits = 5 )
summary(m02)

m01  = lmer(LZ_avg ~   1 + (1 | Participant) , data = subset_data )
m02  = lmer(var_entropy_avg ~   1 + (1 | Pair) , data = subset_data )
m03  = lmer(var_entropy_avg ~   1 + (1 | Participant) , data = subset_data )
m04  = lmer(MIR_novelty_avg ~   1 + (1 | Participant) , data = subset_data )
m05  = lmer(MIR_entropy_avg ~   1 + (1 | Participant) , data = subset_data )
m06  = lmer(MIR_rms_avg ~   1 + (1 | Participant) , data = subset_data )
tab_model(m01, m02, m03, m04, m05,m06, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06"), digits = 5 )



m01  = lmer(var_entropy_avg ~   1 + (1 | Participant) + (1 | Pair)  , data = subset_data )
m02  = lmer(var_entropy_avg ~   1 + (1 | Participant) , data = subset_data )
m03  = lmer(var_entropy_avg ~   1 + (1 | Pair) , data = subset_data )
m04  = lmer(var_entropy_avg ~   1 + (1 | Pair:Participant) , data = subset_data )
m05  = lmer(var_entropy_avg ~   1 + (1 | Pair/Participant) , data = subset_data )
m06 =  lmer(var_entropy_avg ~   1 + (1 | Artist) , data = subset_data )

tab_model(m01, m02, m03, m04, m05,m06, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06"), digits = 5 )


m01  = lmer(var_entropy_avg ~   1 + (1 | Pair) , data = subset_data )
m02  = lmer(var_entropy_avg ~   Q1a + (1 | Pair) , data = subset_data )
m03  = lmer(var_entropy_avg ~   Q1b + (1 | Pair) , data = subset_data )
m04  = lmer(var_entropy_avg ~   Q3a + (1 | Pair) , data = subset_data )
m05  = lmer(var_entropy_avg ~   Q3b + (1 | Pair) , data = subset_data )
m06  = lmer(var_entropy_avg ~   Perf_Av + (1 | Pair) , data = subset_data )
m07  = lmer(var_entropy_avg ~   Abs_Av + (1 | Pair) , data = subset_data )
m08  = lmer(var_entropy_avg ~   Condition + (1 | Pair) , data = subset_data )
tab_model(m01, m02, m03, m04, m05,m06,m07,m08, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07", "m08"), digits = 5 )

m01  = lmer(var_entropy_avg ~   Q1a + (1 | Pair) , data = subset_data )
m02  = lmer(var_entropy_avg ~   Q1a + Q3b +  (1 | Pair) , data = subset_data )
m03  = lmer(var_entropy_avg ~   Q1a + Abs_Av +  (1 | Pair) , data = subset_data )
m04  = lmer(var_entropy_avg ~    Q1a + Q3a + Abs_Av + (1 | Pair) , data = subset_data )
m05  = lmer(var_entropy_avg ~   Q3b + Abs_Av + (1 | Pair) , data = subset_data )
m06  = lmer(var_entropy_avg ~   Abs_Av + (1 | Pair) , data = subset_data )
tab_model(m01, m02, m03, m04, m05,m06, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06"), digits = 5 )

m01  = lmer(var_entropy_avg ~   Q5a + (1 | Pair) , data = subset_data )
m02  = lmer(var_entropy_avg ~   Q5b +  (1 | Pair) , data = subset_data )
m03  = lmer(var_entropy_avg ~   Q4c+   (1 | Pair) , data = subset_data )
m04  = lmer(var_entropy_avg ~    Q6a + (1 | Pair) , data = subset_data )
m05  = lmer(var_entropy_avg ~   Q6b + (1 | Pair) , data = subset_data )
m06  = lmer(var_entropy_avg ~   Q6a + (1 | Participant) , data = subset_data )
tab_model(m01, m02, m03, m04, m05,m06, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06"), digits = 5 )


m01  = lmer(LZ_avg ~   Q5a + (1 | Pair) , data = subset_data )
m02  = lmer(LZ_avg ~   Q5b +  (1 | Pair) , data = subset_data )
m03  = lmer(LZ_avg ~   Q4c+   (1 | Pair) , data = subset_data )
m04  = lmer(LZ_avg ~    Q6a + (1 | Pair) , data = subset_data )
m05  = lmer(LZ_avg ~   Q6b + (1 | Pair) , data = subset_data )
m06  = lmer(LZ_avg ~   Q6a + (1 | Pair) , data = subset_data )
tab_model(m01, m02, m03, m04, m05,m06, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06"), digits = 5 )

m01  = lmer(var_entropy_avg ~   Q6a + (1 | Pair) , data = subset_data )
m02  = lmer(var_entropy_avg ~   Q6a + Abs_Av + (1 | Pair) , data = subset_data )
m03  = lmer(var_entropy_avg ~   Q1a + Q6a + (1 | Pair) , data = subset_data )
m04  = lmer(var_entropy_avg ~   Q6a + Q3b + (1 | Pair), data = subset_data )
tab_model(m01, m02, m03, m04, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04"), digits = 5 )


#MICRO MODELS

m01  = lmer(LZ ~   1 + (1 | Participant) + (1 | Pair)  , data = data )
m02  = lmer(LZ ~   1 + (1 | Participant) , data = data )
m03  = lmer(LZ ~   1 + (1 | Pair) , data = data )
m04  = lmer(LZ ~   1 + (1 | Pair:Participant) , data = data )
m05  = lmer(LZ ~   1 + (1 | Pair/Participant) , data = data )
m06 =  lmer(LZ ~   1 + (1 | Pair/Condition/number) , data = data )
m07 =  lmer(LZ ~   1 + (1 | Pair/Palo/Music_mode) , data = data )
m08 =  lmer(LZ ~   1 + (1 | Name/number) , data = data )
m09 =  lmer(LZ ~   1 + (1 | Pair/Step) , data = data )
tab_model(m01, m02, m03, m04, m05,m06,m07, m08, m09,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07", "m08", "m09"), digits = 5 )





m01 =  lmer(LZ ~   1 + (1 | Pair/Step) , data = data )
m02 =  lmer(LZ ~   Condition + (1 | Pair/Step) , data = data )
m03 =  lmer(LZ ~   Dance_Imp + (1 | Pair/Step) , data = data )
m04 =  lmer(LZ ~   Music_Imp + (1 | Pair/Step) , data = data )
m05 =  lmer(LZ ~   Baile_Level + (1 | Pair/Step) , data = data )
m06 =  lmer(LZ ~   Guitarra_Level + (1 | Pair/Step) , data = data )
tab_model(m01, m02, m03, m04, m05,m06,m07, m08, m09,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07", "m08", "m09"), digits = 5 )

m01 =  lmer(var_entropy ~   1 + (1 | Pair/Step) , data = data )
m02 =  lmer(var_entropy ~   Condition + (1 | Pair/Step) , data = data )
m03 =  lmer(var_entropy ~   Dance_Imp + (1 | Pair/Step) , data = data )
m04 =  lmer(var_entropy ~   Music_Imp + (1 | Pair/Step) , data = data )
m05 =  lmer(var_entropy ~   Baile_Level + (1 | Pair/Step) , data = data )
m06 =  lmer(var_entropy ~   Guitarra_Level + (1 | Pair/Step) , data = data )
tab_model(m01, m02, m03, m04, m05,m06,m07, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07"), digits = 5 )


m01 =  lmer(LZ ~   Condition + (1 | Pair/Step) , data = data )
m02 =  lmer(var_entropy ~   Condition + (1 | Pair/Step) , data = data )
m03 =  lmer(MIR_entropy ~   Condition + (1 | Pair/Step) , data = data )
m04 =  lmer(MIR_novelty ~   Condition + (1 | Pair/Step) , data = data )
m05 =  lmer(MIR_rms ~   Condition + (1 | Pair/Step) , data = data )

tab_model(m01, m02, m03, m04, m05, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("LZ", "var_entropy", "MIR_entropy", "MIR_novelty", "MIR_rms"), digits = 5 )



# MICRO ALL, CDRS included, data_raw
m01 =  lmer(LZ ~   Flow_subj + (1 | Pair/Step) , data = data )
m02 =  lmer(var_entropy ~   Flow_subj + (1 | Pair/Step) , data = data )
m03 =  lmer(MIR_entropy ~   Flow_subj + (1 | Pair/Step) , data = data )
m04 =  lmer(MIR_novelty ~   Flow_subj + (1 | Pair/Step) , data = data )
m05 =  lmer(MIR_rms ~   Flow_subj + (1 | Pair/Step) , data = data )

tab_model(m01, m02, m03, m04, m05, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("LZ", "var_entropy", "MIR_entropy", "MIR_novelty", "MIR_rms"), digits = 5 )



subset_data <- subset(data, number == 0)
m01 =  lmer(LZ_avg ~   Flow_avg + (1 | Pair) , data = subset_data )
m02 =  lmer(LZ_avg ~   Imp_avg + (1 | Pair) , data = subset_data )
m03 =  lmer(LZ ~   Flow_subj + (1 | Pair/Step) , data = data )
m04 =  lmer(LZ ~   Imp_subj + (1 | Pair/Step) , data = data )
m05 =  lmer(LZ_avg ~   Q6a + (1 | Pair/Step) , data = subset_data )
tab_model(m01, m02, m03, m04, m05, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02", "m03", "m04", "m05"), digits = 5 )


m01 =  lmer(var_entropy_avg ~   Flow_avg + (1 | Pair) , data = subset_data )
m02 =  lmer(var_entropy_avg ~   Imp_avg + (1 | Pair) , data = subset_data )
m03 =  lmer(var_entropy ~   Flow_subj + (1 | Pair/Step) , data = data )
m04 =  lmer(var_entropy ~   Imp_subj + (1 | Pair/Step) , data = data )
m05 =  lmer(var_entropy_avg ~   Q6a + (1 | Pair/Step) , data = subset_data )
tab_model(m01, m02, m03, m04, m05, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02", "m03", "m04", "m05"), digits = 5 )


#£££££ Complexity and flow
m01  = lmer(LZ_avg ~   1 + (1 | Participant) + (1 | Pair)  , data = subset_data )
m02  = lmer(LZ_avg ~   1 + (1 | Participant) , data = subset_data )
m03  = lmer(LZ_avg ~   1 + (1 | Pair) , data = subset_data )
m04  = lmer(LZ_avg ~   1 + (1 | Pair:Participant) , data = subset_data )
m05  = lmer(LZ_avg ~   1 + (1 | Pair/Participant) , data = subset_data )
m06 =  lmer(LZ_avg ~   1 + (1 | Artist) , data = subset_data )

tab_model(m01, m02, m03, m04, m05,m06, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06"), digits = 5 )


m01 = lmer(LZ_avg ~   Q3 +  (1 | Pair), data = subset_data )
m02 = lmer(LZ_avg ~   Q4 +  (1 | Pair), data = subset_data )
m03 = lmer(LZ_avg ~   Q5 +  (1 | Pair), data = subset_data )
m04 = lmer(LZ_avg ~   Q6 +  (1 | Pair), data = subset_data )
m05 = lmer(LZ_avg ~   Perf_Av +  (1 | Pair), data = subset_data )
m06 = lmer(LZ_avg ~   Abs_Av +  (1 | Pair), data = subset_data )
m07 = lmer(LZ_avg ~   Q6a +  (1 | Pair), data = subset_data )
m08 = lmer(LZ_avg ~   Q1 +  (1 | Pair), data = subset_data )

tab_model(m01, m02, m03, m04, m05,m06, m07,m08,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07", "m08"), digits = 5 )

m01 = lmer(LZ_avg ~   Q3 +  (1 | Participant), data = subset_data )
m02 = lmer(LZ_avg ~   Q3a +  (1 | Participant), data = subset_data )
m03 = lmer(LZ_avg ~   Q3b +  (1 | Participant), data = subset_data )
m04 = lmer(LZ_avg ~   Q2a +  (1 | Participant), data = subset_data )
m05 = lmer(LZ_avg ~   Q2c +  (1 | Participant), data = subset_data )
m06 = lmer(LZ_avg ~   Q2f +  (1 | Participant), data = subset_data )
m07 = lmer(LZ_avg ~   Q2j +  (1 | Participant), data = subset_data )
m08 = lmer(LZ_avg ~   Q1a +  (1 | Participant), data = subset_data )
m09 = lmer(LZ_avg ~   Q1b +  (1 | Participant), data = subset_data )
tab_model(m01, m02, m03, m04, m05,m06, m07, m08, m09,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07", "m08", "m09"), digits = 5 )



m01 = lmer(LZ_avg ~   Q3+  (1 | Participant), data = subset_data )
m02 = lmer(LZ_avg ~   Q3 + Abs_Av + (1 | Participant), data = subset_data )
m03 = lmer(LZ_avg ~   Q3 + Q2a + (1 | Participant), data = subset_data )
m04 = lmer(LZ_avg ~   Q3 + Q2c + (1 | Participant), data = subset_data )
m05 = lmer(LZ_avg ~   Q3 + Q2f + (1 | Participant), data = subset_data )
m06 = lmer(LZ_avg ~    Abs_Av + (1 | Participant), data = subset_data )
m07 = lmer(LZ_avg ~   Abs_Av+ Q1  +  (1 | Participant), data = subset_data )
m08 = lmer(LZ_avg ~    Condition +   (1 | Participant), data = subset_data )


tab_model(m01, m02, m03, m04, m05,m06, m07,m08,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07", "m08"),  digits = 5 )

m01 = lmer(LZ_avg ~   Q3 +  (1 | Pair), data = subset_data )
m02 = lmer(LZ_avg ~    Condition +  (1 | Pair), data = subset_data )
m03 = lmer(LZ_avg ~    Palo +  (1 | Pair), data = subset_data )
m04 = lmer(LZ_avg ~    Dance_mode * Palo +  (1 | Pair), data = subset_data )
m05= lmer(LZ_avg ~    Condition * Palo  +  (1 | Pair), data = subset_data )
m06= lmer(LZ_avg ~    Music_mode * Palo + (1 | Pair), data = subset_data )
m07= lmer(LZ_avg ~     Abs_Av +  Q1 + (1 | Pair) , data = subset_data )
m08= lmer(LZ_avg ~      Q3 + Condition +  (1 | Pair) , data = subset_data )
tab_model(m01, m02, m03, m04, m05,m06, m07, m08,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07", "m08"), digits = 5 )

m01 = lmer(dt_LZ_avg ~   Q3 +  (1 | Pair), data = subset_data )
m02 = lmer(dt_LZ_avg ~    Condition +  (1 | Pair), data = subset_data )
m03 = lmer(dt_LZ_avg ~    Palo +  (1 | Pair), data = subset_data )
m04 = lmer(dt_LZ_avg ~    Dance_mode * Palo +  (1 | Pair), data = subset_data )
m05= lmer(dt_LZ_avg ~    Condition * Palo  +  (1 | Pair), data = subset_data )
m06= lmer(dt_LZ_avg ~    Music_mode * Palo +  (1 | Pair), data = subset_data )
m07= lmer(dt_LZ_avg ~     Abs_Av +  Q1 + (1 | Pair) , data = subset_data )
m08= lmer(dt_LZ_avg ~      Q3 + Condition +  (1 | Pair) , data = subset_data )
tab_model(m01, m02, m03, m04, m05,m06, m07, m08,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07", "m08"), digits = 5 )

m01 = lmer(IOI_avg ~   Q3 +  (1 | Pair), data = subset_data )
m02 = lmer(IOI_avg ~    Condition +  (1 | Pair), data = subset_data )
m03 = lmer(IOI_avg ~    Palo +  (1 | Pair), data = subset_data )
m04 = lmer(IOI_avg ~    Dance_mode * Palo +  (1 | Pair), data = subset_data )
m05= lmer(IOI_avg ~    Condition * Palo  +  (1 | Pair), data = subset_data )
m06= lmer(IOI_avg ~    Music_mode * Palo +  (1 | Pair), data = subset_data )
m07= lmer(g_IOI ~     Guitarra_Level +  Q1 + (1 | Pair) , data = subset_data )
m08= lmer(p_IOI ~      Baile_Level +  (1 | Pair) , data = data )
tab_model(m01, m02, m03, m04, m05,m06, m07, m08,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07", "m08"), digits = 5 )



m01 = lmer(p_LZ_avg ~   Q3 +  (1 | Pair), data = subset_data )
m02 = lmer(p_LZ_avg ~   Q4 +  (1 | Pair), data = subset_data )
m03 = lmer(p_LZ_avg ~   Q5 +  (1 | Pair), data = subset_data )
m04 = lmer(p_LZ_avg ~   Q6 +  (1 | Pair), data = subset_data )
m05 = lmer(p_LZ_avg ~   Perf_Av +  (1 | Pair), data = subset_data )
m06 = lmer(p_LZ_avg ~   Abs_Av +  (1 | Pair), data = subset_data )
m07 = lmer(p_LZ_avg ~   Q6a +  (1 | Pair), data = subset_data )

tab_model(m01, m02, m03, m04, m05,m06, m07,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07"), digits = 5 )


m01 = lmer(g_LZ_avg ~   Q3 +  (1 | Participant), data = subset_data )
m02 = lmer(g_LZ_avg ~   Q4 +  (1 | Participant), data = subset_data )
m03 = lmer(g_LZ_avg ~   Q5 +  (1 | Participant), data = subset_data )
m04 = lmer(g_LZ_avg ~   Q6 +  (1 | Participant), data = subset_data )
m05 = lmer(g_LZ_avg ~   Perf_Av +  (1 | Participant), data = subset_data )
m06 = lmer(g_LZ_avg ~   Abs_Av +  (1 | Participant), data = subset_data )
m07 = lmer(g_LZ_avg ~   Q6a +  (1 | Participant), data = subset_data )

tab_model(m01, m02, m03, m04, m05,m06, m07,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07"), digits = 5 )


m01 = lmer(var_entropy_avg ~   Q3 +  (1 | Pair), data = subset_data )
m02 = lmer(var_entropy_avg ~   Q4 +  (1 | Pair), data = subset_data )
m03 = lmer(var_entropy_avg ~   Q5 +  (1 | Pair), data = subset_data )
m04 = lmer(var_entropy_avg ~   Q6 +  (1 | Pair), data = subset_data )
m05 = lmer(var_entropy_avg ~   Perf_Av +  (1 | Pair), data = subset_data )
m06 = lmer(var_entropy_avg ~   Abs_Av +  (1 | Pair), data = subset_data )
m07 = lmer(var_entropy_avg ~   Q6a +  (1 | Pair), data = subset_data )
m08 = lmer(var_entropy_avg ~   Q1 +  (1 | Pair), data = subset_data )

tab_model(m01, m02, m03, m04, m05,m06, m07,m08,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07", "m08"), digits = 5 )



m01 = lmer(Q6a ~   LZ_avg +  (1 | Pair), data = subset_data )
m02 = lmer(Q6a ~   var_entropy_avg +  (1 | Pair), data = subset_data )
m03 = lmer(Q6 ~   MIR_novelty_avg +  (1 | Pair), data = subset_data )
m04 = lmer(Q6 ~   MIR_rms_avg +  (1 | Pair), data = subset_data )
m05 = lmer(Q6 ~   MIR_entropy_avg +  (1 | Pair), data = subset_data )

tab_model(m01, m02, m03, m04, m05,m06, m07,m08,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07", "m08"), digits = 5 )


m01 = lmer(Q3 ~   LZ_avg +  (1 | Pair), data = subset_data )
m02 = lmer(Q3 ~   var_entropy_avg +  (1 | Pair), data = subset_data )
m03 = lmer(Q3 ~   MIR_novelty_avg +  (1 | Pair), data = subset_data )
m04 = lmer(Q3 ~   MIR_rms_avg +  (1 | Pair), data = subset_data )
m05 = lmer(Q3 ~   MIR_entropy_avg +  (1 | Pair), data = subset_data )
m06 = lmer(Q3 ~   g_LZ_avg  + (1 | Participant), data = subset_data )
m07 = lmer(Q3 ~   p_LZ_avg  + (1 | Participant), data = subsetdata_P )

tab_model(m01, m02, m03, m04, m05,m06, m07,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07"), digits = 5 )

m01 = lmer(Q3 ~   LZ_avg +  (1 | Participant), data = subset_data )
m02 = lmer(Q3 ~   Q6 +  (1 | Participant), data = subset_data )
m03 = lmer(LZ_avg ~   Q6a +  (1 | Participant), data = subset_data )
m04 = lmer(LZ ~   Q6 +  (1 | Participant/Step), data = data )

tab_model(m01, m02, m03, m04, m05,m06, m07,m08,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07", "m08"), digits = 5 )



m01 = lmer(p_lag_avg ~   Q3 +  (1 | Pair), data = subset_data )
m02 = lmer(p_lag_avg ~    Condition +  (1 | Pair), data = subset_data )
m03 = lmer(p_lag_avg ~    Palo +  (1 | Pair), data = subset_data )
m04 = lmer(p_lag_avg ~    Dance_mode * Palo +  (1 | Pair), data = subset_data )
m05= lmer(p_lag_avg ~    Condition * Palo  +  (1 | Pair), data = subset_data )
m06= lmer(p_lag_avg ~    Music_mode * Palo +  (1 | Pair), data = subset_data )
m07= lmer(p_lag_avg ~     Abs_Av +  Q1 + (1 | Pair) , data = subset_data )
m08= lmer(p_lag_avg ~      Q3 + Condition +  (1 | Pair) , data = subset_data )
tab_model(m01, m02, m03, m04, m05,m06, m07, m08,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07", "m08"), digits = 5 )


m01 = lmer(p_lag_0 ~   Q3 +  (1 | Pair), data = subset_data )
m02 = lmer(p_lag_0 ~    Condition +  (1 | Pair), data = subset_data )
m03 = lmer(p_lag_0 ~    Palo +  (1 | Pair), data = subset_data )
m04 = lmer(p_lag_0 ~    Dance_mode * Palo +  (1 | Pair), data = subset_data )
m05= lmer(p_lag_0 ~    Condition * Palo  +  (1 | Pair), data = subset_data )
m06= lmer(p_lag_0 ~    Music_mode * Palo +  (1 | Pair), data = subset_data )
m07= lmer(p_lag_0 ~     Abs_Av +  Q1 + (1 | Pair) , data = subset_data )
m08= lmer(p_lag_0 ~      Q3 + Condition +  (1 | Pair) , data = subset_data )
tab_model(m01, m02, m03, m04, m05,m06, m07, m08,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07", "m08"), digits = 5 )


m01 = lmer(p_lag_0 ~   Q3 +  (1 | Pair), data = subset_data )
m02 = lmer(p_lag_0 ~    Q1 +  (1 | Pair), data = subset_data )
m03 = lmer(p_lag_0 ~    Q4 +  (1 | Pair), data = subset_data )
m04 = lmer(p_lag_0 ~    Q5 * Palo +  (1 | Pair), data = subset_data )
m05= lmer(p_lag_0 ~    Abs_Av  +  (1 | Pair), data = subset_data )
m06= lmer(p_lag_0 ~    Perf_Av +  (1 | Pair), data = subset_data )
m07= lmer(p_lag_0 ~     Dance_mode  + (1 | Pair) , data = subset_data )
m08= lmer(g_lag_avg ~     Music_mode +  (1 | Pair) , data = subset_data )
tab_model(m01, m02, m03, m04, m05,m06, m07, m08,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07", "m08"), digits = 5 )


m01 = lmer(g_lag_avg ~   Q3 +  (1 | Pair), data = subset_data )
m02 = lmer(g_lag_avg ~    Q1 +  (1 | Pair), data = subset_data )
m03 = lmer(g_lag_avg ~    Q4 +  (1 | Pair), data = subset_data )
m04 = lmer(g_lag_avg ~    Q5 * Palo +  (1 | Pair), data = subset_data )
m05= lmer(g_lag_avg ~    Abs_Av  +  (1 | Pair), data = subset_data )
m06= lmer(g_lag_avg ~    Perf_Av +  (1 | Pair), data = subset_data )
m07= lmer(g_lag_avg ~     Dance_mode  + (1 | Pair) , data = subset_data )
m08= lmer(g_lag_avg ~     Music_mode +  (1 | Pair) , data = subset_data )
tab_model(m01, m02, m03, m04, m05,m06, m07, m08,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07", "m08"), digits = 5 )


m01 = lmer(p_lag_avg ~   Q3 +  (1 | Pair), data = subset_data )
m02 = lmer(p_lag_avg ~    Q1 +  (1 | Pair), data = subset_data )
m03 = lmer(p_lag_avg ~    Q4 +  (1 | Pair), data = subset_data )
m04 = lmer(p_lag_avg ~    Q5 * Palo +  (1 | Pair), data = subset_data )
m05= lmer(p_lag_avg ~    Abs_Av  +  (1 | Pair), data = subset_data )
m06= lmer(p_lag_avg ~    Perf_Av +  (1 | Pair), data = subset_data )
m07= lmer(p_lag_avg ~     Dance_mode  + (1 | Pair) , data = subset_data )
m08= lmer(p_lag_avg ~     Music_mode +  (1 | Pair) , data = subset_data )
tab_model(m01, m02, m03, m04, m05,m06, m07, m08,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07", "m08"), digits = 5 )


m01 = lmer(p_dt_LZ ~   Baile_Level +  (1 | Pair), data = data )
m02 = lmer(p_dt_LZ ~    Guitarra_Level +  (1 | Pair), data = data )
m03 = lmer(LZ ~   Baile_Level +  (1 | Pair), data = data )
m04 = lmer(p_lag_avg ~    Baile_Level +  (1 | Pair), data = subset_data )
m05= lmer(LZ_avg ~    Q3  +  (1 | Pair), data = subset_data )
m06= lmer(dt_LZ_avg ~    Q3 +  (1 | Pair), data = subset_data )
m07= lmer(p_dt_LZ ~     Baile_Level  + (1 | Pair) , data = data )
m08= lmer(p_lag_avg ~     Music_mode +  (1 | Pair) , data = subset_data )
tab_model(m01, m02, m03, m04, m05,m06, m07, m08,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07", "m08"), digits = 5 )


