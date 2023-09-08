#Sanity checks on dataset 10.07.2023
#Load libraries
library(lme4)
library(lmerTest)

#dataMICRO <- read.csv("~/CODE/RITMO/ENTROPY/output/main/all_experiments_07072023_095/07072023_all_experiments_drums_guitar_zd.csv")
data_raw <- read.csv("~/CODE/RITMO/FILES/Subjective/DuringExperiments_Andalucia_20072023_DropW.csv")
data_exp <- read.csv('/Users/atillajv/CODE/RITMO/FILES/Subjective/DuringExperiments_Andalucia_05092023_DropW_Expertise.csv')
#data_raw <- read.csv('~/CODE/RITMO/ENTROPY/output/main/all_experiments_07072023_095/20072023_ELAN_no_CDRS.csv')
data <- subset(data_raw, !grepl("D0", Dance_mode))
data <- subset(data_exp, !grepl("D0", Dance_mode))
data_P <- data[!grepl("G", data$Participant),] #only dancers
data_G <- data[!grepl("P", data$Participant),] #only dancers

# ALl analysis
data$Dance_mode <- as.factor(data$Dance_mode)
data$Condition <- as.factor(data$Condition)
data$Condition <- relevel(data$Condition, "D6_M6")
data$Dance_mode <- factor(data$Dance_mode, levels = c("D6", 'D5', 'D1'))
data$Condition <- factor(data$Condition, levels = c('D6_M6', 'D5_M6', 'D1_M6', 'D5_M5', 'D1_M1', 'D6_D0'))
#data$Condition_order <- as.factor(data$Condition_order)
data$Palo <- as.factor(data$Palo)
data$Music_mode <- as.factor(data$Music_mode)
data$Music_mode <- factor(data$Music_mode, levels = c("M6",'M5','M1'))
data$Participant <- as.factor(data$Participant)
data$Pair <- as.factor(data$Pair)
#data$Artist <- ifelse(data$Artist == "G", 0, ifelse(data$Artist == "P", 1, data$Artist))
data$Artist <- as.factor(data$Artist)


plot.new()
library(ggplot2)
library(sjPlot)
library(sjlabelled)
library(sjmisc)
ggplot(data, aes(x = Q1a, y = Dance_mode))+ geom_point() + scale_x_continuous(1:8) + facet_wrap(~Participant)


# MACRO Check
data$Q1 <- (data$Q1a + data$Q1b) / 2
data$Q3 <- (data$Q3a + data$Q3b) / 2
data$Q6 <- (data$Q6a + data$Q6b) /2
data$Q5 <-  (data$Q5a + data$Q5b) /2
data$Q4 <- (data$Q4a + data$Q4b + data$Q4c) /3

# Check whether dataset has right amount of repsonses
# G1,P6 lack one response, as one condition was not done due to lack of time. 

participant_counts <- table(data$Participant[data$Q1a != ""])
sorted_counts <- sort(participant_counts, decreasing = TRUE)
print(sorted_counts)


