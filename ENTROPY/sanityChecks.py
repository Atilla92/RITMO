import pandas as pd
import statsmodels.api as sm

df = pd.read_csv ('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/Test/' + 'Test_01022023' + '.csv',  delimiter=',')

print(df['Duration'].mean(), df['Duration'].std())
print(sm.stats.DescrStatsW(df['Duration']).zconfint_mean())