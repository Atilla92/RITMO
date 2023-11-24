library(ggplot2)
library(sjPlot)
library(sjlabelled)
library(sjmisc)
library(dplyr)
library(tidyr)

library(lme4)
library(lmerTest)
library(psych)

data <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/22_Sep_2023_niels/05102023_ELAN_no_CDRS_onset_niels_1s_complete.csv')
data <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/22_Sep_2023_niels/27102023_ELAN_no_CDRS_onset_niels_4s_final.csv')

data <- data %>%
  distinct(Name, Artist, .keep_all = TRUE)


# First the general analysis


# MACRO Check
data$Q1 <- (data$Q1a + data$Q1b) / 2
data$Q3 <- (data$Q3a + data$Q3b) / 2
data$Q6 <- (data$Q6a + data$Q6b) /2
data$Q5 <-  (data$Q5a + data$Q5b) /2
data$Q4 <- (data$Q4a + data$Q4b + data$Q4c) /3

# Factorize
# ALl analysis
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
#data$Artist <- ifelse(data$Artist == "G", 0, ifelse(data$Artist == "P", 1, data$Artist))
data$Artist <- as.factor(data$Artist)
data$Fam <- as.factor(data$Fam)



# Base models

m00  = lmer(Q1 ~   Q3 + (1 | Participant), data = data )
m01  = lmer(Q1 ~   Q1a + (1 | Participant), data = data )
m02  = lmer(Q1 ~   Q1b + (1 | Participant), data = data )
m03  = lmer(Q1 ~   Palo + (1 | Participant), data = data )
m04  = lmer(Q1 ~   Condition + (1 | Participant), data = data )
m05  = lmer(Q1 ~   Perf_Av + (1 | Participant), data = data )
m06  = lmer(Q1 ~   Abs_Av + (1 | Participant), data = data )


