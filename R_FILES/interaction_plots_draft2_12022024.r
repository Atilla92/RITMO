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
library(tidyr)
library(grid)
library(gridExtra)


ggplot(data_test, aes(x = Q1b, y = Q3)) +
  geom_smooth(method = "lm", se = TRUE) 


ggplot(data_test, aes(x = Q1b, y = Q3)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE) +
  facet_wrap(~B)



data <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/22_Sep_2023_niels/27102023_ELAN_no_CDRS_onset_niels_4s_final.csv')

##### ATILLA CODE ADJUSTED######

data_ole <- data %>%
  distinct(Name, Artist, .keep_all = TRUE)

data_ole$instruction <- paste(data_ole$Condition, data_ole$Artist, sep = "_")
data_ole$instruction_2 <- paste(data_ole$instruction, data_ole$Palo, sep = "_")
data_ole$instruction_2 <- as.factor(data_ole$instruction_2)
data_ole$instruction_2 <-factor(data_ole$instruction_2, levels = c("D5_M6_P_R1", "D5_M6_G_R1",  "D1_M6_P_R1", "D1_M6_G_R1","D6_M6_P_R1", "D6_M6_G_R1",  "D5_M5_P_R1", "D5_M5_G_R1","D1_M1_P_R1", "D1_M1_G_R1",
                                                                   "D5_M6_P_R2", "D5_M6_G_R2",  "D1_M6_P_R2", "D1_M6_G_R2","D6_M6_P_R2", "D6_M6_G_R2",  "D5_M5_P_R2", "D5_M5_G_R2","D1_M1_P_R2", "D1_M1_G_R2"
))

# MACRO Check
data_ole$Q1 <- (data_ole$Q1a + data_ole$Q1b) / 2
data_ole$Q3 <- (data_ole$Q3a + data_ole$Q3b) / 2
data_ole$Q6 <- (data_ole$Q6a + data_ole$Q6b) /2
data_ole$Q5 <-  (data_ole$Q5a + data_ole$Q5b) /2
data_ole$Q4 <- (data_ole$Q4a + data_ole$Q4b) /3



# Add contrast labels to dataset
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

data_ole <- data_ole %>%
  mutate(FIXvsMIXvsIMP = case_when(
    Condition %in% c("D6_M6") ~ "Fixed",
    Condition %in% c("D5_M5", "D5_M6") ~ "Mixed",
    Condition %in% c("D1_M1", "D1_M6") ~ "Impro",
    TRUE ~ NA_character_
  ))


# Add a new column based on a condition
data_ole <- data_ole %>%
  mutate(FIXvsOther = ifelse(Condition == "D6_M6", "Fixed", "Other"))

# Create a new data frame for contrasts
# Get the levels of the instruction_2 column
levels <- levels(data_ole$instruction_2)

# Create a new data frame for the levels and contrast values
data_contrasts <- data.frame(levels)


names_contrasts <- c("A_FIXvsOther", "B_MIXvsIMP", "C_INDvsGR", "D_DANvsMUS", "E_R1vsR2", "DxA", "DxB", "DxC")
contrasts <- list(
  A_FIXvsOther = c(1,1,1,1,-4,-4,1,1,1,1,1,1,1,1,-4,-4,1,1,1,1),
  B_MIXvsIMP = c(-1,-1,1,1,0,0,-1,-1,1,1,-1,-1,1,1,0,0,-1,-1,1,1),
  C_INDvsGR = c(-1,-1,-1,-1,0,0,1,1,1,1,-1,-1,-1,-1,0,0,1,1,1,1),
  D_DANvsMUS = c(1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1),
  E_R1vsR2 = c(1,1,1,1,1,1,1,1,1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1),
  DxA = c(1,-1,1,-1,-4,4,1,-1,1,-1,1,-1,1,-1,-4,4,1,-1,1,-1),
  DxB = c(-1,1,1,-1,0,0,-1,1,1,-1,-1,1,1,-1,0,0,-1,1,1,-1),
  DxC = c(-1,1,-1,1,0,0,1,-1,1,-1,-1,1,-1,1,0,0,1,-1,1,-1),
  ExA = c(1,1,1,1,-4,-4,1,1,1,1,-1,-1,-1,-1,4,4,-1,-1,-1,-1),
  ExB = c(-1,-1,1,1,0,0,-1,-1,1,1,1,1,-1,-1,0,0,1,1,-1,-1),
  ExC = c(-1,-1,-1,-1,0,0,1,1,1,1,1,1,1,1,0,0,-1,-1,-1,-1),
  ExD = c(1,-1,1,-1,1,-1,1,-1,1,-1,-1,1,-1,1,-1,1,-1,1,-1,1),
  DxAxE = c(1,-1,1,-1,-4,4,1,-1,1,-1,-1,1,-1,1,4,-4,-1,1,-1,1),
  DxBxE = c(-1,1,1,-1,0,0,-1,1,1,-1,1,-1,-1,1,0,0,1,-1,-1,1),
  DxCxE = c(-1,1,-1,1,0,0,1,-1,1,-1,1,-1,1,-1,0,0,-1,1,-1,1)
)




# Combine data with contrast coefficients
data_contrasts <- cbind(data_contrasts, contrasts$A_FIXvsOther)
data_contrasts <- cbind(data_contrasts, contrasts$B_MIXvsIMP)
data_contrasts <- cbind(data_contrasts, contrasts$C_INDvsGR)
data_contrasts <- cbind(data_contrasts, contrasts$D_DANvsMUS)
data_contrasts <- cbind(data_contrasts, contrasts$E_R1vsR2)
colnames(data_contrasts)[2] <- "A"
colnames(data_contrasts)[3] <- "B"
colnames(data_contrasts)[4] <- "C"
colnames(data_contrasts)[5] <- "D"
colnames(data_contrasts)[6] <- "E"
# Create list of data frames for each contrast

# Merge data_AB with data_ole to add the A and B columns
data_test <- merge(data_ole, data_contrasts, by.x = "instruction_2", by.y = "levels")

# Load the ggplot2 package
library(ggplot2)


data_test$A <- factor(data_test$A, labels = c("Fixed", "Other"))

data_test$B <- factor(data_test$B)
levels(data_test$B)
data_test$B <- factor(data_test$B, labels = c("Mixed", "Fixed", "Impro"))
data_test$B <- factor(data_test$B, levels = c("Fixed", "Mixed", "Impro"))
data_test$C <- factor(data_test$C)
data_test$C <- factor(data_test$C, labels = c("Individual",'Neutral', 'Group'))

data_test$D <- factor(data_test$D)
data_test$D <- factor(data_test$D, labels = c("Musician",'Dancer'))
data_test$D <- factor(data_test$D, levels = c("Dancer", "Musician"))

data_test$E <- factor(data_test$E)
data_test$E <- factor(data_test$E, labels = c("Solea",'Tangos'))




# Load the required library

library(gridExtra)
library(ggplot2)
library(ggsignif)
# Set the alpha transparency value for the violins to 0.5
colors <- c("#8DD3C7", "#FFFFB3", "#BEBADA", "#FB8072", "#80B1D3", "#FDB462", "#B3DE69", "#FCCDE5", "#00008B", "#BC80BD")
labels_names <- c('Fixed', 'Other','Mixed', 'Free','Individual', 'Group', 'Musician', 'Dancer', 'Tangos', 'Solea')
alpha_val <- 0.6


#### Filter data
### RUn datafiltering from analysis1_plot.r first
data_fixed <- data_test[grepl("Fixed", data_test$B),] #only dancers
data_mixed <- data_test[grepl("Mixed", data_test$B),]
data_impro <- data_test[grepl("Impro", data_test$B),]
data_impro_mixed <- data_ole[data_ole$FIXvsOther != "Fixed", ]


###### Quality of Improvisation #####

##### Paired t-tests #######
##### IMPRO######
data_impro <- data_impro %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, INDvsGR) %>%
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


### Medians

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

pd_G <- paired(Group_G, Indiv_G)
p1 <- plot(pd_G, type = "profile") + theme_bw()

pd_G <- paired(Indiv_P, Group_P)
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



##### MIXED ######
data_mixed <- data_mixed %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, INDvsGR) %>%
  mutate(mean_Q1b = mean(Q1b, na.rm = TRUE))

filtered_data <- data_mixed %>%
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
  group_by(Participant, Palo) %>%
  mutate(mean_Q1b = mean(Q1b, na.rm = TRUE))

filtered_data <- data_fixed %>%
  distinct(Participant, Palo, mean_Q1b, Pair, Artist) 

filtered_data 


grouped_data <- filtered_data %>% arrange(Pair, Palo, Artist)
print(grouped_data)

# Split in two groups
grouped_P <- grouped_data[grepl("P", grouped_data$Artist),] #only dancers
print(grouped_P)


grouped_G <- grouped_data[grepl("G", grouped_data$Artist),] #only dancers
print(grouped_G)

# Subset weight data before treatment
Group_P <- grouped_P$mean_Q1b
Group_G <- grouped_G$mean_Q1b
# subset weight data after treatment


# Calculate medians and standard deviations
Median_Group_P <- median(na.omit(Group_P))
SD_Group_P <- sd(na.omit(Group_P))
Median_Group_G <- median(na.omit(Group_G))
SD_Group_G <- sd(na.omit(Group_G))

# Print medians and standard deviations for Group_P and Group_G
cat("Median_Group_P:", Median_Group_P, "\n")
cat("SD_Group_P:", SD_Group_P, "\n")
cat("Median_Group_G:", Median_Group_G, "\n")
cat("SD_Group_G:", SD_Group_G, "\n")

library(PairedData)
pd_P <- paired(Group_P, Group_G)
p1 <- plot(pd_P, type = "profile") + theme_bw()


t.test(Group_P, Group_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')



shapiro.test(Group_P)
shapiro.test(Group_G)

wilcox.test(Indiv_P, Indiv_G, paired = TRUE)
wilcox.test(Group_P, Group_G, paired = TRUE)

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2, ncol = 2
  
)

##### Correction ####
#  p-values
p_values <- c(0.2114,	1.40E-06, 0.119,	2.05E-03)

# FDR correction using Benjamini-Hochberg method
fdr_corrected_p_values <- p.adjust(p_values, method = "fdr")

# Print the original p-values and the FDR-corrected p-values
data.frame(p_values = p_values, fdr_corrected_p_values = fdr_corrected_p_values)



###### Violinplots ##############


