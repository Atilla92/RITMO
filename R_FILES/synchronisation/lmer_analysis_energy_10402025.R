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

library(lme4)
library(lmerTest)
library(psych)
library(jtools)
library(bestNormalize)


# Filter data for Participant 'P'
data_P <- data_raw[data_raw$Artist == "P", ]

# Normalize Potential Energy for 'P'
pe_norm_P <- bestNormalize(data_P$p_PE_wholebody, allow_orderNorm = FALSE)
print("Best normalization method for Potential Energy (P):")
print(pe_norm_P$chosen_transform)
print("Method used (P):")
print(class(pe_norm_P$chosen_transform)[1])
print(pe_norm_P$norm_stats)

# Normalize Kinetic Energy for 'P'
ke_norm_P <- bestNormalize(data_P$p_KE_wholebody, allow_orderNorm = FALSE)
print("Best normalization method for Kinetic Energy (P):")
print(ke_norm_P$chosen_transform)
print("Method used (P):")
print(class(ke_norm_P$chosen_transform)[1])
print(ke_norm_P$norm_stats)

# Add normalized columns for 'P'
data_P$PE_wholebody_norm <- predict(pe_norm_P)
data_P$KE_wholebody_norm <- predict(ke_norm_P)

# Filter data for Participant 'G'
data_G <- data_raw[data_raw$Artist == "G", ]

# Normalize Potential Energy for 'G'
pe_norm_G <- bestNormalize(data_G$g_PE_wholebody, allow_orderNorm = FALSE)
print("Best normalization method for Potential Energy (G):")
print(pe_norm_G$chosen_transform)
print("Method used (G):")
print(class(pe_norm_G$chosen_transform)[1])
print(pe_norm_G$norm_stats)

# Normalize Kinetic Energy for 'G'
ke_norm_G <- bestNormalize(data_G$g_KE_wholebody, allow_orderNorm = FALSE)
print("Best normalization method for Kinetic Energy (G):")
print(ke_norm_G$chosen_transform)
print("Method used (G):")
print(class(ke_norm_G$chosen_transform)[1])
print(ke_norm_G$norm_stats)

# Add normalized columns for 'G'
data_G$PE_wholebody_norm <- predict(pe_norm_G)
data_G$KE_wholebody_norm <- predict(ke_norm_G)

# Merge the two datasets together
combined_data <- rbind(data_P, data_G)

# Optionally, inspect the combined dataset
print(head(combined_data))




# If you'd like to plot histograms for the combined dataset
par(mfrow=c(2,2))
hist(data_P$p_PE_wholebody, main="Original PE Distribution (P)", xlab="PE")
hist(data_P$PE_wholebody_norm, main="Normalized PE Distribution (P)", xlab="Normalized PE")
hist(data_G$g_PE_wholebody, main="Original PE Distribution (G)", xlab="PE") 
hist(data_G$PE_wholebody_norm, main="Normalized PE Distribution (G)", xlab="Normalized PE")


data <- data_P


data$instruction <- paste(data$Condition, data$Artist, sep = "_")
data$instruction_2 <- paste(data$instruction, data$Palo, sep = "_")

unique_instructions <- unique(data$instruction)
print(unique_instructions)

unique_instructions_2 <- unique(data$instruction_2)
print(unique_instructions_2)


data$Q1 <- (data$Q1a + data$Q1b) / 2
data$Q3 <- (data$Q3a + data$Q3b) / 2
data$Q6 <- (data$Q6a + data$Q6b) /2
data$Q5 <-  (data$Q5a + data$Q5b) /2
data$Q4 <- (data$Q4a + data$Q4b) /3
data$p_E_total <- (data$p_PE_wholebody + data$p_PE_wholebody)
data$g_E_total <- (data$g_PE_wholebody + data$g_PE_wholebody)

