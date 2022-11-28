library(lme4)
library(lmerTest)
#load("~/RITMO/Mixed_Models/mixed-models-with-r-workshop-2019-master/data/gpa.RData")
data1 <- read.csv("~/Ritmo/R_FILES/DuringExperiments_Edited.csv", header=TRUE, stringsAsFactors=FALSE)
data2 <- read.csv("~/CODE/RITMO/PILOT_SEV_APRIL_2022/output/Ratings_Entropy.csv")
data3 <- read.csv("~/CODE/RITMO/PILOT_SEV_APRIL_2022/output/ratingsAnalysis/DuringExperiments_Oslo.csv")
data4 <- read.csv('~/CODE/RITMO/MIR/output/Average_rms_ent.csv')
data5 <- read.csv("~/CODE/RITMO/PILOT_SEV_APRIL_2022/output/ratingsAnalysis/DuringExperiments_Edited.csv")

#data 03102022
#data6 <- read.csv("~/CODE/RITMO/PILOT_SEV_APRIL_2022/output/ratingsAnalysis/DuringExperiments_Sevilla_October_2022.csv")
#data7 <- read.csv("~/CODE/RITMO/PILOT_SEV_APRIL_2022/output/ratingsAnalysis/DuringExperiments_Sevilla_October_2022_DropW.csv")

#data 06102022
data6 <- read.csv("~/CODE/RITMO/PILOT_SEV_APRIL_2022/output/ratingsAnalysis/DuringExperiments_Sevilla_October_2022.csv")
data7 <- read.csv("~/CODE/RITMO/PILOT_SEV_APRIL_2022/output/ratingsAnalysis/DuringExperiments_Sevilla_October_2022_DropW.csv")

dataSub <- subset(data3, Dance_mode!="D0")
#dataEntropy <- read.csv("~/CODE/RITMO/ENTROPY/output/mean/means.csv")

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
data3$Dance_mode <- relevel(data3$Dance_mode, "D6")
data3$Palo <- relevel(data3$Palo, "R2")
data3$Participant <- as.factor(data3$Participant)
data_mixed_3 = lmer(Q1b~ Dance_mode    +   (1 | Participant),  data = data3)
data_mixed_3b = lmer(Q1b  ~ Dance_mode + Palo   + (1 | Participant),  data = data3)
data_mixed_3c = lmer(Q1b  ~ Dance_mode * Palo   + (1 | Participant),  data = data3)
AIC(data_mixed_3,data_mixed_3b)
summary(data_mixed_3)
summary(data_mixed_3b)
summary(data_mixed_3c)


### Latest version of Data ALL
data6$Dance_mode<- as.factor(data6$Dance_mode)
data6$Palo <- as.factor(data6$Palo)
data6$Dance_mode <- relevel(data6$Dance_mode, "D6")
data6$Palo <- relevel(data6$Palo, "R2")
data6$Participant <- as.factor(data6$Participant)
data_mixed_6 = lmer(Q1b~ Dance_mode    +   (1 | Participant),  data = data6)
summary(data_mixed_6)
data_mixed_6b = lmer(Q1b  ~ Dance_mode + Palo   + (1 | Participant),  data = data6)
data_mixed_6c = lmer(Q1b  ~ Dance_mode * Palo   + (1 | Participant),  data = data6)
AIC(data_mixed_6,data_mixed_6b)
summary(data_mixed_6b)
summary(data_mixed_6c)


### Latest version of Data without W
data7$Dance_mode<- as.factor(data7$Dance_mode)
data7$Palo <- as.factor(data7$Palo)
data7$Dance_mode <- relevel(data7$Dance_mode, "D6")
data7$Palo <- relevel(data7$Palo, "R2")
data7$Participant <- as.factor(data7$Participant)
data_mixed_7 = lmer(Q1a~ Dance_mode + Q3b    +   (1 | Participant),  data = data7)
summary(data_mixed_7)
data_mixed_7b = lmer(Q1b  ~ Dance_mode + Palo   + (1 | Participant),  data = data7)
data_mixed_7c = lmer(Q1b  ~ Dance_mode * Palo   + (1 | Participant),  data = data7)
AIC(data_mixed_7,data_mixed_7b)
summary(data_mixed_7b)
summary(data_mixed_7c)