library(tidyverse)
colors <- c("#8DD3C7", "#FFFFB3", "#BEBADA", "#FB8072", "#80B1D3", "#FDB462", "#B3DE69", "#FCCDE5", "#00008B", "#BC80BD")
labels_names <- c('Mixed', 'Impro','Mixeded', 'Free','Improidual', 'Mixed', 'Musician', 'Dancer', 'Tangos', 'Solea')
color_lines <- c("#55A4A0","#D2BF8E", '#975991')
label_lines <- c("Mixed","Impro", 'Solea')
common_theme <- theme(
  axis.text.y = element_text(size = 10),   # Adjust y-axis text size
  axis.text.x = element_text(size = 10),   # Adjust y-axis text size
  strip.text = element_text(size = 12),     # Adjust facet titles size
  axis.title.x = element_text(size = 12),
  axis.title.y = element_text(size = 12),
  panel.grid = element_blank(),
  plot.title = element_text(hjust = 0.5),
  panel.background = element_rect(fill = "white", color = "grey70", size = 1)
  )  # Center the title
#plot.margin = margin(1, 1, 1, 1, "cm")

textsize_val <- 6
vjust_val <- 1.8


data_impro$title1 <- "Quality of Improvisation"
pQ1bI <- ggplot(data_impro, aes(x = C, y = Q1b, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = C), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  scale_fill_manual(values = c("Individual" = colors[9], "Group" = colors[10])) +
  labs(x = " (c) Improvised ", y = "", fill = "C") +
  facet_wrap(~ D, ncol = 2) +
  geom_signif(
              comparisons = list(c("Individual", "Group")), 
              textsize = textsize_val, 
              vjust = vjust_val,
              annotations = '',
              map_signif_level = TRUE,
              show.legend = FALSE) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))

ann_text <- data.frame(D = "Dancer",Q3 = 7.0,lab = "Text",
                       C = factor("Individual",levels = c("Individual", "Group")))
pQ1bI <- pQ1bI + geom_text(x = 1.5, y = 7.1, data = ann_text,label = "", size = 5)

ann_text <- data.frame(D = "Musician",Q3 = 7.0,lab = "Text",
                       C = factor("Group",levels = c("Individual", "Group")))
pQ1bI <- pQ1bI + geom_text(x = 1.5, y = 7.1, data = ann_text,label = "***", size = 6.5)

pQ1bI

pQ1bM <- ggplot(data_mixed, aes(x = C, y = Q1b, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = C), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  scale_fill_manual(values = c("Individual" = colors[9], "Group" = colors[10])) +
  labs(x = "(b) Mixed", y = "", fill = "C") +
  facet_wrap(~ D, ncol = 2) +
  geom_signif(
    comparisons = list(c("Individual", "Group")), 
    textsize = textsize_val, 
    vjust = vjust_val,
    map_signif_level = TRUE,
    annotations = '',
    show.legend = FALSE) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))



ann_text <- data.frame(D = "Dancer",Q3 = 7.0,lab = "Text",
                       C = factor("Individual",levels = c("Individual", "Group")))
pQ1bM <- pQ1bM + geom_text(x = 1.5, y = 7.1, data = ann_text,label = "", size = 5)

ann_text <- data.frame(D = "Musician",Q3 = 7.0,lab = "Text",
                       C = factor("Group",levels = c("Individual", "Group")))
pQ1bM <- pQ1bM + geom_text(x = 1.5, y = 7.1, data = ann_text,label = "**", size = 6.5)

pQ1bM


# data_fixed$title1 <- "Group"
# pQ1bF  <- ggplot(data_fixed, aes(x = D, y = Q1b, fill = D)) +
#   geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
#   geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
#   scale_fill_manual(values = c("Musician" = colors[10], "Dancer" = colors[10])) +
#   labs(x = "(a) Fixed", y = "Quality of improvisation", fill = "A")+
#   facet_grid(. ~ title1) +
#   # geom_signif(comparisons = list(c("Musician", "Dancer")), 
#   #             textsize = textsize_val, 
#   #             vjust = vjust_val,
#   #             map_signif_level = FALSE,
#   #             show.legend = FALSE,
#   #             annotations =  ''
#   # ) +
#   common_theme + 
#   scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))


pQ1bF  <-ggplot(data_fixed, aes(x = C, y = Q1b, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = C), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  scale_fill_manual(values = c("Neutral" = colors[10])) +
  labs(x = "(a) Fixed", y = "Quality of improvisation", fill = "C") +
  scale_x_discrete(labels = c("Neutral" = "Group")) +
  facet_wrap(~ D, ncol = 2) +
  geom_signif(
    comparisons = list(c("Dancer", "Musician")), 
    textsize = textsize_val, 
    vjust = vjust_val,
    map_signif_level = TRUE,
    annotations = '',
    show.legend = FALSE) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))



library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  pQ1bF, pQ1bM, pQ1bI, ncol = 3
  
)


###### Flow #####

##### Paired t-tests #######
##### IMPRO######
data_impro <- data_impro %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, INDvsGR) %>%
  mutate(mean_Q1b = mean(Q3, na.rm = TRUE))

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

Group_impro <- grouped_data$Group
Indiv_impro <- grouped_data$Indiv

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


# Calculate medians and standard deviations
median_Group_P <- median(na.omit(Group_P))
SD_Group_P <- sd(na.omit(Group_P))
median_Group_G <- median(na.omit(Group_G))
SD_Group_G <- sd(na.omit(Group_G))
median_Indiv_P <- median(na.omit(Indiv_P))
SD_Indiv_P <- sd(na.omit(Indiv_P))
median_Indiv_G <- median(na.omit(Indiv_G))
SD_Indiv_G <- sd(na.omit(Indiv_G))

# Print medians and standard deviations for Group_P and Group_G
cat("median_Group_P:", median_Group_P, "\n")
cat("SD_Group_P:", SD_Group_P, "\n")
cat("median_Group_G:", median_Group_G, "\n")
cat("SD_Group_G:", SD_Group_G, "\n")

# Print medians and standard deviations for Indiv_P and Indiv_G
cat("median_Indiv_P:", median_Indiv_P, "\n")
cat("SD_Indiv_P:", SD_Indiv_P, "\n")
cat("median_Indiv_G:", median_Indiv_G, "\n")
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


t.test(Group_impro, Indiv_impro, paired = TRUE, correct = TRUE, alternative = 'two.sided')


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



##### MIXED ######
data_mixed <- data_mixed %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, INDvsGR) %>%
  mutate(mean_Q1b = mean(Q3, na.rm = TRUE))

filtered_data <- data_mixed %>%
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


Group_impro <- grouped_data$Group
Indiv_impro <- grouped_data$Indiv
t.test(Group_impro, Indiv_impro, paired = TRUE, correct = TRUE, alternative = 'two.sided')




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
  group_by(Participant, Palo) %>%
  mutate(mean_Q1b = mean(Q3, na.rm = TRUE))

filtered_data <- data_fixed %>%
  distinct(Participant, Palo, mean_Q1b, Pair, Artist) 

filtered_data 


grouped_data <- filtered_data %>% arrange(Pair, Palo, Artist)
print(grouped_data)

# Split in two groups
grouped_P <- grouped_data[grepl("P", grouped_data$Artist),] #only dancers
print(grouped_P)


grouped_G <- grouped_data[grepl("G", grouped_data$Artist),] #only dancers
print(grouped_G)

# Subset weight data before treatment
Group_P <- grouped_P$mean_Q1b
Group_G <- grouped_G$mean_Q1b
# subset weight data after treatment

# Calculate medians and standard deviations
Median_Group_P <- median(na.omit(Group_P))
SD_Group_P <- sd(na.omit(Group_P))
Median_Group_G <- median(na.omit(Group_G))
SD_Group_G <- sd(na.omit(Group_G))

# Print medians and standard deviations for Group_P and Group_G
cat("Median_Group_P:", Median_Group_P, "\n")
cat("SD_Group_P:", SD_Group_P, "\n")
cat("Median_Group_G:", Median_Group_G, "\n")
cat("SD_Group_G:", SD_Group_G, "\n")

library(PairedData)
pd_P <- paired(Group_P, Group_G)
p1 <- plot(pd_P, type = "profile") + theme_bw()


t.test(Group_P, Group_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')



shapiro.test(Group_P)
shapiro.test(Group_G)

wilcox.test(Indiv_P, Indiv_G, paired = TRUE)
wilcox.test(Group_P, Group_G, paired = TRUE)

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2, ncol = 2
  
)


####Corrected #####
p_values <- c(0.4722,	7.57E-04, 0.3306,	1.09E-01)
p_values <- c(0.488,	0.003423, 0.2599,	0.06842)
# FDR correction using Benjamini-Hochberg method
fdr_corrected_p_values <- p.adjust(p_values, method = "fdr")

# Print the original p-values and the FDR-corrected p-values
data.frame(p_values = p_values, fdr_corrected_p_values = fdr_corrected_p_values)



###### Violinplots ##############


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
  plot.title = element_text(hjust = 0.5),
  panel.background = element_rect(fill = "white", color = "grey70", size = 1)
)  # Center the title
#plot.margin = margin(1, 1, 1, 1, "cm")

textsize_val <- 6
vjust_val <- 1.8


data_impro$title1 <- "Flow"
ggplot(data_impro, aes(x = D, y = Q3, fill = D)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = D), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  scale_fill_manual(values = c("Musician" = colors[5], "Dancer" = colors[6])) +
  labs(x = "Improvised", y = "", fill = "C") +
  facet_wrap(~ C, ncol = 2) +
  # geom_signif(
  #   comparisons = list(c("Musician", "Dancer")), 
  #   textsize = textsize_val, 
  #   vjust = vjust_val,
  #   annotations = c(" "), 
  #   map_signif_level = TRUE,
  #   show.legend = FALSE) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1)) 

ggplot(data_impro, aes(x = C, y = Q3, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = C), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  scale_fill_manual(values = c("Individual" = colors[5], "Group" = colors[6])) +
  labs(x = "(c) Improvised", y = "", fill = "C") +
  #facet_wrap(~ D, ncol = 2) +
  geom_signif(
    comparisons = list(c("Individual", "Group")),
    textsize = textsize_val,
    vjust = vjust_val,
    map_signif_level = TRUE,
    show.legend = FALSE) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1)) 



p + 
  annotate(
    "text",
    x = 1.5,  # X-coordinate of annotation
    y = 7,  # Y-coordinate of annotation
    label = "**",
    size = 8
  ) +
  annotate(
    "text",
    x = 1.5,  # X-coordinate of annotation
    y = 7,  # Y-coordinate of annotation
    label = "**", 
    size= 8
  )

ann_text <- data.frame(D = "Musician",Q3 = 7.0,lab = "Text",
                       C = factor("Group",levels = c("Individual", "Group")))
