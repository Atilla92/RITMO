import pandas as pd
import numpy as np

df_mean = pd.read_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/mean/means.csv')
df_long = pd.read_csv('/Users/atillajv/CODE/RITMO/PILOT_SEV_APRIL_2022/output/ratingsAnalysis/DuringExperiments_Sevilla_06102022_DropW.csv')


df_long['LZ'] = np.nan
df_long['CTW'] = np.nan

for i, item in enumerate(df_mean['Name']):

    indexMean = df_long.index[df_long['Name'].str.contains(str(item))]
    for j, itemj in enumerate(indexMean):
        df_long['CTW'].iloc[itemj] = df_mean['CTW'].iloc[i]
        df_long['LZ'].iloc[itemj] = df_mean['LZ'].iloc[i]
print(df_long)

df_long.to_csv('/Users/atillajv/CODE/RITMO/PILOT_SEV_APRIL_2022/output/ratingsAnalysis/DuringExperiments_Sevilla_06102022_DropW_Entropy.csv', index = False)




