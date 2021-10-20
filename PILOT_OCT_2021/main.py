from analysis import workflow, storeDF
import pandas as pd
import numpy as np

#import datasets
df = pd.read_csv (r'DuringAssesment_IMP1_IMP2.csv')


# Define the subdataset you would like to analyse
buleria  = (df.loc[df["Palo"]=="Buleria"])
seguirya = (df.loc[df["Palo"]=="Seguirya"])
solea = (df.loc[df["Palo"]=="Solea"])
guajira = (df.loc[df["Palo"]=="Guajira"])
day1 = (df.loc[df['Day']==1])
day2 = (df.loc[df['Day']==2])
imp1 = (df.loc[df['Setup']=='IMP1'])
imp2 = (df.loc[df['Setup']=='IMP2'])



# Indicate which datasets you want to be analysed
meanPAT = workflow(df, True, True, "All") # (dataset, perform analysis, store data, Title  )
meanDay1 = workflow(day1, True, True, "Day1")
meanDay2 = workflow(day2, True, True, "Day2")
meanBuleria = workflow (buleria,True, True,"Buleria")
meanIMP1 = workflow (imp1,True, True,"IMP1")
meanIMP2 = workflow (imp2,True, True,"IMP2")
# meanIMP1 = workflow (imp1,True, True,"IMP1")
# meanIMP2 = workflow (imp2,True, True,"IMP2")
meanSeguirya = workflow (seguirya,True, True,"Seguirya")
meanGuajira =  workflow (guajira,True, True,"Guajira")
meanSolea = workflow (solea,True, True,"Solea")


#Store means and stds of specific datasets
dfSummary = meanPAT.append(meanDay1)
dfSummary = dfSummary.append(meanDay2)
dfSummary = dfSummary.append(meanBuleria)
dfSummary = dfSummary.append(meanSolea)
dfSummary = dfSummary.append(meanGuajira)
dfSummary = dfSummary.append(meanSeguirya)
dfSummary = dfSummary.append(meanIMP1)
dfSummary = dfSummary.append(meanIMP2)
storeDF(dfSummary,"meanSummary", False)
print(dfSummary)


#Plotting results