tab_model(m00, m01, m02, m03, m04, m05,m06,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", "m06"), digits = 5 )


m00  = lmer(Q1a ~   Q3 + ( 1 | Participant), data = data )
m01  = lmer(Q1b ~   Q3 + (1 | Participant), data = data )
m02  = lmer(Q1 ~   Q3+ (1 | Participant), data = data )
m03  = lmer(Q1a ~   Q3a + (1 | Participant), data = data )
m04  = lmer(Q1b ~   Q3a + (1 | Participant), data = data )
m05  = lmer(Q1 ~   Q3a + (1 | Participant), data = data )
m06  = lmer(Q1a ~   Q3b + (1 | Participant), data = data )
m07  = lmer(Q1b ~   Q3b + (1 | Participant), data = data )
m08  = lmer(Q1 ~   Q3b + (1 | Participant), data = data )
m09  = lmer(Q1a ~   Perf_Av + (1 | Participant), data = data )
m10  = lmer(Q1b ~   Perf_Av + (1 | Participant), data = data )
m11  = lmer(Q1 ~   Perf_Av+ (1 | Participant), data = data )
m12  = lmer(Q1a ~   Abs_Av + (1 | Participant), data = data )
m13  = lmer(Q1b ~   Abs_Av + (1 | Participant), data = data )
m14  = lmer(Q1 ~   Abs_Av + (1 | Participant), data = data )


tab_model(m00, m01, m02, m03, m04, m05,m06, m07, m08,m09, m10, m11, m12, m13, m14,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", "m06", 'm07', 'm08','m09', 'm10', 'm11', 'm12','m13','m14'), digits = 5 )

anova(m01,m02)
anova(m03,m04,m05)


m00  = lmer(Q1 ~   Q3 + ( Q3 | Participant), data = data )
m01  = lmer(Q1 ~   Q3 + (1 | Participant), data = data )
tab_model(m00, m01,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01"), digits = 5 )



m00  = lmer(Perf_Av ~   Condition + (1 | Participant), data = data )
m01  = lmer(Perf_Av ~   Artist + (1 | Participant), data = data )
m02  = lmer(Q1 ~   Perf_Av+ (1 | Participant), data = data )
m03  = lmer(Q1a ~   Abs_Av + (1 | Participant), data = data )
m04  = lmer(Q1b ~   Abs_Av + (1 | Participant), data = data )
m05  = lmer(Q1 ~   Abs_Av + (1 | Participant), data = data )

tab_model(m00, m01, m02, m03, m04, m05,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05"), digits = 5 )




m00  = lmer(Q1 ~   Q3 + (1 | Participant), data = data )
m01  = lmer(Q1 ~   Q4 + (1 | Participant), data = data )
m02  = lmer(Q1 ~   Q5 + (1 | Participant), data = data )
m03  = lmer(Q1 ~   Q6 + (1 | Participant), data = data )
m04  = lmer(Q1 ~   Condition + (1 | Participant), data = data )
m05  = lmer(Q1 ~   Perf_Av + (1 | Participant), data = data )
m06  = lmer(Q1 ~   Abs_Av + (1 | Participant), data = data )
m07 =  lmer(Q1 ~   Palo + (1 | Participant), data = data )
m08 =  lmer(Q1 ~   Artist + (1 | Participant), data = data )
m09 =  lmer(Q3 ~   Condition + (1 | Participant), data = data )


tab_model(m00, m01, m02, m03, m04, m05,m06, m07, m08, m09,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", "m06", "m07", "m08", "m09"), digits = 5 )

m00  = lmer(Q1 ~   Artist + (1 | Participant), data = data )
m01  = lmer(Q1 ~   Palo + (1 | Participant), data = data )
m02  = lmer(Q1 ~   Condition + (1 | Participant), data = data )
m03  = lmer(Q1 ~   Dance_mode + (1 | Participant), data = data )
m04  = lmer(Q1 ~   Music_mode + (1 | Participant), data = data )
m05  = lmer(Q3 ~   Artist + (1 | Participant), data = data )
m06  = lmer(Q3 ~   Palo + (1 | Participant), data = data )
m07  = lmer(Q3 ~   Condition + (1 | Participant), data = data )
m08  = lmer(Q3 ~   Dance_mode + (1 | Participant), data = data )
m09  = lmer(Q3 ~   Music_mode + (1 | Participant), data = data )

tab_model(m00, m01, m02, m03, m04, m05, m06, m07, m08, m09,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("Q1", "Q1", "Q1","Q1","Q1", "Q3", 'Q3', 'Q3', 'Q3', 'Q3'), digits = 5 )


m00  = lmer(Q1 ~   Artist * Condition + (1 | Participant), data = data )
m01  = lmer(Q1 ~   Palo + (1 | Participant), data = data )
m02  = lmer(Q1 ~   GDSI * Condition + (1 | Participant), data = data )
m03  = lmer(Q1 ~   GDSI * Artist + (1 | Participant), data = data )
m04  = lmer(Q1 ~   Fam + (1 | Participant), data = data )
m05  = lmer(Q3 ~   Artist * Condition + (1 | Participant), data = data )
m06  = lmer(Q3 ~   Palo + (1 | Participant), data = data )
m07  = lmer(Q3 ~   GDSI * Condition + (1 | Participant), data = data )
m08  = lmer(Q3 ~   GMSI + (1 | Participant), data = data )
m09  = lmer(Q3 ~   Fam + (1 | Participant), data = data )

tab_model(m00, m01, m02, m03, m04, m05, m06, m07, m08, m09,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", 'm06', 'm07', 'm08', 'm09'), digits = 5 )


m00  = lmer(Perf_Av ~   Artist + (1 | Participant), data = data )
m01  = lmer(Perf_Av ~   Palo + (1 | Participant), data = data )
m02  = lmer(Perf_Av ~   GDSI  + (1 | Participant), data = data )
m03  = lmer(Perf_Av ~   GMSI + (1 | Participant), data = data )
m04  = lmer(Perf_Av ~   Fam + (1 | Participant), data = data )
m05  = lmer(Abs_Av ~   Artist * Condition + (1 | Participant), data = data )
m06  = lmer(Abs_Av ~   Palo + (1 | Participant), data = data )
m07  = lmer(Abs_Av ~   GDSI + (1 | Participant), data = data )
m08  = lmer(Abs_Av ~   GMSI + (1 | Participant), data = data )
m09  = lmer(Abs_Av ~   Fam * Condition + (1 | Participant), data = data )

tab_model(m00, m01, m02, m03, m04, m05, m06, m07, m08, m09,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", 'm06', 'm07', 'm08', 'm09'), digits = 5 )


m00  = lmer(Q4b ~   Artist + (1 | Participant), data = data )
m01  = lmer(Q4b ~   Palo + (1 | Participant), data = data )
m02  = lmer(Q4b ~   GDSI  + (1 | Participant), data = data )
m03  = lmer(Q4b ~   GMSI + (1 | Participant), data = data )
m04  = lmer(Q4a ~   Fam * Condition + (1 | Participant), data = data )
m05  = lmer(Q6 ~   Artist + (1 | Participant), data = data )
m06  = lmer(Q6 ~   Palo + (1 | Participant), data = data )
m07  = lmer(Q6 ~   GDSI + (1 | Participant), data = data )
m08  = lmer(Q6 ~   GMSI + (1 | Participant), data = data )
m09  = lmer(Q6 ~   Fam * Condition + (1 | Participant), data = data )

tab_model(m00, m01, m02, m03, m04, m05, m06, m07, m08, m09,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", 'm06', 'm07', 'm08', 'm09'), digits = 5 )

confint(m00)


m00  = lmer(Q1 ~   Palo + (1 | Participant), data = data )
m01  = lmer(Q3 ~   Palo + (1 | Participant), data = data )
m02  = lmer(Q4 ~   Palo + (1 | Participant), data = data )
m03  = lmer(Q5 ~   Palo + (1 | Participant), data = data )
m04  = lmer(Q6 ~   Palo + (1 | Participant), data = data )
m05  = lmer(Q6a ~   Palo + (1 | Participant), data = data )
m06  = lmer(Q6b ~   Palo + (1 | Participant), data = data )
m07  = lmer(Perf_Av ~   Palo + (1 | Participant), data = data )
m08  = lmer(Abs_Av ~   Palo + (1 | Participant), data = data )

tab_model(m00, m01, m02, m03, m04, m05, m06, m07, m08,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", 'm06', 'm07', 'm08'), digits = 5 )

######### BONFERRONI CORRECTION 

# Calculate the number of tests
fixed_effects <- length(fixef(m04))  # Number of fixed effects
random_effects <- length(ranef(m04))  # Number of random effects
total_tests <- fixed_effects + random_effects  # Total number of tests

model_summary <- summary(m04)
p_values <- model_summary$coefficients[, "Pr(>|t|)"]
# Apply Bonferroni correction
corrected_p_values <- p.adjust(p_values, method = "bonferroni", n = total_tests)

# Display the corrected p-values
print(corrected_p_values)

# Calculate the number of tests
fixed_effects <- length(fixef(m05))  # Number of fixed effects
random_effects <- length(ranef(m05))  # Number of random effects
total_tests <- fixed_effects + random_effects  # Total number of tests

model_summary <- summary(m05)
p_values <- model_summary$coefficients[, "Pr(>|t|)"]
# Apply Bonferroni correction
corrected_p_values <- p.adjust(p_values, method = "bonferroni", n = total_tests)

# Display the corrected p-values
print(corrected_p_values)


# Calculate the number of tests
fixed_effects <- length(fixef(m07))  # Number of fixed effects
random_effects <- length(ranef(m07))  # Number of random effects
total_tests <- fixed_effects + random_effects  # Total number of tests

model_summary <- summary(m07)
p_values <- model_summary$coefficients[, "Pr(>|t|)"]
# Apply Bonferroni correction
corrected_p_values <- p.adjust(p_values, method = "bonferroni", n = total_tests)

# Display the corrected p-values
print(corrected_p_values)





m00 = lmer(Perf_Av ~   Q6a + (1 | Participant), data = data )
m01 = lmer(Perf_Av ~   Q6b + (1 | Participant), data = data )
m02 = lmer(Perf_Av ~   Q6 + (1 | Participant), data = data )
m03 = lmer(Perf_Av ~   Palo + (1 | Participant), data = data )
m04 = lmer(Perf_Av ~   Q6a * Palo + (1 | Participant), data = data )
m05 = lmer(Perf_Av ~   Q6b * Palo  + (1 | Participant), data = data )
m06 = lmer(Perf_Av ~   Q6 * Palo + (1 | Participant), data = data )
m07 = lmer(Q6a ~ Palo + (1 | Participant), data = data )
m08 = lmer(Q6b ~ Palo + (1 | Participant), data = data )
m09 = lmer(Q6 ~ Palo + (1 | Participant), data = data )
tab_model(m00, m01, m02, m03, m04, m05, m06, m07, m08,m09,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", 'm06', 'm07', 'm08', 'm09'), digits = 5 )



# Calculate the number of tests
fixed_effects <- length(fixef(m04))  # Number of fixed effects
random_effects <- length(ranef(m04))  # Number of random effects
total_tests <- fixed_effects + random_effects  # Total number of tests

model_summary <- summary(m04)
p_values <- model_summary$coefficients[, "Pr(>|t|)"]
# Apply Bonferroni correction
corrected_p_values <- p.adjust(p_values, method = "bonferroni", n = total_tests)

# Display the corrected p-values
print(corrected_p_values)

fixed_effects <- length(fixef(m05))  # Number of fixed effects
random_effects <- length(ranef(m05))  # Number of random effects
total_tests <- fixed_effects + random_effects  # Total number of tests

model_summary <- summary(m05)
p_values <- model_summary$coefficients[, "Pr(>|t|)"]
# Apply Bonferroni correction
corrected_p_values <- p.adjust(p_values, method = "bonferroni", n = total_tests)

# Display the corrected p-values
print(corrected_p_values)


fixed_effects <- length(fixef(m06))  # Number of fixed effects
random_effects <- length(ranef(m06))  # Number of random effects
total_tests <- fixed_effects + random_effects  # Total number of tests

model_summary <- summary(m06)
p_values <- model_summary$coefficients[, "Pr(>|t|)"]
# Apply Bonferroni correction
corrected_p_values <- p.adjust(p_values, method = "bonferroni", n = total_tests)

# Display the corrected p-values
print(corrected_p_values)




m00  = lmer(Q2b ~   Palo + (1 | Participant), data = data )
m01  = lmer(Q2d ~   Palo + (1 | Participant), data = data )
m02  = lmer(Q2e ~   Palo + (1 | Participant), data = data )
m03  = lmer(Q2g ~   Palo + (1 | Participant), data = data )
m04  = lmer(Q2h ~   Palo + (1 | Participant), data = data )
m05  = lmer(Q2i ~   Palo + (1 | Participant), data = data )
m06  = lmer(Perf_Av ~   Palo + (1 | Participant), data = data )

tab_model(m00, m01, m02, m03, m04, m05, m06, m07, m08,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", 'm06', 'm07', 'm08'), digits = 5 )










# List of lmer models
models_list <- list(m00, m01, m02, m03, m04, m05, m06)

# Extract the p-values from each model
p_values <- sapply(models_list, function(model) {
  summary(model)$coefficients[, "Pr(>|t|)"]
})

# Flatten the list of p-values to a vector
p_values_vector <- unlist(p_values)
# Apply Bonferroni correction
corrected_p_values <- p.adjust(p_values_vector, method = "bonferroni")

# Print the corrected p-values
print(corrected_p_values)

result_table <- data.frame(
  Model = c("m00", "m01", "m02", "m03", "m04", "m05", "m06"),
  Original_P_Value = p_values,
  Corrected_P_Value = corrected_p_values
)

# Displaying the new table
print(result_table)

m00  = lmer(Q1 ~   Music_mode + (1 | Participant), data = data )
m01  = lmer(Q1 ~   Dance_mode + (1 | Participant), data = data )
m02 =  lmer(Q1 ~   Condition + (1 | Participant), data = data )
m03 =  lmer(Q1 ~   Artist + (1 | Participant), data = data )
m04 =  lmer(Q1 ~   Palo + (1 | Participant), data = data )

tab_model(m00, m01, m02, m03,m04,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03", "m04"), digits = 5 )

anova(m00, m01,m02,m03,m04,m05)
summary(m02)

m00 =  lmer(Q1 ~   Condition + (1 | Participant) + (1 | Fam), data = data )
m01 =  lmer(Q1 ~   Condition + (1 | Participant) + (1 | GDSI), data = data )
m02 =  lmer(Q1 ~   Condition + (1 | Participant) + (1 | Gender), data = data )
m03 =  lmer(Q1 ~   Condition + (1 | Participant) + (1 | Artist), data = data )
m04 =  lmer(Q1 ~   Condition + (1 | Participant) + (1 | GMSI), data = data )
m05 =  lmer(Q1 ~   Condition  +  (1 | Participant) + (1 | GDSI)  + (1 | Artist),  data = data )
tab_model(m00, m01, m02, m03, m04, m05,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03", "m04", "m05"), digits = 5 )
anova(m02, m03)



m01  = lmer(Q3b ~   1 + (1 | Participant) + (1 | Pair)  , data = data )
m02  = lmer(Q3b ~   1 + (1 | Participant)  + (1 | GMSI) + (1|GDSI), data = data )
m03  = lmer(Q3b ~   1 + (1 | Participant) + (1 | GMSI) , data = data )
m04  = lmer(Q3b ~   1 +  (1|Participant) + (1 |GDSI)  , data = data )
m05  = lmer(Q3b ~   1 + (1 | Pair/Participant) , data = data )
m06 =  lmer(Q3b ~   1 + (1 | Artist) , data = data )
m07 =  lmer(Q3b ~   1 + (1 | GDSI) , data = data )
m08 =  lmer(Q3b ~   1 + (1 | GMSI) , data = data )
m09 =  lmer(Q3b ~   1 + (1 | Fam) , data = data )

tab_model(m01, m02, m03, m04, m05,m06,m07, m08, m09,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07", "m08", "m09"), digits = 5 )

anova(m01, m02, m03, m04, m05, m06)
anova(m02,m03,m04)

m00  = lmer(Q3b ~   1 + (1 | Participant), data = data )
m01  = lmer(Q3b ~   Q1a + (1 | Participant), data = data )
m02  = lmer(Q3b ~   Q1b + (1 | Participant), data = data )
m03  = lmer(Q3b ~   Palo + (1 | Participant), data = data )
m04  = lmer(Q3b ~   Condition + (1 | Participant), data = data )
m05  = lmer(Q3b ~   Perf_Av + (1 | Participant), data = data )
m06  = lmer(Q3b ~   Abs_Av + (1 | Participant), data = data )
m07 =  lmer(Q3b ~   Q3a + (1 | Participant), data = data )
m08 =  lmer(Q3b ~   Artist + (1 | Participant), data = data )

tab_model(m00, m01, m02, m03, m04, m05,m06, m07, m08,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", "m06", "m07", 'm08'), digits = 5 )



m00  = lmer(Q3 ~   Q1 + (1 | Participant), data = data )
m01  = lmer(Q3 ~   Q4 + (1 | Participant), data = data )
m02  = lmer(Q3 ~   Q5 + (1 | Participant), data = data )
m03  = lmer(Q3 ~   Q6 + (1 | Participant), data = data )
m04  = lmer(Q3 ~   Condition + (1 | Participant), data = data )
m05  = lmer(Q3 ~   Perf_Av + (1 | Participant), data = data )
m06  = lmer(Q3 ~   Abs_Av + (1 | Participant), data = data )
m07 =  lmer(Q3 ~   Palo + (1 | Participant), data = data )
m08 =  lmer(Q3 ~   Artist + (1 | Participant), data = data )

tab_model(m00, m01, m02, m03, m04, m05,m06, m07, m08,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", "m06", "m07", "m08"), digits = 5 )
anova(m00, m04, m05,m06, m07, m08)

m00  = lmer(Q3 ~   Q4a + (1 | Participant), data = data )
m01  = lmer(Q3 ~   Q4b + (1 | Participant), data = data )
m02  = lmer(Q3 ~   Q4c + (1 | Participant), data = data )
m03  = lmer(Q3 ~   Q4 + (1 | Participant), data = data )
m04  = lmer(Q3 ~   Q5a  + (1 | Participant), data = data )
m05  = lmer(Q3 ~   Q5b + (1 | Participant), data = data )
m06  = lmer(Q3 ~   Q5 + (1 | Participant), data = data )
m07 =  lmer(Q3 ~   Q6a + (1 | Participant), data = data )
m08 =  lmer(Q3 ~   Q6b + (1 | Participant), data = data )
m09 =  lmer(Q3 ~   Q6 + (1 | Participant), data = data )
tab_model(m00, m01, m02, m03, m04, m05,m06, m07, m08, m09,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", "m06", "m07", "m08", 'm09'), digits = 5 )


m00  = lmer(Q3 ~   Condition + (1 | Participant), data = data )
m01  = lmer(Q3 ~   Q4a + (1 | Participant), data = data )
m02  = lmer(Q3 ~   Q4b + (1 | Participant), data = data )
m03  = lmer(Q3 ~   Q4c + (1 | Participant), data = data )
m04  = lmer(Q3 ~  Q4 + (1 | Participant), data = data )
m05  = lmer(Q3 ~  Palo +  (1 | Participant), data = data )
m06  = lmer(Q3 ~  Artist +  (1 | Participant), data = data )
tab_model(m00, m01, m02, m03, m04, m05,m06,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", "m06"), digits = 5 )






m00  = lmer(Q3b ~  Condition + (1 | Participant), data = data )
m01  = lmer(Q3b ~  Condition +Q4 +   (1 | Participant), data = data )
m02  = lmer(Q3b ~  Q1b +  Q4 + (1 | Participant), data = data )
m03  = lmer(Q3b ~  Condition + Q1b + Q4 + Q6 + (1 | Participant), data = data )
m04  = lmer(Q3b ~   Q1b + Q4 + Q5 + Q6 +  (1 | Participant), data = data )
m05  = lmer(Q3b ~    Q1b + Q4 + Q6 + (1 | Participant), data = data )
m06 =  lmer(Q3b ~      Q1b + Q4a + Q6 +  (1 | Participant), data = data )
m07 =  lmer(Q3b ~      Q1b + Q4a + Q6 + Perf_Av +  (1 | Participant), data = data )


tab_model(m00, m01, m02, m03, m04, m05,m06,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", "m06"), digits = 5 )


m00  = lmer(Q3b ~    Q1b + Q4 + Q6 + GDSI + (1 | Participant), data = data )
m01  = lmer(Q3b ~    Q1b + Q4 + Q6 + (1| GDSI) + (1 | Participant), data = data )
m02  = lmer(Q3b ~    Q1b + Q4 + Q6 + (1 |GMSI) + (1 | Participant), data = data )
m03  = lmer(Q3b ~    Q1b + Q4 + Q6 + Abs_Av + (1 |GMSI) + (1 |Participant), data = data )
m04  = lmer(Q3b ~    Q1b + Q4b + Q6 + Abs_Av +  (1 | GMSI) + (1 |Participant), data = data )
anova(m00, m01, m02, m03, m04)
tab_model(m00, m01, m02, m03, m04, m05,m06,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", "m06"), digits = 5 )


######
m00 =  lmer(Q3a ~      Q1b + Q4a + Q6 + (1 | Participant), data = data )
m01 =  lmer(Q3b ~      Q1b + Q4a  + Q6 + (1 | Participant), data = data )
m02 =  lmer(Q3 ~      Q1b + Q4a  + Q6 +   (1 | Participant), data = data )
m03 =  lmer(Perf_Av ~        Q4a + Q5a  +   (1 | Participant), data = data )
m04 =  lmer(Abs_Av ~      Q1b  + Q6  +   (1 | Participant), data = data )
tab_model(m00, m01, m02, m03, m04, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("Q3a", "Q3b", "Q3","Perf_Av", "Abs_Av"), digits = 5 )





m00  = lmer(Q3b ~  Condition + (1 | Participant), data = data )
m01  = lmer(Q3b ~  Condition +Q4a +   (1 | Participant), data = data )
m02  = lmer(Q3b ~  Q1b +  Q4a +  Q4b + (1 | Participant), data = data )
m03  = lmer(Q3b ~  Condition + Q1b + Q4a  + (1 | Participant), data = data )
m04  = lmer(Q3b ~   Condition + Q4a + Perf_Av +  (1 | Participant), data = data )
m05  = lmer(Q3b ~    Condition + Q4a + Q1b +  Abs_Av + (1 | Participant), data = data )

tab_model(m00, m01, m02, m03, m04, m05, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05"), digits = 5 )

m00  = lmer(Q3a ~    Condition + Q4a + Q1b  + (1 | Participant), data = data )
m01  = lmer(Q3b ~    Condition + Q4a + Q1b  + (1 | Participant), data = data )
m02  = lmer(Q3 ~    Condition + Q4a + Q1b + (1 | Participant), data = data )
m03  = lmer(Perf_Av ~    Condition + Q4a + Q1b  + (1 | Participant), data = data )
m04  = lmer(Abs_Av ~   Condition +  Q4a + Q1b +(1 | Participant), data = data )

tab_model(m00, m01, m02, m03, m04,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("Q3a", "Q3b", "Q3", "Perf_Av", "Abs_Av"), digits = 5 )

m00  = lmer(Q3b ~    Condition  + (1 | Participant), data = data )
m01  = lmer(Q3b ~   Condition + Q4a   + (1 | Participant), data = data )
m02  = lmer(Q3b ~   Condition + Q4a   + Q1b + (1 | Participant), data = data )
m03  = lmer(Q3b ~    Condition + Q4a + Q1b +  Abs_Av + (1 | Participant), data = data )
m04  = lmer(Q3b ~    Condition + Q4a + Q1b  + (1 | Participant), data = data )
m05  = lmer(Q3b ~    Q4a + Q1b  + Abs_Av +(1 | Participant), data = data )
m06  = lmer(Q3b ~    1 + (1 | Participant), data = data )

tab_model(m00, m01, m02, m03, m04,m05, m06,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02", "m03", "m04", "m05", "m06"), digits = 5 )
anova(m04,m03)


m00  = lmer(Q3b ~    Condition + Q4a + Q1b  + Abs_Av + GDSI + (1 | Participant) , data = data )
m01  = lmer(Q3b ~    Q4a + Q1b  + Abs_Av + GDSI + (1 | Participant), data = data )
m02  = lmer(Q3b ~    Condition + Q4a +  Q1b   + Abs_Av  + GDSI + (1 | Participant), data = data )
m03  = lmer(Q3b ~    Q4a + Q1b  + Abs_Av + (1 | Participant)  + (1|Artist), data = data )
m04  = lmer(Q3b ~    Q4a + Q1b  + Abs_Av + Artist  +  (1 | Participant) , data = data )
m05  = lmer(Q3b ~    Q4a + Q1b  + Abs_Av + Artist +  GDSI + (1 | Participant) , data = data )


tab_model(m00, m01, m02, m03, m04,m05, m06,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02", "m03", "m04", "m05", "m06"), digits = 5 )

anova(m00, m01, m02)

m01  = lmer(Q3b ~ 1 + (1 | Pair), data = data )
m01  = lmer(Q3b ~ 1 + (1 | Participant), data = data )


m00  = lmer(Q3a ~    Condition + (1 | Participant), data = data )
m01  = lmer(Q3b ~    Condition  + (1 | Participant), data = data )
m02  = lmer(Q3 ~    Condition  + (1 | Participant), data = data )
m03  = lmer(Perf_Av ~    Condition + (1 | Participant), data = data )
m04  = lmer(Abs_Av ~   Condition  +(1 | Participant), data = data )

tab_model(m00, m01, m02, m03, m04,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("Q3a", "Q3b", "Q3", "Perf_Av", "Abs_Av"), digits = 5 )

anova(m00,m01,m02,m03,m04)


m00  = lmer(Q1 ~    Condition + (1 | Participant), data = data )
m01  = lmer(Q3 ~    Condition  + (1 | Participant), data = data )
m02  = lmer(Q4 ~    Condition  + (1 | Participant), data = data )
m03  = lmer(Q5 ~    Condition  + (1 | Participant), data = data )
m04  = lmer(Q6 ~    Condition  + (1 | Participant), data = data )
m05  = lmer(Perf_Av ~    Condition + (1 | Participant), data = data )
m06  = lmer(Abs_Av ~   Condition  +(1 | Participant), data = data )

tab_model(m00, m01, m02, m03, m04,m05, m06,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("Q1", "Q3", "Q4","Q5","Q6", "Perf_Av", "Abs_Av"), digits = 5 )


m00  = lmer(Q1a ~    Condition + (1 | Participant), data = data )
m01  = lmer(Q1b ~    Condition  + (1 | Participant), data = data )
m02  = lmer(Q1 ~    Condition  + (1 | Participant) + (1 | Pair), data = data )
m03  = lmer(Q1 ~    Condition  + (1 | Participant), data = data )
m04  = lmer(Q1 ~    Condition + (1 | Pair), data = data )
m05  = lmer(Q1 ~    Condition + (1| GDSI)+ (1 | Participant) + (1 | Pair), data = data )
m06  = lmer(Q1a ~    Condition + (1| GDSI)+ (1 | Participant) + (1 | Pair), data = data )
m07  = lmer(Q1b ~    Condition + (1| GDSI)+ (1 | Participant) + (1 | Pair), data = data )


tab_model(m00, m01, m02, m03, m04,m05, m06, m07,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02", "m03", "m04", "m05", "m06", "m07"), digits = 5 )

tab_model(m05, m06, m07,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c( "m05", "m06", "m07"), digits = 5 )


# Extract variance components for each model
var_comp_m05 <- VarCorr(m05)
var_comp_m06 <- VarCorr(m06)
var_comp_m07 <- VarCorr(m07)

# Extract the values for GDSI, Participant, and Pair
gdsi_m05 <- var_comp_m05$GDSI
gdsi_m06 <- var_comp_m06$GDSI
gdsi_m07 <- var_comp_m07$GDSI

participant_m05 <- var_comp_m05$Participant
participant_m06 <- var_comp_m06$Participant
participant_m07 <- var_comp_m07$Participant

pair_m05 <- var_comp_m05$Pair
pair_m06 <- var_comp_m06$Pair
pair_m07 <- var_comp_m07$Pair

# Calculate the percentages
total_var_m05 <- sum(sigma(m05)^2) + gdsi_m05 + participant_m05 + pair_m05 
total_var_m06 <- sum(sigma(m06)^2)+ gdsi_m06 + participant_m06 + pair_m06 
total_var_m07 <- sum(sigma(m07)^2)+ gdsi_m07 + participant_m07 + pair_m07

percentage_gdsi_m05 <- (gdsi_m05 / total_var_m05) * 100
percentage_gdsi_m06 <- (gdsi_m06 / total_var_m06) * 100
percentage_gdsi_m07 <- (gdsi_m07 / total_var_m07) * 100

percentage_participant_m05 <- (participant_m05 / total_var_m05) * 100
percentage_participant_m06 <- (participant_m06 / total_var_m06) * 100
percentage_participant_m07 <- (participant_m07 / total_var_m07) * 100

percentage_pair_m05 <- (pair_m05 / total_var_m05) * 100
percentage_pair_m06 <- (pair_m06 / total_var_m06) * 100
percentage_pair_m07 <- (pair_m07 / total_var_m07) * 100




anova(m05,m06,m07)




m00  = lmer(Q3a ~    Q1b * Condition + (1 | Participant), data = data )
m01  = lmer(Q3b ~   Q1b *  Condition  + (1 | Participant), data = data )
m02  = lmer(Q3 ~    Q1b * Condition  + (1 | Participant), data = data )
m03  = lmer(Perf_Av ~   Q1b *  Condition + (1 | Participant), data = data )
m04  = lmer(Abs_Av ~   Q1b * Condition  +(1 | Participant), data = data )

tab_model(m00, m01, m02, m03, m04,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("Q3a", "Q3b", "Q3", "Perf_Av", "Abs_Av"), digits = 5 )

anova(m00,m01,m02,m03,m04)




# COMPLEXITY 
dataP <- data[grepl("P", data$Participant),] #only dancers
dataG <- data[grepl("G", data$Participant),] #only dancers

# Normalize the data accross participants. 

# Group your data by participant (assuming you have a participant identifier, e.g., "Participant_ID")
data <- data %>%
  group_by(Participant) %>%
  mutate(
    n_p_LZ = (p_LZ - min(p_LZ)) / (max(p_LZ) - min(p_LZ)),  # Scale to [0, 1]
    n_p_dt_LZ = ((p_dt_LZ - min(p_dt_LZ)) / (max(p_dt_LZ) - min(p_dt_LZ))) - 0.5,  # Scale to [-0.5, 0.5]
    n_p_IOI = (p_IOI - min(p_IOI)) / (max(p_IOI) - min(p_IOI)),  # Scale to [0, 1]
    n_p_ncounts = (p_ncounts - min(p_ncounts)) / (max(p_ncounts) - min(p_ncounts))  # Scale to [0, 1]
  ) %>%
  ungroup()  # Remove grouping






dataP <- dataP %>%
  group_by(Participant) %>%
  mutate(
    n_p_LZ = (p_LZ - min(p_LZ)) / (max(p_LZ) - min(p_LZ)),  # Scale to [0, 1]
    n_p_dt_LZ = ((p_dt_LZ - min(p_dt_LZ)) / (max(p_dt_LZ) - min(p_dt_LZ))) - 0.5,  # Scale to [-0.5, 0.5]
    n_p_IOI = (p_IOI - min(p_IOI)) / (max(p_IOI) - min(p_IOI)),  # Scale to [0, 1]
    n_p_ncounts = (p_ncounts - min(p_ncounts)) / (max(p_ncounts) - min(p_ncounts))  # Scale to [0, 1]
  ) %>%
  ungroup()  # Remove grouping


dataG <- dataG %>%
  group_by(Participant) %>%
  mutate(
    n_g_LZ = (g_LZ - min(g_LZ)) / (max(g_LZ) - min(g_LZ)),  # Scale to [0, 1]
    n_g_dt_LZ = ((g_dt_LZ - min(g_dt_LZ)) / (max(g_dt_LZ) - min(g_dt_LZ))) - 0.5,  # Scale to [-0.5, 0.5]
    n_g_IOI = (g_IOI - min(g_IOI)) / (max(g_IOI) - min(g_IOI)),  # Scale to [0, 1]
    n_g_ncounts = (g_ncounts - min(g_ncounts)) / (max(g_ncounts) - min(g_ncounts))  # Scale to [0, 1]
  ) %>%
  ungroup()  # Remove grouping


non_finite_count <- sum(!is.finite(dataP$n_p_dt_LZ))
# Print the result
cat("Number of non-finite values in kn_p_dt_LZ:", non_finite_count, "\n")







m00  = lmer(p_LZ ~  Condition * Palo + (1 | Participant), data = dataP )
m01  = lmer(g_LZ ~  Condition * Palo +  (1 | Participant), data = dataG )
m02  = lmer(n_p_LZ ~  Condition* Palo + (1 | Participant), data = dataP )
m03  = lmer(n_g_LZ ~  Condition * Palo+  (1 | Participant), data = dataG )
m04  = lmer(p_dt_LZ ~  Condition* Palo + (1 | Participant), data = dataP )
m05  = lmer(g_dt_LZ ~  Condition* Palo +  (1 | Participant), data = dataG )
m06  = lmer(n_p_dt_LZ ~  Condition* Palo + (1 | Participant), data = dataP )
m07  = lmer(n_g_dt_LZ ~  Condition* Palo +  (1 | Participant), data = dataG )


tab_model(m00, m01, m02, m03, m04, m05,m06, m07,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", "m06", "m07"), digits = 5 )

m00  = lmer(p_LZ ~  Q1a * Palo + (1 | Participant), data = dataP )
m01  = lmer(g_LZ ~  Q1a * Palo +  (1 | Participant), data = dataG )
m02  = lmer(n_p_LZ ~  Q1a* Palo + (1 | Participant), data = dataP )
m03  = lmer(n_g_LZ ~  Q1a * Palo+  (1 | Participant), data = dataG )
m04  = lmer(p_dt_LZ ~  Q1a* Palo + (1 | Participant), data = dataP )
m05  = lmer(g_dt_LZ ~  Q1a* Palo +  (1 | Participant), data = dataG )
m06  = lmer(n_p_dt_LZ ~  Q1a* Palo + (1 | Participant), data = dataP )
m07  = lmer(n_g_dt_LZ ~  Q1a* Palo +  (1 | Participant), data = dataG )


tab_model(m00, m01, m02, m03, m04, m05,m06, m07,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", "m06", "m07"), digits = 5 )



m00  = lmer(Q6a ~  Condition * Palo + (1 | Participant), data = dataP )
m01  = lmer(Q6b ~  Condition * Palo +  (1 | Participant), data = dataP )
m02  = lmer(Q6 ~  Condition* Palo + (1 | Participant), data = dataP )
m03  = lmer(Q6a ~  Condition * Palo+  (1 | Participant), data = dataG )
m04  = lmer(Q6b ~  Condition* Palo + (1 | Participant), data = dataG )
m05  = lmer(Q6 ~  Condition* Palo +  (1 | Participant), data = dataG )
m06  = lmer(Q6a ~  Condition* Palo + (1 | Participant), data = data )
m07  = lmer(Q6b ~  Condition* Palo +  (1 | Participant), data = data )
m08  = lmer(Q6 ~  Condition* Palo +  (1 | Participant), data = data )
m09  = lmer(Q6a ~  Condition* Palo + Artist +   (1 | Participant), data = data )

tab_model(m00, m01, m02, m03, m04, m05,m06, m07,m08, m09,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", "m06", "m07", "m08", "m09"), digits = 5 )


m00  = lmer(Q6a ~  Condition + (1 | Participant), data = data )
m01  = lmer(Q6b ~  Condition +  (1 | Participant), data = data )
m02  = lmer(Q6 ~  Condition +  (1 | Participant), data = data )
m03  = lmer(Q6a ~   Palo +    (1 | Participant), data = data )
m04  = lmer(Q6b ~   Palo +    (1 | Participant), data = data )
m05  = lmer(Q6 ~   Palo +   (1 | Participant), data = data )
m06  = lmer(Q6a ~  Condition* Palo + (1 | Participant), data = data )
m07  = lmer(Q6b ~  Condition* Palo +  (1 | Participant), data = data )
m08  = lmer(Q6 ~  Condition* Palo +  (1 | Participant), data = data )
m09  = lmer(Q6a ~   Music_mode * Artist +   (1 | Participant), data = data )

tab_model(m00, m01, m02, m03, m04, m05,m06, m07,m08, m09,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", "m06", "m07", "m08", "m09"), digits = 5 )

m00  = lmer(Q6a ~  Condition + (1 | Participant), data = data )
m01  = lmer(Q6a ~  Condition * Palo + (1 | Participant), data = data )
m02  = lmer(Q6a ~  Dance_mode + (1 | Participant), data = data )
m03  = lmer(Q6a ~  Dance_mode * Palo + (1 | Participant), data = data )
m04  = lmer(Q6a ~  Music_mode  + (1 | Participant), data = data )
m05  = lmer(Q6a ~  Music_mode * Palo  + (1 | Participant), data = data )

tab_model(m00, m01, m02, m03, m04, m05,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05" ), digits = 5 )

anova(m00, m01, m02, m03, m04, m05)
fixed_effects <- length(fixef(m00))  # Number of fixed effects
random_effects <- length(ranef(m00))  # Number of random effects
total_tests <- fixed_effects + random_effects  # Total number of tests

model_summary <- summary(m03)
p_values <- model_summary$coefficients[, "Pr(>|t|)"]
# Apply Bonferroni correction
corrected_p_values <- p.adjust(p_values, method = "bonferroni", n = total_tests)

# Display the corrected p-values
print(corrected_p_values)
print(p_values)



m00  = lmer(Q6a ~  p_LZ * Palo + (1 | Participant), data = dataP )
m01  = lmer(Q6a ~  n_p_LZ * Palo +  (1 | Participant), data = dataP )
m02  = lmer(Q6a ~  np_LZ + (1 | Participant), data = dataP )
m03  = lmer(Q6a ~  n_p_ncounts +  (1 | Participant), data = dataP )
m04  = lmer(Q6a ~  n_p_ncounts* Palo + (1 | Participant), data = dataP )
m05  = lmer(Q6a~  n_p_IOI  +  (1 | Participant), data = dataP )
m06  = lmer(Q6a ~  p_IOI  + (1 | Participant), data = dataP )
m07  = lmer(Q6b ~  n_p_IOI * Palo +  (1 | Participant), data = dataP )
m08  = lmer(Q6 ~  Condition* Palo +  (1 | Participant), data = data )
m09  = lmer(Q6a ~  Condition* Palo + Artist +   (1 | Participant), data = data )

tab_model(m00, m01, m02, m03, m04, m05,m06, m07,m08, m09,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", "m06", "m07", "m08", "m09"), digits = 5 )



m00  = lmer(Q6a ~  p_LZ + (1 | Participant), data = data )
m01  = lmer(Q6b ~  p_LZ +  (1 | Participant), data = data )
m02  = lmer(Q6 ~  p_LZ + (1 | Participant), data = data )
m03  = lmer(Q6a ~  p_LZ + (1 | Participant), data = dataP )
m04  = lmer(Q6b ~  p_LZ +  (1 | Participant), data = dataP )
m05  = lmer(Q6 ~  p_LZ + (1 | Participant), data = dataP )
m06  = lmer(Q6a ~  n_p_LZ + (1 | Participant), data = data )
m07  = lmer(Q6b ~  n_p_LZ +  (1 | Participant), data = data )
m08  = lmer(Q6 ~  n_p_LZ + (1 | Participant), data = data )


tab_model(m00, m01, m02, m03, m04, m05,m06, m07,m08, m09,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", "m06", "m07", "m08", "m09"), digits = 5 )

m00  = lmer(Q1a ~  Condition  + (1 | Participant), data = data )
m01  = lmer(Q1b ~  Condition  + (1 | Participant), data = data )
m02  = lmer(Q3a ~  Condition +  (1 | Participant), data = data )
m03  = lmer(Q3b ~  Condition +  (1 | Participant), data = data )
m04  = lmer(Q4a ~  Condition + (1 | Participant), data = data )
m05  = lmer(Q4b ~  Condition + (1 | Participant), data = data )
m06  = lmer(Q4c ~  Condition + (1 | Participant), data = data )
m07  = lmer(Q5a ~  Condition + (1 | Participant), data = data )
m08  = lmer(Q5b ~  Condition + (1 | Participant), data = data )
m09  = lmer(Q6a ~  Condition +  (1 | Participant), data = data )
m10  = lmer(Q6b ~  Condition +  (1 | Participant), data = data )
m11  = lmer(Perf_Av ~  Condition + (1 | Participant), data = data )
m12  = lmer(Abs_Av ~  Condition + (1 | Participant), data = data )


tab_model(m00, m01, m02, m03, m04, m05,m06, m07,m08, m09,m10,m11,m12,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("Q1a", "Q1b", "Q3a","Q3b","Q4a", "Q4b", "Q4c", "Q5a", "Q5b", "Q6a", 'Q6b', 'Perf_Av', 'Abs_Av'), digits = 5 )


m00  = lmer(Q1a ~  Condition * Palo  + (1 | Participant), data = data )
m01  = lmer(Q1b ~  Condition* Palo  + (1 | Participant), data = data )
m02  = lmer(Q3a ~  Condition* Palo +  (1 | Participant), data = data )
m03  = lmer(Q3b ~  Condition* Palo +  (1 | Participant), data = data )
m04  = lmer(Q4a ~  Condition* Palo + (1 | Participant), data = data )
m05  = lmer(Q4b ~  Condition* Palo + (1 | Participant), data = data )
m06  = lmer(Q4c ~  Condition* Palo + (1 | Participant), data = data )
m07  = lmer(Q5a ~  Condition* Palo + (1 | Participant), data = data )
m08  = lmer(Q5b ~  Condition* Palo + (1 | Participant), data = data )
m09  = lmer(Q6a ~  Condition* Palo +  (1 | Participant), data = data )
m10  = lmer(Q6b ~  Condition* Palo +  (1 | Participant), data = data )
m11  = lmer(Perf_Av ~  Condition* Palo + (1 | Participant), data = data )
m12  = lmer(Abs_Av ~  Condition * Palo+ (1 | Participant), data = data )


tab_model(m00, m01, m02, m03, m04, m05,m06, m07,m08, m09,m10,m11,m12,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("Q1a", "Q1b", "Q3a","Q3b","Q4a", "Q4b", "Q4c", "Q5a", "Q5b", "Q6a", 'Q6b', 'Perf_Av', 'Abs_Av'), digits = 5 )



### Test for familiarity, Artist and Experience effect. 






#### Test whether Abs_Av remains stable accross conditions. 
#### TO investigate whehter in fact there is no significant p-value across conditions. 


ggplot(data, aes(x = Condition, y = Abs_Av, fill = Condition)) +
  geom_violin(trim = FALSE) +
  stat_summary(fun.data = mean_sdl, geom = "pointrange", 
               position = position_dodge(width = 0.9)) +
  labs(x = "Conditions", y = "Abs_Av", fill = "Conditions") +
  ggtitle("Violin Plot for Abs_Av Grouped by Conditions") +
  theme_minimal()

ggplot(data, aes(x = Condition, y = Abs_Av, fill = Condition)) +
  geom_violin(trim = FALSE) +
  geom_boxplot(width = 0.1, position = position_dodge(0.9)) +
  labs(x = "Conditions", y = "Abs_Av", fill = "Conditions") +
  ggtitle("Box plot with Quartiles on Top of Violin Plot") +
  theme_minimal()


ggplot(data, aes(x = Condition, y = Q3b, fill = Condition)) +
  geom_violin(trim = FALSE) +
  geom_boxplot(width = 0.1, position = position_dodge(0.9)) +
  labs(x = "Conditions", y = "Flow Intensity", fill = "Conditions") +
  ggtitle("Flow intensity for different conditions") +
  theme_minimal()


ggplot(data, aes(x = Condition, y = Q1, fill = Condition)) +
  geom_violin(trim = FALSE) +
  geom_boxplot(width = 0.1, position = position_dodge(0.9)) +
  labs(x = "Conditions", y = "Quality and Quantity of Improvisation", fill = "Conditions") +
  ggtitle("Flow intensity for different conditions") +
  theme_minimal()

data %>%
  mutate(Condition = ifelse(Condition == "D6_M6", "D6_M6", "D1_M1")) %>%
  ggplot(aes(x = factor(Condition), y = Q1, fill = Condition)) +
  geom_violin(data = . %>% filter(Condition == "D6_M6"), position = "dodge", trim = FALSE) +
  geom_violin(data = . %>% filter(Condition == "D1_M1"), position = "dodge", trim = FALSE) +
  stat_summary(fun = mean, geom = "point", shape = 20, size = 3, color = "black") +
  stat_summary(fun.data = mean_sdl, fun.args = list(mult = 1), geom = "errorbar", width = 0.2) +
  labs(title = "Violin Plot with Mean and Standard Deviation for Q1",
       x = "Condition",
       y = "Q1") +
  theme_minimal()


# Install and Load the packages


library(ggplot2)
library(see)


# Create the violin plot
ggplot(data, aes(Condition, Q1, fill = Condition)) +
  geom_violinhalf(flip = TRUE, aes(fill = Condition), trim = FALSE) +
  stat_summary(fun = "mean", geom = "point", shape = 20, size = 3, color = "black") +
  stat_summary(fun.data = "mean_cl_boot", geom = "errorbar", width = 0.2, color = "black") +
  theme_minimal() +
  labs(x = "Condition", y = "Q1")


ggplot(data, aes(Condition, Q3, fill = Condition)) +
  geom_violinhalf(flip = FALSE, aes(fill = Condition), trim = FALSE) +
  stat_summary(fun = "mean", geom = "point", shape = 20, size = 3, color = "black") +
  stat_summary(fun.data = "mean_cl_boot", geom = "errorbar", width = 0.2, color = "black") +
  theme_minimal() +
  labs(x = "Condition", y = "Q3")



ggplot(data, aes(Condition, Q1, fill = Condition)) +
  geom_violinhalf(flip = TRUE, aes(fill = Condition), trim = FALSE) +
  stat_summary(aes(label = round(..y.., 2)), fun.y = "mean", geom = "text", vjust = -0.5, size = 3) +
  stat_summary(fun = "mean", geom = "point", shape = 20, size = 3, color = "black") +
  stat_summary(fun.data = "mean_cl_boot", geom = "errorbar", width = 0.2, color = "black") +
  geom_violinhalf(data = data, aes(Condition, Abs_Av, fill = Condition), flip = FALSE, trim = FALSE, width = 0.6) +
  stat_summary(aes(label = round(..y.., 2)), fun.y = "mean", geom = "text", vjust = -0.5, size = 3) +
  stat_summary(data = data, fun = "mean", geom = "point", shape = 20, size = 3, color = "black") +
  stat_summary(data = data, fun.data = "mean_cl_boot", geom = "errorbar", width = 0.2, color = "black") +
  theme_minimal() +
  labs(x = "Condition", y = "Values") 




## Do a pair-wise t-test and bonferroni correction. If no p-values are found then i guess no correction is to be made. 


### T-test

install.packages("rstatix")

library(rstatix)

# Perform pair-wise t-tests across conditions
pairwise.t.test(data$Q3b, data$Artist, p.adjust.method = "bonferroni")

pairwise.t.test(data$Abs_Av, data$Condition, p.adjust.method = "bonferroni")
pairwise.t.test(data$Perf_Av, data$Condition, p.adjust.method = "bonferroni")
pairwise.t.test(data$Q6, data$Condition, p.adjust.method = "bonferroni")
pairwise.t.test(data$Q4a, data$Condition, p.adjust.method = "bonferroni")
pairwise.t.test(data$Q1b, data$Condition, p.adjust.method = "bonferroni")
pairwise.t.test(data$Q3b, data$Condition, p.adjust.method = "bonferroni")
# Assuming df is your data frame








cor_results <- list()
unique_conditions <- unique(df$Condition)

for (cond in unique_conditions) {
  data_subset <- subset(df, Condition == cond)
  cor_res <- cor.test(data_subset$Q6a, data_subset$Q3a, method = "pearson")
  cor_results[[cond]] <- cor_res
}

# Correcting p-values for multiple comparisons
p_values <- sapply(cor_results, function(x) x$p.value)
p_values_corrected <- p.adjust(p_values, method = "bonferroni")

# Results
cor_results
p_values_corrected



# Assuming df is your data frame
highest_value <- max(data$Q3b, na.rm = TRUE)
lowest_value <- min(data$Q3b, na.rm = TRUE)

# Printing the results
cat("Highest Value in Q3a:", highest_value, "\n")
cat("Lowest Value in Q3a:", lowest_value, "\n")



residuals <- resid(m11)

# Extract the fitted values
fitted_values <- fitted(m11)

# Plotting the residuals with the line plot of the fitted model
plot(fitted_values, residuals, main = "Residuals vs Fitted", xlab = "Fitted values", ylab = "Residuals")
abline(lm(residuals ~ fitted_values), col = "red")  # Add the linear regression line

plot(residuals, main = "Residuals Plot with Fitted Values", ylab = "Residuals")







# Assuming your data is in a dataframe named 'data' with columns Q1, Q2, ..., Q6
# Select the columns containing the questionnaire items