p1 <- p + geom_text(x = 1.5, y = 7.1, data = ann_text,label = "**", size = 6.5)


ann_text <- data.frame(D = "Musician",Q3 = 7.0,lab = "Text",
                       C = factor("Individual",levels = c("Individual", "Group")))
pQ3I <- p1 + geom_text(x = 1.5, y = 7.1, data = ann_text,label = "NS.", size = 5)




pQ3M <- ggplot(data_mixed, aes(x = D, y = Q3, fill = D)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = D), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  scale_fill_manual(values = c("Musician" = colors[5], "Dancer" = colors[6])) +
  labs(x = "Mixed", y = "", fill = "D") +
  facet_wrap(~ C, ncol = 2) +
  geom_signif(
    comparisons = list(c("Musician", "Dancer")), 
    textsize = 5, 
    vjust = vjust_val,
    map_signif_level = TRUE,
    show.legend = FALSE) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))


data_fixed$title1 <- "Flow"
pQ3F <- ggplot(data_fixed, aes(x = D, y = Q3, fill = D)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  scale_fill_manual(values = c("Musician" = colors[5], "Dancer" = colors[6])) +
  labs(x = "Fixed", y = "Rating", fill = "A")+
  facet_grid(. ~ title1) +
  geom_signif(comparisons = list(c("Musician", "Dancer")), 
              textsize = textsize_val, 
              vjust = vjust_val,
              map_signif_level = TRUE,
              show.legend = FALSE,
              annotations = c("*"),
  ) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))





library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  pQ3F, pQ3M, pQ3I, ncol = 3
  
)




###### Communication with Partner #####

##### Paired t-tests #######
##### IMPRO######
data_impro <- data_impro %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, INDvsGR) %>%
  mutate(mean_Q1b = mean(Q4a, na.rm = TRUE))

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



##### MIXED ######
data_mixed <- data_mixed %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, INDvsGR) %>%
  mutate(mean_Q1b = mean(Q4a, na.rm = TRUE))

filtered_data <- data_mixed %>%
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
  group_by(Participant, Palo) %>%
  mutate(mean_Q1b = mean(Q4a, na.rm = TRUE))

filtered_data <- data_fixed %>%
  distinct(Participant, Palo, mean_Q1b, Pair, Artist) 

filtered_data 


grouped_data <- filtered_data %>% arrange(Pair, Palo, Artist)
print(grouped_data)

# Split in two groups
grouped_P <- grouped_data[grepl("P", grouped_data$Artist),] #only dancers
print(grouped_P)


grouped_G <- grouped_data[grepl("G", grouped_data$Artist),] #only dancers
print(grouped_G)

# Subset weight data before treatment
Group_P <- grouped_P$mean_Q1b
Group_G <- grouped_G$mean_Q1b
# subset weight data after treatment


# Calculate medians and standard deviations
Median_Group_P <- median(na.omit(Group_P))
SD_Group_P <- sd(na.omit(Group_P))
Median_Group_G <- median(na.omit(Group_G))
SD_Group_G <- sd(na.omit(Group_G))

# Print medians and standard deviations for Group_P and Group_G
cat("Median_Group_P:", Median_Group_P, "\n")
cat("SD_Group_P:", SD_Group_P, "\n")
cat("Median_Group_G:", Median_Group_G, "\n")
cat("SD_Group_G:", SD_Group_G, "\n")

library(PairedData)
pd_P <- paired(Group_P, Group_G)
p1 <- plot(pd_P, type = "profile") + theme_bw()


t.test(Group_P, Group_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')



shapiro.test(Group_P)
shapiro.test(Group_G)

wilcox.test(Indiv_P, Indiv_G, paired = TRUE)
wilcox.test(Group_P, Group_G, paired = TRUE)

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2, ncol = 2
  
)


##### Correction######
#  p-values
p_values <- c(0.05316, 1, 0.02674, 0.4495)

# FDR correction using Benjamini-Hochberg method
fdr_corrected_p_values <- p.adjust(p_values, method = "fdr")

# Print the original p-values and the FDR-corrected p-values
data.frame(p_values = p_values, fdr_corrected_p_values = fdr_corrected_p_values)




###### Violinplots ##############


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
  plot.title = element_text(hjust = 0.5),
  panel.background = element_rect(fill = "white", color = "grey70", size = 1)
)  # Center the title
#plot.margin = margin(1, 1, 1, 1, "cm")

textsize_val <- 6
vjust_val <- 1.8


data_impro$title1 <- "Connection with partner"
ggplot(data_impro, aes(x = D, y = Q4a, fill = D)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = D), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  scale_fill_manual(values = c("Musician" = colors[5], "Dancer" = colors[6])) +
  labs(x = "Improvised", y = "", fill = "C") +
  facet_wrap(~ C, ncol = 2) +
  geom_signif(
    comparisons = list(c("Musician", "Dancer")), 
    textsize = textsize_val, 
    vjust = vjust_val,
    map_signif_level = TRUE,
    show.legend = FALSE) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1)) 



ggplot(data_mixed, aes(x = C, y = Q4a, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = C), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  scale_fill_manual(values = c("Individual" = colors[9], "Group" = colors[10])) +
  labs(x = "Mixed", y = "", fill = "C") +
  facet_wrap(~ D, ncol = 2) +
  geom_signif(
    comparisons = list(c("Individual", "Group")), 
    textsize = 5, 
    vjust = vjust_val,
    map_signif_level = TRUE,
    show.legend = FALSE) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))


data_fixed$title1 <- "Communication with partner"
ggplot(data_fixed, aes(x = D, y = Q4a, fill = D)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  scale_fill_manual(values = c("Musician" = colors[5], "Dancer" = colors[6])) +
  labs(x = "Fixed", y = "Rating", fill = "A")+
  facet_grid(. ~ title1) +
  geom_signif(comparisons = list(c("Musician", "Dancer")), 
              textsize = textsize_val, 
              vjust = vjust_val,
              map_signif_level = TRUE,
              show.legend = FALSE,
              annotations = c("*"),
  ) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))





library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  pQ3F, pQ3M, pQ3I, ncol = 3
  
)





#### Absorption by activity #####


#### t-tests #####
#### DANvsMUS IMPvsMIX
data_ole<- data_ole %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, MIXvsIMP) %>%
  mutate(mean_Q1b = mean(Abs_Av, na.rm = TRUE))

filtered_data <- data_ole %>%
  distinct(Participant, Palo, mean_Q1b, Pair, Artist, MIXvsIMP) %>%
  filter(!is.na(MIXvsIMP))


grouped_data <- filtered_data %>%
  pivot_wider(names_from = MIXvsIMP, values_from = mean_Q1b)

print(grouped_data)

grouped_data <- grouped_data %>% arrange(Pair, Palo, Artist)
print(grouped_data)

### Subgroup level 1
grouped_impro <- grouped_data$Impro
print(grouped_impro)

grouped_mixed <- grouped_data$Mixed
print(grouped_mixed)



# Subgroup level 2
grouped_P <- grouped_data[grepl("P", grouped_data$Artist),] #only dancers
grouped_G <- grouped_data[grepl("G", grouped_data$Artist),]
print(grouped_P)

grouped_impro_P <- grouped_P$Impro
grouped_impro_G <- grouped_G$Impro

grouped_mixed_P <- grouped_P$Mixed
grouped_mixed_G <- grouped_G$Mixed
print(grouped_mixed_P)


