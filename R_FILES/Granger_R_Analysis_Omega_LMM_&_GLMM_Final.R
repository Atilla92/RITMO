# Analysis of Omega Ensemble Granger Causality (GC) data
# Runs linear mixed models (LMM) and binomial generalized mixed models (GLMM)
# Select whether to analyze with Bonferroni correction (BFC) or uncorrected (UC) in lines 54/55 & lines 184/185 

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

source("https://gist.githubusercontent.com/benmarwick/2a1bb0133ff568cbe28d/raw/fb53bd97121f7f9ce947837ef1a4c65a73bffb3f/geom_flat_violin.R")

# Read in csv data ---------
setwd("~/Documents/Work-MARCS/EXPERIMENTS/Omega Ensemble/Omega Ensemble Rehearsal/Analysis_2020/Sanket_analysis/Granger Causality") # set path to folder with csv-files

data_brahms <- data.frame(read_csv('~/Documents/Work-MARCS/EXPERIMENTS/Omega Ensemble/Omega Ensemble Rehearsal/Analysis_2020/Sanket_analysis/Granger Causality/Final_Brahms_Results_GC.csv'))
data_borodin <- data.frame(read_csv('~/Documents/Work-MARCS/EXPERIMENTS/Omega Ensemble/Omega Ensemble Rehearsal/Analysis_2020/Sanket_analysis/Granger Causality/Final_Borodin_Results_GC.csv'))
data <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/22_Sep_2023_niels/27102023_ELAN_no_CDRS_onset_niels_4s_final.csv')



##### ATILLA CODE ADJUSTED######

data_ole <- data %>%
  distinct(Name, Artist, .keep_all = TRUE)
data_ole$GMSI <- ifelse(data_ole$Participant == "G7", 5, data_ole$GMSI)
data_ole$GDSI <- ifelse(data_ole$Participant == "G7", 3.65, data_ole$GDSI)
data_ole$Fam <- ifelse(data_ole$Participant %in% c("G4", "P8"), 1, data_ole$Fam)


# Create a new column with concatenated strings
data_ole$instruction <- paste(data_ole$Condition, data_ole$Artist, sep = "_")
data_ole$instruction_2 <- paste(data_ole$instruction, data_ole$Palo, sep = "_")
# Print the updated data frame
unique_instructions <- unique(data_ole$instruction)
print(unique_instructions)
 
unique_instructions_2 <- unique(data_ole$instruction_2)
print(unique_instructions_2)

# MACRO Check
data_ole$Q1 <- (data_ole$Q1a + data_ole$Q1b) / 2
data_ole$Q3 <- (data_ole$Q3a + data_ole$Q3b) / 2
data_ole$Q6 <- (data_ole$Q6a + data_ole$Q6b) /2
data_ole$Q5 <-  (data_ole$Q5a + data_ole$Q5b) /2
data_ole$Q4 <- (data_ole$Q4a + data_ole$Q4b) /3

data_ole$Q37 <- (data_ole$Q3a * data_ole$Q3b) / 7


# Factorize
# ALl analysis
data_ole$Dance_mode <- as.factor(data_ole$Dance_mode)
data_ole$Condition <- as.factor(data_ole$Condition)
data_ole$Condition <- relevel(data_ole$Condition, "D6_M6")
data_ole$Dance_mode <- factor(data_ole$Dance_mode, levels = c("D6", 'D5', 'D1'))
data_ole$Condition <- factor(data_ole$Condition, levels = c('D6_M6', 'D5_M6', 'D1_M6', 'D5_M5', 'D1_M1'))
#data_ole$Condition_order <- as.factor(data_ole$Condition_order)
data_ole$Palo <- as.factor(data_ole$Palo)
data_ole$Music_mode <- as.factor(data_ole$Music_mode)
data_ole$Music_mode <- factor(data_ole$Music_mode, levels = c("M6",'M5','M1'))
data_ole$Participant <- as.factor(data_ole$Participant)
data_ole$Pair <- as.factor(data_ole$Pair)
#data_ole$Artist <- ifelse(data_ole$Artist == "G", 0, ifelse(data_ole$Artist == "P", 1, data_ole$Artist))
data_ole$Artist <- as.factor(data_ole$Artist)
data_ole$Fam <- as.factor(data_ole$Fam)

# Instructions
data_ole$instruction <- as.factor(data_ole$instruction)
data_ole$instruction <-factor(data_ole$instruction, levels = c("D5_M6_P", "D5_M6_G",  "D1_M6_P", "D1_M6_G","D6_M6_P", "D6_M6_G",  "D5_M5_P", "D5_M5_G","D1_M1_P", "D1_M1_G"))
data_ole$instruction_2 <- as.factor(data_ole$instruction_2)
data_ole$instruction_2 <-factor(data_ole$instruction_2, levels = c("D5_M6_P_R1", "D5_M6_G_R1",  "D1_M6_P_R1", "D1_M6_G_R1","D6_M6_P_R1", "D6_M6_G_R1",  "D5_M5_P_R1", "D5_M5_G_R1","D1_M1_P_R1", "D1_M1_G_R1",
                                                               "D5_M6_P_R2", "D5_M6_G_R2",  "D1_M6_P_R2", "D1_M6_G_R2","D6_M6_P_R2", "D6_M6_G_R2",  "D5_M5_P_R2", "D5_M5_G_R2","D1_M1_P_R2", "D1_M1_G_R2"
                                                               ))

# Checking contrasts without including Palos
# Check levels

levels(data_ole$instruction)


# Subsets of data
data_filtered_Q4a <- data_ole[!is.na(data_ole$GDSI) & !is.na(data_ole$Q4a), ]
data_filtered_Q6a <- data_ole[!is.na(data_ole$GMSI) & !is.na(data_ole$Q6a), ]
data_filtered_Q6a <- data_ole[!is.na(data_ole$Q6a), ]

data_ole$INDvsGR <- as.factor(data_ole$INDvsGR)
data_ole$FIXvsOther <- as.factor(data_ole$FIXvsOther)
# Models Version 1

m00  = lmer(Q3 ~   instruction + (1 | Participant), data = data_ole )
summary(m00)
# ANOVA with orthogonal planned contrasts: (1) Homophonic vs Polyphonic; (2) Pairing with Melody vs No Melody; (3) Melody-to-Other vs Other-to-Melody
# Check order of conditions (important for specifying contrast coefficients)
FlamencoImp_Comp <- lsmeans(m00, "instruction")
A_FIXvsOther = c(-1,-1,-1,-1,4,4,-1,-1,-1,-1) # Contrasting individual vs both instruction
B_MIXvsIMP = c(-1,-1,1,1,0,0,-1,-1,1,1) # Contrasting mixed vs free improvisation
C_INDvsGR = c(-1,-1,-1,-1,0,0,1,1,1,1) # Contrast comparing Individual vs Group
D_DANvsMUS = c(-1,1,-1,1,-1,1,-1,1,-1,1) # Contrast comparing Dancer vs Musician
DxA = c(1,-1,1,-1,-4,4,1,-1,1,-1) # Interaction DxA
DxB = c(1,-1,-1,1,0,0,1,-1,-1,1) # Interaction DxB
DxC = c(1,-1,1,-1,0,0,-1,1,-1,1) # Interaction DxC
Contrasts = list(A_FIXvsOther, B_MIXvsIMP, C_INDvsGR,D_DANvsMUS,DxA, DxB, DxC )
FlamencoImp_Comp.output <- contrast(FlamencoImp_Comp, Contrasts, adjust="none") # No need for adjust for multiple comparisons since contrasts are planned & orthogonal
#capture.output(FlamencoImp_Comp.output, file = "/Users/atillajv/CODE/RITMO/R_FILES/m00_planned_contrasts.txt")
FlamencoImp_Comp.output


#Best prediciting model 

m00 = lmer(Q3b ~     instruction_2+ Q1b + Q4 + Q6 + (1 |GMSI) + (1 |Participant), data = data_ole)
m01 = lmer(Q3b ~    instruction_2 + Q1b + Q4 + Q6 + (1 |GMSI) + (1 |Participant), data = data_ole)
m02 = lmer(Q3b ~    Q1b + Q4 + Q6 + Abs_Av + (1 |GMSI) + (1 |Participant), data = data_ole)
m03 = lmer(Q3b ~    instruction_2 + Q1b + Q4  + Q6 + Perf_Av +  Abs_Av + (1 |GMSI) + (1 |Participant), data = data_ole)
anova(m00, m01, m02, m03)


#Models Version 2
m00  = lmer(Q1a~ 1 +  (1 | Participant), data = data_ole )
m01  = lmer(Q1a ~ 1 +  (1 | Pair), data = data_ole )
m02  = lmer(Q1a ~ 1 +  (1 | Participant)+  (1 | Pair), data = data_ole )
m03  = lmer(Q1a ~  instruction_2 + (1 | Participant), data = data_ole )
m04  = lmer(Q1a ~  instruction_2 + (1 | Participant)+  (1 | Pair), data = data_ole )
anova(m00,m01, m02,m03, m04)


m00  = lmer(Q3b ~ 1 +  (1 | Participant), data = data_ole )
m01  = lmer(Q3b ~ 1 +  (1 | Pair), data = data_ole )
m02  = lmer(Q3b ~ 1 +  (1 | Participant)+  (1 | Pair), data = data_ole )
m03  = lmer(Q3b ~ 1 +  (1 | Pair/Participant), data = data_ole )
m04  = lmer(Q3b ~  instruction_2 + (1 | Participant) + (1|Pair), data = data_ole )
m05  = lmer(Q3b ~  instruction_2  + (1|Pair), data = data_ole )
m06  = lmer(Q3b ~  instruction_2 + (1 | Participant) + (1 | Pair), data = data_ole )
m07  = lmer(Q3b ~  instruction_2 + (1 | Pair/Participant), data = data_ole )
anova(m00,m01, m02,m03, m04,m05, m06, m07)

