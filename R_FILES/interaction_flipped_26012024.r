library(tidyr)
# Preparing data
name_palo <- data_ole %>% select(Participant, Palo) %>% distinct()
data_ole <- data_ole %>%
  mutate(INDvsGR = case_when(
    Condition %in% c("D1_M1", "D5_M5") ~ "Group",
    Condition %in% c("D5_M6", "D1_M6") ~ "Indiv",
    TRUE ~ NA_character_
  ))

data_ole <- data_ole %>%
  mutate(FIXvsOther = ifelse(Condition == "D6_M6", "Fixed", "Other"))


data_ole <- data_ole %>%
  mutate(MIXvsIMP = case_when(
    Condition %in% c("D1_M1", "D1_M6") ~ "Impro",
    Condition %in% c("D5_M6", "D5_M5") ~ "Mixed",
    TRUE ~ NA_character_
  ))


data_ole <- data_ole %>%
  mutate(FIXvsIMP = case_when(
    Condition %in% c("D6_M6") ~ "Fixed",
    Condition %in% c("D1_M1", "D1_M6") ~ "Impro",
    TRUE ~ NA_character_
  ))

data_ole <- data_ole %>%
  mutate(FIXvsMIX = case_when(
    Condition %in% c("D6_M6") ~ "Fixed",
    Condition %in% c("D5_M5", "D5_M6") ~ "Mixed",
    TRUE ~ NA_character_
  ))



# Add a new column based on a condition
data_ole <- data_ole %>%
  mutate(FIXvsOther = ifelse(Condition == "D6_M6", "Fixed", "Other"))

#### Filter data
### RUn datafiltering from analysis1_plot.r first
data_fixed <- data_test[grepl("Fixed", data_test$B),] #only dancers
data_mixed <- data_test[grepl("Mixed", data_test$B),]
data_impro <- data_test[grepl("Free", data_test$B),]
data_impro_mixed <- data_ole[data_ole$FIXvsOther != "Fixed", ]


####### Let try for PKs version
#### Quality of improvisation

subj_rating = "Q3"
#### DxCxA #####
data_ole<- data_ole %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, MIXvsIMP) %>%
  mutate(mean_Q1b = mean(Q4a, na.rm = TRUE))

filtered_data <- data_ole %>%
  distinct(Participant, Palo, mean_Q1b, Pair, Artist, MIXvsIMP) %>%
  filter(!is.na(INDvsGR))  # Remove rows with missing FIXvsOther values

grouped_data <- filtered_data %>%
  pivot_wider(names_from = INDvsGR, values_from = mean_Q1b)

print(grouped_data)

grouped_data <- grouped_data %>% arrange(Pair, Palo, Artist)


### Subgroup level 1
grouped_impro <- grouped_data[grepl("Impro", grouped_data$MIXvsIMP),]
print(grouped_impro)

grouped_mixed <- grouped_data[grepl("Mixed", grouped_data$MIXvsIMP),]
print(grouped_mixed)



# Subgroup level 2
grouped_mixed_P <- grouped_mixed[grepl("P", grouped_mixed$Artist),] #only dancers
grouped_mixed_G <- grouped_mixed[grepl("G", grouped_mixed$Artist),]
print(grouped_mixed_P)

grouped_impro_P <- grouped_impro[grepl("P", grouped_impro$Artist),] #only dancers
grouped_impro_G <- grouped_impro[grepl("G", grouped_impro$Artist),]
print(grouped_impro_P)


# Subset weight data before treatment
Group_impro_P <- grouped_impro_P$Group
Group_impro_G <- grouped_impro_G$Group

Group_mixed_P <- grouped_mixed_P$Group
Group_mixed_G <- grouped_mixed_G$Group
# subset weight data after treatment
Indiv_impro_P <- grouped_impro_P$Indiv
Indiv_impro_G <- grouped_impro_G$Indiv

Indiv_mixed_P <- grouped_mixed_P$Indiv
Indiv_mixed_G <- grouped_mixed_G$Indiv
# Plot paired data


library(PairedData)

pd_impro_Group <- paired(Group_impro_P, Group_impro_G)
p1 <- plot(pd_impro_Group, type = "profile") + theme_bw()

pd_impro_Indiv <- paired(Indiv_impro_P, Indiv_impro_G)
p2 <- plot(pd_impro_Indiv, type = "profile") + theme_bw()

pd_mixed_Group <- paired(Group_mixed_P, Group_mixed_G)
p3 <- plot(pd_mixed_Group, type = "profile") + theme_bw()

pd_mixed_Indiv <- paired(Indiv_mixed_P, Indiv_mixed_G)
p4 <- plot(pd_mixed_Indiv, type = "profile") + theme_bw()

pd_mixed_G <- paired(Indiv_mixed_G, Group_mixed_G)
p5 <- plot(pd_mixed_G, type = "profile") + theme_bw()
pd_impro_G <- paired(Indiv_impro_G, Group_impro_G)
p6 <- plot(pd_impro_G, type = "profile") + theme_bw()

