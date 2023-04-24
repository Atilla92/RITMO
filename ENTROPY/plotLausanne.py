# This file will plot entropy time-series
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from statsmodels.graphics.mosaicplot import mosaic
import glob
import os



file_input = '/Users/atillajv/CODE/RITMO/ENTROPY/output/main/all_experiments_095/'
save_plot = '/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/' 

#Import dataset
df_file = '18042023_all_experiments_drums_guitar_zd'
df = pd.read_csv(file_input + df_file + '.csv', index_col=0)
df.drop_duplicates(subset=None, keep="first", inplace=True)

loop_on = True
loop_off = 'P7_D5_G1_M6_R1_T1.csv'
entropy_files = []
array_x = []
array_y = []
#Load Data
if loop_on:
    for filepath in glob.iglob(str(file_input + '*.csv')):
        if filepath.endswith('.csv'):
            filepath_split = filepath.partition(file_input[len(file_input)-10:])
            if len(filepath_split[-1])<22:
                entropy_files.append(filepath_split[2])
else:
 entropy_files = [loop_off]
 


plt.figure()

for i, item in enumerate(entropy_files):
    print(i)
    df_i = pd.read_csv(file_input + item)
    #Drop first row with mean info
    df_i.drop(index=df.index[0], axis=0, inplace=True)

    t_end =df_i['t0'].iloc[-1]
    df_i['t_%'] = df_i['t0']/t_end
    #print(df_i)

    #plt.plot(df_i['t_%'], df_i['LZ'] )
    array_x.append(np.array(df_i['t_%']))
    array_y.vstack(np.array(df_i['LZ']))
    print(array_y)
#plt.show()


print(len(array_y))

# plt.figure()
# plt.scatter(array_x, array_y)
# plt.show()



