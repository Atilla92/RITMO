library(lme4)
library(lmerTest)
#load("~/RITMO/Mixed_Models/mixed-models-with-r-workshop-2019-master/data/gpa.RData")
data1 <- read.csv("~/Ritmo/R_FILES/DuringExperiments_Edited.csv", header=TRUE, stringsAsFactors=FALSE)
data2 <- read.csv("~/CODE/RITMO/PILOT_SEV_APRIL_2022/output/Ratings_Entropy.csv")
data3 <- read.csv("~/CODE/RITMO/PILOT_SEV_APRIL_2022/output/ratingsAnalysis/DuringExperiments_Oslo.csv")
data4 <- read.csv('~/CODE/RITMO/MIR/output/Average_rms_ent.csv')
data5 <- read.csv("~/CODE/RITMO/PILOT_SEV_APRIL_2022/output/ratingsAnalysis/DuringExperiments_Edited.csv")

#data 03102022
#data6 <- read.csv("~/CODE/RITMO/PILOT_SEV_APRIL_2022/output/ratingsAnalysis/DuringExperiments_Sevilla_October_2022.csv")
#data7 <- read.csv("~/CODE/RITMO/PILOT_SEV_APRIL_2022/output/ratingsAnalysis/DuringExperiments_Sevilla_October_2022_DropW.csv")

#data 06102022
data6 <- read.csv("~/CODE/RITMO/PILOT_SEV_APRIL_2022/output/ratingsAnalysis/DuringExperiments_Sevilla_October_2022.csv")
data7 <- read.csv("~/CODE/RITMO/PILOT_SEV_APRIL_2022/output/ratingsAnalysis/DuringExperiments_Sevilla_October_2022_DropW.csv")

dataSub <- subset(data3, Dance_mode!="D0")
#dataEntropy <- read.csv("~/CODE/RITMO/ENTROPY/output/mean/means.csv")

# Linear model
#gpa_lm = lm(gpa ~ occasion, data = gpa)
#summary(gpa_lm)

#data_lm = lm(Q1a ~ Dance, data = data1)
#summary(data_lm)


# Mixed model
#gpa_mixed = lmer(gpa ~ occasion + (1 | student), data = gpa)
#summary(gpa_mixed)
#confint(gpa_mixed)
data1$Dance_mode<-as.factor(data1$Dance_mode)
data1$Palo <-as.factor(data1$Palo)
data_mixed = lmer(Q1a ~ Dance_mode + (1 | Participant), data = data1)
#data_mixed = lmer(Q1a ~ Q3a + (1 | Participant),  data = data1)
summary(data_mixed)


#data2$Value<- as.factor(data2$Value)
data2$Dance_mode<- as.factor(data2$Dance_mode)
data2$Palo <- as.factor(data2$Palo)
data2$Participant <- as.factor(data2$Participant)
data_mixed_2 = lmer(Q1b ~ Palo + (1 | Participant),  data = data2)
summary(data_mixed_2)


#Dataset 3 Analysis
data3$Dance_mode<- as.factor(data3$Dance_mode)
data3$Palo <- as.factor(data3$Palo)
data3$Dance_mode <- relevel(data3$Dance_mode, "D6")
data3$Palo <- relevel(data3$Palo, "R2")
data3$Participant <- as.factor(data3$Participant)
data_mixed_3 = lmer(Q1b~ Dance_mode    +   (1 | Participant),  data = data3)
data_mixed_3b = lmer(Q1b  ~ Dance_mode + Palo   + (1 | Participant),  data = data3)
data_mixed_3c = lmer(Q1b  ~ Dance_mode * Palo   + (1 | Participant),  data = data3)
AIC(data_mixed_3,data_mixed_3b)
summary(data_mixed_3)
summary(data_mixed_3b)
summary(data_mixed_3c)


### Latest version of Data ALL
data6$Dance_mode<- as.factor(data6$Dance_mode)
data6$Palo <- as.factor(data6$Palo)
data6$Dance_mode <- relevel(data6$Dance_mode, "D6")
data6$Palo <- relevel(data6$Palo, "R2")
data6$Participant <- as.factor(data6$Participant)
data_mixed_6 = lmer(Q1b~ Dance_mode    +   (1 | Participant),  data = data6)
summary(data_mixed_6)
data_mixed_6b = lmer(Q1b  ~ Dance_mode + Palo   + (1 | Participant),  data = data6)
data_mixed_6c = lmer(Q1b  ~ Dance_mode * Palo   + (1 | Participant),  data = data6)
AIC(data_mixed_6,data_mixed_6b)
summary(data_mixed_6b)
summary(data_mixed_6c)