t.test(Group_impro_P, Group_impro_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(Indiv_impro_P, Indiv_impro_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')

t.test(Group_mixed_P, Group_mixed_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(Indiv_mixed_P, Indiv_mixed_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')

t.test(Group_impro_G, Indiv_impro_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')#YES
t.test(Group_impro_P, Indiv_impro_P, paired = TRUE, correct = TRUE, alternative = 'two.sided')

t.test(Group_mixed_G, Indiv_mixed_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')#YES
t.test(Group_mixed_P, Indiv_mixed_P, paired = TRUE, correct = TRUE, alternative = 'two.sided')


shapiro.test(Indiv_P)
shapiro.test(Group_P)
shapiro.test(Indiv_G)
shapiro.test(Group_G)

wilcox.test(Indiv_P, Indiv_G, paired = TRUE)
wilcox.test(Group_P, Group_G, paired = TRUE)

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2,p3, p4,  ncol = 4
  
)

grid.arrange(
  # First column with plots p1, p2, and p3
  p5,p6,  ncol = 2
  
)

##### FIXED DxCxA ######
data_fixed <- data_fixed %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo) %>%
  mutate(mean_Q1b = mean(Q3, na.rm = TRUE))

filtered_data <- data_fixed %>%
  distinct(Participant, Palo, mean_Q1b, Pair, Artist) 

filtered_data 

grouped_data <- filtered_data %>%
  pivot_wider(names_from = INDvsGR, values_from = mean_Q1b)


grouped_data <- filtered_data %>% arrange(Pair, Palo, Artist)
print(grouped_data)

# Split in two groups
grouped_P <- grouped_data[grepl("P", grouped_data$Artist),] #only dancers
grouped_P <- grouped_P$mean_Q1b


grouped_G <- grouped_data[grepl("G", grouped_data$Artist),] 
grouped_G <- grouped_G$mean_Q1b
print(grouped_G)




pd_P <- paired(grouped_P, grouped_G)
plot(pd_P, type = "profile") + theme_bw()

t.test(grouped_P, grouped_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')





##### IMPRO AND MIXED ######

data_impro_mixed <- data_impro_mixed %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, INDvsGR) %>%
  mutate(mean_Q1b = mean(Q3, na.rm = TRUE))

filtered_data <- data_impro_mixed %>%
  distinct(Participant, Palo, INDvsGR, mean_Q1b, Pair, Artist) %>%
  filter(!is.na(INDvsGR))  # Remove rows with missing FIXvsOther values

filtered_data
grouped_data <- filtered_data %>%
  pivot_wider(names_from = INDvsGR, values_from = mean_Q1b)

print(grouped_data)

grouped_data <- grouped_data %>% arrange(Pair, Palo, Artist)

# Split in two groups
grouped_P <- grouped_data[grepl("P", grouped_data$Artist),] #only dancers
print(grouped_P)


grouped_G <- grouped_data[grepl("G", grouped_data$Artist),] #only dancers
print(grouped_G)


# Subset weight data before treatment
Group_P <- grouped_P$Group
Group_G <- grouped_G$Group
# subset weight data after treatment
Indiv_P <- grouped_P$Indiv
Indiv_G <- grouped_G$Indiv
# Plot paired data


# Calculate means and standard deviations
Mean_Group_P <- mean(na.omit(Group_P))
SD_Group_P <- sd(na.omit(Group_P))
Mean_Group_G <- mean(na.omit(Group_G))
SD_Group_G <- sd(na.omit(Group_G))
Mean_Indiv_P <- mean(na.omit(Indiv_P))
SD_Indiv_P <- sd(na.omit(Indiv_P))
Mean_Indiv_G <- mean(na.omit(Indiv_G))
SD_Indiv_G <- sd(na.omit(Indiv_G))

# Print means and standard deviations for Group_P and Group_G
cat("Mean_Group_P:", Mean_Group_P, "\n")
cat("SD_Group_P:", SD_Group_P, "\n")
cat("Mean_Group_G:", Mean_Group_G, "\n")
cat("SD_Group_G:", SD_Group_G, "\n")

# Print means and standard deviations for Indiv_P and Indiv_G
cat("Mean_Indiv_P:", Mean_Indiv_P, "\n")
cat("SD_Indiv_P:", SD_Indiv_P, "\n")
cat("Mean_Indiv_G:", Mean_Indiv_G, "\n")
cat("SD_Indiv_G:", SD_Indiv_G, "\n")


library(PairedData)
pd_P <- paired(Group_P, Group_G)
p1 <- plot(pd_P, type = "profile") + theme_bw()

pd_G <- paired(Indiv_P, Indiv_G)
p2 <- plot(pd_G, type = "profile") + theme_bw()

t.test(Group_P, Group_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(Indiv_P, Indiv_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')



t.test(Group_P, Indiv_P, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(Indiv_G, Group_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')


shapiro.test(Indiv_P)
shapiro.test(Group_P)
shapiro.test(Indiv_G)
shapiro.test(Group_G)

wilcox.test(Indiv_P, Indiv_G, paired = TRUE)
wilcox.test(Group_P, Group_G, paired = TRUE)

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2, ncol = 2
  
)

##### IMPRO DxB  ######
data_impro <- data_impro %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo) %>%
  mutate(mean_Q1b = mean(Abs_Av, na.rm = TRUE))

filtered_data <- data_impro %>%
  distinct(Participant, Palo, mean_Q1b, Pair, Artist) 

filtered_data 

grouped_data <- filtered_data %>%
  pivot_wider(names_from = INDvsGR, values_from = mean_Q1b)


grouped_data <- filtered_data %>% arrange(Pair, Palo, Artist)
print(grouped_data)

# Split in two groups
grouped_P_imp <- grouped_data[grepl("P", grouped_data$Artist),] #only dancers
grouped_P_imp <- grouped_P_imp$mean_Q1b


grouped_G_imp <- grouped_data[grepl("G", grouped_data$Artist),] 
grouped_G_imp <- grouped_G_imp$mean_Q1b
print(grouped_G_imp)




pd_P <- paired(grouped_P_imp, grouped_G_imp)
plot(pd_P, type = "profile") + theme_bw()

t.test(grouped_P_imp, grouped_G_imp, paired = TRUE, correct = TRUE, alternative = 'two.sided')

##### MIXED DxB  ######
data_mixed <- data_mixed %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, INDvsGR) %>%
  mutate(mean_Q1b = mean(Q1b, na.rm = TRUE))

filtered_data <- data_mixed %>%
  distinct(Participant, Palo, mean_Q1b, Pair, Artist) 

filtered_data 

grouped_data <- filtered_data %>%
  pivot_wider(names_from = INDvsGR, values_from = mean_Q1b)


grouped_data <- filtered_data %>% arrange(Pair, Palo, Artist)
print(grouped_data)

# Split in two groups
grouped_P_mixed <- grouped_data[grepl("P", grouped_data$Artist),] #only dancers
grouped_P_mixed <- grouped_P_mixed$mean_Q1b


grouped_G_mixed <- grouped_data[grepl("G", grouped_data$Artist),] 
grouped_G_mixed <- grouped_G_mixed$mean_Q1b
print(grouped_G_mixed)




pd_P <- paired(grouped_P_mixed, grouped_G_mixed)
plot(pd_P, type = "profile") + theme_bw()

t.test(grouped_P_mixed, grouped_G_mixed, paired = TRUE, correct = TRUE, alternative = 'two.sided')

t.test(grouped_P_mixed, grouped_P_imp, paired = TRUE, correct = TRUE, alternative = 'two.sided')

pd_P <- paired(grouped_P_mixed, grouped_P_imp)
plot(pd_P, type = "profile") + theme_bw()


t.test(grouped_G_mixed, grouped_G_imp, paired = TRUE, correct = TRUE, alternative = 'two.sided')

pd_P <- paired(grouped_G_mixed, grouped_G_imp)
plot(pd_P, type = "profile") + theme_bw()



t.test(grouped_P, grouped_P_imp, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(grouped_G, grouped_G_mixed, paired = TRUE, correct = TRUE, alternative = 'two.sided')
pd_P <- paired(grouped_G, grouped_G_mixed)
plot(pd_P, type = "profile") + theme_bw()


##### IMPRO######
data_impro <- data_impro %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, INDvsGR, Pair) %>%
  mutate(mean_Q1b = mean(Q1b, na.rm = TRUE))

filtered_data <- data_impro %>%
  distinct(Participant, Palo, INDvsGR, mean_Q1b, Pair, Artist) %>%
  filter(!is.na(INDvsGR))  # Remove rows with missing FIXvsOther values

grouped_data <- filtered_data %>%
  pivot_wider(names_from = INDvsGR, values_from = mean_Q1b)

print(grouped_data)

grouped_data <- grouped_data %>% arrange(Pair, Palo, Artist)

# Split in two groups
grouped_P <- grouped_data[grepl("P", grouped_data$Artist),] #only dancers
print(grouped_P)


grouped_G <- grouped_data[grepl("G", grouped_data$Artist),] #only dancers
print(grouped_G)


# Subset weight data before treatment
Group_P <- grouped_P$Group
Group_G <- grouped_G$Group
# subset weight data after treatment
Indiv_P <- grouped_P$Indiv
Indiv_G <- grouped_G$Indiv
# Plot paired data

# Calculate means and standard deviations
Mean_Group_P <- mean(na.omit(Group_P))
SD_Group_P <- sd(na.omit(Group_P))
Mean_Group_G <- mean(na.omit(Group_G))
SD_Group_G <- sd(na.omit(Group_G))
Mean_Indiv_P <- mean(na.omit(Indiv_P))
SD_Indiv_P <- sd(na.omit(Indiv_P))
Mean_Indiv_G <- mean(na.omit(Indiv_G))
SD_Indiv_G <- sd(na.omit(Indiv_G))

# Print means and standard deviations for Group_P and Group_G
cat("Mean_Group_P:", Mean_Group_P, "\n")
cat("SD_Group_P:", SD_Group_P, "\n")
cat("Mean_Group_G:", Mean_Group_G, "\n")
cat("SD_Group_G:", SD_Group_G, "\n")

# Print means and standard deviations for Indiv_P and Indiv_G
cat("Mean_Indiv_P:", Mean_Indiv_P, "\n")
cat("SD_Indiv_P:", SD_Indiv_P, "\n")
cat("Mean_Indiv_G:", Mean_Indiv_G, "\n")
cat("SD_Indiv_G:", SD_Indiv_G, "\n")



library(PairedData)
pd_P <- paired(Group_P, Group_G)
p1 <- plot(pd_P, type = "profile") + theme_bw()

pd_G <- paired(Indiv_P, Indiv_G)
p2 <- plot(pd_G, type = "profile") + theme_bw()

t.test(Group_P, Group_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(Indiv_P, Indiv_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')


t.test(Group_G, Indiv_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(Indiv_P, Group_P, paired = TRUE, correct = TRUE, alternative = 'two.sided')


shapiro.test(Indiv_P)
shapiro.test(Group_P)
shapiro.test(Indiv_G)
shapiro.test(Group_G)

wilcox.test(Indiv_P, Indiv_G, paired = TRUE)
wilcox.test(Group_P, Group_G, paired = TRUE)

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2, ncol = 2
  
)






##### FIXED######
data_fixed <- data_fixed %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, Pair) %>%
  mutate(mean_Q1b = mean(Q1b, na.rm = TRUE))

filtered_data <- data_fixed %>%
   distinct(Participant, Palo, mean_Q1b, Pair, Artist) 

filtered_data 

grouped_data <- filtered_data %>%
  pivot_wider(names_from = INDvsGR, values_from = mean_Q1b)


grouped_data <- filtered_data %>% arrange(Pair, Palo, Artist)
print(grouped_data)

# Split in two groups
grouped_P <- grouped_data[grepl("P", grouped_data$Artist),] #only dancers
print(grouped_P)


grouped_G <- grouped_data[grepl("G", grouped_data$Artist),] #only dancers
print(grouped_G)




# Subset weight data before treatment
Group_P <- grouped_P$Group
Group_G <- grouped_G$Group
# subset weight data after treatment
Indiv_P <- grouped_P$Indiv
Indiv_G <- grouped_G$Indiv
# Plot paired data

# Calculate medians and standard deviations
Median_Group_P <- median(na.omit(Group_P))
SD_Group_P <- sd(na.omit(Group_P))
Median_Group_G <- median(na.omit(Group_G))
SD_Group_G <- sd(na.omit(Group_G))
Median_Indiv_P <- median(na.omit(Indiv_P))
SD_Indiv_P <- sd(na.omit(Indiv_P))
Median_Indiv_G <- median(na.omit(Indiv_G))
SD_Indiv_G <- sd(na.omit(Indiv_G))

# Print medians and standard deviations for Group_P and Group_G
cat("Median_Group_P:", Median_Group_P, "\n")
cat("SD_Group_P:", SD_Group_P, "\n")
cat("Median_Group_G:", Median_Group_G, "\n")
cat("SD_Group_G:", SD_Group_G, "\n")

# Print medians and standard deviations for Indiv_P and Indiv_G
cat("Median_Indiv_P:", Median_Indiv_P, "\n")
cat("SD_Indiv_P:", SD_Indiv_P, "\n")
cat("Median_Indiv_G:", Median_Indiv_G, "\n")
cat("SD_Indiv_G:", SD_Indiv_G, "\n")

library(PairedData)
pd_P <- paired(Group_P, Group_G)
p1 <- plot(pd_P, type = "profile") + theme_bw()

pd_G <- paired(Indiv_P, Indiv_G)
p2 <- plot(pd_G, type = "profile") + theme_bw()

t.test(Group_P, Group_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(Indiv_P, Indiv_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')


shapiro.test(Indiv_P)
shapiro.test(Group_P)
shapiro.test(Indiv_G)
shapiro.test(Group_G)

wilcox.test(Indiv_P, Indiv_G, paired = TRUE)
wilcox.test(Group_P, Group_G, paired = TRUE)

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2, ncol = 2
  
)

##################
#
##### IMPRO ######

data_impro <- data_impro %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, INDvsGR, Pair) %>%
  mutate(mean_Q1b = mean(Q1b, na.rm = TRUE))

filtered_data <- data_impro %>%
  distinct(Participant, Palo, INDvsGR, mean_Q1b, Pair, Artist) %>%
  filter(!is.na(INDvsGR))  # Remove rows with missing FIXvsOther values

grouped_data <- filtered_data %>%
  pivot_wider(names_from = INDvsGR, values_from = mean_Q1b)

print(grouped_data)

grouped_data <- grouped_data %>% arrange(Pair, Palo, Artist)

# Split in two groups
grouped_P <- grouped_data[grepl("P", grouped_data$Artist),] #only dancers
print(grouped_P)


grouped_G <- grouped_data[grepl("G", grouped_data$Artist),] #only dancers
print(grouped_G)


# Subset weight data before treatment
Group_P <- grouped_P$Group
Group_G <- grouped_G$Group
# subset weight data after treatment
Indiv_P <- grouped_P$Indiv
Indiv_G <- grouped_G$Indiv
# Plot paired data


# Calculate means and standard deviations
Mean_Group_P <- mean(na.omit(Group_P))
SD_Group_P <- sd(na.omit(Group_P))
Mean_Group_G <- mean(na.omit(Group_G))
SD_Group_G <- sd(na.omit(Group_G))
Mean_Indiv_P <- mean(na.omit(Indiv_P))
SD_Indiv_P <- sd(na.omit(Indiv_P))
Mean_Indiv_G <- mean(na.omit(Indiv_G))
SD_Indiv_G <- sd(na.omit(Indiv_G))

# Print means and standard deviations for Group_P and Group_G
cat("Mean_Group_P:", Mean_Group_P, "\n")
cat("SD_Group_P:", SD_Group_P, "\n")
cat("Mean_Group_G:", Mean_Group_G, "\n")
cat("SD_Group_G:", SD_Group_G, "\n")

# Print means and standard deviations for Indiv_P and Indiv_G
cat("Mean_Indiv_P:", Mean_Indiv_P, "\n")
cat("SD_Indiv_P:", SD_Indiv_P, "\n")
cat("Mean_Indiv_G:", Mean_Indiv_G, "\n")
cat("SD_Indiv_G:", SD_Indiv_G, "\n")


library(PairedData)
pd_P <- paired(Group_P, Group_G)
p1 <- plot(pd_P, type = "profile") + theme_bw()

pd_G <- paired(Indiv_P, Indiv_G)
p2 <- plot(pd_G, type = "profile") + theme_bw()

t.test(Group_P, Group_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(Indiv_P, Indiv_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')


shapiro.test(Indiv_P)
shapiro.test(Group_P)
shapiro.test(Indiv_G)
shapiro.test(Group_G)

wilcox.test(Indiv_P, Indiv_G, paired = TRUE)
wilcox.test(Group_P, Group_G, paired = TRUE)

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2, ncol = 2
  
)





#### Quality of improvisation
##### ExF ######
data_ole <- data_ole %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, FIXvsMIX, Pair) %>%
  mutate(mean_Q1b = mean(Q1b, na.rm = TRUE))

filtered_data <- data_ole %>%
  distinct(Participant, Palo, FIXvsMIX, mean_Q1b, Pair, Artist) %>%
  filter(!is.na(FIXvsMIX))  # Remove rows with missing FIXvsOther values

grouped_data <- filtered_data %>%
  pivot_wider(names_from = FIXvsMIX, values_from = mean_Q1b)

print(grouped_data)

grouped_data <- grouped_data %>% arrange(Pair, Palo)

# Split in two groups
grouped_R1 <- grouped_data[grepl("R1", grouped_data$Palo),] #only dancers
print(grouped_R1)


grouped_R2 <- grouped_data[grepl("R2", grouped_data$Palo),] #only dancers
print(grouped_R2)


# Subset weight data before treatment
Fixed_R1 <- grouped_R1$Fixed
Fixed_R2 <- grouped_R2$Fixed
# subset weight data after treatment
Mixed_R1 <- grouped_R1$Mixed
Mixed_R2 <- grouped_R2$Mixed
# Plot paired data



# Calculate means and standard deviations
Mean_Fixed_R1 <- mean(na.omit(Fixed_R1))
SD_Fixed_R1 <- sd(na.omit(Fixed_R1))
Mean_Fixed_R2 <- mean(na.omit(Fixed_R2))
SD_Fixed_R2 <- sd(na.omit(Fixed_R2))
Mean_Mixed_R1 <- mean(na.omit(Mixed_R1))
SD_Mixed_R1 <- sd(na.omit(Mixed_R1))
Mean_Mixed_R2 <- mean(na.omit(Mixed_R2))
SD_Mixed_R2 <- sd(na.omit(Mixed_R2))

# Print means and standard deviations for Fixed_R1 and Fixed_R2
cat("Mean_Fixed_R1:", Mean_Fixed_R1, "\n")
cat("SD_Fixed_R1:", SD_Fixed_R1, "\n")
cat("Mean_Fixed_R2:", Mean_Fixed_R2, "\n")
cat("SD_Fixed_R2:", SD_Fixed_R2, "\n")

# Print means and standard deviations for Mixed_R1 and Mixed_R2
cat("Mean_Mixed_R1:", Mean_Mixed_R1, "\n")
cat("SD_Mixed_R1:", SD_Mixed_R1, "\n")
cat("Mean_Mixed_R2:", Mean_Mixed_R2, "\n")
cat("SD_Mixed_R2:", SD_Mixed_R2, "\n")


library(PairedData)
pd_R1 <- paired(Fixed_R1, Fixed_R2)
p1 <- plot(pd_R1, type = "profile") + theme_bw()

pd_R2 <- paired(Mixed_R1, Mixed_R2)
p2 <- plot(pd_R2, type = "profile") + theme_bw()

t.test(Fixed_R1, Fixed_R2, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(Mixed_R1, Mixed_R2, paired = TRUE, correct = TRUE, alternative = 'two.sided')


pd_R1 <- paired(Fixed_R1, Mixed_R1)
p1 <- plot(pd_R1, type = "profile") + theme_bw()

pd_R2 <- paired(Fixed_R2, Mixed_R2)
p2 <- plot(pd_R2, type = "profile") + theme_bw()

t.test(Fixed_R1, Mixed_R1, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(Fixed_R2, Mixed_R2, paired = TRUE, correct = TRUE, alternative = 'two.sided')




shapiro.test(Mixed_R1)
shapiro.test(Fixed_R1)
shapiro.test(Mixed_R2)
shapiro.test(Fixed_R2)

wilcox.test(Mixed_R1, Fixed_R1, paired = TRUE)
wilcox.test(Mixed_R2, Fixed_R2, paired = TRUE)

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2, ncol = 2
  
)



#### Communication with partner ExA
#### FIX vs IMP

data_ole <- data_ole %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, FIXvsIMP) %>%
  mutate(mean_Q4a = mean(Q4a, na.rm = TRUE))

filtered_data <- data_ole %>%
  distinct(Participant, Palo, FIXvsIMP, mean_Q4a, Pair) %>%
  filter(!is.na(FIXvsIMP))  # Remove rows with missing FIXvsIMP values

grouped_data <- filtered_data %>%
  pivot_wider(names_from = FIXvsIMP, values_from = mean_Q4a)

print(grouped_data)

grouped_data <- grouped_data %>% arrange(Pair, Palo)

# Split in two groups
grouped_R1 <- grouped_data[grepl("R1", grouped_data$Palo),] #only dancers
print(grouped_R1)


grouped_R2 <- grouped_data[grepl("R2", grouped_data$Palo),] #only dancers
print(grouped_R2)


# Subset weight data before treatment
Fixed_R1 <- grouped_R1$Fixed
Fixed_R2 <- grouped_R2$Fixed
# subset weight data after treatment
Impro_R1 <- grouped_R1$Impro
Impro_R2 <- grouped_R2$Impro
# Plot paired data



# Calculate means and standard deviations
Mean_Fixed_R1 <- mean(na.omit(Fixed_R1))
SD_Fixed_R1 <- sd(na.omit(Fixed_R1))
Mean_Fixed_R2 <- mean(na.omit(Fixed_R2))
SD_Fixed_R2 <- sd(na.omit(Fixed_R2))
Mean_Impro_R1 <- mean(na.omit(Impro_R1))
SD_Impro_R1 <- sd(na.omit(Impro_R1))
Mean_Impro_R2 <- mean(na.omit(Impro_R2))
SD_Impro_R2 <- sd(na.omit(Impro_R2))

# Print means and standard deviations for Fixed_R1 and Fixed_R2
cat("Mean_Fixed_R1:", Mean_Fixed_R1, "\n")
cat("SD_Fixed_R1:", SD_Fixed_R1, "\n")
cat("Mean_Fixed_R2:", Mean_Fixed_R2, "\n")
cat("SD_Fixed_R2:", SD_Fixed_R2, "\n")

# Print means and standard deviations for Impro_R1 and Impro_R2
cat("Mean_Impro_R1:", Mean_Impro_R1, "\n")
cat("SD_Impro_R1:", SD_Impro_R1, "\n")
cat("Mean_Impro_R2:", Mean_Impro_R2, "\n")
cat("SD_Impro_R2:", SD_Impro_R2, "\n")


library(PairedData)
pd_R1 <- paired(Fixed_R1, Fixed_R2)
p1 <- plot(pd_R1, type = "profile") + theme_bw()

pd_R2 <- paired(Impro_R1, Impro_R2)
p2 <- plot(pd_R2, type = "profile") + theme_bw()

t.test(Fixed_R1, Fixed_R2, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(Impro_R1, Impro_R2, paired = TRUE, correct = TRUE, alternative = 'two.sided')

t.test(Fixed_R1, Impro_R1, paired = TRUE, correct = TRUE, alternative = 'two.sided')
pd_R2 <- paired(Fixed_R1, Impro_R1)
plot(pd_R2, type = "profile") + theme_bw()

t.test(Fixed_R2, Impro_R2, paired = TRUE, correct = TRUE, alternative = 'two.sided')


shapiro.test(Impro_R1)
shapiro.test(Fixed_R1)
shapiro.test(Impro_R2)
shapiro.test(Fixed_R2)

wilcox.test(Impro_R1, Fixed_R1, paired = TRUE)
wilcox.test(Impro_R2, Fixed_R2, paired = TRUE)

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2, ncol = 2
  
)#### Communication with partner ExA
#### FIX vs MIX

data_ole <- data_ole %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, FIXvsMIX) %>%
  mutate(mean_Q4a = mean(Q4a, na.rm = TRUE))

filtered_data <- data_ole %>%
  distinct(Participant, Palo, FIXvsMIX, mean_Q4a, Pair) %>%
  filter(!is.na(FIXvsMIX))  # Remove rows with missing FIXvsMIX values

grouped_data <- filtered_data %>%
  pivot_wider(names_from = FIXvsMIX, values_from = mean_Q4a)

print(grouped_data)

grouped_data <- grouped_data %>% arrange(Pair, Palo)

# Split in two groups
grouped_R1 <- grouped_data[grepl("R1", grouped_data$Palo),] #only dancers
print(grouped_R1)


grouped_R2 <- grouped_data[grepl("R2", grouped_data$Palo),] #only dancers
print(grouped_R2)


# Subset weight data before treatment
Fixed_R1 <- grouped_R1$Fixed
Fixed_R2 <- grouped_R2$Fixed
# subset weight data after treatment
Mixed_R1 <- grouped_R1$Mixed
Mixed_R2 <- grouped_R2$Mixed
# Plot paired data



# Calculate means and standard deviations
Mean_Fixed_R1 <- mean(na.omit(Fixed_R1))
SD_Fixed_R1 <- sd(na.omit(Fixed_R1))
Mean_Fixed_R2 <- mean(na.omit(Fixed_R2))
SD_Fixed_R2 <- sd(na.omit(Fixed_R2))
Mean_Mixed_R1 <- mean(na.omit(Mixed_R1))
SD_Mixed_R1 <- sd(na.omit(Mixed_R1))
Mean_Mixed_R2 <- mean(na.omit(Mixed_R2))
SD_Mixed_R2 <- sd(na.omit(Mixed_R2))

# Print means and standard deviations for Fixed_R1 and Fixed_R2
cat("Mean_Fixed_R1:", Mean_Fixed_R1, "\n")
cat("SD_Fixed_R1:", SD_Fixed_R1, "\n")
cat("Mean_Fixed_R2:", Mean_Fixed_R2, "\n")
cat("SD_Fixed_R2:", SD_Fixed_R2, "\n")

# Print means and standard deviations for Mixed_R1 and Mixed_R2
cat("Mean_Mixed_R1:", Mean_Mixed_R1, "\n")
cat("SD_Mixed_R1:", SD_Mixed_R1, "\n")
cat("Mean_Mixed_R2:", Mean_Mixed_R2, "\n")
cat("SD_Mixed_R2:", SD_Mixed_R2, "\n")


library(PairedData)
pd_R1 <- paired(Fixed_R1, Fixed_R2)
p1 <- plot(pd_R1, type = "profile") + theme_bw()

pd_R2 <- paired(Mixed_R1, Mixed_R2)
p2 <- plot(pd_R2, type = "profile") + theme_bw()

t.test(Fixed_R1, Fixed_R2, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(Mixed_R1, Mixed_R2, paired = TRUE, correct = TRUE, alternative = 'two.sided')

t.test(Fixed_R1, Mixed_R1, paired = TRUE, correct = TRUE, alternative = 'two.sided')
pd_R2 <- paired(Fixed_R1, Mixed_R1)
plot(pd_R2, type = "profile") + theme_bw()

t.test(Fixed_R2, Mixed_R2, paired = TRUE, correct = TRUE, alternative = 'two.sided')


shapiro.test(Mixed_R1)
shapiro.test(Fixed_R1)
shapiro.test(Mixed_R2)
shapiro.test(Fixed_R2)

wilcox.test(Mixed_R1, Fixed_R1, paired = TRUE)
wilcox.test(Mixed_R2, Fixed_R2, paired = TRUE)

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2, ncol = 2
  
)






#####

data_ole <- data_ole %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, FIXvsOther) %>%
  mutate(mean_Q4a = mean(Q4a, na.rm = TRUE))

filtered_data <- data_ole %>%
  distinct(Participant, Palo, FIXvsOther, mean_Q4a, Pair) %>%
  filter(!is.na(FIXvsOther))  # Remove rows with missing FIXvsOther values

grouped_data <- filtered_data %>%
  pivot_wider(names_from = FIXvsOther, values_from = mean_Q4a)

print(grouped_data)

grouped_data <- grouped_data %>% arrange(Pair, Palo)

# Split in two groups
grouped_R1 <- grouped_data[grepl("R1", grouped_data$Palo),] #only dancers
print(grouped_R1)


grouped_R2 <- grouped_data[grepl("R2", grouped_data$Palo),] #only dancers
print(grouped_R2)


# Subset weight data before treatment
Fixed_R1 <- grouped_R1$Fixed
Fixed_R2 <- grouped_R2$Fixed
# subset weight data after treatment
Other_R1 <- grouped_R1$Other
Other_R2 <- grouped_R2$Other
# Plot paired data



# Calculate means and standard deviations
Mean_Fixed_R1 <- mean(na.omit(Fixed_R1))
SD_Fixed_R1 <- sd(na.omit(Fixed_R1))
Mean_Fixed_R2 <- mean(na.omit(Fixed_R2))
SD_Fixed_R2 <- sd(na.omit(Fixed_R2))
Mean_Other_R1 <- mean(na.omit(Other_R1))
SD_Other_R1 <- sd(na.omit(Other_R1))
Mean_Other_R2 <- mean(na.omit(Other_R2))
SD_Other_R2 <- sd(na.omit(Other_R2))

# Print means and standard deviations for Fixed_R1 and Fixed_R2
cat("Mean_Fixed_R1:", Mean_Fixed_R1, "\n")
cat("SD_Fixed_R1:", SD_Fixed_R1, "\n")
cat("Mean_Fixed_R2:", Mean_Fixed_R2, "\n")
cat("SD_Fixed_R2:", SD_Fixed_R2, "\n")

# Print means and standard deviations for Other_R1 and Other_R2
cat("Mean_Other_R1:", Mean_Other_R1, "\n")
cat("SD_Other_R1:", SD_Other_R1, "\n")
cat("Mean_Other_R2:", Mean_Other_R2, "\n")
cat("SD_Other_R2:", SD_Other_R2, "\n")


library(PairedData)
pd_R1 <- paired(Fixed_R1, Fixed_R2)
p1 <- plot(pd_R1, type = "profile") + theme_bw()

pd_R2 <- paired(Other_R1, Other_R2)
p2 <- plot(pd_R2, type = "profile") + theme_bw()

t.test(Fixed_R1, Fixed_R2, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(Other_R1, Other_R2, paired = TRUE, correct = TRUE, alternative = 'two.sided')

t.test(Fixed_R1, Other_R1, paired = TRUE, correct = TRUE, alternative = 'two.sided')
pd_R2 <- paired(Fixed_R1, Other_R1)
plot(pd_R2, type = "profile") + theme_bw()

t.test(Fixed_R2, Other_R2, paired = TRUE, correct = TRUE, alternative = 'two.sided')


shapiro.test(Other_R1)
shapiro.test(Fixed_R1)
shapiro.test(Other_R2)
shapiro.test(Fixed_R2)

wilcox.test(Other_R1, Fixed_R1, paired = TRUE)
wilcox.test(Other_R2, Fixed_R2, paired = TRUE)

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2, ncol = 2
  
)


library(tidyverse)
colors <- c("#8DD3C7", "#FFFFB3", "#BEBADA", "#FB8072", "#80B1D3", "#FDB462", "#B3DE69", "#FCCDE5", "#00008B", "#BC80BD")
labels_names <- c('Fixed', 'Other','Mixed', 'Free','Individual', 'Group', 'Musician', 'Dancer', 'Tangos', 'Solea')
color_lines <- c("#55A4A0","#D2BF8E", '#975991')
label_lines <- c("Fixed","Other", 'Solea')
common_theme <- theme(
  axis.text.y = element_text(size = 10),   # Adjust y-axis text size
  axis.text.x = element_text(size = 10),   # Adjust y-axis text size
  strip.text = element_text(size = 12),     # Adjust facet titles size
  panel.grid = element_blank(),
  plot.title = element_text(hjust = 0.5))  # Center the title
#plot.margin = margin(1, 1, 1, 1, "cm")


textsize_val <- 10
vjust_val <- 0.8


#First plot
data <- data.frame(
  Fixed_R1 ,
  Fixed_R2
)

data$row <- 1:nrow(data)
data <- pivot_longer(data, cols = -row, names_to = "Group", values_to = "Value")

head(data)
k3 <- ggplot(data, aes(x = Group, y = Value)) +
  geom_boxplot(width = 0.3, fill = c(colors[9],colors[10]), color = c(colors[9],color_lines[3]), size = 1.2, alpha = alpha_val) +
  geom_line(aes(group = row), alpha = 0.4, size = 1) +
  geom_jitter(width = 0.05, height = 0, alpha = 0.5) +  # Add jittered scatter points
  labs(x = "Fixed", y = "", title = "Connection with Partner") +
  theme_bw()+
  scale_x_discrete(labels = c("Tangos", "Solea")) +
  geom_signif(comparisons = list(c("Fixed_R1", "Fixed_R2")), 
              textsize = 10, 
              vjust = 0.6,
              map_signif_level = TRUE,
              show.legend = FALSE,
              annotations = c(".")
  ) +
  common_theme  + scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))


data <- data.frame(
  Other_R1 ,
  Other_R2
)

data$row <- 1:nrow(data)
data <- pivot_longer(data, cols = -row, names_to = "Group", values_to = "Value")

head(data)
p1<- ggplot(data, aes(x = Group, y = Value)) +
  geom_boxplot(width = 0.3, fill = c(colors[9],colors[10]), color = c(colors[9],color_lines[3]), size = 1.4, alpha = alpha_val) +
  geom_line(aes(group = row), alpha = 0.4, size = 1.1) +
  geom_jitter(width = 0.05, height = 0, alpha = 0.5) +  # Add jittered scatter points
  labs(x = "Other", y = "", title = "Connection with Partner") +
  theme_bw()+
  scale_x_discrete(labels = c("Tangos", "Solea")) +
  geom_signif(comparisons = list(c("Other_R1", "Other_R2")), 
              textsize = textsize_val, 
              vjust = vjust_val,
              map_signif_level = TRUE,
              show.legend = FALSE
  ) +
  common_theme +
  theme(panel.grid = element_blank())



library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p0, p1, ncol = 2
  
)



##### Quality of Impro the other way around DxC


data_ole <- data_ole %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, INDvsGR, Pair, Palo) %>%
  mutate(mean_Q1a = mean(Q1a, na.rm = TRUE))