tab_model(m00, m01, m02,m03,m04,m05, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00","m01", "m02", 'm03', 'm04',"m05"), digits = 5 )

m06  = lmer(Q3b ~   + (1 | Participant) + (1 | Pair), data = data_ole )
m07  = lmer(Q3b ~  instruction_2 + (1 | Pair/Participant), data = data_ole )



# Fit separate models for each group
model_participant <- lmer(Perf_Av ~ instruction_2 + (1 | Participant), data = data_ole)
model_pair <- lmer(Perf_Av ~ instruction_2 + (1 | Pair), data = data_ole)
model_nested <- lmer(Perf_Av ~ instruction_2 + (1 | Pair/Participant), data = data_ole)

# Extract random intercepts for each group
participant_intercept <- ranef(model_participant)$Participant[, 1]
pair_intercept <- ranef(model_pair)$Pair[, 1]
nested_intercept <- ranef(model_nested)$`Participant:Pair`[, 1]


# Get the random intercepts for the Participant:Pair level
random_intercepts <- ranef(model_nested)$`Participant:Pair`
# Get the level names for the random intercepts
level_names <- rownames(random_intercepts)
data_ole <- data_ole %>%
  mutate(Nested = paste(Participant, Pair, sep = ":"))


## ONLY RUN ONCE
# Extract the pair and participant numbers from the level names
level_names_split <- strsplit(level_names, split = ":|_")
pairs <- sapply(level_names_split, function(x) paste(x[2], x[3], sep = "_"))
participants <- sapply(level_names_split, function(x) x[1])
mapping_df <- data.frame(Pair = pairs, Participant = participants, Nested_Name = level_names)
#data_ole <- merge(data_ole, mapping_df, by = c("participant_num", "Pair"))


# Convert the level_names to a data frame
library(tidyr)

# Only run ONCE
# Create a data frame to map each pair+participant to its nested name
#mapping_df <- data.frame(Pair = pairs, Participant = participants, Nested_Name = level_names)

# Merge the mappings into the original data frame
#data_ole <- merge(data_ole, mapping_df, by = c("Participant", "Pair"))

# Create new numerical variables for "participant" and "pair"
data_ole$participant_num <- as.numeric(factor(data_ole$Participant))
data_ole$pair_num <- as.numeric(factor(data_ole$Pair))
data_ole$nested_num <- as.numeric(factor(data_ole$Nested))

# Add random intercepts to the new variables
data_ole$participant_intercept <- participant_intercept[data_ole$participant_num]
data_ole$pair_intercept <- pair_intercept[data_ole$pair_num]
data_ole$nested_intercept <- nested_intercept[data_ole$nested_num]

# Check for collinearity between random intercepts
cor(data_ole$participant_intercept, data_ole$pair_intercept)
cor(data_ole$participant_intercept, data_ole$nested_intercept)
cor(data_ole$pair_intercept, data_ole$nested_intercept)


# Create a scatter plot with a fitted line for all three models
ggplot() +
  geom_jitter(data = data_ole, aes(x = participant_num, y = participant_intercept, color = "Participant"), width = 0.2, height = 0.2) +
  geom_smooth(data = data_ole, aes(x = participant_num, y = participant_intercept), method = "lm", color = "blue") +
  geom_jitter(data = data_ole, aes(x = participant_num, y = pair_intercept, color = "Pair"), width = 0.2, height = 0.2) +
  geom_smooth(data = data_ole, aes(x = participant_num, y = pair_intercept), method = "lm", color = "red") +
  geom_jitter(data = data_ole, aes(x = participant_num, y = nested_intercept, color = "Nested"), width = 0.2, height = 0.2) +
  geom_smooth(data = data_ole, aes(x = participant_num, y = nested_intercept), method = "lm", color = "green") +
  scale_color_manual(values = c("green","red", "blue")) +
  xlab("Group") +
  ylab("Random Intercept") +
  ggtitle("Random Intercepts for Participant, Pair, and Nested Models")


ggplot() +
  geom_jitter(data = data_ole, aes(x = participant_num, y = participant_intercept, color = "Participant"), width = 0.2, height = 0.2) +
  geom_smooth(data = data_ole, aes(x = participant_num, y = participant_intercept), method = "lm", color = "blue") +
  geom_jitter(data = data_ole, aes(x = participant_num, y = pair_intercept, color = "Pair"), width = 0.2, height = 0.2) +
  geom_smooth(data = data_ole, aes(x = pair_num, y = pair_intercept), method = "lm", color = "red") +
  geom_jitter(data = data_ole, aes(x = participant_num, y = nested_intercept, color = "Nested"), width = 0.2, height = 0.2) +
  geom_smooth(data = data_ole, aes(x = nested_num, y = nested_intercept), method = "lm", color = "green") +
  scale_color_manual(values = c("green","red", "blue")) +
  xlab("Group") +
  ylab("Random Intercept") +
  ggtitle("Random Intercepts for Participant, Pair, and Nested Models")




ggplot() +
  geom_jitter(data = data_ole, aes(x = pair_num, y = participant_intercept, color = "Participant"), width = 0.2, height = 0.2) +
  geom_smooth(data = data_ole, aes(x = pair_num, y = participant_intercept), method = "lm", color = "blue") +
  geom_jitter(data = data_ole, aes(x = pair_num, y = pair_intercept, color = "Pair"), width = 0.2, height = 0.2) +
  geom_smooth(data = data_ole, aes(x = pair_num, y = pair_intercept), method = "lm", color = "red") +
  geom_jitter(data = data_ole, aes(x = pair_num, y = nested_intercept, color = "Nested"), width = 0.2, height = 0.2) +
  geom_smooth(data = data_ole, aes(x = pair_num, y = nested_intercept), method = "lm", color = "green") +
  scale_color_manual(values = c("green","red", "blue")) +
  xlab("Group") +
  ylab("Random Intercept") +
  ggtitle("Random Intercepts for Participant, Pair, and Nested Models")



# Print the results
data_ole_q1a_pair



m00  = lmer(Perf_Av ~  instruction_2 + (1 | Participant), data = data_ole )
m01  = lmer(Perf_Av ~ 1 +  (1 | Participant), data = data_ole )
anova(m00, m01)


m00 = lmer(Q6b ~  1 + (1 | Participant), data = data_ole )
m01  = lmer(Q6b ~  1 + (1 | Pair), data = data_ole )
m02  = lmer(Q6b ~  1 + (1 | Pair/Participant), data = data_ole )

anova(m00, m01)

tab_model(m00, m01, m02,m03,m04,m05, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00","m01", "m02", 'm03', 'm04',"m05"), digits = 5 )



m01  = lmer(Q2a ~ instruction_2 + (1 | Pair/Participant), data = data_ole )


m00 = lmer(Abs_Av ~ 1 + (1 |Pair) , data = data_ole)
m01  = lmer(Abs_Av ~  instruction_2+ (1 |Pair), data = data_ole )
anova(m00,m01)


m00 = lmer(Q6b ~ 1 + (1 |Pair) + (1 | Participant), data = data_filtered_Q6a)
m01  = lmer(Q6b ~  instruction_2+ (1 |Pair) + (1 | Participant), data = data_filtered_Q6a )
anova(m00,m01)

# m00 = lmer(Q3 ~ Q1b * Condition + (1 |Pair) + (1 | Participant), data = data_ole)
# m01 = lmer(Q3 ~ Q4a * Condition +  (1 |Pair) + (1 | Participant), data = data_ole)

m00 = lmer(Q1b ~ 1 + (1 |Pair) + (1 | Participant), data = data_ole)
m01  = lmer(Q1b ~  instruction_2 + (1 |Pair) + (1 | Participant), data = data_ole )

tab_model(m00, m01, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00","m01"), digits = 5 )

anova(m00,m01)
summary(m00)

data_ole$Q6b_c <- scale(data_ole$Q6b)


levels(data_ole$instruction_2)
# ANOVA with orthogonal planned contrasts: (1) Homophonic vs Polyphonic; (2) Pairing with Melody vs No Melody; (3) Melody-to-Other vs Other-to-Melody
# Check order of conditions (important for specifying contrast coefficients)
FlamencoImp_Comp <- lsmeans(m01, "instruction_2")


# Define names for contrast coefficients
names_contrasts <- c("A_FIXvsOther", "B_MIXvsIMP", "C_INDvsGR", "D_DANvsMUS", "E_R1vsR2","F_FIXvsMIX","G_FIXvsIMP", "DxA", "DxB", "DxC", "DxF", "DxG")
contrasts <- list(
  A_FIXvsOther = c(1,1,1,1,-4,-4,1,1,1,1,1,1,1,1,-4,-4,1,1,1,1),
  B_MIXvsIMP = c(-1,-1,1,1,0,0,-1,-1,1,1,-1,-1,1,1,0,0,-1,-1,1,1),
  C_INDvsGR = c(-1,-1,-1,-1,0,0,1,1,1,1,-1,-1,-1,-1,0,0,1,1,1,1),
  D_DANvsMUS = c(1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1),
  E_R1vsR2 = c(1,1,1,1,1,1,1,1,1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1),
  # F_FIXvsMIX = c(1,1,0,0,-1,-1,1,1,0,0,1,1,0,0,-1,-1,1,1,0,0),
  # G_FIXvsIMP = c ( 0,0,1,1,-1,-1,0,0,1,1,0,0,1,1,-1,-1,0,0,1,1),
  DxA =  c(1,-1,1,-1,-4,4,1,-1,1,-1,1,-1,1,-1,-4,4,1,-1,1,-1),
  DxB =  c(1,-1,-1,1,0,0,1,-1,-1,1,1,-1,-1,1,0,0,1,-1,-1,1),
  DxC =  c(1,-1,1,-1,0,0,-1,1,-1,1,1,-1,1,-1,0,0,-1,1,-1,1),
  # DxF =  c(-1,1,0,0,1,-1,-1,1,0,0,-1,1,0,0,1,-1,-1,1,0,0),
  # DxG =  c(0,0,-1,1,1,-1,0,0,-1,1,0,0,-1,1,1,-1,-1,1,0,0),
  ExA =  c(-1,-1,-1,-1,4,4,-1,-1,-1,-1,1,1,1,1,-4,-4,1,1,1,1),
  ExB =  c(-1,-1,1,1,0,0,-1,-1,1,1,1,1,-1,-1,0,0,1,1,-1,-1),
  ExC =  c(-1,-1,-1,-1,0,0,1,1,1,1,1,1,1,1,0,0,-1,-1,-1,-1),
  ExD =  c(-1,1,-1,1,-1,1,-1,1,-1,1,1,-1,1,-1,1,-1,1,-1,1,-1),
  # ExF =  c(1,1,0,0,-1,-1,1,1,0,0,-1,-1,0,0,1,1,-1,-1,0,0),
  # ExG =  c(0,0,1,1,-1,-1,0,0,1,1,0,0,-1,-1,1,1,-1,-1,0,0),
  DxCxA =  c(-1,1,-1,1,0,0,1,-1,1,-1,-1,1,-1,1,0,0,1,-1,1,-1),
  DxCxB =  c(-1,1,1,-1,0,0,1,-1,-1,1,-1,1,1,-1,0,0,1,-1,-1,1),
  DxCxE =  c(1,-1,1,-1,0,0,-1,1,-1,1,-1,1,-1,1,0,0,1,-1,1,-1),
  # DxCxF =  c(1,-1,0,0,0,0,-1,1,0,0,1,-1,0,0,0,0,-1,1,0,0),
  # DxCxG =  c(0,0,1,-1,0,0,0,0,-1,1,0,0,1,-1,0,0,-1,1,0,0),
  DxExA =  c(1,-1,1,-1,-4,4,1,-1,1,-1,-1,1,-1,1,4,-4,-1,1,-1,1),
  DxExB =  c(1,-1,-1,1,0,0,1,-1,-1,1,-1,1,1,-1,0,0,-1,1,1,-1)
  # DxExF =  c(-1,1,0,0,1,-1,-1,1,0,0,1,-1,0,0,-1,1,1,-1,0,0),
  # DxExG =  c(0,0,-1,1,1,-1,0,0,-1,1,0,0,1,-1,-1,1,1,-1,0,0)
  
)


# Run contrasts and assign names to output table
FlamencoImp_Comp.output <- contrast(FlamencoImp_Comp, contrasts, adjust="none", names = names_contrasts)
FlamencoImp_Comp.output
levels(FlamencoImp_Comp$A_FIXvsOther)

mean_by_group <- data_ole %>%
  group_by("FIXvsOther") %>%
  summarize(mean_Q6b = mean(Q6b, na.rm = TRUE))


FlamencoImp_Comp.output.ci <- confint(FlamencoImp_Comp.output)
FlamencoImp_Comp.output.ci

max_Q3b <- max(data_ole$Q3b, na.rm = TRUE)

max_Q3b

# Run lsmeans for factor A (instruction_2)
lsmeans_output <- lsmeans(FlamencoImp_Comp, "instruction_2")

# Display the estimated marginal means for each level of factor A
summary(lsmeans_output)




# Fit separate models for each group
model_participant <- lmer(Abs_Av ~ instruction_2 + (1 | Participant), data = data_ole)
model_pair <- lmer(Abs_Av ~ instruction_2 + (1 | Pair), data = data_ole)

# Extract random intercepts for each group
participant_intercept <- ranef(model_participant)$Participant[, 1]
pair_intercept <- ranef(model_pair)$Pair[, 1]

# Create new numerical variables for "participant" and "pair"
data_ole$participant_num <- as.numeric(factor(data_ole$Participant))
data_ole$pair_num <- as.numeric(factor(data_ole$Pair))

# Add random intercepts to the new variables
data_ole$participant_intercept <- participant_intercept[data_ole$participant_num]
data_ole$pair_intercept <- pair_intercept[data_ole$pair_num]

# Check for collinearity between "participant_intercept" and "pair_intercept"
cor(data_ole$participant_intercept, data_ole$pair_intercept)


# Create a scatter plot with a fitted line for both the participant and pair models
ggplot() +
  geom_jitter(data = data_ole, aes(x = participant_num, y = participant_intercept, color = "Participant"), width = 0.2, height = 0.2) +
  geom_smooth(data = data_ole, aes(x = participant_num, y = participant_intercept), method = "lm", color = "red") +
  geom_jitter(data = data_ole, aes(x = pair_num, y = pair_intercept, color = "Pair"), width = 0.2, height = 0.2) +
  geom_smooth(data = data_ole, aes(x = pair_num, y = pair_intercept), method = "lm", color = "blue") +
  scale_color_manual(values = c("blue", "red")) +
  xlab("Group") +
  ylab("Random Intercept") +
  ggtitle("Random Intercepts for Participant and Pair Models")




#contrasts <- list(A_FIXvsOther = c(-1,-1,-1,-1,4,4,-1,-1,-1,-1,-1,-1,-1,-1,4,4,-1,-1,-1,-1),
#                  B_MIXvsIMP = c(-1,-1,1,1,0,0,-1,-1,1,1,-1,-1,1,1,0,0,-1,-1,1,1),
#                  C_INDvsGR = c(-1,-1,-1,-1,0,0,1,1,1,1,-1,-1,-1,-1,0,0,1,1,1,1),
#                  D_DANvsMUS = c(-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1),
#                  E_R1vsR2 = c(1,1,1,1,1,1,1,1,1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1),
#                  DxA = c(1,-1,1,-1,-4,4,1,-1,1,-1,1,-1,1,-1,-4,4,1,-1,1,-1),
#                  DxB = c(1,-1,-1,1,0,0,1,-1,-1,1,1,-1,-1,1,0,0,1,-1,-1,1),
#                  DxC = c(1,-1,1,-1,0,0,-1,1,-1,1,1,-1,1,-1,0,0,-1,1,-1,1),
#                  ExA = c(-1,-1,-1,-1,4,4,-1,-1,-1,-1,1,1,1,1,-4,-4,1,1,1,1),
#                  ExB = c(-1,-1,1,1,0,0,-1,-1,1,1,1,1,-1,-1,0,0,1,1,-1,-1),
#                  ExC = c(-1,-1,-1,-1,0,0,1,1,1,1,1,1,1,1,0,0,-1,-1,-1,-1),
#                  ExD = c(-1,1,-1,1,-1,1,-1,1,-1,1,1,-1,1,-1,1,-1,1,-1,1,-1),
#                  DxAxE = c(1,-1,1,-1,-4,4,1,-1,1,-1,-1,1,-1,1,4,-4,-1,1,-1,1),
#                  DxBxE = c(1,-1,-1,1,0,0,1,-1,-1,1,-1,1,1,-1,0,0,-1,1,1,-1),
#                 DxCxE = c(1,-1,1,-1,0,0,-1,1,-1,1,-1,1,-1,1,0,0,1,-1,1,-1)
#                 )


#A_FIXvsOther = c(-1,-1,-1,-1,4,4,-1,-1,-1,-1,-1,-1,-1,-1,4,4,-1,-1,-1,-1) # Contrasting individual vs both instruction
#B_MIXvsIMP = c(-1,-1,1,1,0,0,-1,-1,1,1,-1,-1,1,1,0,0,-1,-1,1,1) # Contrasting mixed vs free improvisation
#C_INDvsGR = c(-1,-1,-1,-1,0,0,1,1,1,1,-1,-1,-1,-1,0,0,1,1,1,1) # Contrast comparing Individual vs Group
#D_DANvsMUS = c(-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1) # Contrast comparing Dancer vs Musician
#E_R1vsR2 = c(1,1,1,1,1,1,1,1,1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1)
#DxA = c(1,-1,1,-1,-4,4,1,-1,1,-1,1,-1,1,-1,-4,4,1,-1,1,-1) # Interaction DxA
#DxB = c(1,-1,-1,1,0,0,1,-1,-1,1,1,-1,-1,1,0,0,1,-1,-1,1) # Interaction DxB
#DxC = c(1,-1,1,-1,0,0,-1,1,-1,1,1,-1,1,-1,0,0,-1,1,-1,1) # Interaction DxC
#Contrasts = list(A_FIXvsOther, B_MIXvsIMP, C_INDvsGR,D_DANvsMUS, E_R1vsR2, DxA, DxB, DxC )
#FlamencoImp_Comp.output <- contrast(FlamencoImp_Comp, Contrasts, adjust="none") # No need for adjust for multiple comparisons since contrasts are planned & orthogonal
#capture.output(FlamencoImp_Comp.output, file = "/Users/atillajv/CODE/RITMO/R_FILES/m00_planned_contrasts.txt")
#FlamencoImp_Comp.output



##### T-TEST Interaction Effect #### 





#### ANALYSIS 2 #### 

library(ggplot2)
library(sjPlot)
library(sjlabelled)
library(sjmisc)
library(dplyr)
library(tidyr)

library(lme4)
library(lmerTest)
library(psych)

m00  = lmer(Q3b ~ 1 +  (1 | Participant), data = data_ole )
m01  = lmer(Q3b ~ 1 +  (1 | Pair), data = data_ole )
m02  = lmer(Q3b ~ 1 +  (1 | Participant)+  (1 | Pair), data = data_ole )
m03  = lmer(Q3b ~ 1 +  (1 | Pair/Participant), data = data_ole )
anova(m00,m01, m02,m03)

# (1|Pair) + (1|Participant) is better, but they are very similar. 


m00  = lmer(Q3b ~  Q1b + (1 | Participant), data = data_ole )
m01  = lmer(Q3b ~  Q1b  + (1|Participant/Pair), data = data_ole )
m02  = lmer(Q3b ~  Q1b + (1 | Participant) + (1 | Pair), data = data_ole )
m03  = lmer(Q3b ~  Q1b + (1 | Pair), data = data_ole )
anova(m00,m01, m02,m03)

tab_model(m00, m01, m02,m03, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00","m01", "m02", 'm03'), digits = 5 )

m00  = lmer(Q3b ~  Q1a  + (1|Participant), data = data_ole )
m01  = lmer(Q3b ~  Q1b  + (1|Participant), data = data_ole )
m02  = lmer(Q3b ~  Q4  + (1|Participant), data = data_ole )
m03  = lmer(Q3b ~  Q5  + (1|Participant), data = data_ole )
m04  = lmer(Q3b ~  Q6  + (1|Participant), data = data_ole )
tab_model(m00, m01, m02,m03,m04, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00","m01", "m02", 'm03', 'm04'), digits = 5 )
anova(m00,m01)
anova(m02,m04)

m00  = lmer(Q3b ~  Q4a  +Q1b + Abs_Av + GDSI +  (1 | Participant), data = data_ole )
m01  = lmer(Q3b ~  Q4a + Q1b + Abs_Av + GDSI +  (1 | Participant),  data = data_ole )
anova(m00,m01)
tab_model(m00, m01, m02,m03,m04, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00","m01", "m02", 'm03', 'm04'), digits = 5 )




m00  = lmer(Q3b ~  Q4a  +Q1b + Abs_Av +  Q6 *GDSI +  (1 | Participant), data = data_ole )
m01  = lmer(Q3b ~  Q4a + Q1b +  Abs_Av + Q6 +GDSI +  (1 | Participant),  data = data_ole )
m02  = lmer(Q3b ~  Q4a + Q1b +  Abs_Av + GDSI * Q6a +  (1 | Participant),  data = data_ole )
m00  = lmer(Q3b ~  Q6a +  (1 | Participant), data = data_ole )
m01  = lmer(Q3b ~ Q6b + (1 | Participant),  data = data_ole )
m02  = lmer(Q3b ~ Q6 + (1 | Participant),  data = data_ole )
anova(m00,m02, m01)

tab_model(m00, m01, m02,m03,m04, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00","m01", "m02", 'm03', 'm04'), digits = 5 )


#BEST FITTING MODELS
#m00 = lmer(Q3b ~ 1 +  (1 | Participant),  data = data_ole )
m00 = lmer(Q3b ~  Q4a * Palo + Q1b + Abs_Av + GDSI +  (1 | Pair/Participant),  data = data_ole )
m01 = lmer(Q3b ~  Q4a * Palo + Q1b + Abs_Av + GDSI +  (1 | Pair/Participant),  data = data_ole )
m02 = lmer(Q3b ~  Q4a + Q1b + Abs_Av + GDSI +  (1 | Pair/Participant),  data = data_ole )

m03  = lmer(Q3b ~  Q4a  +Q1b + Abs_Av +  Q6a *GDSI +  (1 | Pair/Participant), data = data_ole )
m04  = lmer(Q3b ~  Q4a  +Q1b + Abs_Av +  Q6 *GDSI +  (1 | Pair/Participant), data = data_ole )
m05  = lmer(Q3b ~  Q4a*Palo  +Q1b + Abs_Av +  Q6 *GDSI +  (1 | Pair/Participant), data = data_ole )
anova(m04, m05)

tab_model(m00, m01,m02,m03, m04,m05,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00","m01", "m02", "m03", "m04", "m05"), digits = 5 )



#### BEST FITTING MODELS 2024 # WHOLE DATASET


# data_filtered_Q4a <- na.omit(data_ole[, c("Q4a")]) 
# data_filtered_Q4a <- data_ole[!is.na(data_ole$Q4a), ]
# 




m00a = lmer(Q3 ~  1 +  (1 | Pair/Participant), data = data_filtered_Q4a)
m01a = lmer(Q3 ~  Q4a + Q1b + GDSI +  (1 | Pair/Participant), data = data_filtered_Q4a)
m02a = lmer(Q3 ~  Q4a + Q1b + GDSI + Abs_Av +  (1 | Pair/Participant), data = data_filtered_Q4a)

m02a = lmer(Q3 ~  Q4a + Q1b + GDSI + Abs_Av +  (1 | Pair/Participant) , data = data_filtered_Q4a)
m02a = lmer(Q3 ~  Q4a + Q1b + GDSI + Abs_Av +  (1 | Pair:Participant)+  (1 + Q4a | Participant) , data = data_filtered_Q4a)

m02a = lmer(Q3 ~  Q4a + Q1b + GDSI + Abs_Av +  (1  | Pair:Participant)+  (1 | Pair) , data = data_filtered_Q4a) 
m02b = lmer(Q3 ~  Q4a + Q1b + GDSI + Abs_Av +  (1 | Pair/Participant) , data = data_filtered_Q4a)


tab_model(m02a, m02b, m02a,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m02a","m02b", "m02a"), digits = 5 )


m02a = lmer(Q3 ~  Q4a + Q1b + GDSI + Abs_Av +  (1 | Pair) + (1 + Q4a| Participant), data = data_filtered_Q4a)


summary(m02a)
anova( m01a,m02b)

## CHeck for random slopes
m01a = lmer(Q3 ~  Q4a + Q1b + GDSI +  (1 + GDSI | Pair/Participant), data = data_filtered_Q4a)

m00a = lmer(Q3 ~    Q4a + Q1b + GDSI +   (1 + Q4a | Participant), data = data_filtered_Q4a)
m01a = lmer(Q3 ~   Q4a + Q1b + GDSI +  (1 | Pair/Participant), data = data_filtered_Q4a)
m02a = lmer(Q3 ~   Q4a + Q1b + GDSI +  (1  | Participant), data = data_filtered_Q4a)

anova(m00a, m01a)

# Adding Q4a, Q1b, GDSI (each at the time to full model) as random slopes results in singularity issue therefore, accroding the Barr et al. minimum model. 
# Adding to simple model Q3 ~   X + (1 + X | Pair/Participant) runs into singularity issues for GDSI, Q4a, Q1b
# Simplifying even more  Q3 ~   X + (1 + X | Participant) rund into singularity issues for Q1b, GDSI


anova(m00a, m01a)


tab_model(m00a, m01a, m02a,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00a","m01a", "m02a"), digits = 5 )

tab_model(m00a, m01a, m02a,  m03a, m04a,m02b,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00","m01", "m02", "m03", "m04", "m05", "m06"), digits = 5 )

m00 = lmer(Q3 ~  1 + Q1b  (1 | Participant), data = data_ole)
m01 = lmer(Q3 ~  Q1b  +Q4a + Abs_Av + GDSI +  (1 | Pair/Participant), data = data_ole)
m02 = lmer(Q3 ~  Q1b  +Q4a + Abs_Av + GDSI +  (1 | Participant), data = data_ole)

tab_model(m00a, m01a, m02a,  m03a, m04a,m02b,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00","m01", "m02", "m03", "m04", "m05", "m06"), digits = 5 )


anova(m01, m02)
summary(m01)


m00a = lmer(Q3 ~  1 +  (1 | Pair/Participant), data = data_filtered_Q4a)
m01a = lmer(Q3 ~  Q4a + Q1b +  GDSI + (1 + Q4a | Participant), data = data_filtered_Q4a)
m02a = lmer(Q3 ~  Q4a + Q1b  +  Abs_Av +  (1 + Q4a | Participant), data = data_filtered_Q4a)
m03a = lmer(Q3 ~ Q4a + Q1b  +  GDSI + Abs_Av +   (1  + Q4a| Participant), data = data_filtered_Q4a)
m04a = lmer(Q3 ~  Q1b +  (1  | Participant), data = data_filtered_Q4a) 
m05a = lmer(Q3 ~  GDSI +  (1 | Participant), data = data_filtered_Q4a)

anova(m02a, m03a)

# Q1b, GDSI,  none of models possibel by adding random slope. Is a fixed effect punto. 
# Abs_Av, Q4a can add it as varying slope in simple model 

tab_model(m00a, m01a, m02a,  m03a, m04a,m05a,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00","m01", "m02", "m03", "m04", "m05", "m06"), digits = 5 )



m00a = lmer(Q3 ~  1 +  (1 + Q4a | Participant), data = data_filtered_Q4a)
m01a = lmer(Q3 ~ Q4a + Q1b + Abs_Av + GDSI +  (1 + Q4a | Participant), data = data_filtered_Q4a)
m02a = lmer(Q3 ~  Perf_Av +   Abs_Av +  (1 + Q4a | Participant), data = data_filtered_Q4a)
m03a = lmer(Q3 ~ Q2a +    (1  + Q4a| Participant), data = data_filtered_Q4a)
m04a = lmer(Q3 ~  Q1b +  (1  | Participant), data = data_filtered_Q4a) 
m05a = lmer(Q3 ~  GDSI +  (1 | Participant), data = data_filtered_Q4a)

anova(m02a, m03a)

# Q1b, GDSI,  none of models possibel by adding random slope. Is a fixed effect punto. 
# Abs_Av, Q4a can add it as varying slope in simple model 

tab_model(m00a, m01a, m02a,  m03a, m04a,m05a,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00","m01", "m02", "m03", "m04", "m05", "m06"), digits = 5 )

m01a = lmer(Q3 ~   Q1b+ Q4a  +  Abs_Av + GDSI +  (1 + Q4a | Pair) + (1 |Participant), data = data_filtered_Q4a)
m01b = lmer(Q3 ~   Q1b + Q4a + Abs_Av + GDSI +   (1  | Pair) + (1 + Q4a |Participant), data = data_filtered_Q4a)
m02a = lmer(Q3 ~    Q1b + Q4a +Abs_Av + Q6b  + (1 |GMSI) + (1 | Pair) + (1 |Participant), data = data_filtered_Q6a)
m02b = lmer(Q3 ~    Q1b + Q4a + Abs_Av + Q6b  + (1 | Pair)  + (1 + Q4a|Participant), data = data_filtered_Q6a)
m02c = lmer(Q3 ~    Q1b + Q4a + Abs_Av + Q6b + GDSI +  (1  | Pair)  + (1 + Q4a |Participant), data = data_filtered_Q6a)
tab_model(m01a, m01b, m02a,  m02b,m02c,
          p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          pred.labels =c("(Intercept)", "Quality of improvisation", "Connection with partner","Absorption by activity"  ,"Dance Expertise" ,"Rhythmic Complexity"),
          dv.labels=c("model 1a","model 1b", "model 2a", "model 2b", "model 2c"), digits = 5)


m01a = lmer(Q3 ~   Q1b+  (1 + Q1b | Pair/Participant), data = data_filtered_Q4a)
m01a = lmer(Q3 ~   Q4a+  (1 + Q4 | Pair/Participant), data = data_filtered_Q4a)


m01a = lmer(Q3 ~   Q1b+ Q4a  +  Abs_Av + GDSI +  (1 | Pair), data = data_filtered_Q4a)
m01b = lmer(Q3 ~   Q1b + Q4a + Abs_Av + GDSI +   (1  + Q4a| Pair), data = data_filtered_Q4a)
m02a = lmer(Q3 ~    Q1b + Q4a +Abs_Av + Q6b  + (1 |GMSI) + (1 | Pair), data = data_filtered_Q6a)
m02b = lmer(Q3 ~    Q1b + Q4a + Abs_Av + Q6b  + (1 + Q4a | Pair), data = data_filtered_Q6a)
m02c = lmer(Q3 ~    Q1b + Q4a + Abs_Av + Q6b + GDSI +  (1 + Q4a | Pair), data = data_filtered_Q6a)
 tab_model(m01a, m01b, m02a,  m02b,m02c,
          p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          pred.labels =c("(Intercept)", "Quality of improvisation", "Connection with partner","Absorption by activity"  ,"Dance Expertise" ,"Rhythmic Complexity"),
          dv.labels=c("model 1a","model 1b", "model 2a", "model 2b", "model 2c"), digits = 5)



m01a = lmer(Q3 ~   Q1b+ Q4a  +  Abs_Av + GDSI +  (1 | Pair/Participant), data = data_filtered_Q4a)
m01b = lmer(Q3 ~   Q1b + Q4a + Abs_Av + GDSI +   (1  + | Pair/Participant), data = data_filtered_Q4a)


m02a = lmer(Q3 ~    Q1b + Q4a +Abs_Av + Q6b  + (1 |GMSI) + (1 | Pair/Participant), data = data_filtered_Q6a)
m02b = lmer(Q3 ~    Q1b + Q4a + Abs_Av + Q6b  + (1 + Q4a | Pair/Participant), data = data_filtered_Q6a)
m02c = lmer(Q3 ~    Q1b + Q4a + Abs_Av + Q6b + GDSI +  (1 + Q4a | Pair/Participant), data = data_filtered_Q6a)

sjPlot::tab_model(m01a, 
                  show.re.var= TRUE, 
                  pred.labels =c("(Intercept)", "Connection", "Quality Improvisation", "GDSI"),
                  dv.labels= "Model 1 - Main Predictors of Flow")

tab_model(m01a, m01b, m02a,  m02b,m02c,
          p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          pred.labels =c("(Intercept)", "Quality of improvisation", "Connection with partner","Absorption by activity"  ,"Dance Expertise" ,"Rhythmic Complexity"),
          dv.labels=c("model 1a","model 1b", "model 2a", "model 2b", "model 2c"), digits = 5)

        file = "/Users/atillajv/LaTex/5ec0f6099dc1fe00017f2156/paper1/images/lmer_models_table_draft2_2.html")


anova(m02b,m02c)


library(webshot)
webshot("/Users/atillajv/LaTex/5ec0f6099dc1fe00017f2156/paper1/images/lmer_models_table_draft2_2.html", 
        "/Users/atillajv/LaTex/5ec0f6099dc1fe00017f2156/paper1/images/lmer_models_table_draft2_2.png")


anova(m02b,m02c)

row_index <- grep("Dance Exp.", rownames(table$coefficients))
column_index <- grep("Pr(>|t|)", colnames(table$coefficients))

# Replace the "*" with a "." for the specific cell
table$coefficients[row_index, column_index] <- "."

# Print the modified table
print(table)


anova(m02b, m02c)
tab_model(m00a, m01a,  m02a, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("Flow","Flow", "Flow"), digits = 5 ,
          file = "/Users/atillajv/LaTex/5ec0f6099dc1fe00017f2156/paper1/images/lmer_model1_table.html"
)
library(webshot)
webshot("/Users/atillajv/LaTex/5ec0f6099dc1fe00017f2156/paper1/images/lmer_model1_table.html", "/Users/atillajv/LaTex/5ec0f6099dc1fe00017f2156/paper1/images/lmer_model1_table.png")



m00b = lmer(Q3 ~ 1 + (1 | Participant), data = data_filtered_Q6a )

m00b = lmer(Q3 ~    Q1b + Q4a + Abs_Av  + GDSI + (1 + Q4a | Participant), data = data_filtered_Q6a)
m01b = lmer(Q3 ~    Q1b + Q4a + Q6b + Abs_Av + (1 |GMSI) + (1 | Participant), data = data_filtered_Q6a)
m02b = lmer(Q3 ~    Q1b + Q4a + Q6b  + GDSI + (1 |GMSI) + (1 | Participant), data = data_filtered_Q6a)
m03b = lmer(Q3 ~    Q1b + Q4a + Q6b  + Abs_Av + (1 | Participant), data = data_filtered_Q6a) 
m04b = lmer(Q3 ~    Q1b + Q4a + Q6b  + Abs_Av + GDSI + (1 | Participant), data = data_filtered_Q6a) 
m05b = lmer(Q3 ~    Q1b + Q4a + Q6b  + Abs_Av + GDSI + (1 | GMSI) + (1 | Participant), data = data_filtered_Q6a) 



m02a = lmer(Q3 ~    Q1b + Q4a + Q6b + Abs_Av + (1 |GMSI) + (1 | Participant), data = data_filtered_Q6a)
m02b = lmer(Q3 ~    Q1b + Q4a + Q6b + Abs_Av + (1 + Q4a | Participant), data = data_filtered_Q6a)
m02c = lmer(Q3 ~    Q1b + Q4a + Q6b + Abs_Av + GDSI +  (1 + Q4a | Participant), data = data_filtered_Q6a)
anova(m00b, m02b)
anova(m00b,m01b, m02b, m03b, m04b, m05b)
summary(m02a)
tab_model(m00b, m01b,  m03b,m02b, m04b, m05b,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("Flow","Flow", "Flow", "Flow", "Flow", "Flow"), digits = 5,)
          file = "/Users/atillajv/LaTex/5ec0f6099dc1fe00017f2156/paper1/images/lmer_model2_table.html"
)
library(webshot)
webshot("/Users/atillajv/LaTex/5ec0f6099dc1fe00017f2156/paper1/images/lmer_model2_table.html", "/Users/atillajv/LaTex/5ec0f6099dc1fe00017f2156/paper1/images/lmer_model2_table.png")


m00 = lmer(Abs_Av ~    GMSI + (1 | Participant), data = data_filtered_Q6a) 

m01b = lmer(Q3 ~    GDSI  + (1 | Participant), data = data_filtered_Q4a)
# No single effect of GDSI on Q6a data, 

m01b = lmer(Q3 ~    Q1b + Q4a  + Abs_Av +GDSI  + (1 | Participant), data = data_filtered_Q6a)

m01b = lmer(Q3 ~    Q1b + Q4a  + Abs_Av + (1  | GMSI) + (1 + Q6b | Participant), data = data_filtered_Q6a)
m02b = lmer(Q3 ~    Q1b + Q4a + Abs_Av + Q6b +  (1  + Q6b | Participant) + (1 | GMSI), data = data_filtered_Q6a)
m03b = lmer(Q3 ~    Q1b + Q4a + Abs_Av + (1  + Abs_Av | Participant) + (1 | GMSI), data = data_filtered_Q6a)
m04b = lmer(Q3 ~    Q1b + Q4a + Abs_Av  + Q6b +  (1  + Abs_Av | Participant) + (1 | GMSI), data = data_filtered_Q6a)
anova(m01b, m02b, m03b, m04b)

tab_model(m01b, m02b,m03b, m04b,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00","m01", "m03", "m04"), digits = 5 )

# Adding to the full model as random slopes to Participant, Q1b singularity issues; Q4a convergence issue, Q6b does not give singularity issues. Q6b then dissapears. 
m00b = lmer(Q3 ~    Q1b + Q4a + Abs_Av   + (1 + Q4a | Participant), data = data_filtered_Q6a)
m01b = lmer(Q3 ~    Q1b + Q4a + Q6b + Abs_Av + (1  + Q4a | Participant), data = data_filtered_Q6a)
m02b = lmer(Q3 ~    Q1b + Q4a + Abs_Av + Q6b +  (1 |GMSI) +  (1 | Participant), data = data_filtered_Q6a)
m03b = lmer(Q3 ~    Q1b + Q4a + Q6b  + Abs_Av + (1 + Q6b | Participant), data = data_filtered_Q6a) 
m04b = lmer(Q3 ~    Q1b + Q4a + Q6b  + Abs_Av + GDSI + (1 + Q4a | Participant), data = data_filtered_Q6a) 
m05b = lmer(Q3 ~    Q1b + Q4a + Q6b  + Abs_Av + GDSI + (1 + Q6b | Participant), data = data_filtered_Q6a) 

anova(m03b, m01b, m02b, m00b, m04b, m05b)

tab_model(m00b, m01b, m02b,m03b, m04b,m05b,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00","m01", "m03", "m04", "m05", "m06"), digits = 5 )

library(webshot)
tab_model(
  m00a, m01a, m00b,  m01b,
  p.style = "stars",
  show.aic = TRUE,
  show.ci = FALSE,
  show.r2 = FALSE,
  dv.labels = c("Flow", "Flow", "Flow", "Flow"),
  digits = 5,
  pred.labels = c("Intercept", "Connection with Partner", "Quality of Improvisation", "Dance Experience (GDSI)", "Rhythmic complexity", "Absorption of Activity (FSS)")
)
  #file = "/Users/atillajv/LaTex/5ec0f6099dc1fe00017f2156/paper1/images/lmer_table.html"
)
webshot("/Users/atillajv/LaTex/5ec0f6099dc1fe00017f2156/paper1/images/lmer_table.html", "/Users/atillajv/LaTex/5ec0f6099dc1fe00017f2156/paper1/images/lmer_table.png")


  

library(sjPlot)

m00 = lmer(Q3 ~  Q1a +  (1 |Pair/Participant), data = data_ole)
m01 = lmer(Q3 ~  Q1b +  (1 |Pair/Participant), data = data_ole)
m02 = lmer(Q3 ~  Q4a +  (1 |Participant), data = data_ole)
m03 = lmer(Q3 ~  Q4b +  (1 |Participant), data = data_ole)
m04 = lmer(Q3 ~  Q5a +  (1 |Participant), data = data_ole)
m05 = lmer(Q3 ~  Q5b +  (1 |Pair/Participant), data = data_ole)
m06 = lmer(Q3 ~  Q6a +  (1 |Participant), data = data_ole)
m07 = lmer(Q3 ~  Q6b +  (1 |Participant), data = data_ole)
m08 = lmer(Q3 ~  Perf_Av +  (1 |Pair/Participant), data = data_ole)
m09 = lmer(Q3 ~  Abs_Av +  (1 |Pair/Participant), data = data_ole)
m10 = lmer(Q3 ~  GDSI +  (1 |Pair/Participant), data = data_ole)
m11 = lmer(Q3 ~  GMSI +  (1 |Pair/Participant), data = data_ole)
m12 = lmer(Q3 ~  Fam +  (1 |Pair/Participant), data = data_ole)

tab_model(m00, m01, m02,  m03, m04, m05, m06, m07, m08, m09, m10, m11,m12,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("Flow","Flow", "Flow", "Flow","Flow","Flow", "Flow", "Flow","Flow","Flow", "Flow", "Flow", "Flow"),
          digits = 5,
          file = "/Users/atillajv/LaTex/5ec0f6099dc1fe00017f2156/paper1/images/lmer_model3_table.html"
)
library(webshot)
webshot("/Users/atillajv/LaTex/5ec0f6099dc1fe00017f2156/paper1/images/lmer_model3_table.html", "/Users/atillajv/LaTex/5ec0f6099dc1fe00017f2156/paper1/images/lmer_model3_table.png")

m00 = lmer(Q3 ~  Q1a +  (1 |Participant), data = data_filtered_Q6a)
m01 = lmer(Q3 ~  Q1b +  (1 |Participant), data = data_filtered_Q6a)
m02 = lmer(Q3 ~  Q4a +  (1 |Participant), data = data_filtered_Q6a)
m03 = lmer(Q3 ~  Q4b +  (1 |Participant), data = data_filtered_Q6a)
m04 = lmer(Q3 ~  Q5a +  (1 |Participant), data = data_filtered_Q6a)
m05 = lmer(Q3 ~  Q5b +  (1 |Participant), data = data_filtered_Q6a)
m06 = lmer(Q3 ~  Q6a +  (1 |Participant), data = data_filtered_Q6a)
m07 = lmer(Q3 ~  Q6b +  (1 |Participant), data = data_filtered_Q6a)
m08 = lmer(Q3 ~  Perf_Av +  (1 |Participant), data = data_filtered_Q6a)
m09 = lmer(Q3 ~  Abs_Av +  (1 |Participant), data = data_filtered_Q6a)
m10 = lmer(Q3 ~  GDSI +  (1 |Participant), data = data_filtered_Q6a)
m11 = lmer(Q3 ~  GMSI +  (1 |Participant), data = data_filtered_Q6a)
m12 = lmer(Q3 ~  Fam +  (1 |Participant), data = data_filtered_Q6a)
anova(m00, m01)


# Second part of models
m01 = lmer(Q3 ~  MIXvsIMP +  (1 |Pair/Participant), data = data_ole)
m02 = lmer(Q3 ~  FIXvsOther +  (1 |Pair/Participant), data = data_ole)
m03 = lmer(Q3 ~  Palo +  (1 |Pair/Participant), data = data_ole)
m04 = lmer(Q3 ~  Artist +  (1 |Pair/Participant), data = data_ole)
m04 = lmer(Q3 ~  Artist +  (1 |Pair/Participant), data = data_ole)

anova(m00a,m01a)

tab_model(m01, m02, m03,  m04,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("Flow","Flow", "Flow", "Flow"), digits = 5 )

# Post hoc thoughts and analyses
m03 = lmer(Q3a ~  Q6b +  (1 |Participant), data = data_ole)
summary(m03)


# m00a = lmer(Q3 ~  1+ (1 | Participant), data = data_ole)
# m01a = lmer(Q3 ~  Q4a + Q1b + Abs_Av  + (1 | Participant), data = data_ole)
# m02a = lmer(Q3 ~  Q4a + Q1b + Abs_Av  + GDSI +  (1 | Participant), data = data_ole)
# m03a = lmer(Q3 ~  Q4a + Q1b + GDSI +  (1 | Participant), data = data_ole)
# m04a = lmer(Q3 ~  Q4b +  Q1b + GDSI +  (1 | Participant), data = data_ole)
# anova(m04a, m03a)



#### BEST FITTING MODELS 2024 # HALF DATASET

# Display the filtered dataset
data_filtered_Q6a <- na.omit(data_ole[, "Q6a"])

data_filtered_Q6a <- na.omit(data_ole[, c("GMSI", "Q6a")])
# Copy all columns from the original dataset to the filtered dataset
data_filtered_Q6a <- data_ole[which(!is.na(data_ole$Q6a)), ]



 
m00b = lmer(Q3 ~ 1 +(1 |GMSI) + (1 |Participant), data = data_filtered_Q6a )
m01b = lmer(Q3 ~    Q1b + Q4a + Q6b + Abs_Av + (1 |GMSI) + (1 | Participant), data = data_filtered_Q6a)
m02b = lmer(Q3 ~    Q1b + Q4a + Q6 + Abs_Av + (1 |GMSI) + (1 | Participant), data = data_filtered_Q6a)
#m02 = lmer(Q3 ~    Q1b + Q4a + Q6b + (1 |GMSI) + (1 |Participant), data = data_filtered_Q6a)
#m03 = lmer(Q3 ~    Q1b + Q4a + Q6b + Abs_Av +  (1 |Participant), data = data_filtered_Q6a)
anova(m00b, m01b)
summary(m00b, m01b)

tab_model(m00a, m01a, m02a,  m00b, m01b,m02b,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00","m01", "m02", "m03", "m04", "m05", "m06"), digits = 5 )




###### New model Jonna 01.02.2024 ######

m00 = lmer(Q3 ~    Q1b + (1 | Pair/Participant), data = data_ole)
m01 = lmer(Q3 ~    Q1b + (0 + Q1b | Pair/Participant), data = data_ole)
m02 = lmer(Q3 ~    Q1b + (0 + Q1b | Pair:Participant) + (1 | Pair), data = data_ole)
m03 = lmer(Q3 ~    Q1b + (0 + Q1b | Participant) + (1 | Pair), data = data_ole)

anova(m00,m01,m02, m03)
tab_model(m00, m01, m02,m03,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00","m01", "m02", "m03"), digits = 5 )



m00 = lmer(Q3 ~    Q4a + (1 | Pair), data = data_ole)
m01 = lmer(Q3 ~    Q4a + (0 + Q4a | Pair), data = data_ole)
m02 = lmer(Q3 ~    Q4a + (0 + Q4a| Participant) + (1  | Pair), data = data_ole)

anova(m00,m01,m02)
tab_model(m00, m01, m02,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00","m01", "m02"), digits = 5 )

m00 = lmer(Q3 ~    Q6b + ( 0 + Q6a | Pair:Participant) + (1 | Pair), data = data_ole)
m01 = lmer(Q3 ~    Q6b + (0 + Q6b| Participant) + (1  | Pair), data = data_ole)

anova(m00,m01)
tab_model(m00, m01, m02,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00","m01", "m02"), digits = 5 )


m00 = lmer(Q3 ~    Abs_Av +  (1 | Pair/Participant), data = data_ole)
m01 = lmer(Q3 ~    Abs_Av +  (0 + Abs_Av | Pair/Participant), data = data_ole)
m02 = lmer(Q3 ~    Abs_Av + ( 0 + Abs_Av | Pair:Participant) + (1 | Pair), data = data_ole)
m03 = lmer(Q3 ~    Abs_Av + (1| Pair:Participant) + (1 + Abs_Av  | Pair), data = data_ole)
m04 = lmer(Q3 ~    Abs_Av + (1| Participant) + (1 + Abs_Av  | Pair), data = data_ole)

anova(m00,m01, m02, m03, m04)
tab_model(m00, m01, m02, m03,m04,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00","m01", "m02", "m03", "m04"), digits = 5 )

m00 = lmer(Q3 ~   Q1b + Abs_Av + Q4a + Q6b +  (0 + Q1b | Participant) + (1 | Pair), data = data_filtered_Q6a)
m01 = lmer(Q3 ~   Q1b + Abs_Av + Q4a + Q6b + (1 + Q4a | Participant) + (1 | Pair), data = data_filtered_Q6a)
m02 = lmer(Q3 ~   Q1b + Abs_Av + Q4a + Q6b +  (0 + Q4a | Participant) + (1 | Pair), data = data_filtered_Q6a)
m03 = lmer(Q3 ~   Q1b + Abs_Av + Q4a + Q6b +  (0 + Q6b | Participant) + (1 | Pair), data = data_filtered_Q6a)
m04 = lmer(Q3 ~   Q1b   + Abs_Av  + Q4a + Artist + Q6b +  (1  + Q4a | Participant) + (1 | Pair), data = data_filtered_Q6a)
m05 = lmer(Q3 ~   Q1b   + Q4a + Artist + Q6b  + (1  + Q4a | Participant) + (1 | Pair), data = data_filtered_Q6a)

anova(m01,m04)
anova(m00,m01,m02,m03, m04, m05)
summary(m00)

tab_model(m00, m01, m02, m03,m04,m05,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00","m01", "m02", "m03", "m04", "m05"), digits = 5 )

m00 = lmer(Q3 ~   Q1b + Abs_Av + Q4a +   (0 + Q4a  | Participant) + (1 | Pair), data = data_ole)
m01 = lmer(Q3 ~   Q1b + Abs_Av + Q4a +   (0 + Q1b   | Participant) + (1 | Pair), data = data_ole)
m02 = lmer(Q3 ~   Q1b + Abs_Av + Q4a +   (1 + Q4a  | Participant) + (1 | Pair), data = data_ole)
m03 = lmer(Q3 ~   Q1b + Abs_Av + Q4a +   (1 + Abs_Av  | Participant) + (1 | Pair), data = data_ole)
anova(m00,m01,m02,m03)
tab_model(m00, m01, m02, m03,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00","m01", "m02", "m03", "m04"), digits = 5 )

## Play with interaction found in results

m00 = lmer(Q3 ~   Q1b   + Q4a + Artist +  (0 + Q4a  | Participant) + (1 | Pair), data = data_ole)
m01 = lmer(Q3 ~    Abs_Av  + Q4a + Artist + Q1b +  (1 + Abs_Av  | Participant) + (1 | Pair), data = data_ole)
m02 = lmer(Q3 ~    Q1b  + Q4a + Artist +  (0 + Q1b  | Participant) + (1 | Pair), data = data_ole)
m03 = lmer(Q3 ~   Q1b   + Q4a + Artist +  (1 + Abs_Av  | Participant) + (1 | Pair), data = data_ole)
m04 = lmer(Q3 ~   Q1b    + Q4a  + Artist  +  (0 + Abs_Av  | Participant) + (1 | Pair), data = data_ole)

tab_model(m00, m01, m02, m03,m04,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00","m01", "m02", "m03", "m04"), digits = 5 )

anova(m00,m01,m02,m03, m04)
anova(m00, m03)


###Final models
m00 = lmer(Q3 ~   Q1b + Abs_Av + Q4a +   (1 + Abs_Av  | Participant) + (1 | Pair), data = data_ole)
m01 = lmer(Q3 ~   Q1b   + Abs_Av  + Q4a + Q6b +  (1  + Q4a | Participant) + (1 | Pair), data = data_filtered_Q6a)

tab_model(m00, m01,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          pred.labels =c("(Intercept)", "Quality of improvisation","Absorption by activity", "Connection with partner","Rhythmic complexity"),
          dv.labels=c("model 1","model 2"), digits = 5)
,
        file = "/Users/atillajv/LaTex/5ec0f6099dc1fe00017f2156/paper1/images/lmer_models_draft2.html"
          )
library(webshot)
webshot("/Users/atillajv/LaTex/5ec0f6099dc1fe00017f2156/paper1/images/lmer_models_draft2.html", "/Users/atillajv/LaTex/5ec0f6099dc1fe00017f2156/paper1/images/lmer_model3_table.png")




m00 = lmer(Q3 ~   GDSI +   (1 | Participant) + (1 | Pair), data = data_ole)
m01 = lmer(Q3 ~   GMSI +  (1 | Participant) + (1 | Pair), data = data_ole)
m02 = lmer(Q3 ~   Artist +  (1 | Participant) + (1 | Pair), data = data_ole)
m03 = lmer(Q3 ~   Palo +  (1 | Participant) + (1 | Pair), data = data_ole)

tab_model(m00, m01,m02, m03 , p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
         # pred.labels =c("(Intercept)", "Quality of improvisation","Absorption by activity", "Connection with partner","Rhythmic complexity"),
          dv.labels=c("model 1","model 2"), digits = 5)


m00 = lmer(Q3 ~   GDSI * Condition +   (1 | Participant) + (1 | Pair), data = data_ole)
m01 = lmer(Q3 ~   GMSI* Condition +  (1 | Participant) + (1 | Pair), data = data_ole)
m02 = lmer(Q3 ~   Artist* Condition +  (1 | Participant) + (1 | Pair), data = data_ole)
m03 = lmer(Q3 ~   Palo * Condition+  (1 | Participant) + (1 | Pair), data = data_ole)

tab_model(m00, m01,m02, m03 , p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          # pred.labels =c("(Intercept)", "Quality of improvisation","Absorption by activity", "Connection with partner","Rhythmic complexity"),
          dv.labels=c("model 1","model 2"), digits = 5)


          file = "/Users/atillajv/LaTex/5ec0f6099dc1fe00017f2156/paper1/images/lmer_models_draft2.html"
)
library(webshot)
webshot("/Users/atillajv/LaTex/5ec0f6099dc1fe00017f2156/paper1/images/lmer_models_draft2.html", "/Users/atillajv/LaTex/5ec0f6099dc1fe00017f2156/paper1/images/lmer_model3_table.png")




####################################
# PLOTTING CODE PK #####
colors <- c("#8DD3C7", "#FFFFB3", "#BEBADA", "#FB8072", "#80B1D3", "#FDB462", "#B3DE69", "#FCCDE5", "#00008B", "#BC80BD")
new_colors <- c("#5BB8A0", "#8C8AFF", "#FFA500", "#E30B5C")
darker_colors <- c("#348770", "#4F4D9E", "#f19e07ff", "#A50741")
new_colors <- c("#5acfdbff", '#ff5130ff', "#FFA500","#8DD3C7")

common_theme <- theme(
  axis.text.y = element_text(size = 16),   # Adjust y-axis text size
  axis.text.x = element_text(size = 16),   # Adjust y-axis text size
  strip.text = element_text(size = 16),     # Adjust facet titles size
  axis.title.x = element_text(size = 16),
  axis.title.y = element_text(size = 16),
  panel.grid = element_blank(),
  plot.title = element_text(hjust = 0.5),
  panel.background = element_rect(fill = "white", color = "grey70", size = 1)
)  # Center the title
#plot.margin = margin(1, 1, 1, 1, "cm")

Flamenco_model.lm <- lmer(Q3 ~   Q1b + Abs_Av + Q4a +   (1 + Abs_Av  | Participant) + (1 | Pair), data = data_ole)

Plot_fe_Q4a <- effect_plot(Flamenco_model.lm, pred = Q4a, interval = TRUE, partial.residuals = TRUE, plot.points = TRUE, 
                                  jitter = 0.00, point.size = 1.2, colors = new_colors[1]) +
  labs(x= "Connection", y = "Flow", title = "") + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1)) +
  scale_x_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1)) + 
  common_theme

Plot_fe_Q4a

Plot_fe_Q1b <- effect_plot(Flamenco_model.lm, pred = Q1b, interval = TRUE, partial.residuals = TRUE, plot.points = TRUE, 
                           jitter = 0.00, point.size = 1.2, colors = new_colors[2], cat.geom = 'line') +
  labs(x= "Creativity", y = "", title = "") + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1)) +
  scale_x_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))+ 
  common_theme

Plot_fe_Q1b

x_values <- data.frame(Abs_Av = seq(1, 7, 0.1))
predicted_line <- predict(Flamenco_model.lm, newdata = x_values)

Plot_fe_Abs_Av <- effect_plot(Flamenco_model.lm, pred = Abs_Av, interval = TRUE, partial.residuals = TRUE, plot.points = TRUE, 
                           jitter = 0.00, point.size = 1.2, colors = new_colors[3]) +
  labs(x= "Absorption", y = "", title = "") + 
  geom_line(color = darker_colors[3], size =1.2) +  # Set color for the predicted line
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1)) +
  scale_x_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))+ 
  common_theme

Plot_fe_Abs_Av


library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  Plot_fe_Q4a, Plot_fe_Q1b, Plot_fe_Abs_Av, ncol = 4
  
)

#### Model 2 Plots Fixed Effects ######

Flamenco_model.lm <- lmer(Q3 ~   Q1b   + Abs_Av  + Q4a + Q6b +  (1  + Q4a | Participant) + (1 | Pair), data = data_filtered_Q6a)

#Flamenco_model.lm <- lmer(Q3 ~   poly(Q1b, degree = 2)   + Abs_Av  + Q4a + Q6b +  (1  + Q4a | Participant) + (1 | Pair), data = data_filtered_Q6a)

Plot_fe_Q4a <- effect_plot(Flamenco_model.lm, pred = Q4a, interval = TRUE, partial.residuals = TRUE, plot.points = TRUE, 
                           jitter = 0.00, point.size = 1.2, colors = new_colors[1]) +
  labs(x= "Connection", y = "Flow", title = "") + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1)) +
  scale_x_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1)) + 
  common_theme






Plot_fe_Q1b <- effect_plot(Flamenco_model.lm, pred = Q1b, interval = TRUE, partial.residuals = TRUE, plot.points = TRUE, 
                           jitter = 0.00, point.size = 1.2, colors = new_colors[2], cat.geom = 'line') +
  labs(x= "Creativity", y = "", title = "") + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1)) +
  scale_x_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))+ 
  common_theme