### Latest version of Data without W
data7$Dance_mode<- as.factor(data7$Dance_mode)
data7$Palo <- as.factor(data7$Palo)
data7$Dance_mode <- relevel(data7$Dance_mode, "D6")
data7$Palo <- relevel(data7$Palo, "R2")
data7$Participant <- as.factor(data7$Participant)
data_mixed_7 = lmer(Q1a~ Dance_mode + Q3b    +   (1 | Participant),  data = data7)
summary(data_mixed_7)
data_mixed_7b = lmer(Q1b  ~ Dance_mode + Palo   + (1 | Participant),  data = data7)
data_mixed_7c = lmer(Q1b  ~ Dance_mode * Palo   + (1 | Participant),  data = data7)
AIC(data_mixed_7,data_mixed_7b)
summary(data_mixed_7b)
summary(data_mixed_7c)


### Entropy data simple analysis mean
dataEntropy <- read.csv("/Users/atillajv/CODE/RITMO/FILES/Subjective/DuringExperiments_Sevilla_06102022_DropW_Entropy.csv")
dataEntropy$Dance_mode <- as.factor(dataEntropy$Dance_mode)
dataEntropy$Palo <- as.factor(dataEntropy$Palo)
dataEntropy$Q3bF <- as.factor(dataEntropy$Q3b)
dataEntropy$Music_mode <- as.factor(dataEntropy$Music_mode)
dataEntropy$Dance_mode <- relevel(dataEntropy$Dance_mode, "D6")
dataEntropy$Music_mode <- relevel(dataEntropy$Music_mode, "M6")
dataEntropy$Participant <- as.factor(dataEntropy$Participant)
model_entropy = lmer(Q1a ~ Q3b + (1 + Q3b | Participant) , data = dataEntropy )
summary(model_entropy)
model_entropy_2 = lmer(Q1a ~ Q3a + I(Q3b^2) + (1 | Participant), data = dataEntropy)

summary(model_entropy_2)
model_entropy_mixed = lmer(Q1a ~ Dance_mode  + Abs_Av + (1 | Participant), data = dataEntropy )
AIC(model_entropy,model_entropy_2)
summary(model_entropy_mixed)



### Entropy data simple analysis mean
#dataELAN <- read.csv("~/CODE/RITMO/ENTROPY/output/main/28_Nov_2022/Entropy_095_Subjective.csv")

#dataELAN <- read.csv("~/CODE/RITMO/ENTROPY/output/main/28_Nov_2022/13122022_095_2s.csv")
#dataELAN <- read.csv("~/CODE/RITMO/ENTROPY/output/main/17_Dec_2022/17122022_095_2s.csv")
dataELAN <- read.csv("~/CODE/RITMO/ENTROPY/output/main/29_Dec_2022/29122022_095_2s.csv")
dataELAN <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/05_Jan_2023_095/03012023_095_2s_16.csv')
dataELAN <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/05_Jan_2023_095/03012023_095_2s_16_condition.csv')
dataELAN <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/05_Jan_2023_095/03012023_095_2s_16_condition_Filtered_2.csv')
#dataELAN <- read.csv("~/CODE/RITMO/ENTROPY/output/main/29_Nov_2022_075/Entropy_075.csv")


#Latest dataset
#MACRO
dataELAN <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/mean/macroDataset_05_Jan_2023_095.csv')
#MICRO
dataELAN <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/05_Jan_2023_095/13022023_095_pairs_2s_32.csv')
#SEPARATED
dataELAN <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/30032023_095_guitar/30032023_095_32_guitar.csv')
# LAUSANNE
dataELAN <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/all_experiments_095/18042023_all_experiments_drums_guitar_zd.csv')

# ALl analysis
dataELAN$Dance_mode <- as.factor(dataELAN$Dance_mode)
dataELAN$Condition <- as.factor(dataELAN$Condition)
dataELAN$Condition <- relevel(dataELAN$Condition, "D6_M6")
dataELAN$Dance_mode <- factor(dataELAN$Dance_mode, levels = c("D6", 'D5', 'D1'))
dataELAN$Condition <- factor(dataELAN$Condition, levels = c('D6_M6', 'D5_M6', 'D1_M6', 'D5_M5', 'D1_M1'))
#dataELAN$Condition_order <- as.factor(dataELAN$Condition_order)
dataELAN$Palo <- as.factor(dataELAN$Palo)
dataELAN$Music_mode <- as.factor(dataELAN$Music_mode)
dataELAN$Music_mode <- factor(dataELAN$Music_mode, levels = c("M6",'M5','M1'))
dataELAN$Participant <- as.factor(dataELAN$Participant)
dataELAN$Pair <- as.factor(dataELAN$Pair)