filtered_data <- data_ole %>%
  distinct(Participant, Artist, INDvsGR, mean_Q1a, Pair, Palo) %>%
  filter(!is.na(INDvsGR))  # Remove rows with missing INDvsGR values

grouped_data <- filtered_data %>%
  pivot_wider(names_from = INDvsGR, values_from = mean_Q1a)

print(grouped_data)

grouped_data <- grouped_data %>% arrange(Pair, Palo, Artist)

# Split in two groups
grouped_P <- grouped_data[grepl("P", grouped_data$Artist),] #only dancers
print(grouped_P)


grouped_G <- grouped_data[grepl("G", grouped_data$Artist),] #only dancers
print(grouped_G)


# Subset weight data before treatment
Group_P <- grouped_P$Group
Group_G <- grouped_G$Group
# subset weight data after treatment
Indiv_P <- grouped_P$Indiv
Indiv_G <- grouped_G$Indiv
# Plot paired data



# Calculate means and standard deviations
Mean_Group_P <- mean(na.omit(Group_P))
SD_Group_P <- sd(na.omit(Group_P))
Mean_Group_G <- mean(na.omit(Group_G))
SD_Group_G <- sd(na.omit(Group_G))
Mean_Indiv_P <- mean(na.omit(Indiv_P))
SD_Indiv_P <- sd(na.omit(Indiv_P))
Mean_Indiv_G <- mean(na.omit(Indiv_G))
SD_Indiv_G <- sd(na.omit(Indiv_G))