Plot_fe_Q1b

x_values <- data.frame(Abs_Av = seq(1, 7, 0.1))
#predicted_line <- predict(Flamenco_model.lm, newdata = x_values)

Plot_fe_Abs_Av <- effect_plot(Flamenco_model.lm, pred = Abs_Av, interval = TRUE, partial.residuals = TRUE, plot.points = TRUE, 
                              jitter = 0.00, point.size = 1.2, colors = new_colors[3]) +
  labs(x= "Absorption", y = "", title = "") + 
  geom_line(color = darker_colors[3], size =1.2) +  # Set color for the predicted line
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1)) +
  scale_x_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))+ 
  common_theme

Plot_fe_Abs_Av



Plot_fe_Q6b <- effect_plot(Flamenco_model.lm, pred = Q6b, interval = TRUE, partial.residuals = TRUE, plot.points = TRUE, 
                              jitter = 0.00, point.size = 1.2, colors = new_colors[4]) +
  labs(x= "Complexity", y = "", title = "") + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1)) +
  scale_x_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))+ 
  common_theme

Plot_fe_Q6b



library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  Plot_fe_Q4a, Plot_fe_Q1b, Plot_fe_Abs_Av, Plot_fe_Q6b, ncol = 4
  
)




##### Plots draft 2, 20.02.2024
### Does not seem to run
# model1 <-  lmer(Q3 ~   Q1b + Abs_Av + Q4a +   (1 + Abs_Av  | Participant) + (1 | Pair), data = data_ole)
# 
# # Extract participant-level predictions from the model
# predicted_participant <- data.frame(PredictValue = predict(model1, re.form = ~1 | Participant))
# 
# # Merge participant-level predictions with original data
# data_with_predictions_participant <- merge(data_ole, predicted_participant, by = "Participant")
# 
# # Plot line for each participant
# ggplot(data_with_predictions_participant, aes(x = Q3, y = predict)) +
#   geom_line(aes(group = Participant, color = as.factor(Participant))) +
#   geom_point(aes(color = as.factor(Participant))) +
#   labs(x = "Q3", y = "Predicted Values") +
#   ggtitle("Line Plot of Predicted Values by Participant") +
#   theme_minimal()
# 