library(PairedData)
t.test(grouped_impro_P, grouped_impro_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(grouped_mixed_P, grouped_mixed_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')

t.test(grouped_impro_P, grouped_mixed_P, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(grouped_impro_G, grouped_mixed_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')


shapiro.test(grouped_impro_P)
shapiro.test(grouped_mixed_P)
shapiro.test(grouped_mixed_G)
shapiro.test(grouped_impro_G)

wilcox.test(grouped_impro_P, grouped_mixed_P, paired = TRUE)
wilcox.test(grouped_impro_G, grouped_mixed_G, paired = TRUE)

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2,p3, p4,  ncol = 4
  
)

grid.arrange(
  # First column with plots p1, p2, and p3
  p5,p6,  ncol = 2
  
)

### DANvsMUS IMPvsFIX ####


data_ole<- data_ole %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, FIXvsIMP ) %>%
  mutate(mean_Q1b = mean(Abs_Av, na.rm = TRUE))

filtered_data <- data_ole %>%
  distinct(Participant, Palo, mean_Q1b, Pair, Artist, FIXvsIMP) %>%
  filter(!is.na(FIXvsIMP))


grouped_data <- filtered_data %>%
  pivot_wider(names_from = FIXvsIMP, values_from = mean_Q1b)

print(grouped_data)

grouped_data <- grouped_data %>% arrange(Pair, Palo, Artist)
print(grouped_data)


# Subgroup level 2
grouped_P <- grouped_data[grepl("P", grouped_data$Artist),] #only dancers
grouped_G <- grouped_data[grepl("G", grouped_data$Artist),]
print(grouped_P)

grouped_impro_P <- grouped_P$Impro
grouped_impro_G <- grouped_G$Impro

grouped_fixed_P <- grouped_P$Fixed
grouped_fixed_G <- grouped_G$Fixed
print(grouped_fixed_P)


library(PairedData)

pd_impro_Group <- paired(grouped_impro_P, grouped_impro_G)
p1 <- plot(pd_impro_Group, type = "profile") + theme_bw()

pd_impro_Indiv <- paired(grouped_fixed_P, grouped_fixed_G)
p2 <- plot(pd_impro_Indiv, type = "profile") + theme_bw()

pd_fixed_Group <- paired(grouped_impro_P, grouped_fixed_P)
p3 <- plot(pd_fixed_Group, type = "profile") + theme_bw()

pd_fixed_Indiv <- paired(grouped_impro_G, grouped_fixed_G)
p4 <- plot(pd_fixed_Indiv, type = "profile") + theme_bw()


t.test(grouped_impro_P, grouped_impro_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(grouped_fixed_P, grouped_fixed_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')

t.test(grouped_impro_P, grouped_fixed_P, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(grouped_impro_G, grouped_fixed_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')


shapiro.test(grouped_impro_P)
shapiro.test(grouped_fixed_P)
shapiro.test(grouped_fixed_G)
shapiro.test(grouped_impro_G)

wilcox.test(grouped_impro_P, grouped_fixed_P, paired = TRUE)
wilcox.test(grouped_impro_G, grouped_fixed_G, paired = TRUE)

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2,p3, p4,  ncol = 4
  
)

##### DANvsMUS MIXvsFIX
### DANvsMUS MIXvsFIX ####


data_ole<- data_ole %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, FIXvsMIX ) %>%
  mutate(mean_Q1b = mean(Abs_Av, na.rm = TRUE))

filtered_data <- data_ole %>%
  distinct(Participant, Palo, mean_Q1b, Pair, Artist, FIXvsMIX) %>%
  filter(!is.na(FIXvsMIX))


grouped_data <- filtered_data %>%
  pivot_wider(names_from = FIXvsMIX, values_from = mean_Q1b)

print(grouped_data)

grouped_data <- grouped_data %>% arrange(Pair, Palo, Artist)
print(grouped_data)


# Subgroup level 2
grouped_P <- grouped_data[grepl("P", grouped_data$Artist),] #only dancers
grouped_G <- grouped_data[grepl("G", grouped_data$Artist),]
print(grouped_P)

grouped_mixed_P <- grouped_P$Mixed
grouped_mixed_G <- grouped_G$Mixed

grouped_fixed_P <- grouped_P$Fixed
grouped_fixed_G <- grouped_G$Fixed
print(grouped_fixed_P)



### Medians

# Calculate medians and standard deviations
Median_grouped_mixed_P <- median(na.omit(grouped_mixed_P))
SD_grouped_mixed_P <- sd(na.omit(grouped_mixed_P))
Median_grouped_mixed_G <- median(na.omit(grouped_mixed_G))
SD_grouped_mixed_G <- sd(na.omit(grouped_mixed_G))
Median_grouped_fixed_P <- median(na.omit(grouped_fixed_P))
SD_grouped_fixed_P <- sd(na.omit(grouped_fixed_P))
Median_grouped_fixed_G <- median(na.omit(grouped_fixed_G))
SD_grouped_fixed_G <- sd(na.omit(grouped_fixed_G))

# Print medians and standard deviations for grouped_mixed_P and grouped_mixed_G
cat("Median_grouped_mixed_P:", Median_grouped_mixed_P, "\n")
cat("SD_grouped_mixed_P:", SD_grouped_mixed_P, "\n")
cat("Median_grouped_mixed_G:", Median_grouped_mixed_G, "\n")
cat("SD_grouped_mixed_G:", SD_grouped_mixed_G, "\n")

# Print medians and standard deviations for grouped_fixed_P and grouped_fixed_G
cat("Median_grouped_fixed_P:", Median_grouped_fixed_P, "\n")
cat("SD_grouped_fixed_P:", SD_grouped_fixed_P, "\n")
cat("Median_grouped_fixed_G:", Median_grouped_fixed_G, "\n")
cat("SD_grouped_fixed_G:", SD_grouped_fixed_G, "\n")



library(PairedData)

pd_mixed_Group <- paired(grouped_mixed_P, grouped_mixed_G)
p1 <- plot(pd_mixed_Group, type = "profile") + theme_bw()

pd_mixed_Indiv <- paired(grouped_fixed_P, grouped_fixed_G)
p2 <- plot(pd_mixed_Indiv, type = "profile") + theme_bw()

pd_fixed_Group <- paired(grouped_mixed_P, grouped_fixed_P)
p3 <- plot(pd_fixed_Group, type = "profile") + theme_bw()

pd_fixed_Indiv <- paired(grouped_mixed_G, grouped_fixed_G)
p4 <- plot(pd_fixed_Indiv, type = "profile") + theme_bw()


t.test(grouped_mixed_P, grouped_mixed_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(grouped_fixed_P, grouped_fixed_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')

t.test(grouped_mixed_P, grouped_fixed_P, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(grouped_mixed_G, grouped_fixed_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')


shapiro.test(grouped_mixed_P)
shapiro.test(grouped_fixed_P)
shapiro.test(grouped_fixed_G)
shapiro.test(grouped_mixed_G)

wilcox.test(grouped_mixed_P, grouped_fixed_P, paired = TRUE)
wilcox.test(grouped_mixed_G, grouped_fixed_G, paired = TRUE)

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2,p3, p4,  ncol = 4
  
)

#### Multiple Comparisson Correction ##


#  p-values
p_values <- c(0.02281, 0.5121, 0.1986, 0.00009772, 0.01631, 0.076)

# FDR correction using Benjamini-Hochberg method
fdr_corrected_p_values <- p.adjust(p_values, method = "fdr")

# Print the original p-values and the FDR-corrected p-values
data.frame(p_values = p_values, fdr_corrected_p_values = fdr_corrected_p_values)


##### violin plots First Interaction ##

data_impro$title3 <- "Connection with partner"

data_test$B <- factor(data_test$B, levels = c("Fixed", "Mixed", "Impro"))
p1 <- ggplot(data_test, aes(x = B, y = Abs_Av, fill = B)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = B), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  scale_fill_manual(values = c("Fixed" = colors[1], "Mixed" = colors[7],"Impro" = colors[5])) +
  labs(x = "", y = "Absorption by Activity", fill = "B") +
  facet_wrap(~ D, ncol = 2) +
  geom_signif(
    comparisons =list(c("Fixed", "Mixed"), c("Fixed", "Impro"), c("Mixed", "Impro")), 
    textsize = textsize_val, 
    vjust = vjust_val,
    map_signif_level = TRUE,
    annotations = c(" "),
    show.legend = FALSE) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))




ann_text <- data.frame(D = "Musician",Abs_Av = 7.0,lab = "Text",
                       B = factor("Fixed",levels = c("Fixed", "Mixed", "Impro")))
p1 <- p1 + geom_text(x = 1.5, y = 7.1, data = ann_text,label = "***", size = 5)

ann_text_2 <- data.frame(D = "Dancer",Abs_Av = 7.0,lab = "Text",
                       B = factor("Impro",levels = c("Fixed", "Mixed", "Impro")))
p1 <- p1 + geom_text(x = 2.5, y = 7.1, data = ann_text_2,label = "*", size = 5)

ann_text_2 <- data.frame(D = "Dancer",Abs_Av = 7.0,lab = "Text",
                         B = factor("Impro",levels = c("Fixed", "Mixed", "Impro")))
pAbsDB <- p1 + geom_text(x = 2, y = 7.5, data = ann_text_2,label = "*", size = 5)

pAbsDB


##### t-tests #####
#### SOvsTAN IMPvsFIX ###

data_ole<- data_ole %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, FIXvsIMP ) %>%
  mutate(mean_Q1b = mean(Abs_Av, na.rm = TRUE))

filtered_data <- data_ole %>%
  distinct(Participant, Palo, mean_Q1b, Pair, Artist, FIXvsIMP) %>%
  filter(!is.na(FIXvsIMP))


grouped_data <- filtered_data %>%
  pivot_wider(names_from = FIXvsIMP, values_from = mean_Q1b)

print(grouped_data)

grouped_data <- grouped_data %>% arrange(Pair, Artist, Palo)
print(grouped_data)


# Subgroup level 2
grouped_R1 <- grouped_data[grepl("R1", grouped_data$Palo),] #only dancers
grouped_R2 <- grouped_data[grepl("R2", grouped_data$Palo),]
print(grouped_R1)

grouped_impro_R1 <- grouped_R1$Impro
grouped_impro_R2 <- grouped_R2$Impro

grouped_fixed_R1 <- grouped_R1$Fixed
grouped_fixed_R2 <- grouped_R2$Fixed
print(grouped_fixed_R1)


library(PairedData)

pd_impro_R2roup <- paired(grouped_impro_R1, grouped_impro_R2)
p1 <- plot(pd_impro_R2roup, type = "profile") + theme_bw()

pd_impro_Indiv <- paired(grouped_fixed_R1, grouped_fixed_R2)
p2 <- plot(pd_impro_Indiv, type = "profile") + theme_bw()

pd_fixed_R2roup <- paired(grouped_impro_R1, grouped_fixed_R1)
p3 <- plot(pd_fixed_R2roup, type = "profile") + theme_bw()

pd_fixed_Indiv <- paired(grouped_impro_R2, grouped_fixed_R2)
p4 <- plot(pd_fixed_Indiv, type = "profile") + theme_bw()


t.test(grouped_impro_R1, grouped_impro_R2, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(grouped_fixed_R1, grouped_fixed_R2, paired = TRUE, correct = TRUE, alternative = 'two.sided')

t.test(grouped_impro_R1, grouped_fixed_R1, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(grouped_impro_R2, grouped_fixed_R2, paired = TRUE, correct = TRUE, alternative = 'two.sided')


shapiro.test(grouped_impro_R1)
shapiro.test(grouped_fixed_R1)
shapiro.test(grouped_fixed_R2)
shapiro.test(grouped_impro_R2)

wilcox.test(grouped_impro_R1, grouped_fixed_R1, paired = TRUE)
wilcox.test(grouped_impro_R2, grouped_fixed_R2, paired = TRUE)

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2,p3, p4,  ncol = 4
  
)



#### SOvsTAN MIXvsFIX ###

data_ole<- data_ole %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, FIXvsMIX ) %>%
  mutate(mean_Q1b = mean(Abs_Av, na.rm = TRUE))

filtered_data <- data_ole %>%
  distinct(Participant, Palo, mean_Q1b, Pair, Artist, FIXvsMIX) %>%
  filter(!is.na(FIXvsMIX))


grouped_data <- filtered_data %>%
  pivot_wider(names_from = FIXvsMIX, values_from = mean_Q1b)

print(grouped_data)

grouped_data <- grouped_data %>% arrange(Pair, Artist, Palo)
print(grouped_data)


# Subgroup level 2
grouped_R1 <- grouped_data[grepl("R1", grouped_data$Palo),] #only dancers
grouped_R2 <- grouped_data[grepl("R2", grouped_data$Palo),]
print(grouped_R1)

grouped_mixed_R1 <- grouped_R1$Mixed
grouped_mixed_R2 <- grouped_R2$Mixed

grouped_fixed_R1 <- grouped_R1$Fixed
grouped_fixed_R2 <- grouped_R2$Fixed
print(grouped_fixed_R1)


library(PairedData)

pd_mixed_R2roup <- paired(grouped_mixed_R1, grouped_mixed_R2)
p1 <- plot(pd_mixed_R2roup, type = "profile") + theme_bw()

pd_mixed_Indiv <- paired(grouped_fixed_R1, grouped_fixed_R2)
p2 <- plot(pd_mixed_Indiv, type = "profile") + theme_bw()

pd_fixed_R2roup <- paired(grouped_mixed_R1, grouped_fixed_R1)
p3 <- plot(pd_fixed_R2roup, type = "profile") + theme_bw()

pd_fixed_Indiv <- paired(grouped_mixed_R2, grouped_fixed_R2)
p4 <- plot(pd_fixed_Indiv, type = "profile") + theme_bw()


t.test(grouped_mixed_R1, grouped_mixed_R2, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(grouped_fixed_R1, grouped_fixed_R2, paired = TRUE, correct = TRUE, alternative = 'two.sided')

t.test(grouped_mixed_R1, grouped_fixed_R1, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(grouped_mixed_R2, grouped_fixed_R2, paired = TRUE, correct = TRUE, alternative = 'two.sided')


shapiro.test(grouped_mixed_R1)
shapiro.test(grouped_fixed_R1)
shapiro.test(grouped_fixed_R2)
shapiro.test(grouped_mixed_R2)

wilcox.test(grouped_mixed_R1, grouped_fixed_R1, paired = TRUE)
wilcox.test(grouped_mixed_R2, grouped_fixed_R2, paired = TRUE)

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2,p3, p4,  ncol = 4
  
)



#### SOvsTAN MIXvsIMP ###

data_ole<- data_ole %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, MIXvsIMP ) %>%
  mutate(mean_Q1b = mean(Abs_Av, na.rm = TRUE))

filtered_data <- data_ole %>%
  distinct(Participant, Palo, mean_Q1b, Pair, Artist, MIXvsIMP) %>%
  filter(!is.na(MIXvsIMP))


grouped_data <- filtered_data %>%
  pivot_wider(names_from = MIXvsIMP, values_from = mean_Q1b)

print(grouped_data)

grouped_data <- grouped_data %>% arrange(Pair, Artist, Palo)
print(grouped_data)


# Subgroup level 2
grouped_R1 <- grouped_data[grepl("R1", grouped_data$Palo),] #only dancers
grouped_R2 <- grouped_data[grepl("R2", grouped_data$Palo),]
print(grouped_R1)

grouped_mixed_R1 <- grouped_R1$Mixed
grouped_mixed_R2 <- grouped_R2$Mixed

grouped_impro_R1 <- grouped_R1$Impro
grouped_impro_R2 <- grouped_R2$Impro
print(grouped_impro_R1)


library(PairedData)

pd_mixed_R2roup <- paired(grouped_mixed_R1, grouped_mixed_R2)
p1 <- plot(pd_mixed_R2roup, type = "profile") + theme_bw()

pd_mixed_Indiv <- paired(grouped_impro_R1, grouped_impro_R2)
p2 <- plot(pd_mixed_Indiv, type = "profile") + theme_bw()

pd_impro_R2roup <- paired(grouped_mixed_R1, grouped_impro_R1)
p3 <- plot(pd_impro_R2roup, type = "profile") + theme_bw()

pd_impro_Indiv <- paired(grouped_mixed_R2, grouped_impro_R2)
p4 <- plot(pd_impro_Indiv, type = "profile") + theme_bw()


t.test(grouped_mixed_R1, grouped_mixed_R2, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(grouped_impro_R1, grouped_impro_R2, paired = TRUE, correct = TRUE, alternative = 'two.sided')

t.test(grouped_mixed_R1, grouped_impro_R1, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(grouped_mixed_R2, grouped_impro_R2, paired = TRUE, correct = TRUE, alternative = 'two.sided')


shapiro.test(grouped_mixed_R1)
shapiro.test(grouped_impro_R1)
shapiro.test(grouped_impro_R2)
shapiro.test(grouped_mixed_R2)

wilcox.test(grouped_mixed_R1, grouped_impro_R1, paired = TRUE)
wilcox.test(grouped_mixed_R2, grouped_impro_R2, paired = TRUE)

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2,p3, p4,  ncol = 4
  
)


#  p-values
p_values <- c(0.1006, 0.02029, 0.3855, 0.02486, 0.398, 0.1753)
p_values <- c(0.1006, 0.02029)

p_values <- c(0.006522, 0.8543, 0.546)
p_values <- c(0.006522, 0.8543)


# FDR correction using Benjamini-Hochberg method
fdr_corrected_p_values <- p.adjust(p_values, method = "fdr")

# Print the original p-values and the FDR-corrected p-values
data.frame(p_values = p_values, fdr_corrected_p_values = fdr_corrected_p_values)


### violinplots ####

data_impro$title3 <- "Connection with partner"

data_test$B <- factor(data_test$B, levels = c("Fixed", "Mixed", "Impro"))

## Not used
ggplot(data_test, aes(x = B, y = Abs_Av, fill = B)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = B), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  scale_fill_manual(values = c("Fixed" = colors[1], "Mixed" = colors[2],"Impro" = colors[3])) +
  labs(x = "", y = "Absorption by Activity", fill = "B") +
  facet_wrap(~ E, ncol = 2) +
  geom_signif(
    comparisons =list(c("Fixed", "Mixed"), c("Fixed", "Impro"), c("Mixed", "Impro")), 
    textsize = textsize_val, 
    vjust = vjust_val,
    map_signif_level = TRUE,
    annotations = c(" "),
    show.legend = FALSE) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))


p1 <- ggplot(data_test, aes(x = E, y = Abs_Av, fill = E)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = E), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  scale_fill_manual(values = c("Solea" = colors[5], "Tangos" = colors[6])) +
  labs(x = "", y = "Absorption by Activity", fill = "E") +
  facet_wrap(~ B, ncol = 3) +
  geom_signif(
    comparisons =list(c("Solea", "Tangos")), 
    textsize = textsize_val, 
    vjust = vjust_val,
    map_signif_level = TRUE,
    annotations = c(" "),
    show.legend = FALSE) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))




ann_text <- data.frame(E = "Solea",Abs_Av = 7.0,lab = "Text",
                       B = factor("Fixed",levels = c("Fixed", "Mixed", "Impro")))
pAbsEF <- p1 + geom_text(x = 1.5, y = 7.1, data = ann_text,label = "*", size = 7)

pAbsEF 


#### RHYTHMIC COMPLEXITY #####
### DANvsMUS and MIXvsFIX

### DANvsMUS MIXvsFIX ####


data_ole<- data_ole %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, FIXvsMIX ) %>%
  mutate(mean_Q1b = mean(Q6b, na.rm = TRUE))

