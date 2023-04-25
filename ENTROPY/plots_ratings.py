# This file will plot entropy time-series
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

Indicarw: 
    y_var = 'LZ' or 'var', which variable you want to have plot
    file_input = folder where the LZ or Entropy files for songs are
    save_plot = where to save figures
    file_name = name of file being saved 
    hue_var = grouping variable

"""

# Parameters of plotting function.
y_var = ' Value'
file_input = '/Users/atillajv/CODE/RITMO/FILES/Ratings/'
save_plot = '/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/all_experiments_095/'

hue_var = 'Dance_mode'
rating = 'FLOW'
file_name = str(rating + "_t%_" + hue_var + '_filtered_dancer' )

# Loop or single file 
loop_on = True #Set to false if only analysing one file. 
loop_off = 'P7_D5_G1_M6_R1_T1.csv'
filter_out = True

# Initiate empty lists
entropy_files = []
array_x = []
array_y = []

df_plots = pd.DataFrame(columns = ['Name', 't_%', 'y_var', 't0'])
#Load Data
if loop_on:
    for filepath in glob.iglob(str(file_input + '*' + rating +'.csv')):
        if filepath.endswith('.csv'):
            filepath_split = filepath.partition(file_input[len(file_input)-10:])
            entropy_files.append(filepath_split[2])
else:
 entropy_files = [loop_off]

print(entropy_files)


plt.figure()
j= 0
for i, item in enumerate(entropy_files):
    name_list = []
    
    #print(i)
    df_i = pd.read_csv(file_input + item)
    #Drop first row with mean info
    #df_i.drop(index=df_i.index[0], axis=0, inplace=True)

    t_end =df_i['Time'].iloc[-1]
    df_i['t_%'] = df_i['Time']/t_end
    #print(df_i)

    #plt.plot(df_i['t_%'], df_i['LZ'] )
    array_x = np.array(df_i['t_%'])
    array_y = np.array(df_i[y_var])
    name_list.extend(repeat(str(item),len(np.array(df_i['Time']))))
    #print(len(array_y))
    #print(name_list)
    df_plot = pd.DataFrame( {
        'Name': name_list,
        't_%': array_x,
        'y_var': array_y,
        't_0': np.array(df_i['Time'])

    })
    #print(df_plot)
    df_plots = pd.concat([df_plots, df_plot], axis =0 )


def InfotoColumns(df):
    dance_array = []
    music_array = []
    palo_array = []
    condition_array = []
    participant_array = []
    rater_array = []
    artist_array = []
    for i, item in enumerate(df['Name']):

        split_array = item.split('_')
        rater_array.append(split_array[0])
        artist_array.append(split_array[0][0])
        participant_array.append(split_array[1])
        dance_array.append(split_array[2])
        music_array.append(split_array[4])
        palo_array.append(split_array[5])
        condition_array.append(str(split_array[2] +'_' + split_array[4]))
        #print(split_array)
    df['Artist'] = artist_array
    df['Rater'] = rater_array
    df['Participant'] = participant_array
    df['Dance_mode'] = dance_array
    df['Music_mode'] = music_array
    df['Palo'] = palo_array
    df['Condition'] = condition_array


InfotoColumns(df_plots)

print(df_plots)

# Binning
df_plots['Assigned_%'] = 0
df_plots.loc[df_plots['t_%']<= 0.10 , 'Assigned_%'] = 0.05
df_plots.loc[(df_plots['t_%']<= 0.20) & (df_plots['t_%']> 0.10 ) , 'Assigned_%'] = 0.10
df_plots.loc[(df_plots['t_%']<= 0.30) & (df_plots['t_%']> 0.20 ) , 'Assigned_%'] = 0.20
df_plots.loc[(df_plots['t_%']<= 0.40) & (df_plots['t_%']> 0.30 ) , 'Assigned_%'] = 0.30
df_plots.loc[(df_plots['t_%']<= 0.50) & (df_plots['t_%']> 0.40 ) , 'Assigned_%'] = 0.40
df_plots.loc[(df_plots['t_%']<= 0.60) & (df_plots['t_%']> 0.50 ) , 'Assigned_%'] = 0.50
df_plots.loc[(df_plots['t_%']<= 0.70) & (df_plots['t_%']> 0.60 ) , 'Assigned_%'] = 0.60
df_plots.loc[(df_plots['t_%']<= 0.80) & (df_plots['t_%']> 0.70 ) , 'Assigned_%'] = 0.70
df_plots.loc[(df_plots['t_%']<= 0.90) & (df_plots['t_%']> 0.80 ) , 'Assigned_%'] = 0.80
df_plots.loc[df_plots['t_%']> 0.90  , 'Assigned_%'] = 0.90

#df_plots.to_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/all_experiments_095/Test.csv')

df_plots.drop_duplicates(subset=None, keep="first", inplace=True, ignore_index=True)
if filter_out:
    df_plots = df_plots[~df_plots['Dance_mode'].str.contains("D0")]
    df_plots = df_plots[~df_plots['Artist'].str.contains("G")]
#df_plots = df_plots[~df_plots['Dance_mode'].str.contains("D5")]
print(df_plots)
# Figures

#sns.violinplot(data=df_plots, x="Assigned_%", y="LZ", hue = 'Dance_mode')
fig = sns.lineplot(data = df_plots,  x="Assigned_%", y="y_var", hue = hue_var)
fig.set(xlabel='t [%]', ylabel = 'IMPRO', title = rating)
#plt.show()

plt.savefig(save_plot+ file_name + '.png')




# fig, axs = plt.subplots(5,1)
# i = 0
# for label, grp in df_plots.groupby('Condition'):
#     print(label, grp)
#     grp.plot(x = 't_', y = 'LZ', ax = axs[i], label = label)
#     i = i+1