summary(m00)
######PETER CODE ######################
## Select 'concert' data to process
data_brms <- data_brahms
data_brdn <- data_borodin

# Add columns with binary values following Bonferroni correction: p = .05/K (where K is the number of GC tests, one per musician pairing, per excerpt) 
# For Brahms Quintet (K = 10): corrected critical p-value = .005
# For Borodin Quartet (K = 6): corrected critical p-value = .008
data_brms$p_M1_M2_BFC <- with(data_brms, ifelse(p_M1_M2 < .005, 1, 0))
data_brms$p_M2_M1_BFC <- with(data_brms, ifelse(p_M2_M1 < .005, 1, 0))
data_brdn$p_M1_M2_BFC <- with(data_brdn, ifelse(p_M1_M2 < .008, 1, 0))
data_brdn$p_M2_M1_BFC <- with(data_brdn, ifelse(p_M2_M1 < .008, 1, 0))

# Combine both pieces into 1 data frame
data_both <- rbind(data_brms, data_brdn)

# Set up for P value analysis
dataPv_UC <- melt(data_both, id.vars = c('piece', 'part', 'phrase', 'texture', 'pair'), measure.vars = c('p_M1_M2_Bin', 'p_M2_M1_Bin'), variable.name = 'direction', value.name = "p_sig")
# With Bonferroni correction
dataPv_BFC <- melt(data_both, id.vars = c('piece', 'part', 'phrase', 'texture', 'pair'), measure.vars = c('p_M1_M2_BFC', 'p_M2_M1_BFC'), variable.name = 'direction', value.name = "p_sig")