### Entropy data simple analysis mean
dataEntropy <- read.csv("~/CODE/RITMO/PILOT_SEV_APRIL_2022/output/ratingsAnalysis/DuringExperiments_Sevilla_06102022_DropW_Entropy.csv")
dataEntropy$Dance_mode <- as.factor(dataEntropy$Dance_mode)
dataEntropy$Palo <- as.factor(dataEntropy$Palo)
dataEntropy$Q3bF <- as.factor(dataEntropy$Q3b)
dataEntropy$Music_mode <- as.factor(dataEntropy$Music_mode)
dataEntropy$Dance_mode <- relevel(dataEntropy$Dance_mode, "D6")
dataEntropy$Music_mode <- relevel(dataEntropy$Music_mode, "M6")
dataEntropy$Participant <- as.factor(dataEntropy$Participant)
model_entropy = lmer(Q1a ~ Q3a + (1 | Participant) , data = dataEntropy )
model_entropy_2 = lmer(Q1b ~ Q3b + I(Q3b^2) + (1 | Participant), data = dataEntropy)
summary(model_entropy)
summary(model_entropy_2)
model_entropy_mixed = lmer(Q1a ~ Dance_mode  + Abs_Av + (1 | Participant), data = dataEntropy )
AIC(model_entropy,model_entropy_2)
summary(model_entropy_mixed)


### Entropy data simple analysis mean
dataELAN <- read.csv("~/CODE/RITMO/ENTROPY/output/ELAN/Testing_All_ELAN_2.csv")
dataELAN$Dance_mode <- as.factor(dataELAN$Dance_mode)
dataELAN$Palo <- as.factor(dataELAN$Palo)
dataELAN$Music_mode <- as.factor(dataELAN$Music_mode)
dataELAN$Dance_mode <- relevel(dataELAN$Dance_mode, "D6")
dataELAN$Music_mode <- relevel(dataELAN$Music_mode, "M6")
dataELAN$Participant <- as.factor(dataELAN$Participant)
dataELAN$Baile <- as.factor(dataELAN$Baile_Level)
dataELAN$Guitarra <- as.factor(dataELAN$Guitarra_Level)
dataELAN$Guitarra <- relevel(dataELAN$Guitarra, "A1")
dataELAN$Baile <- relevel(dataELAN$Baile, "Z1")
dataELAN$Dance_Imp <- as.factor(dataELAN$Dance_Imp)
dataELAN$Dance_Imp <- relevel(dataELAN$Dance_Imp, "DC")
dataELAN$Music_Imp <- as.factor(dataELAN$Music_Imp)
dataELAN$Music_Imp <- relevel(dataELAN$Music_Imp, "MC")
dataELAN$ImpLevel <- as.factor(dataELAN$Assigned_Cat)
model_entropy = lmer(Imp_Av ~ Guitarra + (1 | Participant) , data = dataELAN )
summary(model_entropy)
model_entropy_2 = lmer(Q1b ~ Q3b + I(Q3b^2) + (1 | Participant), data = dataEntropy)

summary(model_entropy_2)
model_entropy_mixed = lmer(Q1a ~ Dance_mode  + Abs_Av + (1 | Participant), data = dataEntropy )
AIC(model_entropy,model_entropy_2)
summary(model_entropy_mixed)






dataInterval <- read.csv("~/CODE/RITMO/ENTROPY/output/ELAN/LZ_CTW_Intervals.csv")
dataInterval$Dance_mode <- as.factor(dataInterval$Dance_mode)
dataInterval$Palo <- as.factor(dataInterval$Palo)
# dataEntropy$Q3bF <- as.factor(dataEntropy$Q3b)
dataInterval$Music_mode <- as.factor(dataInterval$Music_mode)
dataInterval$Assigned_Cat <- as.factor(dataInterval$Assigned_Cat)
dataInterval$Dance_mode <- relevel(dataInterval$Dance_mode, "D6")
dataInterval$Music_mode <- relevel(dataInterval$Music_mode, "M6")
#dataInterval$Participant <- as.factor(dataInterval$Participant)
model_entropy = lmer(Q1b ~ Q3b + (1 | Participant), data = dataEntropy )
model_entropy_2 = lmer(LZ_Av ~ Imp_Av + (1 | Dance_mode), data = dataInterval)
summary(model_entropy)
summary(model_entropy_2)
model_entropy_mixed = lmer(Q1a ~ Dance_mode  + Abs_Av + (1 | Participant), data = dataEntropy )
AIC(model_entropy,model_entropy_2)
summary(model_entropy_mixed)



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


