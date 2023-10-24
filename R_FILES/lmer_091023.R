library(ggplot2)
library(sjPlot)
library(sjlabelled)
library(sjmisc)
library(dplyr)
library(tidyr)

library(lme4)
library(lmerTest)

data <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/22_Sep_2023_niels/05102023_ELAN_no_CDRS_onset_niels_1s_complete.csv')


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
m03  = lmer(Q3 ~   Artist + (1 | Participant), data = data )
m04  = lmer(Q3 ~   Palo + (1 | Participant), data = data )
m05  = lmer(Q3 ~   Condition + (1 | Participant), data = data )
m06  = lmer(Q3 ~   Dance_mode + (1 | Participant), data = data )
m07  = lmer(Q3 ~   Music_mode + (1 | Participant), data = data )
m08  = lmer(Q3 ~   Music_mode * Dance_mode + (1 | Participant), data = data )

tab_model(m00, m01, m02, m03, m04, m05, m06, m07, m08,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", 'm06', 'm07', 'm08'), digits = 5 )


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

m00  = lmer(Q1 ~   Palo * Artist + (1 | Participant), data = data )
m01  = lmer(Q1 ~   Dance_mode * Palo + (1 | Participant), data = data )
m02 =  lmer(Q1 ~   Palo* Condition + (1 | Participant), data = data )
m03 =  lmer(Q1 ~   Artist* Condition + (1 | Participant), data = data )

tab_model(m00, m01, m02, m03,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03"), digits = 5 )







m01  = lmer(Q3b ~   1 + (1 | Participant) + (1 | Pair)  , data = data )
m02  = lmer(Q3b ~   1 + (1 | Participant) , data = data )
m03  = lmer(Q3b ~   1 + (1 | Pair) , data = data )
m04  = lmer(Q3b ~   1 + (1 | Pair:Participant) , data = data )
m05  = lmer(Q3b ~   1 + (1 | Pair/Participant) , data = data )
m06 =  lmer(Q3b ~   1 + (1 | Artist) , data = data )

tab_model(m01, m02, m03, m04, m05,m06, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06"), digits = 5 )

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
m01  = lmer(Q3b ~  Palo +  (1 | Participant), data = data )
m02  = lmer(Q3b ~  Artist +  (1 | Participant), data = data )
m03  = lmer(Q3b ~   Q4 + (1 | Participant), data = data )
m04  = lmer(Q1 ~   Q5 + (1 | Participant), data = data )
m05  = lmer(Q1 ~   Q6 + (1 | Participant), data = data )
m06 =  lmer(Q1 ~   Palo + (1 | Participant), data = data )
m07 =  lmer(Q1 ~   Artist + (1 | Participant), data = data )

tab_model(m00, m01, m02, m03, m04, m05,m06, m07,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", "m06", "m07"), digits = 5 )



# COMPLEXITY 
dataP <- data[grepl("P", data$Participant),] #only dancers
dataG <- data[grepl("G", data$Participant),] #only dancers

# Normalize the data accross participants. 

# Group your data by participant (assuming you have a participant identifier, e.g., "Participant_ID")
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
m09  = lmer(Q6 ~  Condition* Palo + Artist +   (1 | Participant), data = data )

tab_model(m00, m01, m02, m03, m04, m05,m06, m07,m08, m09,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", "m06", "m07", "m08", "m09"), digits = 5 )







m00  = lmer(Q6a ~  p_LZ * Palo + (1 | Participant), data = dataP )
m01  = lmer(Q6a ~  n_p_LZ * Palo +  (1 | Participant), data = dataP )
m02  = lmer(Q6a ~  p_LZ + (1 | Participant), data = dataP )
m03  = lmer(Q6a ~  n_p_ncounts +  (1 | Participant), data = dataP )
m04  = lmer(Q6a ~  n_p_ncounts* Palo + (1 | Participant), data = dataP )
m05  = lmer(Q6a~  n_p_IOI  +  (1 | Participant), data = dataP )
m06  = lmer(Q6a ~  p_IOI  + (1 | Participant), data = dataP )
m07  = lmer(Q6b ~  n_p_IOI * Palo +  (1 | Participant), data = dataP )
m08  = lmer(Q6 ~  Condition* Palo +  (1 | Participant), data = data )
m09  = lmer(Q6a ~  Condition* Palo + Artist +   (1 | Participant), data = data )

tab_model(m00, m01, m02, m03, m04, m05,m06, m07,m08, m09,   p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m00", "m01", "m02","m03","m04", "m05", "m06", "m07", "m08", "m09"), digits = 5 )