# Print means and standard deviations for Group_P and Group_G
cat("Mean_Group_P:", Mean_Group_P, "\n")
cat("SD_Group_P:", SD_Group_P, "\n")
cat("Mean_Group_G:", Mean_Group_G, "\n")
cat("SD_Group_G:", SD_Group_G, "\n")

# Print means and standard deviations for Indiv_P and Indiv_G
cat("Mean_Indiv_P:", Mean_Indiv_P, "\n")
cat("SD_Indiv_P:", SD_Indiv_P, "\n")
cat("Mean_Indiv_G:", Mean_Indiv_G, "\n")
cat("SD_Indiv_G:", SD_Indiv_G, "\n")


library(PairedData)
pd_P <- paired(Group_P, Group_G)
p1 <- plot(pd_P, type = "profile") + theme_bw()

pd_G <- paired(Indiv_P, Indiv_G)
p2 <- plot(pd_G, type = "profile") + theme_bw()

t.test(Group_P, Group_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(Indiv_P, Indiv_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')


shapiro.test(Indiv_P)
shapiro.test(Group_P)
shapiro.test(Indiv_G)
shapiro.test(Group_G)

wilcox.test(Indiv_P, Group_P, paired = TRUE)
wilcox.test(Indiv_G, Group_G, paired = TRUE)

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2, ncol = 2
  
)



library(tidyverse)
colors <- c("#8DD3C7", "#FFFFB3", "#BEBADA", "#FB8072", "#80B1D3", "#FDB462", "#B3DE69", "#FCCDE5", "#00008B", "#BC80BD")
labels_names <- c('Group', 'Indiv','Mixed', 'Free','Individual', 'Group', 'Musician', 'Dancer', 'Tangos', 'Solea')
color_lines <- c("#55A4A0","#D2BF8E", '#975991', "#e67d08",'#74aa16' )
label_lines <- c("Group","Indiv", 'Solea','Musician', 'Dancer' )
common_theme <- theme(
  axis.text.y = element_text(size = 10),   # Adjust y-axis text size
  axis.text.x = element_text(size = 10),   # Adjust y-axis text size
  strip.text = element_text(size = 12),     # Adjust facet titles size
  panel.grid = element_blank(),
  plot.title = element_text(hjust = 0.5))  # Center the title
#plot.margin = margin(1, 1, 1, 1, "cm")


textsize_val <- 6
vjust_val <- 1.8


#First plot
data <- data.frame(
  Group_P ,
  Group_G
)

data$row <- 1:nrow(data)
data <- pivot_longer(data, cols = -row, names_to = "Group", values_to = "Value")

head(data)
 ggplot(data, aes(x = Group, y = Value)) +
  geom_boxplot(width = 0.3, fill = c(colors[6],colors[7]), color = c(colors[6],colors[7]), size = 1.4, alpha = alpha_val) +
  geom_line(aes(group = row), alpha = 0.4, size = 1.1) +
  geom_jitter(width = 0.05, height = 0, alpha = 0.5) +  # Add jittered scatter points
  labs(x = "Group", y = "", title = "Quality of Improvisation") +
  theme_bw()+
  scale_x_discrete(labels = c("Musician", "Dancer")) +
  geom_signif(comparisons = list(c("Group_P", "Group_G")), 
              textsize = textsize_val, 
              vjust = vjust_val,
              map_signif_level = TRUE,
              show.legend = FALSE,
              annotations = c("*")
  ) +
  common_theme  + scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))

