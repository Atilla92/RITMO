import pandas as pd
import statsmodels.api as sm

'''
This script will go over the datasets and see whether they have any repeated measures.
Look into the statistics and check whether it is clean.
'''
#First dataset:
# DuringExperiments_Sevilla_06102022_DropW_Entropy.csv
# This is the complete small version, can add stuff here. 

df = pd.read_csv ('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/Test/' + 'Test_01022023' + '.csv',  delimiter=',')

print(df['Duration'].mean(), df['Duration'].std())
print(sm.stats.DescrStatsW(df['Duration']).zconfint_mean())