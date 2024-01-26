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
levels(data_test$D)
data_test$B <- factor(data_test$B)
data_test$B <- factor(data_test$B, labels = c("Mixed", "Fixed", "Free"))
data_test$C <- factor(data_test$C)
data_test$C <- factor(data_test$C, labels = c("Individual",'Neutral', 'Group'))

data_test$D <- factor(data_test$D)
data_test$D <- factor(data_test$D, labels = c("Musician",'Dancer'))


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


####
### Plots for paper 3x3 
common_theme <- theme(
  axis.text.y = element_text(size = 10),   # Adjust y-axis text size
  axis.text.x = element_text(size = 10),   # Adjust y-axis text size
  strip.text = element_text(size = 12)     # Adjust facet titles size
  #plot.margin = margin(1, 1, 1, 1, "cm")
) 

textsize_val <- 6
vjust_val <- 1.5



data_test$title2 <- "Quality of Improvisation"
p21 <- ggplot(data_test, aes(x = A, y = Q1b, fill = A)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  scale_fill_manual(values = c("Fixed" = colors[1], "Other" = colors[2])) +
  labs(x = "", y = "Rating", fill = "A")+
  facet_grid(. ~ title2) +
  geom_signif(comparisons = list(c("Fixed", "Other")), 
                                          textsize = textsize_val, 
                                          vjust = vjust_val,
                                          map_signif_level = TRUE,
                                          show.legend = FALSE
                                          ) +
  common_theme 

p21 
# Create the plot grouped by B and filled with only Mixed and Free with boxplot
p22 <- ggplot(data_test[data_test$B != "Fixed", ], aes(x = B, y = Q1b, fill = B)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.15, show.legend = FALSE) +
  scale_fill_manual(values = c("Mixed" = colors[3], "Free" = colors[4])) +
  labs(x = "", y = "", fill = "B")+
  facet_grid(. ~ title2)+
   common_theme + 
  geom_signif(comparisons = list(c("Mixed", "Free")), 
            textsize = textsize_val, 
            vjust = vjust_val,
            map_signif_level = TRUE,
            show.legend = FALSE)

p22

p23 <- ggplot(data_test[data_test$C != "Neutral", ], aes(x = C, y = Q1b, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  scale_fill_manual(values = c("Individual" = colors[5], "Group" = colors[6])) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  labs(x = "", y = "", fill = "C")+
  facet_grid(. ~ title2)+
  geom_signif(comparisons = list(c("Individual", "Group")), 
              textsize = textsize_val, 
              vjust = vjust_val,
              map_signif_level = TRUE,
              show.legend = FALSE) + 
  common_theme
p23

###  Flow
data_test$title41 <- "Flow"
p41 <- ggplot(data_test, aes(x = A, y = Q3, fill = A)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  scale_fill_manual(values = c("Fixed" = colors[1], "Other" = colors[2])) +
  labs(x = "", y = "Rating", fill = "A") +
  facet_grid(. ~ title41)+
  geom_signif(comparisons = list(c("Fixed", "Other")), 
              textsize = textsize_val, 
              vjust = vjust_val,
              map_signif_level = TRUE,
              show.legend = FALSE) + 
  common_theme
p41

# Create the plot grouped by B and filled with only Mixed and Free with boxplot
p42 <- ggplot(data_test[data_test$B != "Fixed", ], aes(x = B, y = Q3, fill = B)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  scale_fill_manual(values = c("Mixed" = colors[3], "Free" = colors[4])) +
  labs(x = "", y = "", fill = "B") +
  facet_grid(. ~ title41) +
  geom_signif(comparisons = list(c("Mixed", "Free")), 
              textsize = textsize_val, 
              vjust = vjust_val,
              map_signif_level = TRUE,
              show.legend = FALSE) + 
  common_theme

p42

p43 <- ggplot(data_test[data_test$C != "Neutral", ], aes(x = C, y = Q3, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  scale_fill_manual(values = c("Individual" = colors[5], "Group" = colors[6])) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  labs(x = "", y = "", fill = "C") +
  facet_grid(. ~ title41) +
  geom_signif(comparisons = list(c("Individual", "Group")), 
              textsize = textsize_val, 
              vjust = vjust_val,
              map_signif_level = TRUE,
              show.legend = FALSE) + 
  common_theme 
p43

data_test$title7 <- "Rhythmic complexity"
p71 <- ggplot(data_test, aes(x = A, y = Q6b, fill = A)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  scale_fill_manual(values = c("Fixed" = colors[1], "Other" = colors[2])) +
  labs(x = "", y = "Rating", fill = "A") +
  facet_grid(. ~ title7) + 
  geom_signif(comparisons = list(c("Fixed", "Other")), 
              textsize = textsize_val, 
              vjust = vjust_val,
              map_signif_level = TRUE,
              show.legend = FALSE,
              annotations = c("**")) + 
  common_theme
p71
# Create the plot grouped by B and filled with only Mixed and Free with boxplot
p72 <- ggplot(data_test[data_test$B != "Fixed", ], aes(x = B, y = Q6b, fill = B)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12,  show.legend = FALSE) +
  scale_fill_manual(values = c("Mixed" = colors[3], "Free" = colors[4])) +
  labs(x = "", y = "", fill = "B")+
  facet_grid(. ~ title7) +
  geom_signif(comparisons = list(c("Mixed", "Free")), 
              textsize = textsize_val, 
              vjust = vjust_val,
              map_signif_level = TRUE,
              show.legend = FALSE,
              annotations = c("***")) +
  common_theme

p72

### Absorption 
data_test$title8 <- "Absorption by activity"
p81 <- ggplot(data_test, aes(x = A, y = Abs_Av, fill = A)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  scale_fill_manual(values = c("Fixed" = colors[1], "Other" = colors[2])) +
  labs(x = "", y = "", fill = "A")+
  facet_grid(. ~ title8) +
  geom_signif(comparisons = list(c("Fixed", "Other")), 
              textsize = textsize_val, 
              vjust = vjust_val,
              map_signif_level = TRUE,
              show.legend = FALSE) +
  common_theme
p81


grid.arrange(
  # First row with plots p11, p13, p15, and p17
  arrangeGrob(p21, p22, p23, ncol = 3),
  # Second row with plots p12,p14,p16, and p18
  arrangeGrob(p41,p42,p43, ncol = 3),
  arrangeGrob(p71,p72,p81, ncol = 3),
  nrow = 3 # Set the number of rows to 2
)


### Interaction Main Paper
data_test$title7 <- "Communication with Partner"
p51 <- ggplot(data_test, aes(x = E, y = Q4a, fill = E)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = E), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  scale_fill_manual(values = c("Tangos" = colors[9], "Solea" = colors[10])) +
  labs(x = "A x E", y = "Q4a - Communication with partner", fill = "E") +
  facet_wrap(~ A, ncol = 2) +
  geom_signif(comparisons = list(c("Tangos", "Solea")), 
              textsize = textsize_val, 
              vjust = vjust_val,
              map_signif_level = TRUE,
              show.legend = FALSE) +
  common_theme

# Print the modified plot
print(p51)




#### Supplementary material - Main effects  
vjust_val_2 = 2.2

# Quantity of improvisation 

p11 <- ggplot(data_test, aes(x = A, y = Q1a, fill = A)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.15, show.legend = FALSE) +
  scale_fill_manual(values = c("Fixed" = colors[1], "Other" = colors[2])) +
  labs(x = "", y = "Rating", fill = "A") +
  facet_grid(. ~ title1) +
  common_theme +
  geom_signif(comparisons = list(c("Fixed", "Other")), 
              textsize = textsize_val, 
              vjust = vjust_val_2,
              map_signif_level = TRUE,
              show.legend = FALSE)

p12 <- ggplot(data_test[data_test$B != "Fixed", ], aes(x = B, y = Q1a, fill = B)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.15, show.legend = FALSE) +
  scale_fill_manual(values = c("Mixed" = colors[3], "Free" = colors[4])) +
  facet_grid(. ~ title1) +
  labs(x = "", y = "", fill = "B") +
  geom_signif(comparisons = list(c("Mixed", "Free")), 
              textsize = textsize_val, 
              vjust = vjust_val_2,
              map_signif_level = TRUE,
              show.legend = FALSE) +
  common_theme

p13 <- ggplot(data_test[data_test$C != "Neutral", ], aes(x = C, y = Q1a, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  scale_fill_manual(values = c("Individual" = colors[5], "Group" = colors[6])) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  facet_grid(. ~ title1) +
  labs(x = "", y = "", fill = "C") +
  geom_signif(comparisons = list(c("Individual", "Group")), 
              textsize = textsize_val, 
              vjust = vjust_val_2,
              map_signif_level = TRUE,
              show.legend = FALSE)+
  common_theme

p13
# 
p14 <- ggplot(data_test, aes(x = D, y = Q1a, fill = D)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.15, show.legend = FALSE) +
  scale_fill_manual(values = c("Musician" = colors[7], "Dancer" = colors[8])) +
  labs(x = "", y = "", fill = "D") +
  facet_grid(. ~ title1) +
  geom_signif(comparisons = list(c("Musician", "Dancer")), 
              textsize = textsize_val, 
              vjust = vjust_val_2,
              map_signif_level = TRUE,
              show.legend = FALSE) +
  common_theme

p14

data_test$title6a <- "Complexity of piece"
p61 <- ggplot(data_test, aes(x = A, y = Q6a, fill = A)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  scale_fill_manual(values = c("Fixed" = colors[1], "Other" = colors[2])) +
  labs(x = "", y = "Rating", fill = "A") +
  facet_grid(. ~ title6a) +
  geom_signif(comparisons = list(c("Fixed", "Other")), 
              textsize = textsize_val, 
              vjust = vjust_val,
              map_signif_level = TRUE,
              show.legend = FALSE,
              annotations = c("**")) +
  common_theme

# Print the modified plot
print(p61)

p62 <- ggplot(data_test[data_test$B != "Fixed", ], aes(x = B, y = Q6a, fill = B)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  scale_fill_manual(values = c("Mixed" = colors[3], "Free" = colors[4])) +
  labs(x = "", y = "", fill = "B") +
  facet_grid(. ~ title6a) +
  geom_signif(comparisons = list(c("Mixed", "Free")), 
              textsize = textsize_val, 
              vjust = vjust_val,
              map_signif_level = TRUE,
              show.legend = FALSE) +
  common_theme

# Print the modified plot
print(p62)

p63 <- ggplot(data_test[data_test$C != "Neutral", ], aes(x = C, y = Q6a, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  scale_fill_manual(values = c("Individual" = colors[5], "Group" = colors[6])) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  labs(x = "", y = "", fill = "C") +
  facet_grid(. ~ title6a) +
  geom_signif(comparisons = list(c("Individual", "Group")), 
              textsize = textsize_val, 
              vjust = vjust_val,
              map_signif_level = TRUE,
              show.legend = FALSE) +
  common_theme

# Print the modified plot
print(p63)

p64 <- ggplot(data_test, aes(x = E, y = Q6a, fill = E)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  scale_fill_manual(values = c("Tangos" = colors[9], "Solea" = colors[10])) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  labs(x = "", y = "", fill = "E") +
  facet_grid(. ~ title6a) +
  geom_signif(comparisons = list(c("Tangos", "Solea")), 
              textsize = textsize_val, 
              vjust = vjust_val,
              map_signif_level = TRUE,
              show.legend = FALSE) +
  common_theme

# Print the modified plot
print(p64)


data_test$title9 <- "Fluency of Performance"
p91 <- ggplot(data_test[data_test$C != "Neutral", ], aes(x = C, y = Perf_Av, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  scale_fill_manual(values = c("Individual" = colors[5], "Group" = colors[6])) +
  labs(x = "", y = "", fill = "C") +
  facet_grid(. ~ title9) +
  geom_signif(comparisons = list(c("Individual", "Group")), 
              textsize = textsize_val, 
              vjust = vjust_val,
              map_signif_level = TRUE,
              show.legend = FALSE,
              annotations = c("**")) +
  common_theme

# Plot p92

p92 <- ggplot(data_test, aes(x = E, y = Perf_Av, fill = E)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  scale_fill_manual(values = c("Tangos" = colors[9], "Solea" = colors[10])) +
  labs(x = "", y = "Rating", fill = "E") +
  facet_grid(. ~ title9) +
  geom_signif(comparisons = list(c("Tangos", "Solea")), 
              textsize = textsize_val, 
              vjust = vjust_val,
              map_signif_level = TRUE,
              show.legend = FALSE) +
  common_theme

# Print the plots
print(p91)
print(p92)

data_test$title10a <- "Feeling rightly challenged"
p101 <- ggplot(data_test, aes(x = A, y = Q2a, fill = A)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  scale_fill_manual(values = c("Fixed" = colors[1], "Other" = colors[2])) +
  labs(x = "", y = "Rating", fill = "A") +
  facet_grid(. ~ title10a) +
  geom_signif(comparisons = list(c("Fixed", "Other")), 
              textsize = textsize_val, 
              vjust = vjust_val,
              map_signif_level = TRUE,
              show.legend = FALSE) +
  common_theme

# Print the modified plot
print(p101)


p103 <- ggplot(data_test[data_test$C != "Neutral", ], aes(x = C, y = Q2a, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  scale_fill_manual(values = c("Individual" = colors[5], "Group" = colors[6])) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  labs(x = "", y = "", fill = "C") +
  facet_grid(. ~ title10a) +
  geom_signif(comparisons = list(c("Individual", "Group")), 
              textsize = textsize_val, 
              vjust = vjust_val,
              map_signif_level = TRUE,
              show.legend = FALSE,
              annotations = c("**")) +
  common_theme

# Print the modified plot
print(p103)
# Print the modified plot
print(p62)


grid.arrange(
  # First row with plots p11, p13, p15, and p17
  arrangeGrob(p11, p13, p12, ncol = 3),
  # Second row with plots p12,p14,p16, and p18
  arrangeGrob(p61,p63,p62, ncol = 3),
  arrangeGrob(p101,p103,p64, ncol = 3),
  arrangeGrob(p92,p91,p14, ncol = 3),
  nrow = 4 # Set the number of rows to 2
)






#### ALL PLOTS from Results
# Quantity of imporviation
# Create the plot grouped and filled by A with boxplot
data_test$title1 <- "Quantity of Improvisation"
p11 <- ggplot(data_test, aes(x = A, y = Q1a, fill = A)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.15, show.legend = FALSE) +
  scale_fill_manual(values = c("Fixed" = colors[1], "Other" = colors[2])) +
  labs(x = "A", y = "Rating", fill = "A") +
  facet_grid(. ~ title1)


p11
# Create the plot grouped by B and filled with only Mixed and Free with boxplot
p12 <- ggplot(data_test[data_test$B != "Fixed", ], aes(x = B, y = Q1a, fill = B)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.15,  show.legend = FALSE,) +
  scale_fill_manual(values = c("Mixed" = colors[3], "Free" = colors[4])) +
  labs(x = "B", y = "Rating", fill = "B") +
  facet_grid(. ~ title1)

p13 <- ggplot(data_test[data_test$C != "Neutral", ], aes(x = C, y = Q1a, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  scale_fill_manual(values = c("Individual" = colors[5], "Group" = colors[6])) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12,  show.legend = FALSE,) +
  labs(x = "C", y = "Rating", fill = "C") +
  facet_grid(. ~ title1)

p14 <-  ggplot(data_test, aes(x = D, y = Q1a, fill = D)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.15,  show.legend = FALSE,) +
  scale_fill_manual(values = c("Musician" = colors[7], "Dancer" = colors[8])) +
  labs(x = "D", y = "Rating", fill = "D") +
  facet_grid(. ~ title1)

#data_test$groupAD <- interaction(data_test$A, data_test$D)

p15 <- ggplot(data_test, aes(x = D, y = Q1a, fill = D)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = D), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9),  show.legend = FALSE) +
  scale_fill_manual(values = c("Musician" = colors[7], "Dancer" = colors[8])) +
  labs(x = "A x D - Quantity of Improvisation", y = "Rating", fill = "D") +
  facet_wrap(~ A, ncol = 2)  


data_test$groupDC <- interaction(data_test$C, data_test$D)

  
p16 <- ggplot(data_test[data_test$C != "Neutral", ], aes(x = D, y = Q1a, fill = D)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9) ) +
  geom_boxplot(aes(fill = D), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  scale_fill_manual(values = c("Musician" = colors[7], "Dancer" = colors[8])) +
  labs(x = "C x D - Quantity of Improvisation", y = "Rating", fill = "D") +
  facet_wrap(~ C, ncol = 2) 


grid.arrange(
  # First column with plots p1, p2, and p3
  arrangeGrob(p11, p13, p15, ncol = 1),
  # Second column with plots p4, p5, and p6
  arrangeGrob(p12,p14,p16, ncol = 1),
  ncol = 2
)





### Quality of improv
data_test$title2 <- "Quality of Improvisation"
p21 <- ggplot(data_test, aes(x = A, y = Q1b, fill = A)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  scale_fill_manual(values = c("Fixed" = colors[1], "Other" = colors[2])) +
  labs(x = "A", y = "Rating", fill = "A")+
  facet_grid(. ~ title2)

# Create the plot grouped by B and filled with only Mixed and Free with boxplot
p22 <- ggplot(data_test[data_test$B != "Fixed", ], aes(x = B, y = Q1b, fill = B)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.15, show.legend = FALSE) +
  scale_fill_manual(values = c("Mixed" = colors[3], "Free" = colors[4])) +
  labs(x = "B", y = "Rating", fill = "B")+
  facet_grid(. ~ title2)

p23 <- ggplot(data_test[data_test$C != "Neutral", ], aes(x = C, y = Q1b, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  scale_fill_manual(values = c("Individual" = colors[5], "Group" = colors[6])) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  labs(x = "C", y = "Rating", fill = "C")+
  facet_grid(. ~ title2)


data_test$groupDC <- interaction(data_test$C, data_test$D)
p24 <- ggplot(data_test[data_test$C != "Neutral", ], aes(x = D, y = Q1b, fill = D)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = D), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  scale_fill_manual(values = c("Musician" = colors[7], "Dancer" = colors[8])) +
  labs(x = "C x D - Quality of Improvisation", y = "Rating", fill = "D") +
  facet_wrap(~ C, ncol = 2)


p24


grid.arrange(
  # First column with plots p1, p2, and p3
  arrangeGrob(p21, p23, ncol = 1),
  # Second column with plots p4, p5, and p6
  arrangeGrob(p22,p24, ncol = 1),
  ncol = 2
)






### Quantity of Flow
data_test$title3 <- "Quantity of flow"
p31 <- ggplot(data_test, aes(x = A, y = Q3a, fill = A)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  scale_fill_manual(values = c("Fixed" = colors[1], "Other" = colors[2])) +
  labs(x = "A", y = "Rating", fill = "A")+
  facet_grid(. ~ title3)

# Create the plot grouped by B and filled with only Mixed and Free with boxplot
p32 <- ggplot(data_test[data_test$B != "Fixed", ], aes(x = B, y = Q3a, fill = B)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  scale_fill_manual(values = c("Mixed" = colors[3], "Free" = colors[4])) +
  labs(x = "B", y = "Rating", fill = "B")+
  facet_grid(. ~ title3)

p33 <- ggplot(data_test[data_test$C != "Neutral", ], aes(x = C, y = Q3a, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  scale_fill_manual(values = c("Individual" = colors[5], "Group" = colors[6])) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  labs(x = "C", y = "Rating", fill = "C") +
  facet_grid(. ~ title3)


grid.arrange(
  # First column with plots p1, p2, and p3
  arrangeGrob(p31, p32, p33, ncol = 3)
  # Second column with plots p4, p5, and p6
)


### Intensity of Flow
data_test$title41 <- "Flow intensity"
p41 <- ggplot(data_test, aes(x = A, y = Q3b, fill = A)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  scale_fill_manual(values = c("Fixed" = colors[1], "Other" = colors[2])) +
  labs(x = "A", y = "Rating", fill = "A") +
  facet_grid(. ~ title41)

# Create the plot grouped by B and filled with only Mixed and Free with boxplot
p42 <- ggplot(data_test[data_test$B != "Fixed", ], aes(x = B, y = Q3b, fill = B)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  scale_fill_manual(values = c("Mixed" = colors[3], "Free" = colors[4])) +
  labs(x = "B", y = "Rating", fill = "B") +
  facet_grid(. ~ title41)


p43 <- ggplot(data_test[data_test$C != "Neutral", ], aes(x = C, y = Q3b, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  scale_fill_manual(values = c("Individual" = colors[5], "Group" = colors[6])) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  labs(x = "C", y = "Rating", fill = "C") +
  facet_grid(. ~ title41)


grid.arrange(
  # First column with plots p1, p2, and p3
  arrangeGrob(p41, p42, p43, ncol = 3)
  # Second column with plots p4, p5, and p6
)


grid.arrange(
  # First row with plots p11, p13, p15, and p17
  arrangeGrob(p11, p21, p31, p41, ncol = 4),
  # Second row with plots p12,p14,p16, and p18
  arrangeGrob(p12,p22,p32, p42, ncol = 4),
  arrangeGrob(p13,p23,p33, p43, ncol = 4),
  arrangeGrob(p14,p15,p16, p24, ncol = 4),
  nrow = 4 # Set the number of rows to 2
)





### Communication with partner

data_test$groupEA <- interaction(data_test$A, data_test$E)
p51 <- ggplot(data_test, aes(x = E, y = Q4a, fill = E)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = E), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  scale_fill_manual(values = c("Tangos" = colors[9], "Solea" = colors[10])) +
  labs(x = "A x E", y = "Q4a - Communication with partner", fill = "E") +
  facet_wrap(~ A, ncol = 2) 
p51



grid.arrange(
  # First column with plots p1, p2, and p3
  arrangeGrob(p1, ncol = 1)
  # Second column with plots p4, p5, and p6
)




### Q6a Complexity of piece
data_test$title6a <- "Complexity of piece"
p61 <- ggplot(data_test, aes(x = A, y = Q6a, fill = A)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  scale_fill_manual(values = c("Fixed" = colors[1], "Other" = colors[2])) +
  labs(x = "A", y = "Rating", fill = "A")  +
  facet_grid(. ~ title6a)
p61

# Create the plot grouped by B and filled with only Mixed and Free with boxplot
p62 <- ggplot(data_test[data_test$B != "Fixed", ], aes(x = B, y = Q6a, fill = B)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  scale_fill_manual(values = c("Mixed" = colors[3], "Free" = colors[4])) +
  labs(x = "B", y = "Rating", fill = "B") +
  facet_grid(. ~ title6a)
p62

p63 <- ggplot(data_test[data_test$C != "Neutral", ], aes(x = C, y = Q6a, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  scale_fill_manual(values = c("Individual" = colors[5], "Group" = colors[6])) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  labs(x = "C", y = "Rating", fill = "C") +
  facet_grid(. ~ title6a)
p63

p64 <- ggplot(data_test, aes(x = E, y = Q6a, fill = E)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  scale_fill_manual(values = c("Tangos" = colors[9], "Solea" = colors[10])) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  labs(x = "E", y = "", fill = "E") +
  facet_grid(. ~ title6a)

p64

data_test$groupDC <- interaction(data_test$C, data_test$D)
p65 <- ggplot(data_test[data_test$C != "Neutral", ], aes(x = D, y = Q6a, fill = D)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = D), width = 0.12, outlier.shape = NA, alpha = alpha_val, show.legend = FALSE,position = position_dodge(width = 0.9)) +
  scale_fill_manual(values = c("Musician" = colors[7], "Dancer" = colors[8])) +
  labs(x = "C x D", y = "Complexity of piece", fill = "D") +
  facet_wrap(~ C, ncol = 2) 
p65






### Q6b Rhythmic complexity
data_test$title7 <- "Rhythmic complexity"
p71 <- ggplot(data_test, aes(x = A, y = Q6b, fill = A)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  scale_fill_manual(values = c("Fixed" = colors[1], "Other" = colors[2])) +
  labs(x = "A", y = "Rating", fill = "A") +
  facet_grid(. ~ title7)
p71
# Create the plot grouped by B and filled with only Mixed and Free with boxplot
p72 <- ggplot(data_test[data_test$B != "Fixed", ], aes(x = B, y = Q6b, fill = B)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12,  show.legend = FALSE) +
  scale_fill_manual(values = c("Mixed" = colors[3], "Free" = colors[4])) +
  labs(x = "B", y = "Rating", fill = "B")+
  facet_grid(. ~ title7)
p72

grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2, ncol = 2

)


### Absorption 
data_test$title8 <- "Absorption of activity"
p81 <- ggplot(data_test, aes(x = A, y = Abs_Av, fill = A)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
  scale_fill_manual(values = c("Fixed" = colors[1], "Other" = colors[2])) +
  labs(x = "A", y = "Rating", fill = "A")+
  facet_grid(. ~ title8)
p81
# p82 <- ggplot(data_test, aes(x = D, y = Abs_Av, fill = D)) +
#   geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
#   geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12, show.legend = FALSE) +
#   scale_fill_manual(values = c("Fixed" = colors[1], "Other" = colors[2])) +
#   labs(x = "D", y = "Rating", fill = "D")+
#   facet_grid(. ~ title8)
# p82

data_test$groupBD <- interaction(data_test$B, data_test$D)
p82 <- ggplot(data_test[data_test$B != "Fixed", ], aes(x = D, y = Abs_Av, fill = D)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE, position = position_dodge(width = 0.9)) +
  geom_boxplot(aes(fill = D), width = 0.12, outlier.shape = NA, alpha = alpha_val, position = position_dodge(width = 0.9), show.legend = FALSE) +
  scale_fill_manual(values = c("Musician" = colors[7], "Dancer" = colors[8])) +
  labs(x = "B x D", y = "Absorption of activity", fill = "D") +
  facet_wrap(~ B, ncol = 2) 
p82


# grid.arrange(
#   # First column with plots p1, p2, and p3
#   arrangeGrob(p1, p2, ncol = 1),
#   # Second column with plots p4, p5, and p6
#   arrangeGrob(p3, ncol = 1),
#   ncol = 2
# )

grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2, ncol = 2
  
)


### Fluency of performance
data_test$title9 <- "Fluency of performance"
p91 <- ggplot(data_test[data_test$C != "Neutral", ], aes(x = C, y = Perf_Av, fill = C)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12,  show.legend = FALSE) +
  scale_fill_manual(values = c("Individual" = colors[5], "Group" = colors[6])) +
  labs(x = "C", y = "Rating", fill = "C")+
  facet_grid(. ~ title9)
p91
# Create the plot grouped by B and filled with only Mixed and Free with boxplot
p92 <- ggplot(data_test, aes(x = E, y = Perf_Av, fill = E)) +
  geom_violin(alpha = alpha_val, scale = "count", show.legend = FALSE) +
  geom_boxplot(outlier.shape = NA, alpha = alpha_val, width = 0.12,  show.legend = FALSE) +
  scale_fill_manual(values = c("Tangos" = colors[9], "Solea" = colors[10])) +
  labs(x = "E", y = "Rating", fill = "E")+
  facet_grid(. ~ title9)
p92

grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2, ncol = 2
  
)


grid.arrange(
  # First row with plots p11, p13, p15, and p17
  arrangeGrob(p61, p71, p81, ncol = 3),
  # Second row with plots p12,p14,p16, and p18
  arrangeGrob(p62,p72,p91, ncol = 3),
  arrangeGrob(p63,p64,p92, ncol = 3),
  arrangeGrob(p65, p82, p51, ncol = 3),
  nrow = 4 # Set the number of rows to 2
)


grid.arrange(
  # First row with plots p11, p13, p15, and p17
  arrangeGrob(p61, p71, p81, ncol = 3),
  # Second row with plots p12,p14,p16, and p18
  arrangeGrob(p62,p72,p91, ncol = 3),
  arrangeGrob(p63,p64,p92, ncol = 3),
  arrangeGrob(p65, p82, p51, ncol = 3),
  nrow = 4 # Set the number of rows to 2
)


grid.arrange(
  # First row with plots p11, p13, p15, and p17
  arrangeGrob(p61, p71, p81, p82, ncol = 4),
  # Second row with plots p12,p14,p16, and p18
  arrangeGrob(p62,p72,p91,p92, ncol = 4),
  arrangeGrob(p63, p64, p65, p51, ncol = 4),
  nrow = 3 # Set the number of rows to 2
)


grid.arrange(
  # First row with plots p11, p13, p15, and p17
  arrangeGrob(p61, p71, p81, p82, ncol = 4),
  # Second row with plots p12,p14,p16, and p18
  arrangeGrob(p62,p72,p91,p63, ncol = 4),
  arrangeGrob(p64, p92, p51,p65, ncol = 4),
  nrow = 3 # Set the number of rows to 2
)



##### Correlation plot 

library(corrplot)
library(symnum)
library(psych)

# Select columns of interest
plot.new()
corr_mat <- data_ole[, c("Q1a", "Q1b", "Q3a", "Q3b")]


# Compute correlation matrix
M <- cor(corr_mat, use = 'complete.obs', method='spearman')


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


### Bonferroni corrected.

# Define the variables for correlation
corr_vars <- c("Q1a", "Q1b", "Q3a", "Q3b", "Q4a", "Q4b", "Q4c", "Q5a", "Q5b","Q6a", "Q6b", "Abs_Av", "Perf_Av", 'GDSI','GMSI')
corr_vars <- c("Q1b", "Q3b", "Q4a", "Q6a","Q6b", "Abs_Av", 'GDSI')

# Subset the data for correlation
corr_mat <- data_ole[, corr_vars]

# Compute correlation matrix
M <- cor(corr_mat, use = 'complete.obs', method = 'spearman')

# Bonferroni correction on p-values
p_values <- corr.test(corr_mat, method = "spearman", adjust = "bonferroni")$p

# Define the name for the plot
name_plot <- "data_ole"

# Plot correlation matrix with Bonferroni-corrected p-values
corrplot(M, order = "AOE", tl.col = "black", tl.srt = 45,
         p.mat = p_values,
         insig = 'label_sig',
         addCoef.col = "white",
         sig.level = c(.001, .01, .05),
         pch.cex = 1.8, pch.col = 'red',
         #addCoef.col = "white",
         title = paste('Correlation Plot (', name_plot, ')'),
         cex.main = 1.8,
         mar = c(0, 0, 2, 0))




#### Between variables

plot.new()

name_plot <- 'Quantity & Quality of Improvisation'
corr_vars <- c("Q1a", "Q1b", 'Q1')


name_plot <- 'Quantity & Quality of Flow'
corr_vars <- c("Q3a", "Q3b", "Q3")


name_plot <- 'Communication & Coordination'
corr_vars <- c("Q4a", "Q4b", "Q4c", "Q4")

name_plot <- 'Timing & Rhythmic originality'
corr_vars <- c("Q5a", "Q5b", "Q5")

name_plot <- 'Complexity of Performance & Rhythm'
corr_vars <- c("Q6a", "Q6b", "Q6")

name_plot <- 'Quality'
corr_vars <- c("Q1b", "Q5b", "Q5a", "Q4b")
name_plot <- 'Quality & Complexity'
corr_vars <- c("Q1b", "Q6a", "Q6b")


name_plot <- 'Coordination and in tune'
corr_vars <- c("Q4b", "Q5a")

corr_vars <- c("Q3","Q2a", "Q2b", "Q2c", "Q2d", "Q2e", "Q2f", "Q2g", 'Q2h', "Q2i", "Q2j")



# Subset the data for correlation
corr_mat <- data_ole[, corr_vars]

# Compute correlation matrix
M <- cor(corr_mat, use = 'complete.obs', method = 'spearman')

# Bonferroni correction on p-values
p_values <- corr.test(corr_mat, method = "spearman", adjust = "bonferroni")$p

# Define the name for the plot

# Plot correlation matrix with Bonferroni-corrected p-values
corrplot(M, order = "AOE", tl.col = "black", tl.srt = 45,
         p.mat = p_values,
         insig = 'label_sig',
         addCoef.col = "white",
         sig.level = c(.001, .01, .05),
         pch.cex = 0.1, pch.col = 'red',
         #addCoef.col = "white",
         title = paste( name_plot),
         cex.main = 1.8,
         mar = c(6, 6, 6, 6))






