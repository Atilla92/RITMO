# Script for plotting the data and fitting models on latest dataset. 


# Import libraries
library(lme4)
library(performance)
library(tidyverse)
library(ggplot2)
library(patchwork)
library(sjPlot)

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
dataELAN_C <- dataELAN[grepl("D1_M1", dataELAN$Condition),] #only Fully flow


# Checking whether data looks good. 




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




(p1 <- (ggplot(dataELAN_P, aes(Flow_avg, p_LZ_avg , group =Condition, color = Condition))+
  geom_smooth(aes(x= Flow_avg, y= p_LZ_avg, group =Condition, color = Condition),method="lm" ,se=FALSE)))
(p2 <- (ggplot(dataELAN_G, aes(Flow_avg, g_LZ_avg , group =Condition, color = Condition))+ guides(color=FALSE) + 
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


summary(m1)
summary(m2)
tab_model(m1,m2, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m1", "m2"), digits = 5)


# Looking at Improvisation and Flow. 

ggplot(dataELAN, aes(Q1a, Q3b )) + facet_wrap(~Condition) + geom_point() +
  geom_smooth(aes(x= Q1a, y= Q3b,),method="lm" ,se=FALSE)

ggplot(dataELAN, aes(Q1b, Q3b )) + facet_wrap(~Pair:Participant) +
  geom_smooth(aes(x= Q1a, y= Q3b,),method="lm" ,se=FALSE)
ggplot(dataELAN, aes(Q1a, Q3b ))  + facet_wrap(~Pair:Participant) +
  geom_smooth(aes(x= Q1a, y= Q3b,),method="lm" ,se=FALSE, colour = 'blue', show.legend = TRUE) + 
  geom_smooth(aes(x= Q1b, y= Q3b,),method="lm" ,se=FALSE, colour = 'red', show.legend = FALSE) +
  geom_smooth(aes(x= Q4a, y= Q3b,),method="lm" ,se=FALSE, colour = 'green', show.legend = FALSE) +
  geom_smooth(aes(x= Q4b, y= Q3b,),method="lm" ,se=FALSE, colour = 'black', show.legend = FALSE) +
  geom_smooth(aes(x= Abs_Av, y= Q3b,),method="lm" ,se=FALSE, colour = 'pink', show.legend = FALSE) +
  geom_smooth(aes(x= Perf_Av, y= Q3b,),method="lm" ,se=FALSE, colour = 'orange', show.legend = FALSE) +
  labs(x = "Improv", y = "Flow") +
  scale_x_continuous(limits = c(1, 7)) +
  scale_y_continuous(limits = c(1, 7)) +
  theme(legend.position = "bottom")

p + scale_color_manual(values = c("blue","red", "green", "black"),
                       name = "Improv/Flow",
                       labels = c("Quantity/Quality", "Quality/Quality", "Quantity/Quantity", "Quality/Quantity"))




# Which factors have fixed effect
m01 = lmer(Q3b ~ Q1a +(Condition |Pair:Participant) , data = dataELAN )
m02 = lmer(Q3b ~ Q1b + (Condition |Pair:Participant) , data = dataELAN )
m03 = lmer(Q3b ~ Q4a + (Condition |Pair:Participant), data = dataELAN )
m04 = lmer(Q3b ~ Q4b  +(Condition |Pair:Participant) , data = dataELAN )
m05 = lmer(Q3b ~ Perf_Av  + (Condition |Pair:Participant) , data = dataELAN )
m06 = lmer(Q3b ~ Abs_Av  + (Condition |Pair:Participant) , data = dataELAN )
tab_model(m01, m02, m03, m04, m05,m06, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m6"), digits = 5 )


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
m01 = lmer(Q3b ~ Q1a + Condition + (1 | Condition) , data = dataELAN )
m02 = lmer(Q3b ~ Q1b + (1 | Condition) , data = dataELAN )
m12 = lmer(Q3b ~ Q1a +Q1b +(1 | Condition) , data = dataELAN )
m123 = lmer(Q3b ~ Q1a +Q1b + Q4a +(1 | Condition) , data = dataELAN )
m13 = lmer(Q3b ~ Q1b + Q4a +(1 | Condition) , data = dataELAN )
m03 = lmer(Q3b ~ Q4a + (1 | Condition) , data = dataELAN )
m04 = lmer(Q3b ~ Q4b + (1 | Condition) , data = dataELAN )
m05 = lmer(Q3b ~ Abs_Av + (1 | Condition) , data = dataELAN )
m254 = lmer(Q3b ~ Q1b + Abs_Av + Q4a + (1 | Condition) , data = dataELAN )
m06 = lmer(Q3b ~ Perf_Av + (1 | Condition) , data = dataELAN )
m64 = lmer(Q3b ~ Perf_Av + Q4a + (1 | Condition) , data = dataELAN )
m264 = lmer(Q3b ~ Q1b + Perf_Av + Q4a + (1 | Condition) , data = dataELAN )

m12 = lmer(Q3b ~ Q1a +Q1b +(1 | Condition) , data = dataELAN )
summary(m01)
summary(m12)

tab_model(m01, m02,m12, m03,m123, m13, m04,m05,m254, m06, m64,m264, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m12","m03","m123","m13","m04","m05","m254" ,"m06", "m64", "m264"), digits = 5, title = "Table 2 : Combination of Fixed Effects in Linear Mixed-Effects Models ",
          file = "/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/Stats/R/tab2_lmer_flow_predictors.html")


m264_1 = lmer(Q3b ~ Q1b + Q4a + Perf_Av + (1 | Condition) , data = dataELAN )
m264_2 = lmer(Q3b ~ Q1b + Q4a + Perf_Av + (1 | Participant) , data = dataELAN )
m264_3 = lmer(Q3b ~ Q1b + Q4a + Perf_Av + (1 | Pair) , data = dataELAN )
m264_4 = lmer(Q3b ~ Q1b + Q4a + Perf_Av + (1 | Pair:Participant)  , data = dataELAN )
m264_5 = lmer(Q3b ~ Q1b + Q4a + Perf_Av + (1 | Pair:Participant) + (1 | Condition)  , data = dataELAN )
m264_6 = lmer(Q3b ~ Q1b + Q4a + Perf_Av + (1 | Pair) + (1 | Condition)  , data = dataELAN )
m264_7 = lmer(Q3b ~ Q1b + Q4a + Perf_Av +  Condition + (1 | Pair:Participant)  , data = dataELAN )
#m264_8 = lmer(Q3b ~  (Q1b + Q4a + Perf_Av) + (Condition |Pair:Participant)   , data = dataELAN )
#m264_9 = lmer(Q3b ~  (Q1b + Q4a + Perf_Av):Condition + (Condition |Pair:Participant)   , data = dataELAN )

tab_model(m264_1,m264_2,m264_3,m264_4,m264_5, m264_6, m264_7, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m264_1", "m264_2","m264_3","m264_4","m264_5", "m264_6", "m264_7"), digits = 5, 
          title = "Summary of Linear Mixed-Effects Models - Predicting state of Flow" ,
          file = "/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/Stats/R/tab3_lmer_flow_predictors.html"
          )

library(webshot)
webshot("/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/Stats/R/tab3_lmer_flow_predictors.html",
        "/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/Stats/R/tab3_lmer_flow_predictors.png")



m01 = lmer(Q3b ~ Q1b + Q4a + Abs_Av + Perf_Av + (Condition |Pair:Participant) + (1 | Condition)  , data = dataELAN )
m02 = lmer(Q3b ~ Q1b + Q4a  + Perf_Av + (Condition |Pair:Participant) + (1 | Condition)  , data = dataELAN )
m03 = lmer(Q3b ~ Q1b + Q4a  + Perf_Av + (Condition |Pair:Participant) , data = dataELAN )
m04 = lmer(Q3b ~ Q1b + Q4a  + Perf_Av + (1 |Pair:Participant) , data = dataELAN )
m05 = lmer(Q3b ~ Q1b + Q4a  + Perf_Av + (1 |Condition) , data = dataELAN )
m06 = lmer(Q3b ~ Q1b + Q4a  + Perf_Av + (Condition  |Pair) , data = dataELAN )
summary(m03)
tab_model(m01, m02, m03, m04, m05,m06, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m6"), digits = 5 )
          file = "/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/Stats/R/tab3_lmer_flow_predictors.html")


#: allows for non nested data, can handle crossed and partially crossed data. 
library(webshot)
webshot("/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/Stats/R/tab3_lmer_flow_predictors.html", "/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/Stats/R/tab3_lmer_flow_predictors.png")


# LZ- complexity 
(p1 <- (ggplot(dataELAN_P, aes(Flow_avg, p_LZ_avg , group =Condition, color = Condition))+
          geom_smooth(aes(x= Flow_avg, y= p_LZ_avg, group =Condition, color = Condition),method="lm" ,se=FALSE)))
(p2 <- (ggplot(dataELAN_G, aes(Flow_avg, g_LZ_avg , group =Condition, color = Condition))+ guides(color=FALSE) + 
          geom_smooth(aes(x= Flow_avg, y= g_LZ_avg, group =Condition, color = Condition),method="lm" ,se=FALSE)))
(p3 <- (ggplot(dataELAN, aes(Flow_avg, LZ_avg , group =Condition, color = Condition))+ guides(color=FALSE) + 
          geom_smooth(aes(x= Flow_avg, y= LZ_avg, group =Condition, color = Condition),method="lm" ,se=FALSE)))

p1 /p2/p3

ggplot(dataELAN, aes(Flow_avg, LZ_avg , group =Condition, color = Condition))+ facet_wrap(~Pair)+
  geom_smooth(aes(x= Flow_avg, y= LZ_avg, group =Condition, color = Condition),method="lm" ,se=FALSE)


#Look at dataset form fully improvised only

ggplot(dataELAN_C, aes(Flow_avg, LZ_avg ))+ facet_wrap(~Pair)+
  geom_smooth(aes(x= Flow_avg, y= LZ_avg), method="lm",se=FALSE)



m0 = lmer(Q3b ~ Condition + (Condition |Pair:Participant) , data = dataELAN )
m2 = lmer(Q3b ~ Q1b + (Condition |Pair:Participant) , data = dataELAN )
m3 = lmer(LZ_avg ~ Condition + (Condition |Pair:Participant) , data = dataELAN )
m4 = lmer(Q3b ~ Q1b + (1 |Pair:Participant) , data = dataELAN_C )
tab_model(m0, m2,m3, m4,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m1","m2", 'm3', "m4_C"), digits = 5, digits.re=5 )

summary(m0)

m01 = lmer(LZ_avg ~ Q3a+ (1 |Pair:Participant) , data = dataELAN_C )
m02 = lmer(LZ_avg ~ Q3b + (1 |Pair:Participant) , data = dataELAN_C )
m03 = lmer(LZ_avg ~ Q1a + (1 |Pair:Participant) , data = dataELAN_C )
m04 = lmer(LZ_avg ~ Q1b + (1 |Pair:Participant) , data = dataELAN_C )
m05 = lmer(LZ_avg ~ Perf_Av+ (1 |Pair:Participant) , data = dataELAN_C )
m06 = lmer(LZ_avg ~ Abs_Av+ (1 |Pair:Participant) , data = dataELAN_C )
m07 = lmer(LZ_avg ~ Abs_Av + Q3a + (1 |Pair:Participant) , data = dataELAN_C )
m08 = lmer(LZ_avg ~ Q3a + Abs_Av + Q3b + Q1a  + (1 |Pair:Participant) , data = dataELAN_C )

tab_model(m01, m02, m03, m04, m05,m06,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m6"), digits = 5, digits.re=5,
          file ="/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/Stats/R/tab1_lmer_LZ_predictors.html" )
webshot("/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/Stats/R/tab1_lmer_LZ_predictors.html", 
        "/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/Stats/R/tab1_lmer_LZ_predictors.png")

m01 = lmer(LZ_avg ~ Abs_Av + (1 |Pair:Participant) , data = dataELAN_C )
m02 = lmer(LZ_avg ~ Q3a + Abs_Av + (1 |Pair:Participant) , data = dataELAN_C )
m03 = lmer(LZ_avg ~ Q3a + Abs_Av + Q3b  + (1 |Pair:Participant) , data = dataELAN_C )
m04 = lmer(LZ_avg ~ Abs_Av + Q3b  + (1 |Pair:Participant) , data = dataELAN_C )
m05 = lmer(LZ_avg ~ Q3a + Abs_Av + Q3b  + Perf_Av + (1 |Pair:Participant) , data = dataELAN_C )
m06 = lmer(LZ_avg ~ Q3a + Abs_Av + Q3b  + Q1a + (1 |Pair:Participant) , data = dataELAN_C )
m07 = lmer(LZ_avg ~ Abs_Av + Q3b  + Q1a + (1 |Pair:Participant) , data = dataELAN_C )
tab_model(m01, m02, m03, m04, m05,m06,m07,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m1", "m2","m3","m4", "m5", "m6", "m7"), digits = 5, digits.re=5 ,
          file ="/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/Stats/R/tab2_lmer_LZ_predictors.html")
library(webshot)
webshot("/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/Stats/R/tab2_lmer_LZ_predictors.html", 
        "/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/Stats/R/tab2_lmer_LZ_predictors.png")


m01 = lmer(LZ_avg ~ Q3b+ (Condition |Pair:Participant) + (1 | Condition)  , data = dataELAN )
m02 = lmer(LZ_avg ~ Q3b +  (1 | Condition)  , data = dataELAN)
m03 = lmer(LZ_avg ~ Q3b + (Condition |Pair:Participant) , data = dataELAN )
m04 = lmer(LZ_avg ~ Q3b + (1 |Pair:Participant) , data = dataELAN )
m05 = lmer(LZ_avg ~ (Q3b*Condition) + (1 |Pair:Participant) , data = dataELAN )
m06 = lmer(LZ_avg ~ Q3b:Condition + (1 |Pair:Participant) , data = dataELAN )
m07 = lmer(LZ_avg ~ Q3b + Condition + (1 |Pair:Participant) , data = dataELAN )
tab_model(m01, m02, m03, m04, m05,m06,m07,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m6", "m7"), digits = 5, digits.re=5 )
summary(m01)


# Data Time-Series Visualisation 

dataSeries <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/all_experiments_095/data/t%_merged_average.csv')
view(dataSeries)
dataSeries$time <- as.factor(dataSeries$Assigned)
ggplot(dataSeries, aes(x = time, y= t_LZ , group = Rater, color=factor(Artist)))+ facet_wrap(~Condition)+
  geom_smooth(aes(x = time, y= t_LZ, group = Rater, color=factor(Artist)), method="lm",se=FALSE) + geom_point()

geom_smooth(aes(x= Assigned, y= FLOW), method="lm",se=FALSE, colour='red')


require("lme4")
require("splines")

m7_spline<-lmer(t_LZ ~ 1+ (bs(time) | Rater), data=dataSeries) #bs() base spline, estimate for best fitting spline for data. 
dat$pred_spline<-predict(m7_spline, dat,re.form=NA)

ggplot(dataSeries, aes(x=time, y=t_LZ, color=factor(Artist), fill=factor(Artist), group=Artist))+facet_wrap(~Condition)+
  stat_summary(fun.data="mean_se", geom="ribbon", color=NA, alpha=0.1)+
  stat_summary(fun="mean", geom="line", size=1.25)+
  labs(title="LZ Complexity Across Conditions, Time-Series", y="Baseline-corrected pupil size (a.u.)")+
  theme_bw(base_size=15)+theme(axis.title.x=element_blank(), legend.position="none")

ggplot(dataSeries, aes(x=time, y=FLOW, color=factor(Artist), fill=factor(Artist), group=Artist))+facet_wrap(~Condition)+
  stat_summary(fun.data="mean_se", geom="ribbon", color=NA, alpha=0.1)+
  stat_summary(fun="mean", geom="line", size=1.25)+
  labs(title="LZ Complexity Across Conditions, Time-Series", y="Baseline-corrected pupil size (a.u.)")+
  theme_bw(base_size=15)+theme(axis.title.x=element_blank(), legend.position="none")

ggplot(dataSeries, aes(x=time, y=IMPRO, color=factor(Artist), fill=factor(Artist), group=Artist))+facet_wrap(~Condition)+
  stat_summary(fun.data="mean_se", geom="ribbon", color=NA, alpha=0.1)+
  stat_summary(fun="mean", geom="line", size=1.25)+
  labs(title="LZ Complexity Across Conditions, Time-Series", y="Baseline-corrected pupil size (a.u.)")+
  theme_bw(base_size=15)+theme(axis.title.x=element_blank(), legend.position="none")

