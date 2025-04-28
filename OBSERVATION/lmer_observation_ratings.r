
# Analysis global brain dynamics Jazz imp
rm(list=ls()) # Clear work Environment

# Libraries & options ----------
options(scipen = 100, digits = 4)

library(afex) 
library(dplyr)
library(forcats)
library(ggeffects) 
library(ggplot2)
library(ggsci)
library(huxtable)
library(lme4) 
library(lsmeans)
library(readr)
library(reshape2)
library(Rmisc)
library(rstatix)
library(stargazer) 
library(ggplot2)
library(sjPlot)
library(sjlabelled)
library(sjmisc)
library(dplyr)
library(tidyr)
library(effects)
library(lme4)
library(lmerTest)
library(psych)
library(jtools)
library(lsmeans)
library(dplyr)
library(emmeans)
emm_options(pbkrtest.limit = 20000)

data_raw <-read.csv('/Users/atillajv/CODE/RITMO/OBSERVATION/Seminar_Responses.csv')
data <- na.omit(data_raw)

data$Condition <- as.factor(data$Condition)
data$Dancer <- as.factor(data$Dancer)
data$Question <- as.factor(data$Question)
data$Video <- as.factor(data$Video)


data_1 <- data %>%
  filter(Question != "Improvisation")
# Calculate Spearman correlation for each Question category
cor_results <- data_1 %>%
  group_by('Question') %>%
  summarize(correlation = cor(Rating, Response, method = "spearman"))

print(cor_results)



data_2 <- data %>%
  filter(Question != "Flow")
# Calculate Spearman correlation for each Question category
cor_results <- data_2 %>%
  group_by('Question') %>%
  summarize(correlation = cor(Rating, Response, method = "spearman"))

print(cor_results)


data_3 <- data %>%
  filter(Question != "Connection")
# Calculate Spearman correlation for each Question category
cor_results <- data_3 %>%
  group_by('Question') %>%
  summarize(correlation = cor(Rating, Response, method = "spearman"))

print(cor_results)


data_4 <- data %>%
  filter(Question != "Complex")
# Calculate Spearman correlation for each Question category
cor_results <- data_4 %>%
  group_by('Question') %>%
  summarize(correlation = cor(Rating, Response, method = "spearman"))

print(cor_results)


cor_results <- data %>%
  summarize(correlation = cor(Rating, Response, method = "spearman"))

print(cor_results)

# Ignore condition B



# Boxplots with correlation values displayed on the plot




m00  = lmer(Response ~   Rating  + (1 | Dancer), data = data )
m01  = lmer(Response ~   Rating * Palo + (1 | Dancer), data = data )
m01  = lmer(Response ~   Rating * Palo + (1 | Dancer), data = data )
anova(m00,m01)
summary(m01)

m01  = lmer(Q1 ~   Q1a + (1 | Participant), data = data )
m02  = lmer(Q1 ~   Q1b + (1 | Participant), data = data )
m03  = lmer(Q1 ~   Palo + (1 | Participant), data = data )
m04  = lmer(Q1 ~   Condition + (1 | Participant), data = data )
m05  = lmer(Q1 ~   Perf_Av + (1 | Participant), data = data )
m06  = lmer(Q1 ~   Abs_Av + (1 | Participant), data = data )


tab_model(m00, m01,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01"), digits = 5 )




