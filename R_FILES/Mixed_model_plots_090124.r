###
data <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/22_Sep_2023_niels/27102023_ELAN_no_CDRS_onset_niels_4s_final.csv')



##### ATILLA CODE ADJUSTED######

data_ole <- data %>%
  distinct(Name, Artist, .keep_all = TRUE)
data_ole$GMSI <- ifelse(data_ole$Participant == "G7", 5, data_ole$GMSI)
data_ole$GDSI <- ifelse(data_ole$Participant == "G7", 3.65, data_ole$GDSI)
data_ole$Fam <- ifelse(data_ole$Participant %in% c("G4", "P8"), 1, data_ole$Fam)
data_filtered_Q4a <- data_ole[!is.na(data_ole$GDSI) & !is.na(data_ole$Q4a), ]
data_filtered_Q6a <- data_ole[!is.na(data_ole$GMSI) & !is.na(data_ole$Q6a), ]
data_filtered_Q6a <- data_ole[!is.na(data_ole$Q6a), ]


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


#### Subsets data for models
data_filtered_Q4a <- data_ole[!is.na(data_ole$GDSI) & !is.na(data_ole$Q4a), ]
data_filtered_Q6a <- data_ole[!is.na(data_ole$GMSI) & !is.na(data_ole$Q6a), ]
data_filtered_Q6a <- data_ole[!is.na(data_ole$Q6a), ]


#### Rasndom EFFECTS
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




# Create a scatter plot with a fitted line for all three models
ggplot() +
   geom_jitter(data = data_ole, aes(x = participant_num, y = Perf_Av, color = "Fixed Effects"), width = 0.2, height = 0.2) +
  geom_smooth(data = data_ole, aes(x = participant_num, y = Perf_Av, color = "Fixed Effects"), method = "lm", se = FALSE, linetype = "dashed") +
  scale_color_manual(values = c("green", "red", "blue", "black")) +
  xlab("Group") +
  ylab("Intercept") +
  ggtitle("Random Intercepts and Fixed Effects")

ggplot() +
  geom_jitter(data = data_ole, aes(x = participant_num, y = participant_intercept, color = "Participant"), width = 0.2, height = 0.2) +
  geom_smooth(data = data_ole, aes(x = participant_num, y = participant_intercept), method = "lm", color = "blue") 
  geom_smooth(data = data_ole, aes(x = participant_num, y = Perf_Av, color = "Fixed Effects"), method = "lm", se = FALSE, linetype = "dashed") +
  scale_color_manual(values = c("green", "red", "blue", "black")) +
  xlab("Group") +
  ylab("Intercept") +
  ggtitle("Random Intercepts and Fixed Effects")

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


plot.new()


m00a = lmer(Q3 ~  1 +  (1 | Pair/Participant), data = data_filtered_Q4a)
m01a = lmer(Q3 ~  Q4a + Q1b + GDSI +  (1 | Pair/Participant), data = data_filtered_Q4a)


sjPlot::plot_model(title = 'LMER - Quality of Improvisation [Q1b] - Conditions',
                   m01a, show.p = TRUE, show.values = TRUE, digits = 3,show.intercept = TRUE)




library(ggplot2)

# Extract the fixed effects coefficients from the model
coefficients <- fixef(m01a)


sjPlot::tab_model(m01a, 
                  show.re.var= TRUE, 
                  pred.labels =c("(Intercept)", "Connection", "Quality Improvisation", "GDSI"),
                  dv.labels= "Model 1 - Main Predictors of Flow")

# Create a data frame with the fixed effects coefficients
data_fixed <- data.frame(x = names(coefficients), y = coefficients)


# Get the observed values from the data
observed <- data_filtered_Q4a$Q3

# Get the predicted values from the model
predicted <- fitted(m01a)

# Create a data frame with the observed and predicted values
data_points <- data.frame(observed = observed, predicted = predicted)