# Select whether to analyze with Bonferroni correction (BFC) or uncorrected (UC) !!!! Comment-out (#) the one you don't want
dataPv <- dataPv_UC # Uncorrected
#dataPv <- dataPv_BFC # With Bonferroni correction

dataPv$phrase <- as.factor(dataPv$phrase) # 'Phrase' here refers to each excerpt extracted from the performances

## Analysis of PROPORTIONS of significant GC values -------
# Linear Mixed Effects Model (LMM) analysis

# Compute proportions across pairs
data_p_prop <- dataPv %>% group_by(piece, part, phrase, texture, direction) %>% summarise_at(vars(p_sig), mean)
data_p_prop <- data.frame(data_p_prop)

# Run Shapiro-Wilk test of normality. Can assume normality if p > .05
data_p_prop %>%
  group_by(texture) %>%
  shapiro_test(p_sig) # Neither Homophonic nor Polyphonic proportion data are normally distributed. This justifies GLMER.

# Run LMM
Pv_long_prop <- lmer(p_sig ~ 1 + texture + (1 | direction) + (1 | piece/part/phrase), data = data_p_prop,
                     control = lmerControl(optimizer = "bobyqa"), REML = FALSE)
Pv_long_prop.output <- summary(Pv_long_prop) # Print model summary to console
Pv_long_prop.output 
capture.output(Pv_long_prop.output, file = "ProportionSigGC.txt") # Write output to text file