Q1a_counts <- table(data$Q5b)
sorted_Q1a_counts <- sort(Q1a_counts)
barplot(Q1a_counts, main = "Number of Data Points per Participant (Q1b)",
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


x_limits <- c(min(data$Q1a), max(data$Q1a))
ggplot(data, aes(Q1a, Q3a ))+
  geom_point(aes(group=Participant,color=factor(Artist)))+
  facet_wrap(~Dance_mode) +
  geom_smooth(aes(group=Participant,color=factor(Artist)),method="lm", size=1.5, se=FALSE)+
  xlim(x_limits)

ggplot(data, aes(Q1a, Q3b )) +
  geom_smooth(aes(x= Q1a, y= Q3b, group = Pair, color=factor(Pair)),method="lm" ,se=FALSE) +
  geom_smooth(aes(x= Q1a, y= Q3b),method="lm" ,se=FALSE, color='black', linetype = 'dashed') +
  facet_wrap(~Artist)

ggplot(data, aes(Q1, Q3 )) +
  geom_smooth(aes(x= Q1, y= Q3, group = Pair, color=factor(Pair)),method="lm" ,se=FALSE) +
  geom_smooth(aes(x= Q1, y= Q3),method="lm" ,se=FALSE, color='black', linetype = 'dashed') +
  facet_wrap(~Artist)

ggplot(data, aes(Q1b, Q3b )) +
  geom_smooth(aes(x= Q1a, y= Q3b, group = Pair, color=factor(Pair)),method="lm" ,se=FALSE) +
  geom_smooth(aes(x= Q1a, y= Q3b),method="lm" ,se=FALSE, color='black', linetype = 'dashed') +
  facet_wrap(~Artist)


ggplot(data, aes(Q1a, Q3b )) +
  #geom_smooth(aes(x= Q1a, y= Q3b, group = Participant, color=factor(Participant)),method="lm" ,se=FALSE) +
  geom_smooth(aes(x= Q1a, y= Q3b),method="lm" ,se=FALSE, color='black', linetype = 'dashed') +
  facet_wrap(~Condition)

ggplot(data, aes(Q1a, Q3b )) +
  #geom_smooth(aes(x= Q1a, y= Q3b, group = Participant, color=factor(Participant)),method="lm" ,se=FALSE) +
  geom_smooth(aes(x= Q1a, y= Q3b),method="lm" ,se=FALSE, color='black', linetype = 'dashed') +
  facet_wrap(~Music_mode)

ggplot(data, aes(Q1a, Q3b )) +
  #geom_smooth(aes(x= Q1a, y= Q3b, group = Participant, color=factor(Participant)),method="lm" ,se=FALSE) +
  geom_smooth(aes(x= Q1a, y= Q3b),method="lm" ,se=FALSE, color='black', linetype = 'dashed') +
  facet_wrap(~Palo)
h                                                                                          
ggplot(data, aes(Q1a, Q3b )) +
  #geom_smooth(aes(x= Q1a, y= Q3b, group = Participant, color=factor(Participant)),method="lm" ,se=FALSE) +
  geom_smooth(aes(x= Q1a, y= Q3b, group = Artist, color = factor(Artist)),method="lm", se = FALSE) +
  geom_smooth(aes(group = Artist, color = factor(Artist)), method = "lm", se = TRUE, alpha = 0.3) +
  geom_smooth(aes(x= Q1a, y= Q3b),method="lm", color='black', linetype = 'dashed') + 
  facet_wrap(~Palo)

ggplot(data, aes(Q1a, Q3b )) +
  #geom_smooth(aes(x= Q1a, y= Q3b, group = Participant, color=factor(Participant)),method="lm" ,se=FALSE) +
  geom_smooth(aes(x= Q1a, y= Q3b, group = Palo, color = factor(Palo)),method="lm", se = FALSE) +
  geom_smooth(aes(group = Palo, color = factor(Palo)), method = "lm", se = TRUE, alpha = 0.3) +
  geom_smooth(aes(x= Q1a, y= Q3b),method="lm", color='black', linetype = 'dashed') + 
  facet_wrap(~Condition)

ggplot(data, aes(Q1a, Q3b )) +
  #geom_smooth(aes(x= Q1a, y= Q3b, group = Participant, color=factor(Participant)),method="lm" ,se=FALSE) +
  geom_smooth(aes(x= Q1a, y= Q3b, group = Artist, color = factor(Artist)),method="lm", se = FALSE) +
  geom_smooth(aes(group = Artist, color = factor(Artist)), method = "lm", se = TRUE, alpha = 0.3) +
  geom_smooth(aes(x= Q1a, y= Q3b),method="lm", color='black', linetype = 'dashed') + 
  facet_wrap(~Condition)






library(lme4)
library(lmerTest)
m01  = lmer(Q3b ~   1 + (1 | Participant) + (1 | Pair)  , data = data )
m02  = lmer(Q3b ~   1 + (1 | Participant) , data = data )
m03  = lmer(Q3b ~   1 + (1 | Pair) , data = data )
m04  = lmer(Q3b ~   1 + (1 | Pair:Participant) , data = data )
m05  = lmer(Q3b ~   1 + (1 | Pair/Participant) , data = data )
m06 =  lmer(Q3b ~   1 + (1 | Artist) , data = data )

tab_model(m01, m02, m03, m04, m05,m06, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06"), digits = 5 )

m00  = lmer(Q3b ~   1 + (1 | Participant), data = data )
m01  = lmer(Q3b ~   Q1a + (1 | Participant), data = data )
m02  = lmer(Q3b ~   Q1b + (1 | Participant), data = data )
m03  = lmer(Q3b ~   Palo + (1 | Participant), data = data )
m04  = lmer(Q3b ~   Condition + (1 | Participant), data = data )
m05  = lmer(Q3b ~   Perf_Av + (1 | Participant), data = data )
m06  = lmer(Q3b ~   Abs_Av + (1 | Participant), data = data )
m07 =  lmer(Q3b ~   Q3a + (1 | Participant), data = data )

tab_model(m00, m01, m02, m03, m04, m05,m06, m07,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", "m06", "m07"), digits = 5 )



m01 = lmer(Q3b ~   Q1b +  Condition + (1 | Participant), data = data )
m02 = lmer(Q3b ~   Abs_Av + (1 | Participant), data = data )
m03 = lmer(Q3b ~   Q1b +Abs_Av + (1 | Participant), data = data )
m04 = lmer(Q3b ~   Q1b + Q3a + (1 | Participant), data = data )
m05 = lmer(Q3b ~   Q1a + Q1b + Q3a + (1 | Participant), data = data )
m06 = lmer(Q3b ~   Perf_Av + Q1b + Q3a + (1 | Participant), data = data )
m07 = lmer(Q3b ~   Condition  + Q3a + (1 | Participant), data = data )
tab_model(m01, m02, m03, m04, m05,m06, m07,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07"), digits = 5 )




m01  = lmer(Q3b ~   Q1a + (1 | Participant), data = data )
m02  = lmer(Q3b ~   Q1b + (1 | Participant), data = data )
m03 =  lmer(Q3b ~   Q4b + (1 | Participant) , data = data )
m06  = lmer(Q3b ~   Condition + Q1b + (1 | Participant), data = data )
m07  = lmer(Q3b ~   Perf_Av + (1 | Participant), data = data )
m08 = lmer(Q3b ~   Abs_Av + (1 | Participant), data = data )
tab_model(m01, m02, m03, m04, m05,m06, m07, m08,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07", "m08"), digits = 5 )




m01  = lmer(Q3b ~   Q6a + (1 | Participant), data = data )
m02  = lmer(Q3b ~   Q6b + (1 | Participant), data = data )
m03 =  lmer(Q3b ~   Q5a + (1 | Participant) , data = data )
m04  = lmer(Q3b ~   Q5b + (1 | Participant), data = data )
m05  = lmer(Q3b ~   Q4c + (1 | Participant), data = data )
m06  = lmer(Q3b ~   Q4a + (1 | Participant), data = data )
m07  = lmer(Q3b ~   Q4b + (1 | Participant), data = data )
tab_model(m01, m02, m03, m04, m05, m06, m07,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07"), digits = 5 )


m01  = lmer(Q3b ~   Q4c + Q4a + (1 | Participant), data = data )
m02 = lmer(Q3b ~   Q6a + Q5b + (1 | Participant), data = data )
m03 = lmer(Q3b ~   Q6a + Q5b + Q4c + (1 | Participant), data = data )
m04 = lmer(Q3b ~   Q6a + Q5b + Q4c + Q4b + (1 | Participant), data = data )
m05 = lmer(Q3b ~   Q6a + Q5b + Q4c + Q4b + Q4a + (1 | Participant), data = data )
m06 = lmer(Q3b ~   Q6a + Q5b + Q4c + Q4b + Q5a + (1 | Participant), data = data )
m07 = lmer(Q3b ~   Q6a + Q5b + Q4c + Q6b + (1 | Participant), data = data )
tab_model(m01, m02, m03, m04, m05,m06, m07,m08,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07"), digits = 5 )




m01 = lmer(Q3b ~   Q6a + Q5b + Q4c + (1 | Participant), data = data )
m02 = lmer(Q3b ~   Q6a + Q5b + Q4c + Q1b + (1 | Participant), data = data )
m03 = lmer(Q3b ~   Q6a  + Q4c + Q1b + (1 | Participant), data = data )
m04 = lmer(Q3b ~   Q6a  + Q1b + (1 | Participant), data = data )
m05 = lmer(Q3b ~   Q6a  + Q4c + Q3a + (1 | Participant), data = data )
m06 = lmer(Q3b ~   Q6a  + Q4c + Q3a +  Q1b + (1 | Participant), data = data )
m07 = lmer(Q3b ~   Q6a  + Q3a +  Q1b + (1 | Participant), data = data )
tab_model(m01, m02, m03, m04, m05,m06, m07,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07"), digits = 5 )



m01  = lmer(Q3b ~   Q4a + (1 | Participant), data = data )
m02  = lmer(Q3b ~   Palo * Condition + (1 | Participant), data = data )
m03  = lmer(Q3b ~   Q4a + Condition + (1 | Participant), data = data )
m04  = lmer(Q3b ~   Q4a + Condition + Q4b + (1 | Participant), data = data )
m05  = lmer(Q3b ~   Q4a + Condition + Q1a + (1 | Participant), data = data )
m06  = lmer(Q3b ~   Q4a + Condition + Q1b + (1 | Participant), data = data )
m07  = lmer(Q3b ~   Q4a  + Q4c +  (1 | Participant), data = data )

tab_model(m01, m02, m03, m04, m05,m06, m07,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07"), digits = 5 )


tab_model(m01, m02, m03, m04, m05,m06, m07,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07"), digits = 5 )



m01  = lmer(Q3b ~   Q4b + (1 | Participant) + (1 | Pair)  , data = data )
m02  = lmer(Q3b ~   Q4b + (1 | Participant) , data = data )
m03  = lmer(Q3b ~   Q4b + (1 | Pair) , data = data )
m04  = lmer(Q3b ~   Q4b + (1 | Pair:Participant) , data = data )
m05  = lmer(Q3b ~   Q4b + (1 | Pair/Participant) , data = data )

tab_model(m01, m02, m03, m04, m05, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05"), digits = 5 )


m01  = lmer(Q3b ~   Q4a + (1 | Participant) , data = data )
m02  = lmer(Q3b ~   Q4a + Condition + (1 | Participant) , data = data )
m03  = lmer(Q3b ~   Q4a + Palo + (1 | Participant) , data = data )
m04  = lmer(Q3b ~   Q4a + Condition + (1 | Participant) , data = data )
m05 = lmer(Q3b~   Q4a + Condition + (1 | Participant)+ (1 | Pair) , data = data )


tab_model(m01, m02, m03, m04, m05,m06, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06"), digits = 5 )



m01 = lmer(Q3b ~   Q6a  + Q3a +  Q1b + (1 | Participant), data = data )
m02 = lmer(Q3b ~   Q6a  + Q3a +  Q1b + (1 | Participant) + (1 | Dance_mode), data = data )
m03 = lmer(Q3b ~   Q6a  * Q3a +  Q1b + (1 | Participant), data = data )
m04 = lmer(Q3b ~   Q6a +  Q3a *  Q1b + (1 | Participant), data = data )
m05 = lmer(Q3b ~   Q6a *  Q1b +  Q3a + (1 | Participant), data = data )
m06 = lmer(Q3b ~   Q6a  + Q3a +  Q1b + (1 + Q6a |Participant), data = data )
m07 = lmer(Q3b ~   Q6a  + Q3a +  Q1b + (1 | Participant)+ (1 | Condition), data = data )
tab_model(m01, m02, m03, m04, m05,m06, m07,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07"), digits = 5 )


m01 = lmer(Q3b ~   Q6a + ( Q6a |Participant), data = data )

tab_model(m01, m02, m03, m04, m05,m06, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m6"), digits = 5 )


summary(model)

###### Investigating improvisation and flow ######
ggplot(data, aes(Q1, Q3 )) +
  #geom_smooth(aes(x= Q1a, y= Q3b, group = Participant, color=factor(Participant)),method="lm" ,se=FALSE) +
  geom_smooth(aes(x= Q1, y= Q3, group = Artist, color = factor(Artist)),method="lm", se = FALSE) +
  geom_smooth(aes(group = Artist, color = factor(Artist)), method = "lm", se = TRUE, alpha = 0.3) +
  geom_smooth(aes(x= Q1, y= Q3),method="lm", color='black', linetype = 'dashed')+ 
  labs(x = "Improvisation", y = "Flow") +
  theme(
    axis.title = element_text(size = 18),  # Adjust the font size here
    axis.text = element_text(size = 12)    # Adjust the font size of tick labels if needed
  )


ggplot(data, aes(Q1b, Q3 )) +
  #geom_smooth(aes(x= Q1a, y= Q3b, group = Participant, color=factor(Participant)),method="lm" ,se=FALSE) +
  geom_smooth(aes(x= Q1b, y= Q3, group = Participant, color = factor(Participant)),method="lm", se = FALSE) +
    geom_smooth(aes(x= Q1b, y= Q3),method="lm", color='black', linetype = 'dashed') 




m01 = lmer(Q3 ~  Q1 + (1 | Participant), data = data )
m02 = lmer(Q3 ~  Q1a +  (1 | Participant) , data = data )
m03 = lmer(Q3 ~  Q1b +  (1 | Participant) , data = data )
m04 = lmer(Q3a ~  Q1 +  (1 | Participant), data = data )
m05 = lmer(Q3a ~  Q1a +  (1 | Participant) , data = data )
m06 = lmer(Q3a ~  Q1b +  (1 | Participant), data = data )
m07 = lmer(Q3b ~  Q1 +  (1 | Participant) , data = data )
m08 = lmer(Q3b ~  Q1a +  (1 | Participant), data = data )
m09 = lmer(Q3b ~  Q1b +  (1 | Participant) , data = data )

tab_model(m01, m02, m03, m04, m05,m06, m07,m08, m09,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07", "m08", "m09"), digits = 5 )

m01 = lmer(Q3 ~  Q1b + ( 1 | Participant) , data = data )
m02 = lmer(Q3 ~  Q1b + ( 1 | Participant)  + ( 1 | Condition), data = data )
m03 = lmer(Q3 ~  Q1b + ( 1 | Participant)  + ( 1 | Music_mode), data = data )
m04 = lmer(Q3 ~  Q1b + ( 1 | Participant)  + ( 1 | Artist), data = data )
m05 = lmer(Q3 ~  Q1b* Artist + ( 1 | Participant) , data = data )
m06 = lmer(Q3 ~  Q1b + Artist + ( 1 | Participant) , data = data )
m07 = lmer(Q3 ~  Q1b * Artist + ( 1 | Participant) + ( 1 | Condition) , data = data )
tab_model(m01, m02, m03, m04, m05,m06, m07,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07"), digits = 5 )

m01 = lmer(Q3 ~  Condition + ( 1 | Participant) , data = data )
m02 = lmer(Q3 ~  Music_mode + ( 1 | Participant), data = data )
m03 = lmer(Q3 ~  Dance_mode + ( 1 | Participant), data = data )
m04 = lmer(Q3 ~  Palo + ( 1 | Participant), data = data )
m05 = lmer(Q3 ~  Artist + ( 1 | Participant), data = data )
m06 = lmer(Q3 ~  1 + (1 | Condition) + ( 1 | Participant) , data = data )
m07 = lmer(Q3 ~  1 + (1 |Music_mode) + ( 1 | Participant), data = data )
m08 = lmer(Q3 ~  1 + (1 |Dance_mode) + ( 1 | Participant), data = data )
m09 = lmer(Q3 ~  1 + (1 | Artist) + ( 1 | Participant), data = data )

tab_model(m01, m02, m03, m04, m05,m06, m07,m08, m09,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07", "m08", "m09"), digits = 5 )


m01 = lmer(Q3 ~  1+  Condition + ( 1 | Participant)  , data = data )
m02 = lmer(Q3 ~  1  + ( 1 | Participant)  + (1 |Dance_mode) , data = data )
m03 = lmer(Q3 ~  1+  Condition + ( 1 | Participant)  + (1 |Dance_mode) , data = data )
m04 = lmer(Q3 ~  Q1b +  Condition + ( 1 | Participant), data = data )
m05 = lmer(Q3 ~  Q1b +  (1 |Condition) + ( 1 | Participant), data = data )
m06 = lmer(Q3 ~  Q1b + (Q1b |  Condition )+ ( 1 | Participant), data = data )
tab_model(m01, m02, m03, m04, m05,m06,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06"), digits = 5 )



##### Other subjective variables and flow. #####

m01  = lmer(Q3 ~   1 + (1 | Participant) + (1 | Pair)  , data = data )
m02  = lmer(Q3 ~   1 + (1 | Participant) , data = data )
m03  = lmer(Q3 ~   1 + (1 | Pair) , data = data )
m04  = lmer(Q3 ~   1 + (1 | Pair:Participant) , data = data )
m05  = lmer(Q3 ~   1 + (1 | Pair/Participant) , data = data )
m06 =  lmer(Q3 ~   1 + (1 | Artist) , data = data )
tab_model(m01, m02, m03, m04, m05,m06,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06"), digits = 5 )

m00  = lmer(Q3 ~   Q1b + (1 | Pair:Participant), data = data )
m01  = lmer(Q3 ~   Q4a + (1 | Pair:Participant), data = data )
m02  = lmer(Q3 ~   Q4b + (1 | Pair:Participant), data = data )
m03  = lmer(Q3 ~   Q5a + (1 | Pair:Participant), data = data )
m04  = lmer(Q3 ~   Q5b + (1 | Pair:Participant), data = data )
m05  = lmer(Q3 ~   Q6a + (1 | Pair:Participant), data = data )
m06  = lmer(Q3 ~   Q6b + (1 | Pair:Participant), data = data )
m07 =  lmer(Q3 ~   Q4c + (1 | Pair:Participant), data = data )
m08  = lmer(Q3 ~   Q4 + (1 | Pair:Participant), data = data )
m09  = lmer(Q3 ~   Q5 + (1 | Pair:Participant), data = data )
m10  = lmer(Q3 ~   Q6 + (1 | Pair:Participant), data = data )

tab_model(m00, m01, m02, m03, m04, m05,m06, m07, m08, m09, m10,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", "m06", "m07", "m08", "m09", "m10"), digits = 5 )

m00  = lmer(Q3 ~   Q1b + (1 | Participant), data = data )
m01  = lmer(Q3 ~   Q4a + (1 | Participant), data = data )
m02  = lmer(Q3 ~   Q4b + (1 | Participant), data = data )
m03  = lmer(Q3 ~   Q5a + (1 | Participant), data = data )
m04  = lmer(Q3 ~   Q5b + (1 | Participant), data = data )
m05  = lmer(Q3 ~   Q6a + (1 | Participant), data = data )
m06  = lmer(Q3 ~   Q6b + (1 | Participant), data = data )
m07 =  lmer(Q3 ~   Q4c + (1 | Participant), data = data )
m08  = lmer(Q3 ~   Q4 + (1 | Participant), data = data )
m09  = lmer(Q3 ~   Q5 + (1 | Participant), data = data )
m10  = lmer(Q3 ~   Q6 + (1 | Participant), data = data )

tab_model(m00, m01, m02, m03, m04, m05,m06, m07, m08, m09, m10,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", "m06", "m07", "m08", "m09", "m10"), digits = 5 )



m00  = lmer(Q3 ~   Q4 + (1 | Pair:Participant), data = data )
m01  = lmer(Q3 ~   Q5 + (1 | Pair:Participant), data = data )
m02  = lmer(Q3 ~   Q6 + (1 | Pair:Participant), data = data )
m03  = lmer(Q3 ~   Q4 +Q5 +  (1 | Pair:Participant), data = data )
m04  = lmer(Q3 ~   Q5 + Q6 +  (1 | Pair:Participant), data = data )
m05  = lmer(Q3 ~   Q5+ Q6 + Q4 +(1 | Pair:Participant), data = data )
m06  = lmer(Q3 ~   Q4+ Q6 +(1 | Pair:Participant), data = data )
m07  = lmer(Q3 ~   Q6a + Q4 + (1 | Pair:Participant), data = data )
m08  = lmer(Q3 ~   Q6b + Q4 + (1 | Pair:Participant), data = data )

tab_model(m00, m01, m02, m03, m04, m05,m06, m07, m08,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", "m06", "m07", "m08"), digits = 5 )


m01  = lmer(Q3 ~   Q6 + Q4 + (1 | Pair:Participant), data = data )
m02  = lmer(Q3 ~   Q6 + Q4 + Q5a +  (1 | Pair:Participant), data = data )
m03  = lmer(Q3 ~   Q6 + Q4 + Q5b +  (1 | Pair:Participant), data = data )
m04  = lmer(Q3 ~   Q6 + Q4a + Q5b +  (1 | Pair:Participant), data = data )
m05  = lmer(Q3 ~   Q6 + Q4b + Q5b +  (1 | Pair:Participant), data = data )
m06  = lmer(Q3 ~   Q6 + Q4c + Q5b +  (1 | Pair:Participant), data = data )
m07  = lmer(Q3 ~   Q6a + Q4c + Q5b +  (1 | Pair:Participant), data = data )
m08  = lmer(Q3 ~   Q6b + Q4c + Q5b +  (1 | Pair:Participant), data = data )

tab_model(m00, m01, m02, m03, m04, m05,m06, m07, m08,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", "m06", "m07", "m08"), digits = 5 )

m00 =  lmer(Q3 ~   Q1b  + (Q1b|Condition) + (1 | Pair:Participant), data = data )
m01  = lmer(Q3 ~   Q6 + Q4a + Q5b +  (1 | Pair:Participant), data = data )
m02  = lmer(Q3 ~   Q1b + Q6 + Q4a + Q5b +  (1 | Pair:Participant), data = data )
m03  = lmer(Q3 ~   Q1b + Q6 + Q4a + Q5b + (Q1b|Condition) + (1 | Pair:Participant), data = data )
m04  = lmer(Q3 ~   Q1b + Q6 + Q4a  + (1 |Condition) + (1 | Pair:Participant), data = data )
m05  = lmer(Q3 ~   Q1b + Q6 + Q4a  + (1 |Condition) + (1 |Participant), data = data )
m06  = lmer(Q3 ~   Q1b + Q6 + Q4a  + (1 |Participant), data = data )
m07  = lmer(Q3 ~   Q1b + Q6 + Q4a  + (Q4a |Condition) + (1 |Participant), data = data )
m08  = lmer(Q3 ~   Q1b + Q6 + Q4a  + Perf_Av + (Q4a |Condition) + (1 |Participant), data = data )
tab_model(m00, m01, m02, m03, m04, m05,m06, m07, m08,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", "m06", "m07", "m08"), digits = 5 )

m00 =  lmer(Q3 ~   Q1b  + (Q1b|Condition) + (1 | Pair:Participant), data = data )
m01 =  lmer(Q3 ~   Q1b  +  Perf_Av + (1|Condition) + (1 | Pair:Participant), data = data )
m02 =  lmer(Q3 ~   Q1b  +  Abs_Av + (1|Condition) + (1 | Pair:Participant), data = data )
m03 =  lmer(Q3 ~   Q1b  +  Abs_Av + (1|Condition) + (1 | Pair:Participant), data = data )
tab_model(m00, m01, m02, m03, m04, m05,m06, m07, m08,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", "m06", "m07", "m08"), digits = 5 )

m00  = lmer(Q3 ~   Q1b + Q6 + Q4a  + (1 |Participant), data = data )
m01  = lmer(Q3 ~   Q1b + Q6 + Q4a  + Condition + (1 |Participant), data = data )
tab_model(m00, m01, m02, m03, m04, m05,m06, m07, m08,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", "m06", "m07", "m08"), digits = 5 )

### Iteration 3 ####
subset_data <- subset(data, Palo == "R2")
m00 = lmer(Q1~ Condition + (1| Participant), data = data  )
m01 =  lmer(Q1~ Condition + (1| Pair), data = data  )
m02 = lmer(Q1~ Artist + (1 | Participant), data = data  )
m03 =  lmer(Q1~ Artist * Condition + (1| Participant), data = data  )
m04 =  lmer(Q1~ Palo  + (1| Participant), data = data  )
tab_model(m00, m01,m02,m03, m04,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02", "m03", "m04"), digits = 5 )

m00 = lmer(Q3~ Condition + (1| Participant), data = data  )
m01 =  lmer(Q3~ Condition + (1| Pair), data = data  )
m02 = lmer(Q3~ Artist + (1 | Participant), data = data  )
m03 =  lmer(Q3~ Artist * Condition + (1| Participant), data = data  )
m04 =  lmer(Q3~  Palo + (1  | Participant), data = data  )
tab_model(m00, m01,m02,m03, m04,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02", "m03", "m04"), digits = 5 )



m01 = lmer(Q3 ~  Q1b * Artist + ( 1 | Participant) + ( 1 | Condition) , data = data )
m02 = lmer(Q3 ~  Q1b + GDSI + GMSI + (  1 | Participant)  , data = data )
m03 = lmer(Q3 ~  Q1b + GDSI + (  GDSI | Participant)  , data = data )
m04 = lmer(Q3 ~  Q1b + Q6 + Q4a + ( 1 | Participant) , data = data )
m05 = lmer(Q3 ~  Q1b* Artist + Q6 + Q4a + ( 1 | Participant) + ( 1 | Condition) , data = data )
m06 = lmer(Q3 ~  Q1b * GMSI + (  1 | Participant)  , data = data )
m07 = lmer(Q3 ~  Q1b + GDSI + Q6 + Q4a + ( 1 | Participant) , data = data )
tab_model(m01, m02, m03,m04, m05, m06,m07, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02", "m03", "m04", "m05", "m06", "m07"), digits = 5 )

m01 = lmer(Q3 ~  Q1b * Artist + ( 1 | Participant) + ( 1 | Condition) , data = data )
m02 = lmer(Q3 ~  Q1b + Q6 + ( 1 | Participant) + ( 1 | Condition) , data = data )
tab_model(m01, m02, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02"), digits = 5 )


m01 = lmer(Q3_normalized ~  Q1b_normalized + ( 1 | Participant) , data = data )
m02 = lmer(Q3_normalized ~  Q1b_normalized * Artist + ( 1 | Participant) , data = data )
tab_model(m01, m02, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02"), digits = 5 )

m01 = lmer(Q3_normalized ~  Q1b_normalized + ( 1 | Participant) , data = data )
m02 = lmer(Q3_normalized ~  Q1b_normalized * Artist + ( 1 | Participant) , data = data )
m03 = lmer(Q3_norm_part ~  Q1b_norm_part + ( 1 | Participant) , data = data )
m04 = lmer(Q3_norm_part ~  Q1b_norm_part * Artist + ( 1 | Participant) , data = data )
tab_model(m01, m02, m03, m04,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02", "m03", "m04"), digits = 5 )


##### PETER KELLER's SUGGESTION to DO THIS ON DATA
shapiro_test(data) #you want to have p-value above threshold
bc_trans_async <- BoxCoxTrans (data)

#look at correlation between the old data and new data (spearman), if it changes the order, you want to have a curve.
# caret library
# if the transformation does not make any difference, use the original data obviously. 
# Plot raw data and partial residuals of model



### Looking a bit further into the dataset 

library(ggplot2)

# Create a violin plot
ggplot(data, aes(x = Artist, y = Q3)) +
  geom_violin(fill = "lightblue", color = "blue") +
  geom_jitter(width = 0.1, alpha = 0.5) +  # Add jittered points for individual data points
  labs(x = "Artist", y = "Q3") +  # Label the axes
  ggtitle("Distribution of Q3 by Artist") +  # Add a title
  theme_minimal()  # Choose a minimal theme (optional)

ggplot(data, aes(x = Artist, y = Q3)) +
  geom_violin(fill = "lightblue", color = "blue") +
  geom_boxplot(width = 0.15, fill = "white", color = "black", outlier.shape = NA) +  # Add boxplot
  geom_jitter(width = 0.1, alpha = 0.5) +  # Add jittered points for individual data points
  labs(x = "Artist", y = "Q3") +
  ggtitle("Distribution of Q3 by Artist") +
  theme_minimal()

library(patchwork)

ochre_yellow <- "#e3c360ff"  # You can adjust the color code to your preference

# Create a plot for Q1 with different colors for "P" and "G"
plot_q1_1 <- ggplot(data, aes(x = Artist, y = Q1, fill = Artist)) +
  geom_violin(color = "black") +
  labs(x = "Artist", y = "Q1") +
  ggtitle("Distribution of Q1 by Artist") +
  geom_boxplot(width = 0.15, fill = "white", color = "black", outlier.shape = NA) +
  geom_jitter(width = 0.1, alpha = 0.5) +
  scale_fill_manual(values = c("G" = "lightblue", "P" = ochre_yellow)) +  # Specify colors
  theme_minimal()

# Create a plot for Q3 with different colors for "P" and "G"
plot_q3_1 <- ggplot(data, aes(x = Artist, y = Q3, fill = Artist)) +
  geom_violin(color = "black") +
  labs(x = "Artist", y = "Q3") +
  ggtitle("Distribution of Q3 by Artist") +
  geom_boxplot(width = 0.15, fill = "white", color = "black", outlier.shape = NA) +
  geom_jitter(width = 0.1, alpha = 0.5) +
  scale_fill_manual(values = c("G" = "lightblue", "P" = ochre_yellow)) +  # Specify colors
  theme_minimal()

# Arrange the plots side by side
final_plot <- plot_q1_1 + plot_q3_1

# Display the final plot
final_plot



# What happens if we normalize the data. Looks like each participant will have a different relationship based on normalizing their data. 
# Or do we normalize over the whole set?
library(dplyr)

# Calculate the mean and standard deviation of Q1
mean_Q1b <- mean(data$Q1b, na.rm = TRUE)
sd_Q1b <- sd(data$Q1b, na.rm = TRUE)

# Create a new column with normalized values
data <- data %>%
  mutate(Q1b_normalized = (Q1b - mean_Q1b) / sd_Q1b)

# Calculate the mean and standard deviation of Q3
mean_Q3 <- mean(data$Q3, na.rm = TRUE)
sd_Q3 <- sd(data$Q1, na.rm = TRUE)

# Create a new column with normalized values
data <- data %>%
  mutate(Q3_normalized = (Q3 - mean_Q3) / sd_Q3)




# Create a plot for Q1 with different colors for "P" and "G"
plot_q1 <- ggplot(data, aes(x = Artist, y = Q1b_normalized, fill = Artist)) +
  geom_violin(color = "black") +
  labs(x = "Artist", y = "Q1") +
  ggtitle("Distribution of Q1 by Artist") +
  geom_boxplot(width = 0.15, fill = "white", color = "black", outlier.shape = NA) +
  geom_jitter(width = 0.1, alpha = 0.5) +
  scale_fill_manual(values = c("G" = "lightblue", "P" = ochre_yellow)) +  # Specify colors
  theme_minimal()

# Create a plot for Q3 with different colors for "P" and "G"
plot_q3 <- ggplot(data, aes(x = Artist, y = Q1b_norm_part, fill = Artist)) +
  geom_violin(color = "black") +
  labs(x = "Artist", y = "Q3") +
  ggtitle("Distribution of Q3 by Artist") +
  geom_boxplot(width = 0.15, fill = "white", color = "black", outlier.shape = NA) +
  geom_jitter(width = 0.1, alpha = 0.5) +
  scale_fill_manual(values = c("G" = "lightblue", "P" = ochre_yellow)) +  # Specify colors
  theme_minimal()

# Arrange the plots side by side
final_plot <- plot_q1 + plot_q3 

# Display the final plot
final_plot



library(dplyr)

# Calculate the mean Q1b per Participant
data <- data %>%
  group_by(Participant) %>%
  mutate(Q1b_mean = mean(Q1b, na.rm = TRUE)) %>%
  ungroup()

# Create a new column with Q1b normalized per Participant
data <- data %>%
  mutate(Q1b_norm_part = Q1b / Q1b_mean)


# Calculate the mean Q3 per Participant
data <- data %>%
  group_by(Participant) %>%
  mutate(Q3_mean = mean(Q3, na.rm = TRUE)) %>%
  ungroup()

# Create a new column with Q1b normalized per Participant
data <- data %>%
  mutate(Q3_norm_part = Q3 / Q3_mean)