data <- data.frame(
  Indiv_P ,
  Indiv_G
)

data$row <- 1:nrow(data)
data <- pivot_longer(data, cols = -row, names_to = "Group", values_to = "Value")

head(data)
#THIS ONE IS A KEEPER
k2 <- ggplot(data, aes(x = Group, y = Value)) +
  geom_boxplot(width = 0.3, fill = c(colors[6],colors[7]), color = c(color_lines[4],color_lines[5]), size = 1.4, alpha = alpha_val) +
  geom_line(aes(group = row), alpha = 0.4, size = 1) +
  geom_jitter(width = 0.05, height = 0, alpha = 0.5) +  # Add jittered scatter points
  labs(x = "Individual", y = "", title = "Qualitiy of Improvisation") +
  theme_bw()+
  scale_x_discrete(labels = c("Musician", "Dancer")) +
  geom_signif(comparisons = list(c("Indiv_P", "Indiv_G")), 
              textsize = textsize_val, 
              vjust = vjust_val,
              map_signif_level = TRUE,
              show.legend = FALSE
  ) +
  common_theme +
  theme(panel.grid = element_blank()) + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))



library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  k0, k2, k3, ncol = 3
  
)




##### Absorption by activity the other way around


data_ole <- data_ole %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, INDvsGR, Pair, Palo) %>%
  mutate(mean_Abs_Av = mean(Abs_Av, na.rm = TRUE))