# save model output as a text file
class(Pv_long_prop) <- "lmerMod"
stargazer(Pv_long_prop, type = "text", title='LMER Summary Statistics - Proportion Significant', out='Pv_long_prop_table.txt')

# Compute confidence intervals
Pv_long_prop.ci <- confint(Pv_long_prop)
Pv_long_prop.ci
capture.output(Pv_long_prop.ci, file = "ProportionSigGC_CI.txt")

# Now run a reduced model excluding the fixed factor of 'texture'.
Pv_long_prop_reduced <- lmer(p_sig ~ 1 + (1 | direction) + (1 | piece/part/phrase), data = data_p_prop,
                        control = lmerControl(optimizer = "bobyqa"), REML = FALSE)
summary(Pv_long_prop_reduced) # Print model summary to console

# Compare full and reduced models to see whether the model that includes texture explains more variance in GC
Pv_long_prop.anova <- anova(Pv_long_prop, Pv_long_prop_reduced) # Check output to see whether the Chi-square value is significant
Pv_long_prop.anova
capture.output(Pv_long_prop.anova, file = "ProportionSigGC_model_eval.txt") # Write output to text file

# Raincloud plot ----

summary_data_p_prop <- summarySE(data = data_p_prop, measurevar = "p_sig", groupvars = "texture", 
                                       na.rm = TRUE, conf.interval = 0.95, .drop = TRUE)

