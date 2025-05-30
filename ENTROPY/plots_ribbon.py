# This file will plot entropy time-series
from functionsE import binningPlots, InfotoColumnsPlots
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from statsmodels.graphics.mosaicplot import mosaic
import glob
import os
from itertools import repeat


"""
Create a Ribbon plot of Entropy and LZ data.Loops over .csv files

Uncomment on the bottom if you want .csv file to be stored and plots to be shown/saved. 

Indicarw: 
    y_var = 'LZ' or 'var', which variable you want to have plot
    file_input = folder where the LZ or Entropy files for songs are
    save_plot = where to save figures
    save_csv = where csv is to be saved. 
    file_name = name of file being saved 
    hue_var = grouping variable
    loop_on = if you want to loop through all .csv files
    filter_out = True if you want to filter out D0 of data. 


"""

# Parameters of plotting function.
y_var = 'var'
source_var = 'guitar_zd'
hue_var = 'Dance_mode'
title_plot = 'Zapateado'
file_input = '/Users/atillajv/CODE/RITMO/ENTROPY/output/main/all_experiments_095_'+ source_var +'/var/'

save_plot = '/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/all_experiments_07072023_095/'
save_csv = '/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/all_experiments_07072023_095/'


file_name = str(y_var + '_t_%' + '_' + source_var + '_' + hue_var +'_filtered' )

# Loop or single file 
loop_on = True #Set to false if only analysing one file. 
loop_off = 'P7_D5_G1_M6_R1_T1.csv'
filter_out = False

# Initiate empty lists
entropy_files = []
array_x = []
array_y = []

df_plots = pd.DataFrame(columns = ['Name', 't_%'])
#Load Data
if loop_on:
    for filepath in glob.iglob(str(file_input + '*.csv')):
        if filepath.endswith('.csv'):
            filepath_split = filepath.partition(file_input[len(file_input)-10:])
            if len(filepath_split[-1])<23:
                entropy_files.append(filepath_split[2])
else:
 entropy_files = [loop_off]


plt.figure()
j= 0
for i, item in enumerate(entropy_files):
    name_list = []
    
    #print(i)
    df_i = pd.read_csv(file_input + item)
    #Drop first row with mean info
    #df_i.drop(index=df_i.index[0], axis=0, inplace=True)

    t_end =df_i['t0'].iloc[-1]
    df_i['t_%'] = df_i['t0']/t_end
    #print(df_i)

    #plt.plot(df_i['t_%'], df_i['LZ'] )
    array_x = np.array(df_i['t_%'])
    array_y = np.array(df_i[y_var])
    name_list.extend(repeat(str(item).strip('.csv'),len(np.array(df_i['t0']))))
    
    #print(len(array_y))
    df_plot = pd.DataFrame( {
        'Name': name_list,
        't_%': array_x,
        'y_var': array_y,
        't_0': np.array(df_i['t0'])

    })
    #print(df_plot)
    df_plots = pd.concat([df_plots, df_plot], axis =0 )
    j = j+1 


def InfotoColumns(df):
    dance_array = []
    music_array = []
    palo_array = []
    condition_array = []
    participant_array = []
    for i, item in enumerate(df['Name']):

        split_array = item.split('_')
        participant_array.append(split_array[0])
        dance_array.append(split_array[1])
        music_array.append(split_array[3])
        palo_array.append(split_array[4])
        condition_array.append(str(split_array[1] +'_' + split_array[3]))
        #print(split_array)
    df['Participant'] = participant_array
    df['Dance_mode'] = dance_array
    df['Music_mode'] = music_array
    df['Palo'] = palo_array
    df['Condition'] = condition_array


InfotoColumns(df_plots)

# Binning
binningPlots(df_plots)


#df_plots.to_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/all_experiments_095/Test.csv')

df_plots.drop_duplicates(subset=None, keep="first", inplace=True, ignore_index=True)

if filter_out:
    df_plots = df_plots[~df_plots['Dance_mode'].str.contains("D0")]

# Figures

#sns.violinplot(data=df_plots, x="Assigned_%", y="LZ", hue = 'Dance_mode')
fig = sns.lineplot(data = df_plots,  x="Assigned_%", y="y_var", hue = hue_var)
fig.set(xlabel='t [%]', ylabel = y_var, title = title_plot)
#plt.show()
#plt.savefig(save_plot+ file_name + '.png')


df_plots.to_csv(save_csv + '/data/t%_' + y_var +source_var+'.csv')


#print(df_plots)

# fig, axs = plt.subplots(5,1)
# i = 0
# for label, grp in df_plots.groupby('Condition'):
#     print(label, grp)
#     grp.plot(x = 't_', y = 'LZ', ax = axs[i], label = label)
#     i = i+1