filtered_data <- data_ole %>%
  distinct(Participant, Palo, mean_Q1b, Pair, Artist, FIXvsMIX) %>%
  filter(!is.na(FIXvsMIX))


grouped_data <- filtered_data %>%
  pivot_wider(names_from = FIXvsMIX, values_from = mean_Q1b)

print(grouped_data)

grouped_data <- grouped_data %>% arrange(Pair, Palo, Artist)
print(grouped_data)


# Subgroup level 2
grouped_P <- grouped_data[grepl("P", grouped_data$Artist),] #only dancers
grouped_G <- grouped_data[grepl("G", grouped_data$Artist),]
print(grouped_P)

grouped_mixed_P <- grouped_P$Mixed
grouped_mixed_G <- grouped_G$Mixed

grouped_fixed_P <- grouped_P$Fixed
grouped_fixed_G <- grouped_G$Fixed
print(grouped_fixed_P)


library(PairedData)

pd_mixed_Group <- paired(grouped_mixed_P, grouped_mixed_G)
p1 <- plot(pd_mixed_Group, type = "profile") + theme_bw()

pd_mixed_Indiv <- paired(grouped_fixed_P, grouped_fixed_G)
p2 <- plot(pd_mixed_Indiv, type = "profile") + theme_bw()

pd_fixed_Group <- paired(grouped_mixed_P, grouped_fixed_P)
p3 <- plot(pd_fixed_Group, type = "profile") + theme_bw()

pd_fixed_Indiv <- paired(grouped_mixed_G, grouped_fixed_G)
p4 <- plot(pd_fixed_Indiv, type = "profile") + theme_bw()