# set up the theme here for raincloud plots 
raincloud_theme = theme(
  text = element_text(size = 14),
  axis.title.x = element_text(size = 24, vjust = 0),
  axis.title.y = element_text(size = 24, vjust = 2),
  axis.text = element_text(size = 20, color = 'black'),
  legend.title=element_text(size=20),
  legend.text=element_text(size=20),
  legend.position = "right",
  plot.title = element_text(lineheight=.8, face="bold", size = 28),
  panel.border = element_blank(),
  panel.grid.minor = element_blank(),
  panel.grid.major = element_blank(),
  axis.line.x = element_line(colour = 'black', size=0.5, linetype='solid'),
  axis.line.y = element_line(colour = 'black', size=0.5, linetype='solid'))

GC_p_plot_long_prop <- data_p_prop  %>%
  mutate(texture = fct_relevel(data_p_prop$texture, "H", "P")) %>%
  ggplot(aes(y = p_sig, x = texture, fill = texture)) +
  geom_flat_violin(position = position_nudge(x = .175, y = 0), alpha = .8, show.legend = FALSE) +
  geom_point(aes(y = p_sig, x = texture, fill = texture), position = position_jitter(width = .06, height = 0), shape = 21, size = 2, color = "black", alpha = 0.5, show.legend = FALSE) +
  geom_errorbar(data = summary_data_p_prop, aes(x = texture, y = p_sig, ymin = p_sig-ci, ymax = p_sig+ci), position = position_nudge(c(-.175, -.175)), colour = "black",
                width = 0.08, size = 0.6) +
  geom_point(data = summary_data_p_prop, aes(x = texture, y = p_sig, fill = texture), position =
               position_nudge(c(-.175, -.175)), shape = 21, size = 5, colour = "black", fill = c('orange', 'royalblue'), show.legend = FALSE) +
  expand_limits(x = 3) +
  scale_color_ucscgb() +
  scale_fill_ucscgb() +
  scale_fill_manual(values=c('orange', 'royalblue')) +
  labs(x="Texture", y = "Proportion")+
  scale_x_discrete("Texture", labels = c("H" = "Homophonic","P" = "Polyphonic")) +
  theme_bw() +
  raincloud_theme

GC_p_plot_long_prop
ggsave("GC_p_plot_long_prop.png", dpi=600)


# Binomial Generalized Linear Mixed Effects Model (GLMM) on binary data ----
# Binary values indicate whether (1) or not (0) each individual Granger test was statistically significant.

Pv_binary.glme <- glmer(p_sig ~ 1 + texture + (1 | direction/pair) + (1 | piece/part/phrase),  family=binomial, data = dataPv,
                           control = glmerControl(optimizer = "bobyqa"))
Pv_binary.output <- summary(Pv_binary.glme)
Pv_binary.output
capture.output(Pv_binary.output, file = "Pv_binary_GLMER.txt") # Write output to text file

# Compute confidence intervals (does not run for Bonferroni corrected data)
Pv_binary.glme.ci <- confint(Pv_binary.glme) 
Pv_binary.glme.ci
capture.output(Pv_binary.glme.ci, file = "BinaryGLMM_SigGC_CI.txt")

# Reduced model with random effects only
Pv_binary_random.glme <- glmer(p_sig ~ 1 + (1 | direction/pair) + (1 | piece/part/phrase),  family=binomial, data = dataPv,
                                control = glmerControl(optimizer = "bobyqa"))
Pv_binary_random.output <- summary(Pv_binary_random.glme)
Pv_binary_random.output
capture.output(Pv_binary_random.output, file = "Pv_binary_random_GLMER.txt") # Write output to text file

# Compare the full and reduced model
Pv_binary_comparison <- anova(Pv_binary.glme, Pv_binary_random.glme)
Pv_binary_comparison
capture.output(Pv_binary_comparison, file = "Pv_binary_comparison.txt") # Write output to text file

# Make a table
Pv_binary_GLMER.table <- huxreg(Pv_binary.glme, Pv_binary_random.glme, statistics = NULL, number_format = 2)
Pv_binary_GLMER.table
huxtable::quick_docx(Pv_binary_GLMER.table, file = "Pv_binary_GLMER_table.docx") # Make Word table (not standardized coefficients)


# Analysis of effects of MELODY INSTRUMENT ------
# Linear Mixed Effects Model (LMM) and Analysis of Variance (ANOVA) with planned contrasts

# First need to add column to indicate whether GC data in each row are for: 
# (1) melody influencing other (Melody_to_Other), (2) other influencing melody (Other_to_Melody), or other influencing other (Other_to_Other), in Homophonic textures
# or 'Mixed' in polyphonic textures

dataPv_melody_UC <- melt(data_both, id.vars = c('piece', 'part', 'phrase', 'texture', 'pair', 'musician1', 'musician2', 'melody_instrument'), measure.vars = c('p_M1_M2_Bin', 'p_M2_M1_Bin'), variable.name = 'direction', value.name = "p_sig")
# With Bonferroni
dataPv_melody_BFC <- melt(data_both, id.vars = c('piece', 'part', 'phrase', 'texture', 'pair', 'musician1', 'musician2', 'melody_instrument'), measure.vars = c('p_M1_M2_BFC', 'p_M2_M1_BFC'), variable.name = 'direction', value.name = "p_sig")

# Select whether to analyze with Bonferroni correction (BFC) or uncorrected (UC) !!!! Comment-out (#) the one you don't want
#dataPv_melody <- dataPv_melody_UC
dataPv_melody <- dataPv_melody_BFC 


dataPv_melody$leadership <- ifelse(dataPv_melody$melody_instrument == 'Mixed', 'Mixed',
                                   ifelse(dataPv_melody$melody_instrument == dataPv_melody$musician1 & grepl("p_M1_M2", dataPv_melody$direction), 'Melody_to_Other',
                                          ifelse(dataPv_melody$melody_instrument == dataPv_melody$musician2 & grepl("p_M2_M1", dataPv_melody$direction), 'Melody_to_Other',
                                                 ifelse(dataPv_melody$melody_instrument == dataPv_melody$musician2 & grepl("p_M1_M2", dataPv_melody$direction), 'Other_to_Melody',
                                                        ifelse(dataPv_melody$melody_instrument == dataPv_melody$musician1 & grepl("p_M2_M1", dataPv_melody$direction), 'Other_to_Melody', 'Other_to_Other')))))
dataPv_melody$leadership <- as.factor(dataPv_melody$leadership)
#dataPv_melody <- melt(data_both, id.vars = c('piece', 'part', 'phrase', 'texture', 'pair', 'leadership'), measure.vars = c('p_M1_M2_Bin', 'p_M2_M1_Bin'), variable.name = 'direction', value.name = "p_sig")

# Compute proportion data
data_p_prop_melody <- dataPv_melody %>% group_by(piece, part, phrase, leadership) %>% summarise_at(vars(p_sig), mean)
data_p_prop_melody <- data.frame(data_p_prop_melody)

data_p_prop_melody$leadership <- as.factor(data_p_prop_melody$leadership)

# Run Shapiro-Wilk test of normality. Can assume normality if p > .05
data_p_prop_melody %>%
  group_by(leadership) %>%
  shapiro_test(p_sig) # Most data are not normally distributed. This justifies GLMER

# First run the full model to test the effect of the fixed factor 'leadership' on whether or not GC is significant  
Pv_long_melody <- lmer(p_sig ~ 1 + leadership + (1 | piece/part/phrase), data = data_p_prop_melody,
                       control = lmerControl(optimizer = "bobyqa"), REML = FALSE)
Pv_long_melody.output <- summary(Pv_long_melody) # Print model summary to console
Pv_long_melody.output
capture.output(Pv_long_melody.output, file = "ProportionSigGC_Melody.txt") # Write output to text file

# save model output as a text file
class(Pv_long_melody) <- "lmerMod"
stargazer(Pv_long_melody, type = "text", title='LMER Summary Statistics - Proportion Significant', out='Pv_long_melody_table.txt')

# Pairwise comparisons (exhaustive - don't use; use planned orthogonal contrasts instead)
Melody_Pairwise.comp <- lsmeans(Pv_long_melody, pairwise ~ leadership, mult.name = "Leadership", pbkrtest.limit = 9999)
Melody_Pairwise.comp
write.table(Melody_Pairwise.comp, file = "SigGC_Melody_pairwise_comparisons.txt", sep = "") 

# ANOVA with orthogonal planned contrasts: (1) Homophonic vs Polyphonic; (2) Pairing with Melody vs No Melody; (3) Melody-to-Other vs Other-to-Melody
levels(data_p_prop_melody$leadership) # Check order of conditions (important for specifying contrast coefficients)
Melody_PlannedComp <- lsmeans(Pv_long_melody, "leadership")
HvsP = c(1,-3,1,1) # Contrast comparing Homophonic with Polyphonic - this comparison is redundant with the main analysis
MELvsNoMEL = c(1,0,1,-2) # Contrast comparing pairings including Melody player vs pairings excluding Melody player
MOvsOM = c(1,0,-1,0) # Contrast comparing Melody-to-Other vs Other-to-Melody
Contrasts = list(HvsP, MELvsNoMEL, MOvsOM)
Melody_PlannedComp.output <- contrast(Melody_PlannedComp, Contrasts, adjust="none") # No need for adjust for multiple comparisons since contrasts are planned & orthogonal
capture.output(Melody_PlannedComp.output, file = "SigGC_Melody_planned_contrasts.txt")
Melody_PlannedComp.output

# Compute confidence intervals
Melody_PlannedComp.output.ci <- confint(Melody_PlannedComp.output)
Melody_PlannedComp.output.ci
capture.output(Melody_PlannedComp.output.ci, file = "Melody_PlannedComp.output_CI.txt")

# Now run a reduced model excluding the fixed factor of 'leadership'.
Pv_long_melody_reduced <- lmer(p_sig ~ 1 + (1 | piece/part/phrase), data = data_p_prop_melody,
                               control = lmerControl(optimizer = "bobyqa"), REML = FALSE)
summary(Pv_long_melody_reduced) # Print model summary to console

