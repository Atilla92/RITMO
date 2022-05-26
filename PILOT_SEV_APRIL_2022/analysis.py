import numpy as np
import pandas as pd
from scipy.stats.stats import pearsonr
from scipy import stats
import pingouin as pg
import seaborn as sns
import matplotlib.pyplot as plt

df = pd.read_csv ('Responses/DuringExperiments.csv')
#print(df.loc[:, ~df.columns.isin(['Name', 'Participant'])])
ch_alpha = pg.cronbach_alpha(data=df.loc[:, ~df.columns.isin(['Name', 'Participant'])])
#print(df)
print('chronbach alpha',ch_alpha )
#df['Impr_Av'] =df['Q1a']/7 * df['Q1b']
df['Impr_Av'] = df[['Q1a', 'Q1b']].mean(axis = 1)
print(df)
#df['Impr_Av'] = df[['Q1b']].mean(axis = 1)

df['Flow_Av'] = df[['Q3a', 'Q3b']].mean(axis = 1) 
#df['Flow_Av'] = df[['Q3b']].mean(axis = 1) 
df['Abs_Av'] = df[['Q2a', 'Q2c', 'Q2f', 'Q2j']].mean(axis = 1) 
df['Perf_Av'] = df[['Q2b','Q2d','Q2e','Q2g','Q2h','Q2i']].mean(axis = 1)
df['SFS'] = df[['Abs_Av', 'Perf_Av']].mean(axis= 1)
#print(df)


pearson_Imp_Imp = pearsonr(df['Q1a'], df['Q1b'])
pearson_Impr_Flow = pearsonr(df['Impr_Av'], df['Flow_Av'])
pearson_Impr_Abs_Av = pearsonr(df['Impr_Av'], df['Abs_Av'])
pearson_Impr_Perf_Av = pearsonr(df['Impr_Av'], df['Perf_Av'])
pearson_Impr_SFS = pearsonr(df['Impr_Av'], df['SFS'])

pearson_Flow_Abs = pearsonr(df['Flow_Av'], df['Abs_Av'])
pearson_Flow_Perf = pearsonr(df['Flow_Av'], df['Perf_Av'])
pearson_Flow_FLow = pearsonr(df['Q3a'], df['Q3b'])


print('Imp_Imp', pearson_Imp_Imp, 'Impr_Flow', pearson_Impr_Flow, 'Impr_Abs', pearson_Impr_Abs_Av, 'Impr_Perf', pearson_Impr_Perf_Av, 'Impr_SPS', pearson_Impr_SFS )
print('Flow_Flow', pearson_Flow_FLow, 'Flow_Abs', pearson_Flow_Abs, 'Flow_Perf', pearson_Flow_Perf)

df_small = df.loc[:, ~df.columns.isin(['Name', 'Participant'])]

correlation_mat = df_small.corr()
sns.heatmap(correlation_mat, annot = True)

#sns.pairplot(df_small)
plt.show()

r_corr = df_small.rcorr()
#sns.heatmap(r_corr, annot= True)
#plt.show()
print(r_corr)

#https://blog.4dcu.be/programming/2021/03/16/Code-Nugget-Correlation-Heatmaps.html