filtered_data <- data_ole %>%
  distinct(Participant, Artist, MIXvsIMP, mean_Abs_Av, Pair, Palo) %>%
  filter(!is.na(MIXvsIMP))  # Remove rows with missing INDvsGR values

grouped_data <- filtered_data %>%
  pivot_wider(names_from = MIXvsIMP, values_from = mean_Abs_Av)

print(grouped_data)

grouped_data <- grouped_data %>% arrange(Pair, Palo, Artist)

# Split in two groups
grouped_P <- grouped_data[grepl("P", grouped_data$Artist),] #only dancers
print(grouped_P)


grouped_G <- grouped_data[grepl("G", grouped_data$Artist),] #only dancers
print(grouped_G)


# Subset weight data before treatment
Mixed_P <- grouped_P$Mixed
Mixed_G <- grouped_G$Mixed
# subset weight data after treatment
Impro_P <- grouped_P$Impro
Impro_G <- grouped_G$Impro
# Plot paired data



# Calculate means and standard deviations
Mean_Mixed_P <- mean(na.omit(Mixed_P))
SD_Mixed_P <- sd(na.omit(Mixed_P))
Mean_Mixed_G <- mean(na.omit(Mixed_G))
SD_Mixed_G <- sd(na.omit(Mixed_G))
Mean_Impro_P <- mean(na.omit(Impro_P))
SD_Impro_P <- sd(na.omit(Impro_P))
Mean_Impro_G <- mean(na.omit(Impro_G))
SD_Impro_G <- sd(na.omit(Impro_G))