# Compare full and reduced models to see whether the model that includes texture explains more variance in GC
Pv_long_melody.anova <- anova(Pv_long_melody, Pv_long_melody_reduced) # Check output to see whether the Chi-square value is significant
Pv_long_melody.anova
capture.output(Pv_long_melody.anova, file = "ProportionSigGC_Melody_model_eval.txt") # Write output to text file

# Raincloud plot  

summary_melody_p_prop <- summarySE(data = data_p_prop_melody, measurevar = "p_sig", groupvars = "leadership", 
                                 na.rm = TRUE, conf.interval = 0.95, .drop = TRUE)

GC_p_plot_leadership <- data_p_prop_melody  %>%
  mutate(leadership = fct_relevel(data_p_prop_melody$leadership, "Melody_to_Other", "Other_to_Melody", "Other_to_Other", "Mixed")) %>%
  ggplot(aes(y = p_sig, x = leadership, fill = leadership)) +
  geom_flat_violin(position = position_nudge(x = .175, y = 0), alpha = .8, show.legend = FALSE) +
  geom_point(aes(y = p_sig, x = leadership, fill = leadership), position = position_jitter(width = .06, height = 0), shape = 21, size = 2, color = "black", alpha = 0.5, show.legend = FALSE) +
  geom_errorbar(data = summary_melody_p_prop, aes(x = leadership, y = p_sig, ymin = p_sig-ci, ymax = p_sig+ci), position = position_nudge(c(-.175, -.175, -.175, -.175)), colour = "black",
                width = 0.08, size = 0.6) +
  geom_point(data = summary_melody_p_prop, aes(x = leadership, y = p_sig, fill = leadership), position =
               position_nudge(c(-.175, -.175, -.175, -.175)), shape = 21, size = 4, colour = "black", fill = c('#A2B59F', 'lightgrey', 'darkgrey', '#B59F9F'), show.legend = FALSE) +
  expand_limits(x = 3) +
  scale_fill_manual(values=c('#A2B59F', 'lightgrey', 'darkgrey', '#B59F9F')) +
  labs(x="Direction of Influence", y = "Proportion")+
  scale_x_discrete("Direction of Influence", labels = c("Melody_to_Other" = "Melody\non Other", "Other_to_Melody" = "Other\non Melody", "Other_to_Other" = "Other\non Other", "Mixed" = "Mixed\nPolyphonic")) +
  theme_bw() +
  raincloud_theme

GC_p_plot_leadership
ggsave("GC_p_plot_leadership.png", dpi=600)


# Binomial Generalized Linear Mixed Effects Model (GLMM) on binary data for MELODY INSTRUMENT ----
# Binary values indicate whether (1) or not (0) each individual Granger test was statistically significant.

Pv_binary_melody.glme <- glmer(p_sig ~ 1 + leadership + (1 | direction/pair) + (1 | piece/part/phrase),  family=binomial, data = dataPv_melody,
                        control = glmerControl(optimizer = "bobyqa"))
Pv_binary_melody.output <- summary(Pv_binary_melody.glme)
Pv_binary_melody.output
capture.output(Pv_binary_melody.output, file = "Pv_binary_melody_GLMER.txt") # Write output to text file

# Find best-fitting random effects model
Pv_binary_melody_random.glme <- glmer(p_sig ~ 1 + (1 | direction/pair) + (1 | piece/part/phrase),  family=binomial, data = dataPv_melody,
                                       control = glmerControl(optimizer = "bobyqa"))
Pv_binary_melody_random.output <- summary(Pv_binary_melody_random.glme)
Pv_binary_melody_random.output
capture.output(Pv_binary_random.output, file = "Pv_binary_random_GLMER.txt") # Write output to text file

# Compare the full and reduced model
Pv_binary_melody_comparison <- anova(Pv_binary_melody.glme, Pv_binary_melody_random.glme)
Pv_binary_melody_comparison
capture.output(Pv_binary_melody_comparison, file = "Pv_binary_melody_comparison.txt") # Write output to text file

# Make a table
Pv_binary_melody_GLMER.table <- huxreg(Pv_binary_melody.glme, Pv_binary_melody_random.glme, statistics = NULL, number_format = 2)
Pv_binary_melody_GLMER.table
huxtable::quick_docx(Pv_binary_melody_GLMER.table, file = "Pv_binary_melody_GLMER_table.docx") # Make Word table (not standardized coefficients)

# Orthogonal planned contrasts: (1) Homophonic vs Polyphonic; (2) Pairing with Melody vs No Melody; (3) Melody-on-Other vs Other-on-Melody
levels(dataPv_melody$leadership) # Check order of conditions (important for specifying contrast coefficients)
Melody_PlannedComp.glme <- lsmeans(Pv_binary_melody.glme, "leadership")
HvsP = c(1,-3,1,1) # Contrast comparing Homophonic with Polyphonic - this comparison is redundant with the main analysis
MELvsNoMEL = c(1,0,1,-2) # Contrast comparing pairings including Melody player vs pairings excluding Melody player
MOvsOM = c(1,0,-1,0) # Contrast comparing Melody-on-Other vs Other-on-Melody
Contrasts = list(HvsP, MELvsNoMEL, MOvsOM)
Melody_PlannedComp.glme.output <- contrast(Melody_PlannedComp.glme, Contrasts, adjust="none") # No need for adjust for multiple comparisons since contrasts are planned & orthogonal
capture.output(Melody_PlannedComp.glme.output, file = "SigGC_Melody_GLMM_planned_contrasts.txt")
Melody_PlannedComp.glme.output

# Compute confidence intervals
Melody_PlannedComp.glme.output.ci <- confint(Melody_PlannedComp.glme.output)
Melody_PlannedComp.glme.output.ci
capture.output(Melody_PlannedComp.glme.output.ci, file = "Melody_GLMM_PlannedComp.output_CI.txt")




##### ANALYSIS 2


library(corrplot)
library(symnum)
library(psych)



# Select columns of interest
plot.new()

library(nortest)
ad.test(data_ole$Q1a)
ad.test(data_ole$Q1b)
ad.test(data_ole$Q3a)
ad.test(data_ole$Q3b)
ad.test(data_ole$Q4a)
ad.test(data_ole$Q4b)
ad.test(data_ole$Q5a)
ad.test(data_ole$Q5b)
ad.test(data_ole$Q6a)
ad.test(data_ole$Q6b)
ad.test(data_ole$Perf_Av)
ad.test(data_ole$Abs_Av)


corr_mat <- data_ole[, c("Q1a", "Q1b", "Q3a", "Q3b", "Q4a", "Q4b", "Q5a", "Q5b", "Q6a", "Q6b", "Perf_Av", "Abs_Av")]
corr_mat <- data_ole[, c( "Q1b", "Q3b", "Q4a", "Q6a")]

corr_mat <- data_ole[, c("Q1a", "Q1b", "Q3a", "Q3b")]


# Compute correlation matrix
M <- cor(corr_mat, use = 'complete.obs', method='spearman')


# Plot correlation matrix
corrplot(M, order = "AOE", tl.col = "black", tl.srt = 45, p.mat = corr.test(corr_mat)$p, insig = 'label_sig', sig.level = c(.001, .01, .05),
         pch.cex = 1.2, pch.col = 'red', 
         addCoef.col = "white", # add correlation values as text labels
         title = paste('Correlation Plot (', name_plot , ')'), cex.main = 1.8,
         mar=c(0,0,2,0))

# Save plot as image file
png(filename = paste("/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/Stats/R/corr_", name_plot, '_AOE.png'), 
    width = 865, height = 636)
corrplot(M, order = "AOE", tl.col = "black", tl.srt = 45, p.mat = corr.test(corr_mat)$p, insig = 'label_sig', sig.level = c(.001, .01, .05),
         pch.cex = 0.8, pch.col = 'red',
         title = paste('Correlation Plot (', name_plot , ')'),
         mar=c(0,0,2,0))
dev.off()

# Add correlation coefficients and p-values as text labels to the plot
p_corr_test <-corr.test(corr_mat)$p
cor_test_star <- symnum(p_corr_test, cutpoints = c(0, 0.001, 0.01, 0.05, 1), symbols = c("***","**","*",""))
r = round(cor(corr_mat, use = 'complete.obs', method='spearman'), digits = 2)
txt <- paste(r, cor_test_star, sep = " ")
cex.cor <- 0.8/strwidth(txt)
text(0.5, 0.5, txt, cex = cex.cor*r)


## Inspecting residuals
Flamenco_model.lm <- lmer(Q3 ~   Q1b + Abs_Av +   (1 + Abs_Av  | Participant) + (1 | Pair), data = data_ole)

data_filtered_Q6a_na <- na.omit(data_filtered_Q6a)

Flamenco_model.lm <- lmer(Q3 ~   Q1a + Q1b + Abs_Av + Perf_Av + Q4a + Q4b + Q4c  + Q5a + Q5b + Q6a+ Q6b +  (1 | Participant) + (1 | Pair), data = data_filtered_Q6a, na.action = na.omit)

res <- dredge(Flamenco_model.lm, trace=2, na.action = na.exclude)

library(MuMIn)
eval(metafor:::.MuMIn)
full <- rma(Q3, mods =  )

options(na.action = "na.exclude") 
cols_with_na <- c("GMSI","GDSI","Fam","Q1a","Q3","Q4a", "Q1b","Perf_Av", "Abs_Av", "Q4b" , "Q4c","Q6a", "Q6b", "Q5a", "Q5b", "Participant", "Pair", "Artist")  # Specify the column names with missing values

data_filtered_Q6a_complete <- na.omit(data_ole[, cols_with_na])
model = lmer(Q3 ~  Q1a + Q1b + Fam + GDSI + GMSI + Artist   + Q4a + Abs_Av + Perf_Av + Q4b + Q4c + Q6a + Q6b+ Q5a + Q5b +  (1  | Participant) + (1 | Pair), data = data_filtered_Q6a_complete,na.action = na.fail)
model = lmer(Q3 ~  Q1b + Artist + Q4a + Artist+  (1  | Participant) + (1 | Pair), data = data_filtered_Q6a_complete,na.action = na.fail)
model = lmer(Q3 ~   Q1b  + Abs_Av + Q4a + Q6b + (1 + Q4a  | Participant) + (1 | Pair), data = data_filtered_Q6a)

res <- dredge(model, trace=2)
subset(res, delta <= 2, recalc.weights=FALSE)
summary(model.avg(res))
sw(res)



model2 = lmer(Q3 ~   Q1b  + Abs_Av + Q4a + Q6b + (1 + Q4a  | Participant) + (1 | Pair), data = data_filtered_Q6a)

Flamenco_model.lm <- lmer(Q3 ~   Q1b   + Abs_Av  + Q4a + Q6b +  (1  + Q4a | Participant) + (1 | Pair), data = data_filtered_Q6a)


summary(Flamenco_model.lm)
#Flamenco_model.lm <- lmer(Q3 ~   poly(Q1b, degree = 2)   + Abs_Av  + Q4a + Q6b +  (1  + Q4a | Participant) + (1 | Pair), data = data_filtered_Q6a)

Plot_fe_Q4a <- effect_plot(Flamenco_model.lm, pred = Q4a, interval = TRUE, partial.residuals = TRUE, plot.points = TRUE, 
                           jitter = 0.00, point.size = 1.2, colors = new_colors[1]) +
  labs(x= "Connection", y = "Flow", title = "") + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1)) +
  scale_x_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1)) + 
  common_theme

plot(Flamenco_model.lm, xlab = "Abs_Av", resid = TRUE, partial.resid = TRUE)
plot_fe <- effect_plot(Flamenco_model.lm, pred = Q4a, partial.residuals = TRUE) 
plot_fe

# Create the marginal effects plot with partial residuals for the predictor variable "Days"
marginal_plot <- ggpredict(Flamenco_model.lm, terms = c("Abs_Av", "Q1b"), type = "re")
plot(marginal_plot)


plot(Flamenco_model.lm, xlab = "Rating", resid = TRUE, partial.resid = TRUE, type = "p")

mydf <- ggpredict(Flamenco_model.lm, terms = "Q6b", type = "re")
ggplot(mydf, aes(x, predicted)) +
  geom_line() +
  geom_point(aes(x, predicted)) +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high), alpha = .1)



