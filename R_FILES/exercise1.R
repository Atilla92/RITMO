library(lme4)
library(lmerTest)
#load("~/RITMO/Mixed_Models/mixed-models-with-r-workshop-2019-master/data/gpa.RData")
data1 <- read.csv("~/Ritmo/R_FILES/DuringExperiments_Edited.csv", header=TRUE, stringsAsFactors=FALSE)
data2 <- read.csv("~/CODE/RITMO/PILOT_SEV_APRIL_2022/output/Ratings_Entropy.csv")
data3 <- read.csv("~/CODE/RITMO/PILOT_SEV_APRIL_2022/output/DuringExperiments_Oslo.csv")
# Linear model
#gpa_lm = lm(gpa ~ occasion, data = gpa)
#summary(gpa_lm)

#data_lm = lm(Q1a ~ Dance, data = data1)
#summary(data_lm)


# Mixed model
#gpa_mixed = lmer(gpa ~ occasion + (1 | student), data = gpa)
#summary(gpa_mixed)
#confint(gpa_mixed)
#data1$Dance_mode<-as.factor(data1$Dance_mode)
#data1$Palo <-as.factor(data1$Palo)
#data_mixed = lmer(Q1b ~ Dance_mode + Palo + (1 | Participant), data = data1)
#data_mixed = lmer(Q1a ~ Q3a + (1 | Participant),  data = data1)
#summary(data_mixed)


#data2$Value<- as.factor(data2$Value)
data2$Dance_mode<- as.factor(data2$Dance_mode)
data2$Palo <- as.factor(data2$Palo)
data2$Participant <- as.factor(data2$Participant)
data_mixed_2 = lmer(Value ~ Entropy + (1 | Participant),  data = data2)
summary(data_mixed_2)

data3$Dance_mode<- as.factor(data3$Dance_mode)
data3$Palo <- as.factor(data3$Palo)
data3$Participant <- as.factor(data3$Participant)
data_mixed_3 = lmer(Q3b~ Dance_mode + (1 | Participant),  data = data3)
summary(data_mixed_3)