# Create a scatter plot of the data points with the fitted model
ggplot(data = data_points, aes(x = observed, y = predicted)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  xlab("Observed") +
  ylab("Predicted") +
  ggtitle("Scatter Plot of Data Points and Fitted Model")



#### Visualize model

effects_m01a <- effects::effect(term= "Q4a", mod= m01a)
summary(effects_m01a) #output of what the values are

x_Q4a <- as.data.frame(effects_m01a)


ggplot() + 
  #2
  geom_point(data=data_ole, aes(Q4a, Q3)) + 
  #3
  geom_point(data=x_Q4a, aes(x=Q4a, y=fit), color="blue") +
  #4
  geom_line(data=x_Q4a, aes(x=Q4a, y=fit), color="blue") +
  #5
  geom_ribbon(data= x_Q4a, aes(x=Q4a, ymin=lower, ymax=upper), alpha= 0.3, fill="blue") +
  #6
  labs(x="Urchins (centered & scaled)", y="Coral Cover")


#Refit code

m01a = lmer(Q3 ~  Q4a + Q1b + GDSI +  (1 | Pair/Participant), data = data_filtered_Q4a)
model_participant <-  lmer(Q3 ~  Q4a + Q1b + GDSI +  (1 | Participant), data = data_filtered_Q4a)
model_pair <-  lmer(Q3 ~  Q4a + Q1b + GDSI +  (1 | Pair), data = data_filtered_Q4a)
model_nested <-  lmer(Q3 ~  Q4a + Q1b + GDSI +  (1 | Pair/Participant), data = data_filtered_Q4a)

# Extract random intercepts for each group
participant_intercept <- ranef(model_participant)$Participant[, 1]
pair_intercept <- ranef(model_pair)$Pair[, 1]
nested_intercept <- ranef(model_nested)$`Participant:Pair`[, 1]


# Extract Coefficients for each group
participant_intercept <- coef(model_participant)$Participant[, 1]
pair_intercept <- coef(model_pair)$Pair[, 1]
nested_intercept <- coef(model_nested)$`Participant:Pair`[, 1]


# Get the random intercepts for the Participant:Pair level
random_intercepts <- ranef(model_nested)$`Participant:Pair`
# Get the level names for the random intercepts
level_names <- rownames(random_intercepts)
data_filtered_Q4a <- data_filtered_Q4a %>%
  mutate(Nested = paste(Participant, Pair, sep = ":"))


## ONLY RUN ONCE
# Extract the pair and participant numbers from the level names
level_names_split <- strsplit(level_names, split = ":|_")
pairs <- sapply(level_names_split, function(x) paste(x[2], x[3], sep = "_"))
participants <- sapply(level_names_split, function(x) x[1])
mapping_df <- data.frame(Pair = pairs, Participant = participants, Nested_Name = level_names)
#data_filtered_Q4a <- merge(data_filtered_Q4a, mapping_df, by = c("participant_num", "Pair"))


# Convert the level_names to a data frame
library(tidyr)

# Only run ONCE
# Create a data frame to map each pair+participant to its nested name
#mapping_df <- data.frame(Pair = pairs, Participant = participants, Nested_Name = level_names)

# Merge the mappings into the original data frame
#data_filtered_Q4a <- merge(data_filtered_Q4a, mapping_df, by = c("Participant", "Pair"))

# Create new numerical variables for "participant" and "pair"
data_filtered_Q4a$participant_num <- as.numeric(factor(data_filtered_Q4a$Participant))
data_filtered_Q4a$pair_num <- as.numeric(factor(data_filtered_Q4a$Pair))
data_filtered_Q4a$nested_num <- as.numeric(factor(data_filtered_Q4a$Nested))

# Add random intercepts to the new variables
data_filtered_Q4a$participant_intercept <- participant_intercept[data_filtered_Q4a$participant_num]
data_filtered_Q4a$pair_intercept <- pair_intercept[data_filtered_Q4a$pair_num]
data_filtered_Q4a$nested_intercept <- nested_intercept[data_filtered_Q4a$nested_num]

# Check for collinearity between random intercepts
cor(data_filtered_Q4a$participant_intercept, data_filtered_Q4a$pair_intercept)
cor(data_filtered_Q4a$participant_intercept, data_filtered_Q4a$nested_intercept)
cor(data_filtered_Q4a$pair_intercept, data_filtered_Q4a$nested_intercept)


# Create a scatter plot with a fitted line for all three models
ggplot() +
  geom_jitter(data = data_filtered_Q4a, aes(x = participant_num, y = participant_intercept, color = "Participant"), width = 0.2, height = 0.2) +
  geom_smooth(data = data_filtered_Q4a, aes(x = participant_num, y = participant_intercept), method = "lm", color = "blue") +
  geom_jitter(data = data_filtered_Q4a, aes(x = participant_num, y = pair_intercept, color = "Pair"), width = 0.2, height = 0.2) +
  geom_smooth(data = data_filtered_Q4a, aes(x = participant_num, y = pair_intercept), method = "lm", color = "red") +
  geom_jitter(data = data_filtered_Q4a, aes(x = participant_num, y = nested_intercept, color = "Nested"), width = 0.2, height = 0.2) +
  geom_smooth(data = data_filtered_Q4a, aes(x = participant_num, y = nested_intercept), method = "lm", color = "green") +
  scale_color_manual(values = c("green","red", "blue")) +
  xlab("Group") +
  ylab("Random Intercept") +
  ggtitle("Random Intercepts for Participant, Pair, and Nested Models")




# Create a scatter plot with a fitted line for all three models
ggplot() +
  geom_jitter(data = data_filtered_Q4a, aes(x = participant_num, y = Q3, color = "Fixed Effects"), width = 0.2, height = 0.2) +
  geom_smooth(data = data_filtered_Q4a, aes(x = participant_num, y = Q3, color = "Fixed Effects"), method = "lm", se = FALSE, linetype = "dashed") +
  scale_color_manual(values = c("green", "red", "blue", "black")) +
  xlab("Group") +
  ylab("Intercept") +
  ggtitle("Random Intercepts and Fixed Effects")

ggplot() +
  geom_jitter(data = data_filtered_Q4a, aes(x = participant_num, y = participant_intercept, color = "Participant"), width = 0.2, height = 0.2) +
  geom_smooth(data = data_filtered_Q4a, aes(x = participant_num, y = participant_intercept), method = "lm", color = "blue") 
geom_smooth(data = data_filtered_Q4a, aes(x = participant_num, y = Perf_Av, color = "Fixed Effects"), method = "lm", se = FALSE, linetype = "dashed") +
  scale_color_manual(values = c("green", "red", "blue", "black")) +
  xlab("Group") +
  ylab("Intercept") +
  ggtitle("Random Intercepts and Fixed Effects")