t.test(grouped_mixed_P, grouped_mixed_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(grouped_fixed_P, grouped_fixed_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')

t.test(grouped_mixed_P, grouped_fixed_P, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(grouped_mixed_G, grouped_fixed_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')


shapiro.test(grouped_mixed_P)
shapiro.test(grouped_fixed_P)
shapiro.test(grouped_fixed_G)
shapiro.test(grouped_mixed_G)

wilcox.test(grouped_mixed_P, grouped_fixed_P, paired = TRUE)
wilcox.test(grouped_mixed_G, grouped_fixed_G, paired = TRUE)

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2,p3, p4,  ncol = 4
  
)

#### IMPvs FIX DANvsMUS
data_ole<- data_ole %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, FIXvsIMP ) %>%
  mutate(mean_Q1b = mean(Q6b, na.rm = TRUE))

filtered_data <- data_ole %>%
  distinct(Participant, Palo, mean_Q1b, Pair, Artist, FIXvsIMP) %>%
  filter(!is.na(FIXvsIMP))


grouped_data <- filtered_data %>%
  pivot_wider(names_from = FIXvsIMP, values_from = mean_Q1b)

print(grouped_data)

grouped_data <- grouped_data %>% arrange(Pair, Palo, Artist)
print(grouped_data)


# Subgroup level 2
grouped_P <- grouped_data[grepl("P", grouped_data$Artist),] #only dancers
grouped_G <- grouped_data[grepl("G", grouped_data$Artist),]
print(grouped_P)

grouped_impro_P <- grouped_P$Impro
grouped_impro_G <- grouped_G$Impro

grouped_fixed_P <- grouped_P$Fixed
grouped_fixed_G <- grouped_G$Fixed
print(grouped_fixed_P)


library(PairedData)

pd_impro_Group <- paired(grouped_impro_P, grouped_impro_G)
p1 <- plot(pd_impro_Group, type = "profile") + theme_bw()

pd_impro_Indiv <- paired(grouped_fixed_P, grouped_fixed_G)
p2 <- plot(pd_impro_Indiv, type = "profile") + theme_bw()

pd_fixed_Group <- paired(grouped_impro_P, grouped_fixed_P)
p3 <- plot(pd_fixed_Group, type = "profile") + theme_bw()

pd_fixed_Indiv <- paired(grouped_impro_G, grouped_fixed_G)
p4 <- plot(pd_fixed_Indiv, type = "profile") + theme_bw()


t.test(grouped_impro_P, grouped_impro_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(grouped_fixed_P, grouped_fixed_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')

t.test(grouped_impro_P, grouped_fixed_P, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(grouped_impro_G, grouped_fixed_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')


shapiro.test(grouped_impro_P)
shapiro.test(grouped_fixed_P)
shapiro.test(grouped_fixed_G)
shapiro.test(grouped_impro_G)

wilcox.test(grouped_impro_P, grouped_fixed_P, paired = TRUE)
wilcox.test(grouped_impro_G, grouped_fixed_G, paired = TRUE)

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2,p3, p4,  ncol = 4
  
)

#### DANvsMUS IMPvsMIX
data_ole<- data_ole %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, MIXvsIMP) %>%
  mutate(mean_Q1b = mean(Q6b, na.rm = TRUE))

filtered_data <- data_ole %>%
  distinct(Participant, Palo, mean_Q1b, Pair, Artist, MIXvsIMP) %>%
  filter(!is.na(MIXvsIMP))


grouped_data <- filtered_data %>%
  pivot_wider(names_from = MIXvsIMP, values_from = mean_Q1b)

print(grouped_data)

grouped_data <- grouped_data %>% arrange(Pair, Palo, Artist)
print(grouped_data)

### Subgroup level 1
grouped_impro <- grouped_data$Impro
print(grouped_impro)

grouped_mixed <- grouped_data$Mixed
print(grouped_mixed)



# Subgroup level 2
grouped_P <- grouped_data[grepl("P", grouped_data$Artist),] #only dancers
grouped_G <- grouped_data[grepl("G", grouped_data$Artist),]
print(grouped_P)

grouped_impro_P <- grouped_P$Impro
grouped_impro_G <- grouped_G$Impro

grouped_mixed_P <- grouped_P$Mixed
grouped_mixed_G <- grouped_G$Mixed
print(grouped_mixed_P)


library(PairedData)
t.test(grouped_impro_P, grouped_impro_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(grouped_mixed_P, grouped_mixed_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')

t.test(grouped_impro_P, grouped_mixed_P, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(grouped_impro_G, grouped_mixed_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')


shapiro.test(grouped_impro_P)
shapiro.test(grouped_mixed_P)
shapiro.test(grouped_mixed_G)
shapiro.test(grouped_impro_G)

wilcox.test(grouped_impro_P, grouped_mixed_P, paired = TRUE)
wilcox.test(grouped_impro_G, grouped_mixed_G, paired = TRUE)

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2,p3, p4,  ncol = 4
  
)

grid.arrange(
  # First column with plots p1, p2, and p3
  p5,p6,  ncol = 2
  
)


### Correction ###

p_values <- c(0.1169, 0.2562, 0.001634, 0.0004616, 0.0003954, 0.003453)

# FDR correction using Benjamini-Hochberg method
fdr_corrected_p_values <- p.adjust(p_values, method = "fdr")

# Print the original p-values and the FDR-corrected p-values
data.frame(p_values = p_values, fdr_corrected_p_values = fdr_corrected_p_values)


### violinplots ####

data_impro$title3 <- "Connection with partner"

data_test$B <- factor(data_test$B, levels = c("Fixed", "Mixed", "Impro"))

## Not used
p1 <- ggplot(data_test, aes(x = B, y = Q6b, fill = B)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = B), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  scale_fill_manual(values = c("Fixed" = colors[1], "Mixed" = colors[2],"Impro" = colors[3])) +
  labs(x = "", y = "RHythmic Complexity", fill = "B") +
  facet_wrap(~ D, ncol = 2) +
  geom_signif(
    comparisons =list(c("Fixed", "Mixed"), c("Fixed", "Impro"), c("Mixed", "Impro")), 
    textsize = textsize_val, 
    vjust = vjust_val,
    map_signif_level = TRUE,
    annotations = c(" "),
    show.legend = FALSE) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))



ann_text <- data.frame(D = "Musician",Abs_Av = 7.0,lab = "Text",
                       B = factor("Fixed",levels = c("Fixed", "Mixed", "Impro")))
p1 <- p1 + geom_text(x = 2.5, y = 7.1, data = ann_text,label = "**", size = 5)

p1 <- p1 + geom_text(x = 2, y = 7.5, data = ann_text,label = "**", size = 5)

ann_text <- data.frame(D = "Dancer",Abs_Av = 7.0,lab = "Text",
                       B = factor("Fixed",levels = c("Fixed", "Mixed", "Impro")))
p1 <- p1 + geom_text(x = 2.5, y = 7.1, data = ann_text,label = "**", size = 5)

p1 <- p1 + geom_text(x = 2, y = 7.5, data = ann_text,label = "**", size = 5)

p1
### Violinplots ###









###### Feeling rightly challenged #####

##### Paired t-tests #######
##### IMPRO######
data_impro <- data_impro %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, INDvsGR) %>%
  mutate(mean_Q1b = mean(Q2a, na.rm = TRUE))

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


### Medians

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

pd_G <- paired(Group_G, Indiv_G)
p1 <- plot(pd_G, type = "profile") + theme_bw()

pd_G <- paired(Indiv_P, Group_P)
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



##### MIXED ######
data_mixed <- data_mixed %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, INDvsGR) %>%
  mutate(mean_Q1b = mean(Q2a, na.rm = TRUE))

filtered_data <- data_mixed %>%
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
  group_by(Participant, Palo) %>%
  mutate(mean_Q1b = mean(Q2a, na.rm = TRUE))

filtered_data <- data_fixed %>%
  distinct(Participant, Palo, mean_Q1b, Pair, Artist) 

filtered_data 


grouped_data <- filtered_data %>% arrange(Pair, Palo, Artist)
print(grouped_data)

# Split in two groups
grouped_P <- grouped_data[grepl("P", grouped_data$Artist),] #only dancers
print(grouped_P)


grouped_G <- grouped_data[grepl("G", grouped_data$Artist),] #only dancers
print(grouped_G)

# Subset weight data before treatment
Group_P <- grouped_P$mean_Q1b
Group_G <- grouped_G$mean_Q1b
# subset weight data after treatment


# Calculate medians and standard deviations
Median_Group_P <- median(na.omit(Group_P))
SD_Group_P <- sd(na.omit(Group_P))
Median_Group_G <- median(na.omit(Group_G))
SD_Group_G <- sd(na.omit(Group_G))

# Print medians and standard deviations for Group_P and Group_G
cat("Median_Group_P:", Median_Group_P, "\n")
cat("SD_Group_P:", SD_Group_P, "\n")
cat("Median_Group_G:", Median_Group_G, "\n")
cat("SD_Group_G:", SD_Group_G, "\n")

library(PairedData)
pd_P <- paired(Group_P, Group_G)
p1 <- plot(pd_P, type = "profile") + theme_bw()


t.test(Group_P, Group_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')



Fixshapiro.test(Group_P)
shapiro.test(Group_G)

wilcox.test(Indiv_P, Indiv_G, paired = TRUE)
wilcox.test(Group_P, Group_G, paired = TRUE)

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2, ncol = 2
  
)

##### Correction ####
#  p-values
p_values <- c(0.885,	5.22E-05, 0.5725,	0.04096)

# FDR correction using Benjamini-Hochberg method
fdr_corrected_p_values <- p.adjust(p_values, method = "fdr")

# Print the original p-values and the FDR-corrected p-values
data.frame(p_values = p_values, fdr_corrected_p_values = fdr_corrected_p_values)



###### Violinplots ##############


library(tidyverse)
colors <- c("#8DD3C7", "#FFFFB3", "#BEBADA", "#FB8072", "#80B1D3", "#FDB462", "#B3DE69", "#FCCDE5", "#00008B", "#BC80BD")
labels_names <- c('Mixed', 'Impro','Mixeded', 'Free','Improidual', 'Mixed', 'Musician', 'Dancer', 'Tangos', 'Solea')
color_lines <- c("#55A4A0","#D2BF8E", '#975991')
label_lines <- c("Mixed","Impro", 'Solea')
common_theme <- theme(
  axis.text.y = element_text(size = 12),   # Adjust y-axis text size
  axis.text.x = element_text(size = 10),   # Adjust y-axis text size
  strip.text = element_text(size = 12),     # Adjust facet titles size
  axis.title.x = element_text(size = 12),
  axis.title.y = element_text(size = 14),
  panel.grid = element_blank(),
  plot.title = element_text(hjust = 0.5),
  plot.margin = margin(t = 1, r = 0, b = 2, l = 0.5, unit = "cm"),
  panel.background = element_rect(fill = "white", color = "grey70", size = 1)
)  # Center the title
#plot.margin = margin(1, 1, 1, 1, "cm")

textsize_val <- 6
vjust_val <- 1.7


##### Q2a #######
title1 <- "Feeling rightly challenged"
pQ1bI <- ggplot(data_impro, aes(x = C, y = Q2a, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = C), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  scale_fill_manual(values = c("Individual" = colors[9], "Group" = colors[10])) +
  scale_x_discrete(labels = c("Group" = "Gr", "Individual" = "Ind")) +
  labs(x = " (c) Improvised ", y = "", fill = "C") +
  facet_wrap(~ D, ncol = 2) +
  # geom_signif(
  #   comparisons = list(c("Individual", "Group")), 
  #   textsize = textsize_val, 
  #   vjust = vjust_val,
  #   annotations = '',
  #   map_signif_level = TRUE,
  #   show.legend = FALSE) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))

ann_text <- data.frame(D = "Dancer",Q2a = 7.0,lab = "Text",
                       C = factor("Individual",levels = c("Individual", "Group")))
pQ1bI <- pQ1bI + geom_text(x = 1.5, y = 7.1, data = ann_text,label = "", size = 5)

ann_text <- data.frame(D = "Musician",Q2a = 7.0,lab = "Text",
                       C = factor("Group",levels = c("Individual", "Group")))
pQ1bI <- pQ1bI + geom_text(x = 1.5, y = 7.2, data = ann_text,label = "***", size = 6.5)

pQ1bI

pQ1bM <- ggplot(data_mixed, aes(x = C, y = Q2a, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = C), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  scale_fill_manual(values = c("Individual" = colors[9], "Group" = colors[10])) +
  labs(x = "(b) Mixed", y = "", fill = "C") +
  scale_x_discrete(labels = c("Group" = "Gr", "Individual" = "Ind")) +
  facet_wrap(~ D, ncol = 2) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))

pQ1bM

pQ1bF <-ggplot(data_fixed, aes(x = D, y = Q2a, fill = D)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = D), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  scale_fill_manual(values = c("Dancer" = colors[10],"Musician" = colors[10])) +
  labs(x = "(a) Fixed", y = title1, fill = "D") +
  scale_x_discrete(labels = c("Neutral" = "Group")) +
  facet_wrap(~ C, labeller = labeller(C = c(Neutral = "Group")), ncol = 2) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))

library(gridExtra)
grid_arrange <-grid.arrange(
  # First column with plots p1, p2, and p3
  pQ1bF, pQ1bM, pQ1bI, ncol = 3
  
)



pushViewport(viewport(layout = grid.layout(1, 3)))

# Specify the coordinates for the line above graphs
x1 <- unit(0.9, "npc")
x2 <- unit(0.95, "npc")
y <- unit(0.79, "npc")

# Draw the line between plot 1 and plot 2
grid.lines(x = c(x1, x2), y = c(y, y), gp = gpar(col = "black", lwd = 2) )
y2 <- y - unit( 0.011, "npc")

# Draw the line between plot 1 and plot 2
grid.lines(x = c(x1, x1), y = c(y, y2), gp = gpar(col = "black", lwd = 2) )
grid.lines(x = c(x2, x2), y = c(y, y2), gp = gpar(col = "black", lwd = 2) )


### under graph 
x1 <- unit(0.2, "npc")
x2 <- unit(0.85, "npc")
y <- unit(0.08, "npc")

# Draw the line between plot 1 and plot 2
grid.lines(x = c(x1, x2), y = c(y, y), gp = gpar(col = "black", lwd = 2) )

y2 <- y + unit( 0.015, "npc")

# Draw the line between plot 1 and plot 2
grid.lines(x = c(x1, x1), y = c(y, y2), gp = gpar(col = "black", lwd = 2) )
grid.lines(x = c(x2, x2), y = c(y, y2), gp = gpar(col = "black", lwd = 2) )

# Draw the p-value annotation
text <- "***"
grid.text(label = text, x = unit(0.5, "npc"), y = unit(0.06, "npc"), gp = gpar(fontsize = 18))


### Add title
# title2 = "Feeling rightly challenged"
# grid.text(title2, x = 0.3, y = 0.97, gp = gpar(fontsize = 16, fontface = "bold"))


##### Connection wit partner ##### 
###################################
common_theme <- theme(
  axis.text.y = element_text(size = 12),   # Adjust y-axis text size
  axis.text.x = element_text(size = 10),   # Adjust y-axis text size
  strip.text = element_text(size = 12),     # Adjust facet titles size
  axis.title.x = element_text(size = 12),
  axis.title.y = element_text(size = 14),
  panel.grid = element_blank(),
  plot.title = element_text(hjust = 0.5),
  plot.margin = margin(t = 1, r = 0, b = 2, l = 0.5, unit = "cm"),
  panel.background = element_rect(fill = "white", color = "grey70", size = 1)
)

title1 <- "Connection with partner"
pQ1bI <- ggplot(data_impro, aes(x = C, y = Q4a, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = C), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  scale_fill_manual(values = c("Individual" = colors[9], "Group" = colors[10])) +
  labs(x = " (c) Improvised ", y = "", fill = "C") +
  facet_wrap(~ D, ncol = 2) +
  # geom_signif(
  #   comparisons = list(c("Individual", "Group")), 
  #   textsize = textsize_val, 
  #   vjust = vjust_val,
  #   annotations = '',
  #   map_signif_level = TRUE,
  #   show.legend = FALSE) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))

pQ1bI

pQ1bM <- ggplot(data_mixed, aes(x = C, y = Q2a, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = C), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  scale_fill_manual(values = c("Individual" = colors[9], "Group" = colors[10])) +
  labs(x = "(b) Mixed", y = "", fill = "C") +
  facet_wrap(~ D, ncol = 2) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))



pQ1bF <-ggplot(data_fixed, aes(x = D, y = Q2a, fill = D)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = D), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  scale_fill_manual(values = c("Dancer" = colors[10],"Musician" = colors[10])) +
  labs(x = "(a) Fixed", y = title1, fill = "D") +
  scale_x_discrete(labels = c("Neutral" = "Group")) +
  facet_wrap(~ C, labeller = labeller(C = c(Neutral = "Group")), ncol = 2) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))