# Print means and standard deviations for Mixed_P and Mixed_G
cat("Mean_Mixed_P:", Mean_Mixed_P, "\n")
cat("SD_Mixed_P:", SD_Mixed_P, "\n")
cat("Mean_Mixed_G:", Mean_Mixed_G, "\n")
cat("SD_Mixed_G:", SD_Mixed_G, "\n")

# Print means and standard deviations for Impro_P and Impro_G
cat("Mean_Impro_P:", Mean_Impro_P, "\n")
cat("SD_Impro_P:", SD_Impro_P, "\n")
cat("Mean_Impro_G:", Mean_Impro_G, "\n")
cat("SD_Impro_G:", SD_Impro_G, "\n")


library(PairedData)
pd_P <- paired(Mixed_P, Mixed_G)
p1 <- plot(pd_P, type = "profile") + theme_bw()

pd_G <- paired(Impro_P, Impro_G)
p2 <- plot(pd_G, type = "profile") + theme_bw()

t.test(Mixed_P, Mixed_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(Impro_P, Impro_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')


shapiro.test(Impro_P)
shapiro.test(Mixed_P)
shapiro.test(Impro_G)
shapiro.test(Mixed_G)

wilcox.test(Impro_P, Mixed_P, paired = TRUE)
wilcox.test(Impro_G, Mixed_G, paired = TRUE)

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2, ncol = 2
  
)



library(tidyverse)
colors <- c("#8DD3C7", "#FFFFB3", "#BEBADA", "#FB8072", "#80B1D3", "#FDB462", "#B3DE69", "#FCCDE5", "#00008B", "#BC80BD")
labels_names <- c('Mixed', 'Impro','Mixeded', 'Free','Improidual', 'Mixed', 'Musician', 'Dancer', 'Tangos', 'Solea')
color_lines <- c("#55A4A0","#D2BF8E", '#975991')
label_lines <- c("Mixed","Impro", 'Solea')
common_theme <- theme(
  axis.text.y = element_text(size = 10),   # Adjust y-axis text size
  axis.text.x = element_text(size = 10),   # Adjust y-axis text size
  strip.text = element_text(size = 12),     # Adjust facet titles size
  panel.grid = element_blank(),
  plot.title = element_text(hjust = 0.5))  # Center the title
#plot.margin = margin(1, 1, 1, 1, "cm")


textsize_val <- 6
vjust_val <- 1.8


#First plot
data <- data.frame(
  Mixed_P ,
  Mixed_G
)

data$row <- 1:nrow(data)
data <- pivot_longer(data, cols = -row, names_to = "Mixed", values_to = "Value")

head(data)
p0 <- ggplot(data, aes(x = Mixed, y = Value)) +
  geom_boxplot(width = 0.3, fill = c(colors[9],colors[10]), color = c(colors[9],color_lines[3]), size = 1.4, alpha = alpha_val) +
  geom_line(aes(Mixed = row), alpha = 0.4, size = 1.1) +
  geom_jitter(width = 0.05, height = 0, alpha = 0.5) +  # Add jittered scatter points
  labs(x = "Mixed", y = "Rating", title = "Connection with Partner") +
  theme_bw()+
  scale_x_discrete(labels = c("Tangos", "Solea")) +
  geom_signif(comparisons = list(c("Mixed_P", "Mixed_G")), 
              textsize = textsize_val, 
              vjust = vjust_val,
              map_signif_level = TRUE,
              show.legend = FALSE,
              annotations = c("*")
  ) +
  common_theme

data <- data.frame(
  Impro_P ,
  Impro_G
)

data$row <- 1:nrow(data)
data <- pivot_longer(data, cols = -row, names_to = "Mixed", values_to = "Value")

head(data)
#THIS ONE IS A KEEPER
k1 <- ggplot(data, aes(x = Mixed, y = Value)) +
  geom_boxplot(width = 0.3, fill = c(colors[9],colors[10]), color = c(colors[9],color_lines[3]), size = 1.4, alpha = alpha_val) +
  geom_line(aes(Mixed = row), alpha = 0.4, size = 1.1) +
  geom_jitter(width = 0.05, height = 0, alpha = 0.5) +  # Add jittered scatter points
  labs(x = "Improidual", y = "Rating", title = "Qualitiy of Improvisation") +
  theme_bw()+
  scale_x_discrete(labels = c("Musician", "Dancer")) +
  geom_signif(comparisons = list(c("Impro_P", "Impro_G")), 
              textsize = textsize_val, 
              vjust = vjust_val,
              map_signif_level = TRUE,
              show.legend = FALSE
  ) +
  common_theme +
  theme(panel.grid = element_blank())



library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p0, p1, ncol = 2
  
)

