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

dataELAN_P <- dataELAN[!grepl("G", dataELAN$Participant),] #only dancers
dataELAN_G <- dataELAN[!grepl("P", dataELAN$Participant),] #only dancers






# Looking at flow
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


library(patchwork)

(p1 <- (ggplot(dataELAN, aes(Flow_avg, p_LZ_avg , group =Condition, color = Condition))+
  geom_smooth(aes(x= Flow_avg, y= p_LZ_avg, group =Condition, color = Condition),method="lm" ,se=FALSE)))
(p2 <- (ggplot(dataELAN, aes(Flow_avg, g_LZ_avg , group =Condition, color = Condition))+ guides(color=FALSE) + 
         geom_smooth(aes(x= Flow_avg, y= g_LZ_avg, group =Condition, color = Condition),method="lm" ,se=FALSE)))
(p3 <- (ggplot(dataELAN, aes(Flow_avg, LZ_avg , group =Condition, color = Condition))+ guides(color=FALSE) + 
          geom_smooth(aes(x= Flow_avg, y= LZ_avg, group =Condition, color = Condition),method="lm" ,se=FALSE)))

p1 /p2/p3

ggplot(dataELAN, aes(Flow_avg, LZ_avg , group =Condition, color = Condition))+ facet_wrap(~Participant)+
          geom_smooth(aes(x= Flow_avg, y= LZ_avg, group =Condition, color = Condition),method="lm" ,se=FALSE)

p1 <- ggplot(dataELAN, aes(Flow_avg, p_LZ_avg ))+ guides(color=FALSE) + facet_wrap(~Dance_mode)+ geom_point() +
  geom_smooth(aes(x= Flow_avg, y= p_LZ_avg),method="lm" ,se=FALSE)

p2 <-  ggplot(dataELAN, aes(Flow_avg, g_LZ_avg ))+ guides(color=FALSE) + facet_wrap(~Music_mode)+ geom_point() +
  geom_smooth(aes(x= Flow_avg, y= g_LZ_avg),method="lm" ,se=FALSE)

p1/p2
# There seems to be a condition effect on the slope of LZ vs FLow. Both from participants, music mode, dance mode. 

#Comparing models

m1  = lmer(p_LZ_avg ~ Imp_avg + (1 + Pair | Condition) + (1 | Participant)   , data = dataELAN_P )
m2 = lmer(p_LZ_avg ~ Imp_avg + (1 | Participant) , data = dataELAN_P )

library(sjPlot)
summary(m1)
summary(m2)
tab_model(m1,m2, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m1", "m2"), digits = 5)


# Looking at Improvisation and Flow. 

ggplot(dataELAN, aes(Q1a, Q3b )) + facet_wrap(~Condition) + geom_point() +
  geom_smooth(aes(x= Q1a, y= Q3b,),method="lm" ,se=FALSE)

ggplot(dataELAN, aes(Q1b, Q3b )) + facet_wrap(~Condition) +
  geom_smooth(aes(x= Q1a, y= Q3b,),method="lm" ,se=FALSE)
p <- ggplot(dataELAN, aes(Q1a, Q3b ))  +
  geom_smooth(aes(x= Q1a, y= Q3b,),method="lm" ,se=FALSE, colour = 'blue', show.legend = TRUE) + 
  geom_smooth(aes(x= Q1b, y= Q3b,),method="lm" ,se=FALSE, colour = 'red', show.legend = FALSE) +
  geom_smooth(aes(x= Q1a, y= Q3a,),method="lm" ,se=FALSE, colour = 'green', show.legend = FALSE) +
  geom_smooth(aes(x= Q1b, y= Q3a,),method="lm" ,se=FALSE, colour = 'black', show.legend = FALSE) +
  labs(x = "Improv", y = "Flow") +
  scale_x_continuous(limits = c(1, 7)) +
  scale_y_continuous(limits = c(1, 7)) +
  theme(legend.position = "bottom")

p + scale_color_manual(values = c("blue","red", "green", "black"),
                       name = "Improv/Flow",
                       labels = c("Quantity/Quality", "Quality/Quality", "Quantity/Quantity", "Quality/Quantity"))



# Condition has an effect on slope
m01 = lmer(Q3b ~ Q1a +(1 | Condition) , data = dataELAN )
m02 = lmer(Q3b ~ Q1b + (1 | Condition) , data = dataELAN )
m11 = lmer(Q3b ~ Q1a + Q1b + (1 | Condition) , data = dataELAN )
m12 = lmer(Q3b ~ Q1b  + (1 | Participant) , data = dataELAN )
m13 = lmer(Q3b ~ Q1b  + (1 | Participant) + (1 | Condition) , data = dataELAN )
m14 = lmer(Q3b ~ Q1b  + ( 1 | Pair:Participant) , data = dataELAN )
m15 = lmer(Q3b ~ Q1b  + (1 | Pair:Participant) + (1 | Condition) , data = dataELAN )
m16 = lmer(Q3b ~ Q1b  + Q1a+ (1 | Pair:Participant) + (1 | Condition) , data = dataELAN )



tab_model(m01, m02, m11,m12,m13,m14, m15,m16, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m1", "m2", "m3", "m4", "m5", "m6"), digits = 5)

# Condition has an effect on slope
m01 = lmer(Q3a ~ Q1a +(1 | Condition) , data = dataELAN )
m02 = lmer(Q3a ~ Q1b + (1 | Condition) , data = dataELAN )
m11 = lmer(Q3a ~ Q1a + Q1b + (1 | Condition) , data = dataELAN )
m12 = lmer(Q3a ~ Q1b  + (1 | Participant) , data = dataELAN )
m13 = lmer(Q3a ~ Q1b  + (1 | Participant) + (1 | Condition) , data = dataELAN )
m14 = lmer(Q3a ~ Q1b  + ( 1 | Pair:Participant) , data = dataELAN )
m15 = lmer(Q3a ~ Q1b  + (1 | Pair:Participant) + (1 | Condition) , data = dataELAN )
m16 = lmer(Q3a ~ Q1b  + Q1a+ (1 | Pair:Participant) + (1 | Condition) , data = dataELAN )



tab_model(m01, m02, m11,m12,m13,m14, m15,m16, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m1", "m2", "m3", "m4", "m5", "m6"), digits = 5)