data$Dance_mode <- as.factor(data$Dance_mode)
data$Dance_Imp <- as.factor(data$Dance_Imp)
data$Music_Imp <- as.factor(data$Music_Imp)
data$Baile_Level <- as.factor(data$Baile_Level)
data$Guitarra_Level <- as.factor(data$Guitarra_Level)
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
#data$Artist <- ifelse(data$Artist == "G", 0, ifelse(data$Artist == "P", 1, data$Artist))
data$Artist <- as.factor(data$Artist)
data$Number <- as.factor(data$number)
data$Dancer <- as.factor(data$Dancer)
data$Guitarist <- as.factor(data$Guitarist)
# Instructions
data$instruction <- as.factor(data$instruction)
data$instruction <-factor(data$instruction, levels = c("D5_M6_P",  "D1_M6_P","D6_M6_P",  "D5_M5_P","D1_M1_P"))

data$instruction <-factor(data$instruction, levels = c("D5_M6_G",  "D1_M6_G","D6_M6_G",  "D5_M5_G","D1_M1_G"))

data$instruction <-factor(data$instruction, levels = c("D5_M6_P", "D5_M6_G",  "D1_M6_P", "D1_M6_G","D6_M6_P", "D6_M6_G",  "D5_M5_P", "D5_M5_G","D1_M1_P", "D1_M1_G"))
data$instruction_2 <- as.factor(data$instruction_2)

data$instruction_2 <-factor(data$instruction_2, levels = c("D5_M6_P_R1",  "D1_M6_P_R1","D6_M6_P_R1",  "D5_M5_P_R1","D1_M1_P_R1",
                                                           "D5_M6_P_R2",  "D1_M6_P_R2","D6_M6_P_R2",  "D5_M5_P_R2","D1_M1_P_R2"))

data$instruction_2 <-factor(data$instruction_2, levels = c("D5_M6_G_R1",  "D1_M6_G_R1","D6_M6_G_R1",  "D5_M5_G_R1","D1_M1_G_R1",
                                                           "D5_M6_G_R2",  "D1_M6_G_R2","D6_M6_G_R2",  "D5_M5_G_R2","D1_M1_G_R2"))


data$instruction_2 <-factor(data$instruction_2, levels = c("D5_M6_P_R1", "D5_M6_G_R1",  "D1_M6_P_R1", "D1_M6_G_R1","D6_M6_P_R1", "D6_M6_G_R1",  "D5_M5_P_R1", "D5_M5_G_R1","D1_M1_P_R1", "D1_M1_G_R1",
                                                           "D5_M6_P_R2", "D5_M6_G_R2",  "D1_M6_P_R2", "D1_M6_G_R2","D6_M6_P_R2", "D6_M6_G_R2",  "D5_M5_P_R2", "D5_M5_G_R2","D1_M1_P_R2", "D1_M1_G_R2"))


levels(data$instruction_2)
levels(data$instruction)
levels(data$Dance_Imp)
# by adding (1|Name) and (1|Dancer) we are accounting for repeated measures within Name?

m00 = lmer(PE_wholebody_norm ~ 1  +  (1 | Name)+ (1 | Dancer) , data = data)
m01 = lmer(PE_wholebody_norm ~ 1  +  (1 | Name) , data = data)
m02 = lmer(PE_wholebody_norm ~ 1  +  (1 | Name)+ (1 | Dancer)+ (1 | Guitarist) , data = data)

anova(m00,m01)
anova(m00,m02)
# Adding dancer is by far a better estimate of the model. Adding guitarist does not explain any variance


