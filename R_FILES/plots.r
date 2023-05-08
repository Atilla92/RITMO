# Script for plotting the data and fitting models on latest dataset. 


# Import libraries
library(lme4)
library(performance)
library(tidyverse)

# LAUSANNE
dataELAN <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/all_experiments_095/08052023_all_experiments_drums_guitar_zd.csv')

# ALl analysis
dataELAN$Dance_mode <- as.factor(dataELAN$Dance_mode)
dataELAN$Condition <- as.factor(dataELAN$Condition)
dataELAN$Condition <- relevel(dataELAN$Condition, "D6_M6")
dataELAN$Dance_mode <- factor(dataELAN$Dance_mode, levels = c("D6", 'D5', 'D1'))
dataELAN$Condition <- factor(dataELAN$Condition, levels = c('D6_M6', 'D5_M6', 'D1_M6', 'D5_M5', 'D1_M1'))
#dataELAN$Condition_order <- as.factor(dataELAN$Condition_order)
dataELAN$Palo <- as.factor(dataELAN$Palo)
dataELAN$Music_mode <- as.factor(dataELAN$Music_mode)
dataELAN$Music_mode <- factor(dataELAN$Music_mode, levels = c("M6",'M5','M1'))
dataELAN$Participant <- as.factor(dataELAN$Participant)
dataELAN$Pair <- as.factor(dataELAN$Pair)

#Micro Analysis
dataELAN$Baile <- as.factor(dataELAN$Baile_Level)
dataELAN$Guitarra <- as.factor(dataELAN$Guitarra_Level)
dataELAN$Guitarra <- relevel(dataELAN$Guitarra, "A1")
dataELAN$Baile <- relevel(dataELAN$Baile, "Z1")
dataELAN$Dance_Imp <- as.factor(dataELAN$Dance_Imp)
dataELAN$Dance_Imp <- relevel(dataELAN$Dance_Imp, "DC")
dataELAN$Music_Imp <- as.factor(dataELAN$Music_Imp)
dataELAN$Music_Imp <- relevel(dataELAN$Music_Imp, "MC")
dataELAN$ImpLevel <- as.factor(dataELAN$Assigned_Cat)
dataELAN$Step <- as.factor(dataELAN$Step)




ggplot(dataELAN, aes(number, Imp_subj ))+geom_point(aes(group=Condition,color=factor(Condition)))+facet_wrap(~Participant) +
  geom_smooth(aes(x= number, y= Imp_subj),method="lm",color='black', se=FALSE)

ggplot(dataELAN, aes(number, Flow_subj ))+geom_point(aes(group=Condition,color=factor(Condition)))+facet_wrap(~Participant) +
  geom_smooth(aes(x= number, y= Imp_subj),method="lm",color='black', se=FALSE)


ggplot(dataELAN, aes(number, Flow_subj ))+geom_point(aes(group=Condition,color=factor(Condition)))+ facet_wrap(~Pair) +
  geom_smooth(aes(x= number, y= Flow_subj, group=Condition, color=factor(Condition)),method="lm", se=FALSE)



ggplot(dataELAN, aes(Imp_avg, Flow_avg ))+geom_point(aes(group=Condition,color=factor(Condition)))+ facet_wrap(~Pair) +
  geom_smooth(aes(x= Imp_avg, y= Flow_avg, group =Condition, color = Condition),method="lm" ,se=FALSE)

ggplot(dataELAN, aes(Q1a, Q3a , group =Condition, color = Condition))+
  geom_smooth(aes(x= Imp_avg, y= Flow_avg, group =Condition, color = Condition),method="lm" ,se=FALSE)
#Condition effect on slope variance also on intercept. 

ggplot(dataELAN, aes(Flow_avg, LZ_avg , group =Condition, color = Condition))+
  geom_smooth(aes(x= Flow_avg, y= LZ_avg, group =Condition, color = Condition),method="lm" ,se=FALSE)

ggplot(dataELAN, aes(Flow_avg, p_LZ_avg , group =Condition, color = Condition))+
  geom_smooth(aes(x= Flow_avg, y= p_LZ_avg, group =Condition, color = Condition),method="lm" ,se=FALSE)

ggplot(dataELAN, aes(Flow_avg, g_LZ_avg , group =Condition, color = Condition))+
  geom_smooth(aes(x= Flow_avg, y= g_LZ_avg, group =Condition, color = Condition),method="lm" ,se=FALSE)
# There seems to be a condition effect on the slope of LZ vs FLow. 
