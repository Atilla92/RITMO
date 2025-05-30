# This file will plot entropy time-series
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from statsmodels.graphics.mosaicplot import mosaic
import glob
import os
from itertools import repeat
from functionsE import binningPlots, InfotoColumnsPlots
"""
Create a Ribbon plot of Entropy and LZ data.Loops over .csv files

Indicarw: 
    rating = 'IMPRO' or 'FLOW', which variable you want to have plot
    file_input = folder where ratings are
    audio_input = uses the audio files to fetch total song length over which the %time is binned. 
    save_plot = where to save figures
    file_name = name of file being saved 
    hue_var = grouping variable
    filter_ out = True if you want to filter out certain columns containing string (e.g. DO). 

"""

# Parameters of plotting function.
y_var = ' Value'
file_input = '/Users/atillajv/CODE/RITMO/FILES/Ratings/'
save_plot = '/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/all_experiments_07072023_095/'
audio_input = '/Users/atillajv/CODE/RITMO/ENTROPY/output/main/all_experiments_095/'


hue_var = 'Artist'
rating = 'IMPRO'
file_name = str(rating + "_t%_" + hue_var + 'filter_D0' )

# Loop or single file 
loop_on = True #Set to false if only analysing one file. 
loop_off = 'P3_P3_D5_G1_M6_R1_T1_FLOW.csv'
filter_out = False

# Initiate empty lists
entropy_files = []
array_x = []
array_y = []

df_plots = pd.DataFrame(columns = ['Name', 't_%', 'y_var', 't_0'])
#Load Data
if loop_on:
    for filepath in glob.iglob(str(file_input + '*' + rating +'.csv')):
        if filepath.endswith('.csv'):
            filepath_split = filepath.partition(file_input[len(file_input)-10:])
            entropy_files.append(filepath_split[2])
else:
 entropy_files = [loop_off]



plt.figure()
j= 0
for k, item_k in enumerate(entropy_files):
    name_list = []
    file_list = []
    try:
        dfR = pd.read_csv(file_input + item_k)
        df_a = pd.read_csv(audio_input + item_k.split('_',1)[1].rpartition('_')[0] + '.csv')
        #Drop first row with mean info
        #dfR.drop(index=dfR.index[0], axis=0, inplace=True)

        t_end =df_a['t0'].iloc[-1]
        dfR['t_%'] = dfR['Time']/t_end
        tR_end = dfR['t_%']
        mean_array = []
        time_array = []
        tI_1 = np.arange(0.1, 1.2, 0.1)
        time_r = []
        n= 0
    
        for i, item in enumerate(np.arange(0, 1.1, 0.1)):
            for j in np.arange(n, len(dfR['t_%'])):
                if tR_end.iloc[j]< tI_1[i] and tI_1[i]<1.1:
                    mean_array.append(dfR[' Value'].iloc[j])
                    time_r.append(dfR['Time'].iloc[j])
                    time_array.append(tI_1[i])

                elif tR_end.iloc[j] > 1:
                    mean_array.append(dfR[' Value'].iloc[j])
                    time_r.append(dfR['Time'].iloc[j])
                    time_array.append(1.0)
                    n=j
                    break
                
                elif tR_end.iloc[j]> tI_1[i]:
                    n = j
                    break
            
        item_new = item_k.split("_")
        item_new = "_".join(item_new[1:-1])
        name_list.extend(repeat(str(item_new),len(np.array(mean_array))))
        file_list.extend(repeat(str(item_k),len(np.array(mean_array))))
        df_plot = pd.DataFrame( {
            'Name': name_list,
            'file': file_list,
            'Rater': item_k.split("_")[0],
            't_%': time_array,
            'y_var': mean_array,
            't_0': time_r

        })
        #print(df_plot)
        df_plots = pd.concat([df_plots, df_plot], axis =0 )
    except:
        print('file not found:', item_k)
        pass



InfotoColumnsPlots(df_plots)

# Binning
binningPlots(df_plots)

#df_plots.to_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/all_experiments_095/Test.csv')

#df_plots.drop_duplicates(subset=None, keep="first", inplace=True, ignore_index=True)
# if filter_out:
#     df_plots = df_plots[~df_plots['Dance_mode'].str.contains("D0")]
#df_plots = df_plots[~df_plots['Rater'].str.contains("P")]
    #df_plots = df_plots[~df_plots['Artist'].str.contains("G")]
#df_plots = df_plots[~df_plots['Dance_mode'].str.contains("D5")]
#print(df_plots)
# Figures

#sns.violinplot(data=df_plots, x="Assigned_%", y="LZ", hue = 'Dance_mode')
fig = sns.lineplot(data = df_plots,  x="Assigned_%", y="y_var", hue = hue_var)
fig.set(xlabel='t [%]', ylabel = 'Subjective Rating', title = rating)
fig.set_ylim([0, 7])
#plt.show()
#plt.legend( labels = ['D5 - Semi', 'D1 - Impro', 'D6 - Choreo'])
#plt.show()
#plt.savefig(save_plot+ file_name + '.png')

#print(df_plots)
df_plots.to_csv(save_plot + '/data/ratings/t%_ratings_' + rating+'.csv')




# fig, axs = plt.subplots(5,1)
# i = 0
# for label, grp in df_plots.groupby('Condition'):
#     print(label, grp)
#     grp.plot(x = 't_', y = 'LZ', ax = axs[i], label = label)
#     i = i+1



