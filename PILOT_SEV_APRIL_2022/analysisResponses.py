import numpy as np
import pandas as pd
from scipy.stats.stats import pearsonr
from scipy import stats
#import pingouin as pg
#import seaborn as sns
import matplotlib.pyplot as plt

df = pd.read_csv ('/Users/atillajv/CODE/RITMO/FILES/Subjective/DuringExperiments_23062023_Andalucia_DropW.csv')
print(df)
#df = pd.read_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/17_Dec_2022/17122022_095_2s.csv')


def CronchbachAlpha(df):
    #https://www.statisticshowto.com/probability-and-statistics/statistics-definitions/cronbachs-alpha-spss/#:~:text=A%20low%20value%20for%20alpha,more%20than%20one%20latent%20variable.
    # a > 0.9 Excellent, 0.9>a>=0.8 Good, 0.8>a>0.7 Acceptable,
    # 0.7>a>0.6 Questionable, 0.6>a>0.5 Poor, 0.5>a Unacceptable
    df_filter = filterOut(df,['Name', 'Participant'])
    ch_alpha = pg.cronbach_alpha(data=df_filter)
    print('chronbach alpha',ch_alpha )

def AverageFlowtoDF(df):
    df['Abs_Av'] = df[['Q2a', 'Q2c', 'Q2f', 'Q2j']].mean(axis = 1) 
    df['Perf_Av'] = df[['Q2b','Q2d','Q2e','Q2g','Q2h','Q2i']].mean(axis = 1)
    df['SFS'] = df[['Abs_Av', 'Perf_Av']].mean(axis= 1)

def correlMatrix(df, p):
    df_filter = filterOut(df,['Name', 'Participant', 'Q2a', 'Q2c', 'Q2f', 'Q2j','Q2b','Q2d','Q2e','Q2g','Q2h','Q2i',
    'MIR_entropy_avg', 'MIR_rms_avg', 'MIR_novelty_avg', 'var_entropy_avg', 'Imp_avg', 'Flow_avg', 'LZ_Av', 'CTW_Av'
     ])
    if p: 
        correlation_mat = df_filter.corr()
        sns.heatmap(correlation_mat, annot = True) 
        plt.show()      
    r_corr = df_filter.corr()
    print(r_corr) 

def filterOut(df, listFilter):
    df_filter = df.loc[:, ~df.columns.isin(listFilter)]
    return df_filter


# print(df)
# CronchbachAlpha(df)
AverageFlowtoDF(df)
# correlMatrix(df, False)
# print(df)

# df_P = df.loc[df['Participant'].isin(['P3', 'P4'])]
# CronchbachAlpha(df_P)
# correlMatrix(df_P, False)

# df_G = df.loc[df['Participant'].isin(['G1', 'G2'])]
# CronchbachAlpha(df_G)
# correlMatrix(df_G, True)



def InfotoColumns(df):
    dance_array = []
    music_array = []
    palo_array = []
    participant_array = []
    for i, item in enumerate(df['Name']):

        split_array = item.split('_')
        participant_array.append(split_array[0])
        dance_array.append(split_array[1])
        music_array.append(split_array[3])
        palo_array.append(split_array[4])
        print(split_array)

    df['Dance_mode'] = dance_array
    df['Music_mode'] = music_array
    df['Palo'] = palo_array

#df = df.dropna()
#AverageFlowtoDF(df)
InfotoColumns(df)
print(df)
#correlMatrix(df, True)


#df.to_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/17_Dec_2022/17122022_095_2s_Corr.csv')
df.to_csv('output/ratingsAnalysis/DuringExperiments_Andalucia_07072023_DropW.csv', index=False)

#https://blog.4dcu.be/programming/2021/03/16/Code-Nugget-Correlation-Heatmaps.html

# pearson_Imp_Imp = pearsonr(df['Q1a'], df['Q1b'])
# pearson_Impr_Flow = pearsonr(df['Impr_Av'], df['Flow_Av'])
# pearson_Impr_Abs_Av = pearsonr(df['Impr_Av'], df['Abs_Av'])
# pearson_Impr_Perf_Av = pearsonr(df['Impr_Av'], df['Perf_Av'])
# pearson_Impr_SFS = pearsonr(df['Impr_Av'], df['SFS'])

# pearson_Flow_Abs = pearsonr(df['Flow_Av'], df['Abs_Av'])
# pearson_Flow_Perf = pearsonr(df['Flow_Av'], df['Perf_Av'])
# pearson_Flow_FLow = pearsonr(df['Q3a'], df['Q3b'])


# print('Imp_Imp', pearson_Imp_Imp, 'Impr_Flow', pearson_Impr_Flow, 'Impr_Abs', pearson_Impr_Abs_Av, 'Impr_Perf', pearson_Impr_Perf_Av, 'Impr_SPS', pearson_Impr_SFS )
# print('Flow_Flow', pearson_Flow_FLow, 'Flow_Abs', pearson_Flow_Abs, 'Flow_Perf', pearson_Flow_Perf)

