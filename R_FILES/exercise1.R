library(lme4)
library(lmerTest)
#load("~/RITMO/Mixed_Models/mixed-models-with-r-workshop-2019-master/data/gpa.RData")
data1 <- read.csv("~/Ritmo/R_FILES/DuringExperiments_Edited.csv", header=TRUE, stringsAsFactors=FALSE)
data2 <- read.csv("~/CODE/RITMO/PILOT_SEV_APRIL_2022/output/Ratings_Entropy.csv")
data3 <- read.csv("~/CODE/RITMO/PILOT_SEV_APRIL_2022/output/ratingsAnalysis/DuringExperiments_Oslo.csv")
data4 <- read.csv('~/CODE/RITMO/MIR/output/Average_rms_ent.csv')
data5 <- read.csv("~/CODE/RITMO/PILOT_SEV_APRIL_2022/output/ratingsAnalysis/DuringExperiments_Edited.csv")
# Linear model
#gpa_lm = lm(gpa ~ occasion, data = gpa)
#summary(gpa_lm)

#data_lm = lm(Q1a ~ Dance, data = data1)
#summary(data_lm)


# Mixed model
#gpa_mixed = lmer(gpa ~ occasion + (1 | student), data = gpa)
#summary(gpa_mixed)
#confint(gpa_mixed)
data1$Dance_mode<-as.factor(data1$Dance_mode)
data1$Palo <-as.factor(data1$Palo)
data_mixed = lmer(Q1a ~ Dance_mode + (1 | Participant), data = data1)
#data_mixed = lmer(Q1a ~ Q3a + (1 | Participant),  data = data1)
summary(data_mixed)


#data2$Value<- as.factor(data2$Value)
data2$Dance_mode<- as.factor(data2$Dance_mode)
data2$Palo <- as.factor(data2$Palo)
data2$Participant <- as.factor(data2$Participant)
data_mixed_2 = lmer(Q1b ~ Palo + (1 | Participant),  data = data2)
summary(data_mixed_2)


#Dataset 3 Analysis
data3$Dance_mode<- as.factor(data3$Dance_mode)
data3$Palo <- as.factor(data3$Palo)
data3$Participant <- as.factor(data3$Participant)
data_mixed_3 = lmer(Q1b~ Dance_mode    +   (1 | Participant),  data = data3)
data_mixed_3b = lmer(Q1b  ~ Dance_mode + Q3b   + (1 | Participant),  data = data3)
AIC(data_mixed_3,data_mixed_3b)
summary(data_mixed_3)
summary(data_mixed_3b)

# Model comparison with AIC
# The smallest one is the best. 
# When you have more variables you will be able to explain more. So you need to check that the complexity is justified.
# Since you are comparing two models of different DOF. Need to check the models complexity. 
# The less complexity the better. 
AIC(data_mixed_3,data_mixed_3b)

#Dataset 5 Analysis
data5$Dance_mode<- as.factor(data5$Dance_mode)
data5$Palo <- as.factor(data5$Palo)
data5$Participant <- as.factor(data5$Participant)
data_mixed_5 = lmer(Abs_Av~ Dance_mode + (1 | Participant),  data = data5)
summary(data_mixed_5)


#Dataset 4 Analysis
data4$Dance_mode <- as.factor(data4$Dance_mode)
data4$Palo <- as.factor(data4$Palo)
data4$Participant <- as.factor(data4$Participant)
data_mixed_4 = lmer(Entropy_Av~ Dance_mode + (1 | Participant),  data = data4)
summary(data_mixed_4)