#Micro Analysis
dataELAN$Baile <- as.factor(dataELAN$Baile_Level)
dataELAN$Guitarra <- as.factor(dataELAN$Guitarra_Level)
dataELAN$Guitarra <- relevel(dataELAN$Guitarra, "A1")
dataELAN$Baile <- relevel(dataELAN$Baile, "Z1")
dataELAN$Dance_Imp <- as.factor(dataELAN$Dance_Imp)
dataELAN$Dance_Imp <- relevel(dataELAN$Dance_Imp, "DC")
dataELAN$Music_Imp <- as.factor(dataELAN$Music_Imp)
dataELAN$Music_Imp <- relevel(dataELAN$Music_Imp, "MC")
dataELAN$ImpLevel <- as.factor(dataELAN$Assigned_Cat)
dataELAN$Step <- as.factor(dataELAN$Step)


#Grep subset of data
dataELAN_I <- dataELAN[!grepl("DC", dataELAN$Dance_Imp),]
dataELAN_P <- dataELAN[!grepl("G", dataELAN$Participant),] #only dancers
dataELAN_G <- dataELAN[!grepl("P", dataELAN$Participant),] #only dancers
# Model Micro
model_entropy_micro = lmer(p_LZ ~ Flow_subj + (1 | Participant) + (1 |Pair/Step) , data = dataELAN)
summary(model_entropy_micro)


#Model Macro
model_entropy  = lmer(LZ_avg ~  Q3b + (1 | Participant)  , data = dataELAN ) #this performs better
model_entropy_1  = lmer(LZ_avg ~  Q3b + (1 | Participant) + (1 | Pair)  , data = dataELAN ) #this performs better
#model_entropy_2  = lmer(Q1b ~ MIR_novelty_avg   + (1 | Pair/Participant)  , data = dataELAN )
#model_entropy_3 = lmer(Q1b ~ Q3b + (1 | Pair)  , data = dataELAN )
summary(model_entropy)
summary(model_entropy_1)
anova(model_entropy, model_entropy_1)

model_entropy_2  = lmer(LZ ~ Flow_subj + (1 | Pair/Participant)  , data = dataELAN )
anova(model_entropy, model_entropy_1, model_entropy_2)



# Plot data, Look at data
plot.new()
library(ggplot2)
library(sjPlot)
library(sjlabelled)
library(sjmisc)
ggplot(dataELAN, aes(x = Q3a, y = Condition))+ geom_point() + scale_x_continuous(1:8) + facet_wrap(~Participant)

name_plot = 'lmer_Q1b_Q3b_Macro_Participant'
sjPlot::plot_model(title = 'Q1b ~ Q3b + (1| Participant)  ', model_entropy, show.p = TRUE, show.values = TRUE, digits = 3,show.intercept = TRUE)
dev.print( device = png,              # what are we printing to?
           filename = paste("/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/Stats/R/plot_", name_plot, '.png'),  # name of the image file
           width = 865,                # how many pixels wide should it be
           height = 400,                # how many pixels high should it be
)




model_entropy = lm(Q1a ~ Condition +  Participant + Condition:Participant , data = dataELAN )
model_entropy = lm(Q1a ~ Condition +  Participant + Condition:Participant , data = dataELAN )
coef(model_entropy)
dataELAN %>% summary
model_entropy %>% summary

dataELAN %>%
  count(Participant)

dataEntropy %>%
  count(Participant)


 
#model_entropy = lmer(LZ ~ Dance_Imp:Name  + (1 + Name | Participant) , data = dataELAN )
model_entropy_1  = lmer(LZ_avg ~Dance_mode + (1 | Participant) , data = dataELAN )
model_entropy_2 = lmer(LZ_avg ~ Q3a + Dance_mode + (1 | Participant) , data = dataELAN )

summary(model_entropy)
anova(model_entropy_1, model_entropy_2 )
AIC(model_entropy_1, model_entropy_2)
# Plot p values and model
name_plot = 'lmer_Q4a_Q3b_Q1a_Dance_mode_ELAN'
sjPlot::plot_model(title = 'LMER - Quality of Improvisation [Q1b] - Conditions', model_entropy, show.p = TRUE, show.values = TRUE, digits = 3,show.intercept = TRUE)
dev.print( device = png,              # what are we printing to?
           filename = paste("/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/Stats/R/plot_", name_plot, '.png'),  # name of the image file
           width = 865,                # how many pixels wide should it be
           height = 400,                # how many pixels high should it be
)


