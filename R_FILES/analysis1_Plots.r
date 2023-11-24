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


data <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/22_Sep_2023_niels/27102023_ELAN_no_CDRS_onset_niels_4s_final.csv')

##### ATILLA CODE ADJUSTED######

data_ole <- data %>%
  distinct(Name, Artist, .keep_all = TRUE)

data_ole$instruction_2 <- as.factor(data_ole$instruction_2)
data_ole$instruction_2 <-factor(data_ole$instruction_2, levels = c("D5_M6_P_R1", "D5_M6_G_R1",  "D1_M6_P_R1", "D1_M6_G_R1","D6_M6_P_R1", "D6_M6_G_R1",  "D5_M5_P_R1", "D5_M5_G_R1","D1_M1_P_R1", "D1_M1_G_R1",
                                                                   "D5_M6_P_R2", "D5_M6_G_R2",  "D1_M6_P_R2", "D1_M6_G_R2","D6_M6_P_R2", "D6_M6_G_R2",  "D5_M5_P_R2", "D5_M5_G_R2","D1_M1_P_R2", "D1_M1_G_R2"
))


#####  Create violinplots

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
levels(data_test$B)
data_test$B <- factor(data_test$B)
data_test$B <- factor(data_test$B, labels = c("Mixed", "Fixed", "Free"))



# Create the violin plot
# Create the violin plot
ggplot(data_test, aes(x = A, y = Q1a, fill = A)) +
  geom_violin() +
  scale_fill_manual(values = c("Other" = "#1F77B4", "Fixed" = "#FF7F0E")) +
  labs(x = "A", y = "Q1a", fill = "A")



# Load the required library
library(gridExtra)

# Create the plot grouped and filled by A
p1 <- ggplot(data_test, aes(x = A, y = Q1a, fill = A)) +
  geom_violin() +
  scale_fill_manual(values = c("Other" = "#1F77B4", "Fixed" = "#FF7F0E")) +
  labs(x = "A", y = "Q1a", fill = "A")

# Create the plot grouped by B and filled with only Mixed and Free
p2 <- ggplot(data_test[data_test$B != "Fixed", ], aes(x = B, y = Q1a, fill = B)) +
  geom_violin() +
  scale_fill_manual(values = c("Mixed" = "#1F77B4", "Free" = "#2CA02C")) +
  labs(x = "B", y = "Q1a", fill = "B")

# Combine the plots into a single figure
grid.arrange(p1, p2, ncol = 2)


# Load the required libraries
library(gridExtra)
library(ggplot2)

# Set the alpha transparency value for the violins to 0.5
alpha_val <- 0.5

# Create the plot grouped and filled by A with boxplot
p1 <- ggplot(data_test, aes(x = A, y = Q1a, fill = A)) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.2) +
  geom_violin(alpha = alpha_val, position = position_nudge(x = 0.25), scale = "count", show.legend = FALSE) +
  scale_fill_manual(values = c("Other" = "#1F77B4", "Fixed" = "#FF7F0E")) +
  labs(x = "A", y = "Q1a", fill = "A")

# Create the plot grouped by B and filled with only Mixed and Free with boxplot
p2 <- ggplot(data_test[data_test$B != "Fixed", ], aes(x = B, y = Q1a, fill = B)) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.2) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  scale_fill_manual(values = c("Mixed" = "#1F77B4", "Free" = "#2CA02C")) +
  labs(x = "B", y = "Q1a", fill = "B")

# Combine the plots into a single figure
grid.arrange(p1, p2, ncol = 2)


# Create the plot grouped and filled by A with boxplot
p1 <- ggplot(data_test, aes(x = A, y = Q1a, fill = A)) +
  geom_violin(alpha = alpha_val, position = position_nudge(x = 0.5), scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.2, position = position_nudge(x = 0.5)) +
  scale_fill_manual(values = c("Other" = "#1F77B4", "Fixed" = "#FF7F0E")) +
  labs(x = "A", y = "Q1a", fill = "A")

# Create the plot grouped by B and filled with only Mixed and Free with boxplot
p2 <- ggplot(data_test[data_test$B != "Fixed", ], aes(x = B, y = Q1a, fill = B)) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.2) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  scale_fill_manual(values = c("Mixed" = "#1F77B4", "Free" = "#2CA02C")) +
  labs(x = "B", y = "Q1a", fill = "B")

# Combine the plots into a single figure
grid.arrange(p1, p2, ncol = 2)