# Q1: When do we have to include the fixed effect as random intercept?
m00 = lmer(PE_wholebody_norm ~ Dance_Imp  +  (1 | Name)+ (1 | Dancer) , data = data)
m01  = lmer(PE_wholebody_norm ~   Palo  + p_LZ + Dance_Imp + (1 | Name)+ (1 + p_LZ| Dancer), data = data )
m02  = lmer(PE_wholebody_norm ~   Palo  + p_LZ + Dance_Imp + (1 | Name)+ (1 | Dancer), data = data )
m03 = lmer(PE_wholebody_norm ~ p_LZ  +  (1 | Name)+ (1 | Dancer) , data = data)
m03 = lmer(PE_wholebody_norm ~ Dance_Imp  +  (1 | Name) + (1 + Dance_Imp | Dancer), data = data)
m04 = lmer(PE_wholebody_norm ~ Palo * Dance_Imp  +  (1 | Name)+ (1 | Dancer) , data = data)
m05 = lmer(PE_wholebody_norm ~ Baile_Level  +  (1 | Name)+ (1 | Dancer) , data = data)
m06 = lmer(PE_wholebody_norm ~ Baile_Level * Dance_Imp  +  (1 | Name)+ (1 | Dancer) , data = data)
m07 = lmer(PE_wholebody_norm ~ Palo * Baile_Level  +  (1 | Name) + (1 | Dancer), data = data)
m08 = lmer(PE_wholebody_norm ~ Flow_subj  +  (1 | Name)+ (1 | Dancer) , data = data)
m09 = lmer(PE_wholebody_norm ~ Imp_subj  +  (1 | Name)+ (1 | Dancer) , data = data)