pQ1bF

grid_arrange <-grid.arrange(
  # First column with plots p1, p2, and p3
  pQ1bF, pQ1bM, pQ1bI, ncol = 3
  
)

pushViewport(viewport(layout = grid.layout(1, 3)))



### under graph 
x1 <- unit(0.2, "npc")
x2 <- unit(0.85, "npc")
y <- unit(0.08, "npc")

# Draw the line between plot 1 and plot 2
grid.lines(x = c(x1, x2), y = c(y, y), gp = gpar(col = "black", lwd = 2) )

y2 <- y + unit( 0.015, "npc")

# Draw the line between plot 1 and plot 2
grid.lines(x = c(x1, x1), y = c(y, y2), gp = gpar(col = "black", lwd = 2) )
grid.lines(x = c(x2, x2), y = c(y, y2), gp = gpar(col = "black", lwd = 2) )

# Draw the p-value annotation
y3= y- unit( 0.02, "npc")
x3 = (x1 + x2)/2 
text <- "***"
grid.text(label = text, x = unit(x3, "npc"), y = unit(y3, "npc"), gp = gpar(fontsize = 18))


### Under graph 2 ####

x1 <- unit(0.2, "npc")
x2 <- unit(0.55, "npc")
y <- unit(0.04, "npc")

# Draw the line between plot 1 and plot 2
grid.lines(x = c(x1, x2), y = c(y, y), gp = gpar(col = "black", lwd = 2) )

y2 <- y + unit( 0.015, "npc")

# Draw the line between plot 1 and plot 2
grid.lines(x = c(x1, x1), y = c(y, y2), gp = gpar(col = "black", lwd = 2) )
grid.lines(x = c(x2, x2), y = c(y, y2), gp = gpar(col = "black", lwd = 2) )

# Draw the p-value annotation
y3= y- unit( 0.02, "npc")
x3 = (x1 + x2)/2 

text <- "***"

grid.text(label = text, x = unit(x3, "npc"), y = unit(y3, "npc"), gp = gpar(fontsize = 18))



#### Version 07.03.2024


common_theme <- theme(
  axis.text.y = element_text(size = 12),   # Adjust y-axis text size
  axis.text.x = element_text(size = 10),   # Adjust y-axis text size
  strip.text = element_text(size = 12),     # Adjust facet titles size
  axis.title.x = element_text(size = 12),
  axis.title.y = element_text(size = 14),
  panel.grid = element_blank(),
  plot.title = element_text(hjust = 0.5),
  plot.margin = margin(t = 1, r = 0, b = 2, l = 0.5, unit = "cm"),
  panel.background = element_rect(fill = "white", color = "grey70", size = 1)
)
# 
# new_colors <- c("#5BB8A0", "#8C8AFF", "#FFA500", "#E30B5C")
# 
# darker_colors <- c("#348770", "#4F4D9E", "#BF7F00", "#A50741")

colors <- c("#5BB8A0", "#8C8AFF", "#FFA500", "#E30B5C", "#f15a2eff")
darker_colors <- c("#348770", "#4F4D9E", "#f19e07ff", "#A50741")
colors = c( "#136e60ff", "#3906f6ff")
colors <- c("#8DD3C7", "#FFFFB3", "#BEBADA", "#FB8072", "#80B1D3", "#FDB462", "#B3DE69", "#FCCDE5", "#00008B", "#BC80BD")

#Colors for poster



#### Quality of improvisation ##### 
data_fixed$title1 <- "Improvisational Creativity"
pQ1bI <- ggplot(data_impro, aes(x = C, y = Q1b, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  #geom_boxplot(aes(fill = C), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  geom_boxplot(aes(fill = "white"), width = 0.15, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE, fill = "white") +
  scale_fill_manual(values = c("Individual" = colors[5], "Group" = colors[9])) +
  scale_x_discrete(labels = c("Group" = "Gr", "Individual" = "Ind")) +
  labs(x = " (c) Improvised ", y = "", fill = "C") +
  facet_wrap(~ D, ncol = 2) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))

pQ1bI

pQ1bM <- ggplot(data_mixed, aes(x = C, y = Q1b, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  #geom_boxplot(aes(fill = C), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  geom_boxplot(aes(fill = "white"), width = 0.15, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE, fill = "white") +
  scale_fill_manual(values = c("Individual" = colors[5], "Group" = colors[9])) +
  scale_x_discrete(labels = c("Group" = "Gr", "Individual" = "Ind")) +
  labs(x = "(b) Mixed", y = "", fill = "C") +
  facet_wrap(~ D, ncol = 2) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))

# pQ1bF  <-ggplot(data_fixed, aes(x = C, y = Q1b, fill = C)) +
#   geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
#   #geom_boxplot(aes(fill = C), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
#   geom_boxplot(aes(fill = "white"), width = 0.15, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE, fill = "white") +
#   scale_x_discrete(labels = c("Group" = "Gr", "Individual" = "Ind")) +
#   scale_fill_manual(values = c("Neutral" = colors[10])) +
#   labs(x = "(a) Fixed", y = "Subjective rating", fill = "C") +
#   scale_x_discrete(labels = c("Neutral" = "Group")) +
#   facet_wrap(~ D, ncol = 2) +
#   common_theme + 
#   scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))
title1 <- "Subjective rating"
pQ1bF <-ggplot(data_fixed, aes(x = D, y = Q1b, fill = D)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = "white"), width = 0.15, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE, fill = "white") +
  scale_fill_manual(values = c("Dancer" = colors[9],"Musician" = colors[9])) +
  labs(x = "(a) Fixed", y = title1, fill = "D") +
  scale_x_discrete(labels = c("Neutral" = "Group")) +
  facet_wrap(~ C, labeller = labeller(C = c(Neutral = "Group")), ncol = 2) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))


grid.arrange(
  # First column with plots p1, p2, and p3
  pQ1bF, pQ1bM, pQ1bI, ncol = 3
  
)

#### Flow ##### 

pQ3I <- ggplot(data_impro, aes(x = C, y = Q3, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  #geom_boxplot(aes(fill = C), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  geom_boxplot(aes(fill = "white"), width = 0.15, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE, fill = "white") +
  scale_fill_manual(values = c("Individual" = colors[5], "Group" = colors[9])) +
  scale_x_discrete(labels = c("Group" = "Gr", "Individual" = "Ind")) +
  labs(x = " (c) Improvised ", y = "", fill = "C") +
  facet_wrap(~ D, ncol = 2) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))


pQ3M <- ggplot(data_mixed, aes(x = C, y = Q3, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  #geom_boxplot(aes(fill = C), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  geom_boxplot(aes(fill = "white"), width = 0.15, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE, fill = "white") +
  scale_fill_manual(values = c("Individual" = colors[5], "Group" = colors[9])) +
  scale_x_discrete(labels = c("Group" = "Gr", "Individual" = "Ind")) +
  labs(x = "(b) Mixed", y = "", fill = "C") +
  facet_wrap(~ D, ncol = 2) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))

