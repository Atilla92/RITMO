data<-read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/all_experiments_07072023_095/data/t%_merged_average.csv')


# Need to group by dancer and by guitarist ratings. 
# Need to group by time. 

library(lme4)
library(lmerTest)
library(ggplot2)
library(sjPlot)
library(sjlabelled)
library(sjmisc)
library(dplyr)

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
data$Artist <- as.factor(data$Artist)
data$Assigned_t <- as.factor(data$Assigned_t)

m01  = lmer(FLOW ~   t_LZ + (t_LZ | Assigned_t)  + (1 | Pair)  , data = data ) 
m02  = lmer(FLOW ~   t_var  * Assigned_t + (1| Participant)  , data = data ) 
m03  = lmer(FLOW ~   t_LZ  * Assigned_t  +  (1 | Participant)  , data = data ) 
m04  = lmer(FLOW ~   t_LZ  * Assigned_t  +  (1 | Participant)  , data = data )
m05  = lmer(FLOW ~   t_LZ  * Condition + (1 | Participant)  , data = data ) 
m06  = lmer(IMPRO ~   t_LZ + Assigned_t + (1 | Participant)  , data = data ) 
m07  = lmer(FLOW ~   t_LZ + Condition + Assigned_t + (1 | Participant)  , data = data ) 
tab_model(m01, m02, m03, m04, m05, m06,m07,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07"), digits = 5 )

m01  = lmer(FLOW ~   t_LZ_drum + Assigned_t +  (1 | Name)  , data = data ) 
m02  = lmer(FLOW ~   t_var  * Assigned_t + (1| Name)  , data = data ) 
m03  = lmer(FLOW ~   t_LZ  * Assigned_t  +  (1 | Participant)  , data = data ) 
m04  = lmer(FLOW ~   t_LZ  * Assigned_t  +  (1 | Name)  , data = data )
m05  = lmer(FLOW ~   t_LZ  + Condition + (1 | Participant)  , data = data ) 
m06  = lmer(FLOW ~   t_LZ +  (1 | Participant)  , data = data ) 
m07  = lmer(FLOW ~   t_LZ + Assigned_t + (1 | Pair)  , data = data ) 
m08  = lmer(FLOW ~   t_LZ + Assigned_t + (1 | Pair)  , data = data ) 
tab_model(m01, m02, m03, m04, m05, m06,m07,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07"), digits = 5 )

subset_data <- subset(data, Assigned_t == 0.9)
m01  = lmer(IMPRO ~   FLOW  + Condition +   (1 | Participant/Assigned_t), data = data )
m02  = lmer(IMPRO ~   t_LZ  + Condition +   (1 | Participant/Assigned_t), data = data ) 
m03  = lmer(FLOW ~   t_LZ  + Condition +   (1 | Participant/Assigned_t), data = data ) 
m02  = lmer(FLOW ~   t_LZ + Condition +  (1 | Pair), data = data ) 
m04  = lmer( t_LZ~   Assigned_t +   (1 | Participant), data = data ) 

tab_model(m01, m02, m03, m04, m05, m06,m07,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07"), digits = 5 )

summary(m01)