tab_model(m00,m01, m02,m03,m04, m05,m06,m07,m08, m09, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00","m01", "m02","m03", "m04", "m05", "m06", "m07","m08", "m09"), digits = 5 )




m00 = lmer(p_PE_wholebody ~  1+  (1 | Name) , data = data)
m01 = lmer(p_PE_wholebody ~ Dance_Imp  +  (1 | Name) , data = data)
anova(m00,m01)


levels(data$instruction_2)

# ANOVA with orthogonal planned

# ANOVA with orthogonal planned contrasts: (1) Homophonic vs Polyphonic; (2) Pairing with Melody vs No Melody; (3) Melody-to-Other vs Other-to-Melody
# Check order of conditions (important for specifying contrast coefficients)
m00 = lmer(p_PE_wholebody ~   1 +  (1 | Name) + (1 | Dancer) , data = data )
m01  = lmer(p_PE_wholebody ~   instruction_2  +  (1 | Name) + (1 | Dancer), data = data )


m00 = lmer(Flow_subj ~ 1 +  (1 | Name) + (1 | Dancer) , data = data)
m01 = lmer(Flow_subj ~ instruction_2 +  (1 | Name) + (1 | Dancer) , data = data)


anova(m00,m01)

FlamencoImp_Comp <- lsmeans(m01, "instruction_2")
names_contrasts <- c("A", "B", "C", "E", "ExA", "ExB", "ExB", "ExC")
#both

# P
contrasts <- list(
  A_FIXvsOther = c(-1,-1,4,-1,-1,-1,-1,4,-1,-1),
  B_MIXvsIMP = c(-1,1,0,-1,1,-1,1,0,-1,1),
  C_INDvsGR = c(-1,-1,0,1,1,-1,-1,0,1,1),
  E_R1vsR2 = c(1,1,1,1,1,-1,-1,-1,-1,-1),
  ExA = c(-1,-1,4,-1,-1,1,1,-4,1,1),
  ExB = c(-1,1,0,-1,1,1,-1,0,1,-1),
  ExC = c(-1,-1,0,1,1,1,1,0,-1,-1)
)

# Run contrasts and assign names to output table
FlamencoImp_Comp.output <- contrast(FlamencoImp_Comp, contrasts, adjust="none", names = names_contrasts)
FlamencoImp_Comp.output
FlamencoImp_Comp.output.ci <- confint(FlamencoImp_Comp.output)
FlamencoImp_Comp.output.ci





# Guitarist




# by adding (1|Name) and (1|Dancer) we are accounting for repeated measures within Name?
m00 = lmer(g_PE_wholebody ~ 1  +  (1 | Name)+ (1 | Guitarist) , data = data)
m00 = lmer(g_PE_wholebody ~ 1  +  (1 | Name)+ (1 | Dancer) , data = data)
m01 = lmer(g_PE_wholebody ~ 1  +  (1 | Name)+ (1 | Dancer)  + (1 | Guitarist)  , data = data)

anova(m00,m01)
# Adding dancer is by far a better estimate of the model. 



m00 = lmer(g_PE_wholebody ~ Music_Imp  +  (1 | Name) + (1 | Guitarist), data = data)
m01  = lmer(g_PE_wholebody ~   Palo  + (1 | Name) + (1 | Guitarist), data = data )
m02 = lmer(g_PE_wholebody ~ Condition  +  (1 | Name) + (1 | Guitarist), data = data)
m03 = lmer(g_PE_wholebody ~ Dance_Imp  +  (1 | Name) + (1 | Guitarist) , data = data)
m04 = lmer(g_PE_wholebody ~ g_PE_wholebody  +  (1 | Name) + (1 | Guitarist) , data = data)
m05 = lmer(g_PE_wholebody ~ Guitarra_Level  +  (1 | Name) + (1 | Guitarist) , data = data)
m06 = lmer(g_PE_wholebody ~ Guitarra_Level * Music_Imp  +  (1 | Name) + (1 | Guitarist) , data = data)
m07 = lmer(g_PE_wholebody ~ LZ.1  +  (1 | Name) + (1 | Guitarist), data = data)
m08 = lmer(g_PE_wholebody ~ Flow_subj  +  (1 | Name)+ (1 | Guitarist) , data = data)



tab_model(m00,m01, m02,m03,m04, m05,m06,m07, m08, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00","m01", "m02","m03", "m04", "m05", "m06", "m07", "m08"), digits = 5 )

m00 = lmer(g_E_total ~   1 +  (1 | Name) + (1 | Guitarist) , data = data )
m01  = lmer(g_E_total ~   instruction_2  +  (1 | Name) + (1 | Guitarist), data = data )

anova(m00,m01)

m00 = lmer(Flow_subj ~ 1+   (1 | Name) + (1| Dancer) , data = data)
m01 = lmer(Flow_subj ~ instruction_2  + (1 | Name) + (1| Dancer) , data = data)


FlamencoImp_Comp <- lsmeans(m01, "instruction_2")


contrasts <- list(
  A_FIXvsOther= c(-1,-1,4,-1,-1,-1,-1,4,-1,-1),
  B_MIXvsIMP= c(-1,1,0,-1,1,-1,1,0,-1,1),
  C_INDvsGR= c(-1,-1,0,1,1,-1,-1,0,1,1),
  E_R1vsR2= c(1,1,1,1,1,-1,-1,-1,-1,-1),
  ExA= c(-1,-1,4,-1,-1,1,1,-4,1,1),
  ExB= c(-1,1,0,-1,1,1,-1,0,1,-1),
  ExC= c(-1,-1,0,1,1,1,1,0,-1,-1)
)

# Run contrasts and assign names to output table
FlamencoImp_Comp.output <- contrast(FlamencoImp_Comp, contrasts, adjust="none", names = names_contrasts)
FlamencoImp_Comp.output
FlamencoImp_Comp.output.ci <- confint(FlamencoImp_Comp.output)
FlamencoImp_Comp.output.ci





library(corrplot)
library(symnum)
library(psych)

# Select columns of interest
plot.new()
corr_mat <- data[, c("Flow_subj", "Imp_subj", "p_PE_wholebody", "KE_wholebody_norm", "p_LZ", "CTW","p_MIR_entropy", "p_MIR_rms", "p_MIR_novelty", "p_var_entropy" )]

corr_mat <- data[, c("Flow_subj", "Imp_subj", "PE_wholebody_norm", "KE_wholebody_norm", "p_LZ" , "LZ.1", "p_MIR_novelty")]


# Compute correlation matrix
M <- cor(corr_mat, use = 'complete.obs', method='spearman')
name_plot = 'Correlation'

# Plot correlation matrix
corrplot(M, order = "AOE", tl.col = "black", 
         tl.srt = 45, 
         p.mat = corr.test(corr_mat)$p, 
         insig = 'label_sig',
         sig.level = c(.001, .01, .05),
         pch.cex = 1.2, pch.col = 'red', 
         addCoef.col = "white",
         title = paste('Correlation Plot (', name_plot , ')'), cex.main = 1.8,
         mar=c(0,0,2,0))


### Dancer and Guitarist



m00 = lmer(Flow_subj ~ p_LZ + p_KE_wholebody +   (1 | Name) + (1 + p_LZ | Dancer) , data = data)
m01 = lmer(Flow_subj ~ p_LZ +  (1 | Name) + (1| Dancer) , data = data)
m02 = lmer(Flow_subj ~ Imp_subj + p_LZ + (1 | Name) + (1 + p_LZ | Dancer) , data = data)
m03 = lmer(Flow_subj ~ p_PE_wholebody*Palo  + (1 | Name) + (1 + p_PE_wholebody | Dancer) , data = data)
m04 = lmer(Flow_subj ~ Imp_subj + p_LZ + (1 | Name) + (1+ Imp_subj + p_LZ  | Dancer) , data = data)
m05 = lmer(Flow_subj ~ Baile_Level * Dance_Imp + (1 | Name) + (1| Dancer) , data = data)
m06 = lmer(Flow_subj ~ Baile_Level * p_KE_wholebody+  (1 | Name) + (1  | Dancer) , data = data)
m07 = lmer(Flow_subj ~ Baile_Level * p_LZ +  (1 | Name) + (1 + p_LZ | Dancer) , data = data)
anova(m00,m01)
anova(m01,m02)
anova(m02,m03)
anova(m03,m04)

tab_model(m00,m01,m02,m03,m04,m05,m06,m07,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00","m01", "m02", "m03"," m04", "m05", "m06", "M07"), digits = 5 )


# 
m00 = lmer(Flow_subj ~ p_LZ  * Dance_Imp +  (1 | Name) + (1 + p_LZ | Dancer) , data = data)
m01 = lmer(Flow_subj ~  p_LZ  + Dance_Imp  +  (1 | Name) + (1 + p_LZ | Dancer) , data = data)
m02 = lmer(Flow_subj ~ p_LZ + KE_wholebody_norm+ (1 | Name) + (1 + p_LZ | Dancer) , data = data)
m03 = lmer(Flow_subj ~ PE_wholebody_norm  + (1 | Name) + (1 + PE_wholebody_norm | Dancer) , data = data)
m04 = lmer(Flow_subj ~ p_LZ + PE_wholebody_norm + (1 | Name) + (1+ p_LZ  | Dancer) , data = data)
m05 = lmer(Flow_subj ~ p_LZ + PE_wholebody_norm + (1 | Name) + (1+ p_LZ + PE_wholebody_norm  | Dancer) , data = data)
m06 = lmer(Flow_subj ~ p_LZ + PE_wholebody_norm + KE_wholebody_norm + (1 | Name) + (1+ PE_wholebody_norm | Dancer) , data = data)
m07 = lmer(Flow_subj ~ p_LZ + PE_wholebody_norm + (1 | Name) + (1+ p_LZ + PE_wholebody_norm | Dancer) , data = data)
m08 = lmer(Flow_subj ~  PE_wholebody_norm + (1 | Name) + (1 + PE_wholebody_norm | Dancer) , data = data)

anova(m00,m01)
anova(m01,m02)
anova(m02,m03)
anova(m07,m08)

tab_model(m00,m01,m02,m03,m04,m05,m06,m07,m08,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00","m01", "m02", "m03"," m04", "m05", "m06", "M07", "m08"), digits = 5 )



anova(m01,m02)
summary(m06)