# Plot the model
library(carData)
library(effects)
e <- allEffects(model_entropy)
#Plots the effect
plot.new()
library(ggplot2)
library(sjPlot)
library(sjlabelled)
library(sjmisc)

plot_model(model_entropy)
plot(e ,multiline=TRUE,confint=TRUE,ci.style="bars"
     ,main="LZ_Av and Quality of Flow"
     ,xlab="Abs_Avg"
     ,ylab="LZ_Avg", show.values = TRUE)

name_plot = 'LZ_Av_vs_Q3b'

dev.print( device = png,              # what are we printing to?
           filename = paste("/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/Stats/R/plot_", name_plot, '.png'),  # name of the image file
           width = 865,                # how many pixels wide should it be
           height = 636,                # how many pixels high should it be
)



#Plots all the data points
plot(model_entropy,multiline=TRUE,confint=TRUE,ci.style="bars"
     ,main="Complexity across conditions"
     ,xlab="Palo"
     ,ylab="Dance_imp",
     )



model_entropy_2 = lmer(Q1b ~ Q3b + I(Q3b^2) + (1 | Participant), data = dataEntropy)


#Subset data of ELAN only dancers
dataELAN_P <- dataELAN[!grepl("G", dataELAN$Participant),]
dataELAN_G <- dataELAN[!grepl("P", dataELAN$Participant),]
model_entropy = lmer(Flow_subj ~   Q3b + (1 | Participant) , data = dataSubELAN )
summary(model_entropy)

summary(model_entropy_2)
model_entropy_mixed = lmer(Q1a ~ Q3a + Dance_mode  + Abs_Av + (1 + Condition | Participant), data = dataEntropy )
AIC(model_entropy,model_entropy_2)
summary(model_entropy_mixed)

# Correlation plot
library(corrplot)
library("psych")   

#BLUE PLOTS
name_plot <- "micro_all_new"
corr_mat = dataELAN[, c('LZ', 'Imp_subj', 'Flow_subj', 'MIR_entropy', 'MIR_rms', 'MIR_novelty', 'var_entropy')]
name_plot <- "micro_P_16"
corr_mat = dataELAN_P[, c('LZ', 'Imp_subj', 'Flow_subj', 'MIR_entropy', 'MIR_rms', 'MIR_novelty', 'var_entropy')]
name_plot <- "micro_G_16"
corr_mat = dataELAN_G[, c('LZ', 'Imp_subj', 'Flow_subj', 'MIR_entropy', 'MIR_rms', 'MIR_novelty', 'var_entropy')]

#RED PLOTS
name_plot <- "macro_all"
corr_mat = dataELAN[, c('LZ_avg', 'Imp_avg', 'Flow_avg', 'MIR_entropy_avg', 'MIR_rms_avg', 'MIR_novelty_avg', 'var_entropy_avg')]
name_plot <- "macro_G"
corr_mat = dataELAN_G[, c('LZ_Av', 'Imp_avg', 'Flow_avg', 'MIR_entropy_avg', 'MIR_rms_avg', 'MIR_novelty_avg', 'var_entropy_avg')]
name_plot <- "macro_P"
corr_mat = dataELAN_P[, c('LZ_Av', 'Imp_avg', 'Flow_avg', 'MIR_entropy_avg', 'MIR_rms_avg', 'MIR_novelty_avg', 'var_entropy_avg')]


#RED MORE PLOTS
name_plot <- "macro_all_16"
corr_mat = dataELAN[, c('Abs_Av','Perf_Av','SFS','Q1a','Q1b','Q3a','Q3b','Q4a','Q4b','LZ_Av', 'Imp_avg', 'Flow_avg', 'MIR_entropy_avg', 'MIR_rms_avg', 'MIR_novelty_avg', 'var_entropy_avg')]
name_plot <- "macro_P_16"
corr_mat = dataELAN_P[, c('Abs_Av','Perf_Av','SFS','Q1a','Q1b','Q3a','Q3b','Q4a','Q4b','LZ_Av', 'Imp_avg', 'Flow_avg', 'MIR_entropy_avg', 'MIR_rms_avg', 'MIR_novelty_avg', 'var_entropy_avg')]
name_plot <- "macro_G_16"
corr_mat = dataELAN_G[, c('Abs_Av','Perf_Av','SFS','Q1a','Q1b','Q3a','Q3b','Q4a','Q4b','LZ_Av', 'Imp_avg', 'Flow_avg', 'MIR_entropy_avg', 'MIR_rms_avg', 'MIR_novelty_avg', 'var_entropy_avg')]