pQ3F <-ggplot(data_fixed, aes(x = D, y = Q3, fill = D)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = "white"), width = 0.15, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE, fill = "white") +
  scale_fill_manual(values = c("Dancer" = colors[9],"Musician" = colors[9])) +
  labs(x = "(a) Fixed", y = title1, fill = "D") +
  scale_x_discrete(labels = c("Neutral" = "Group")) +
  facet_wrap(~ C, labeller = labeller(C = c(Neutral = "Group")), ncol = 2) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))


grid.arrange(
  # First column with plots p1, p2, and p3
  pQ3F, pQ3M, pQ3I, ncol = 3
  
)


#### Feeling rightly challenged ##### 
title1 = "Subjective rating"
pQ2aI <- ggplot(data_impro, aes(x = C, y = Q2a, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  #geom_boxplot(aes(fill = C), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  geom_boxplot(aes(fill = "white"), width = 0.15, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE, fill = "white") +
  scale_fill_manual(values = c("Individual" = colors[5], "Group" = colors[9])) +
  scale_x_discrete(labels = c("Group" = "Gr", "Individual" = "Ind")) +
  labs(x = " (c) Improvised ", y = "", fill = "C") +
  facet_wrap(~ D, ncol = 2) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))


pQ2aM <- ggplot(data_mixed, aes(x = C, y = Q2a, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  #geom_boxplot(aes(fill = C), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  geom_boxplot(aes(fill = "white"), width = 0.15, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE, fill = "white") +
  scale_fill_manual(values = c("Individual" = colors[5], "Group" = colors[9])) +
  scale_x_discrete(labels = c("Group" = "Gr", "Individual" = "Ind")) +
  labs(x = "(b) Mixed", y = "", fill = "C") +
  facet_wrap(~ D, ncol = 2) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))

pQ2aF <-ggplot(data_fixed, aes(x = D, y = Q2a, fill = D)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = "white"), width = 0.15, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE, fill = "white") +
  scale_fill_manual(values = c("Dancer" = colors[9],"Musician" = colors[9])) +
  labs(x = "(a) Fixed", y = title1, fill = "D") +
  scale_x_discrete(labels = c("Neutral" = "Group")) +
  facet_wrap(~ C, labeller = labeller(C = c(Neutral = "Group")), ncol = 2) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))


grid.arrange(
  # First column with plots p1, p2, and p3
  pQ2aF, pQ2aM, pQ2aI, ncol = 3
  
)





#### Version 03.06.2024
#### Colors for poster



common_theme <- theme(
  axis.text.y = element_text(size = 18),   # Adjust y-axis text size
  axis.text.x = element_text(size = 12),   # Adjust y-axis text size
  strip.text = element_text(size = 16),     # Adjust facet titles size
  axis.title.x = element_text(size = 16),
  axis.title.y = element_text(size = 18),
  panel.grid = element_blank(),
  plot.title = element_text(hjust = 0.5),
  plot.margin = margin(t = 1, r = 0, b = 2, l = 0.5, unit = "cm"),
  panel.background = element_rect(fill = "white", color = "grey70", size = 1)
)
# 
# new_colors <- c("#5BB8A0", "#8C8AFF", "#FFA500", "#E30B5C")
# 
# darker_colors <- c("#348770", "#4F4D9E", "#BF7F00", "#A50741")

colors <- c("#5BB8A0", "#8C8AFF", "#FFA500", "#E30B5C", "#f15a2eff")
darker_colors <- c("#348770", "#4F4D9E", "#f19e07ff", "#A50741")
colors = c( "#136e60ff", "#3906f6ff")
colors <- c("#8DD3C7", "#FFFFB3", "#BEBADA", "#FB8072", "#80B1D3", "#FDB462", "#B3DE69", "#FCCDE5", "#00008B", "#BC80BD")
colors <- c("#5acfdbff", '#ff5130ff')
#Colors for poster



#### Quality of improvisation ##### 
data_fixed$title1 <- "Improvisational Creativity"
pQ1bI <- ggplot(data_impro, aes(x = C, y = Q1b, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  #geom_boxplot(aes(fill = C), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  geom_boxplot(aes(fill = "white"), width = 0.15, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE, fill = "white") +
  scale_fill_manual(values = c("Individual" = colors[2], "Group" = colors[1])) +
  scale_x_discrete(labels = c("Group" = "Matched", "Individual" = "Unmatched")) +
  labs(x = " (c) Improvised ", y = "", fill = "C") +
  facet_wrap(~ D, ncol = 2) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))

pQ1bI

pQ1bM <- ggplot(data_mixed, aes(x = C, y = Q1b, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  #geom_boxplot(aes(fill = C), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  geom_boxplot(aes(fill = "white"), width = 0.15, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE, fill = "white") +
  scale_fill_manual(values = c("Individual" = colors[2], "Group" = colors[1])) +
  scale_x_discrete(labels = c("Group" = "Matched", "Individual" = "Unmatched")) +
  labs(x = "(b) Mixed", y = "", fill = "C") +
  facet_wrap(~ D, ncol = 2) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))
pQ1bM
# pQ1bF  <-ggplot(data_fixed, aes(x = C, y = Q1b, fill = C)) +
#   geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
#   #geom_boxplot(aes(fill = C), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
#   geom_boxplot(aes(fill = "white"), width = 0.15, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE, fill = "white") +
#   scale_x_discrete(labels = c("Group" = "Gr", "Individual" = "Ind")) +
#   scale_fill_manual(values = c("Neutral" = colors[10])) +
#   labs(x = "(a) Fixed", y = "Subjective rating", fill = "C") +
#   scale_x_discrete(labels = c("Neutral" = "Group")) +
#   facet_wrap(~ D, ncol = 2) +
#   common_theme + 
#   scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))
title1 <- "Improvisational Creativity"
pQ1bF <-ggplot(data_fixed, aes(x = D, y = Q1b, fill = D)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = "white"), width = 0.15, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE, fill = "white") +
  scale_fill_manual(values = c("Dancer" = colors[1],"Musician" = colors[1])) +
  labs(x = "(a) Fixed", y = title1, fill = "D") +
  scale_x_discrete(labels = c("Neutral" = "Matched")) +
  facet_wrap(~ C, labeller = labeller(C = c(Neutral = "Matched")), ncol = 2) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))


grid.arrange(
  # First column with plots p1, p2, and p3
  pQ1bF, pQ1bM, pQ1bI, ncol = 3
  
)

#### Flow ##### 

pQ3I <- ggplot(data_impro, aes(x = C, y = Q3, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  #geom_boxplot(aes(fill = C), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  geom_boxplot(aes(fill = "white"), width = 0.15, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE, fill = "white") +
  scale_fill_manual(values = c("Individual" = colors[2], "Group" = colors[1])) +
  scale_x_discrete(labels = c("Group" = "Matched", "Individual" = "Unmatched")) +
  labs(x = " (c) Improvised ", y = "", fill = "C") +
  facet_wrap(~ D, ncol = 2) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))


pQ3M <- ggplot(data_mixed, aes(x = C, y = Q3, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  #geom_boxplot(aes(fill = C), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  geom_boxplot(aes(fill = "white"), width = 0.15, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE, fill = "white") +
  scale_fill_manual(values = c("Individual" = colors[2], "Group" = colors[1])) +
  scale_x_discrete(labels = c("Group" = "Matched", "Individual" = "Unmatched")) +
  labs(x = "(b) Mixed", y = "", fill = "C") +
  facet_wrap(~ D, ncol = 2) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))


title1 <- "Flow"
pQ3F <-ggplot(data_fixed, aes(x = D, y = Q3, fill = D)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = "white"), width = 0.15, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE, fill = "white") +
  scale_fill_manual(values = c("Dancer" = colors[1],"Musician" = colors[1])) +
  labs(x = "(a) Fixed", y = title1, fill = "D") +
  scale_x_discrete(labels = c("Neutral" = "Matched")) +
  facet_wrap(~ C, labeller = labeller(C = c(Neutral = "Matched")), ncol = 2) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))


grid.arrange(
  # First column with plots p1, p2, and p3
  pQ3F, pQ3M, pQ3I, ncol = 3
  
)


##### Q2a #######
#####Feeling rightly challenged

title1 <- "Feeling rightly challenged"
pQ1bI <- ggplot(data_impro, aes(x = C, y = Q2a, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = C), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  scale_fill_manual(values = c("Individual" = colors[2], "Group" = colors[1])) +
  scale_x_discrete(labels = c("Group" = "Matched", "Individual" = "Unmatched")) +
  labs(x = " (c) Improvised ", y = "", fill = "C") +
  facet_wrap(~ D, ncol = 2) +
  # geom_signif(
  #   comparisons = list(c("Individual", "Group")), 
  #   textsize = textsize_val, 
  #   vjust = vjust_val,
  #   annotations = '',
  #   map_signif_level = TRUE,
  #   show.legend = FALSE) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))

# ann_text <- data.frame(D = "Dancer",Q2a = 7.0,lab = "Text",
#                        C = factor("Individual",levels = c("Individual", "Group")))
# pQ1bI <- pQ1bI + geom_text(x = 1.5, y = 7.1, data = ann_text,label = "", size = 5)
# 
# ann_text <- data.frame(D = "Musician",Q2a = 7.0,lab = "Text",
#                        C = factor("Group",levels = c("Individual", "Group")))
# pQ1bI <- pQ1bI + geom_text(x = 1.5, y = 7.2, data = ann_text,label = "***", size = 6.5)

pQ1bI

pQ1bM <- ggplot(data_mixed, aes(x = C, y = Q2a, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = C), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  scale_fill_manual(values = c("Individual" = colors[2], "Group" = colors[1])) +
  labs(x = "(b) Mixed", y = "", fill = "C") +
  scale_x_discrete(labels = c("Group" = "Matched", "Individual" = "Unmatched")) +
  facet_wrap(~ D, ncol = 2) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))

pQ1bM

pQ1bF <-ggplot(data_fixed, aes(x = D, y = Q2a, fill = D)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = D), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  scale_fill_manual(values = c("Dancer" = colors[1],"Musician" = colors[1])) +
  labs(x = "(a) Fixed", y = title1, fill = "D") +
  scale_x_discrete(labels = c("Neutral" = "Matched")) +
  facet_wrap(~ C, labeller = labeller(C = c(Neutral = "Matched")), ncol = 2) +
  common_theme + 
  scale_y_continuous(limits = c(1, 7 + 1), breaks = seq(1, 7, 1))

library(gridExtra)
grid_arrange <-grid.arrange(
  # First column with plots p1, p2, and p3
  pQ1bF, pQ1bM, pQ1bI, ncol = 3
  
)