name_plot <- "macro_new"
corr_mat = dataELAN[, c('Abs_Av','Perf_Av','SFS','Q1a','Q1b','Q3a','Q3b','Q4a','Q4b','LZ_avg', 'MIR_entropy_avg', 'MIR_novelty_avg', 'var_entropy_avg')]

#Lausanne Data
name_plot <- "Lausanne"
corr_mat = dataELAN[, c('Abs_Av','Perf_Av','SFS','Q1a','Q1b','Q3a','Q3b','Q4a','Q4b','LZ_Av', 'Imp_avg', 'Flow_avg', 'MIR_entropy_avg', 'MIR_rms_avg', 'MIR_novelty_avg', 'var_entropy_avg')]
corr_mat = dataELAN [,x ('LZ', 'p_LZ', 'g_LZ', 'LZ_avg', 'p_LZ_avg', 'g_LZ_avg')]

M <- cor(corr_mat, use = 'complete.obs', method='spearman')
plot.new()
corrplot(M, order = "AOE", tl.col = "black", tl.srt = 45, p.mat = corr.test(corr_mat)$p, insig = 'label_sig', sig.level = c(.001, .01, .05),
         pch.cex = 0.8, pch.col = 'red',
        title =  paste('Correlation Plot (', name_plot , ')'), cex.main = 1.8,
         mar=c(0,0,2,0),
         )

dev.print( device = png,              # what are we printing to?
                         filename = paste("/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/Stats/R/corr_", name_plot, '_AOE.png'),  # name of the image file
                         width = 865,                # how many pixels wide should it be
                         height = 636,                # how many pixels high should it be
             )


p_corr_test <-corr.test(corr_mat)$p
cor_test_star <- symnum(p_corr_test, cutpoints = c(0, 0.001, 0.01, 0.05, 1), 
             symbols = c("***","**","*",""))

r = round(cor(corr_mat, use = 'complete.obs', method='spearman'), digits = 2)
txt <- paste(r, cor_test_star, sep = " ")
cex.cor <- 0.8/strwidth(txt)
text(0.5, 0.5, txt, cex = cex.cor*r)


dataInterval <- read.csv("~/CODE/RITMO/ENTROPY/output/ELAN/LZ_CTW_Intervals.csv")
dataInterval$Dance_mode <- as.factor(dataInterval$Dance_mode)
dataInterval$Palo <- as.factor(dataInterval$Palo)
# dataEntropy$Q3bF <- as.factor(dataEntropy$Q3b)
dataInterval$Music_mode <- as.factor(dataInterval$Music_mode)
dataInterval$Assigned_Cat <- as.factor(dataInterval$Assigned_Cat)
dataInterval$Dance_mode <- relevel(dataInterval$Dance_mode, "D6")
dataInterval$Music_mode <- relevel(dataInterval$Music_mode, "M6")
#dataInterval$Participant <- as.factor(dataInterval$Participant)
model_entropy = lmer(Q1b ~ Q3b + (1 | Participant), data = dataEntropy )
model_entropy_2 = lmer(LZ_Av ~ Abs_Av + (1 | Dance_mode), data = dataInterval)
summary(model_entropy)
summary(model_entropy_2)
model_entropy_mixed = lmer(Q1a ~ Dance_mode  + Abs_Av + (1 | Participant), data = dataEntropy )
AIC(model_entropy,model_entropy_2)
summary(model_entropy_mixed)



# Model comparison with AIC
# The smallest one is the best. 
# When you have more variables you will be able to explain more. So you need to check that the complexity is justified.
# Since you are comparing two models of different DOF. Need to check the models complexity. 
# The less complexity the better. 
AIC(data_mixed_3,data_mixed_3b)

#Dataset 5 Analysis
data5$Dance_mode<- as.factor(data5$Dance_mode)
data5$Palo <- as.factor(data5$Palo)
data5$Participant <- as.factor(data5$Participant)
data_mixed_5 = lmer(Abs_Av~ Dance_mode + (1 | Participant),  data = data5)
summary(data_mixed_5)


#Dataset 4 Analysis
data4$Dance_mode <- as.factor(data4$Dance_mode)
data4$Palo <- as.factor(data4$Palo)
data4$Participant <- as.factor(data4$Participant)
data_mixed_4 = lmer(Entropy_Av~ Dance_mode + (1 | Participant),  data = data4)
summary(data_mixed_4)


