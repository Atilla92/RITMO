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
audio_input = '/Users/atillajv/CODE/RITMO/ENTROPY/output/main/all_experiments_095_drums/'


hue_var = 'Dance_mode'
rating = 'IMPRO'
file_name = str(rating + "_t%_" + hue_var + '_test' )

# Loop or single file 
loop_on = True #Set to false if only analysing one file. 
loop_off = 'P3_P3_D5_G1_M6_R1_T1_FLOW.csv'
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
for k, item_k in enumerate(entropy_files):
    name_list = []
    print(item_k)

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
            


        name_list.extend(repeat(str(item_k),len(np.array(mean_array))))
        #print(len(array_y))
        #print(name_list)
        df_plot = pd.DataFrame( {
            'Name': name_list,
            't_%': time_array,
            'y_var': mean_array,
            't_0': time_r

        })
        #print(df_plot)
        df_plots = pd.concat([df_plots, df_plot], axis =0 )
    except:
        print('file not found:', item_k)
        pass

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
df_plots.loc[df_plots['t_%']<= 0.10 , 'Assigned_%'] = 0.10
df_plots.loc[(df_plots['t_%']<= 0.20) & (df_plots['t_%']> 0.10 ) , 'Assigned_%'] = 0.20
df_plots.loc[(df_plots['t_%']<= 0.30) & (df_plots['t_%']> 0.20 ) , 'Assigned_%'] = 0.30
df_plots.loc[(df_plots['t_%']<= 0.40) & (df_plots['t_%']> 0.30 ) , 'Assigned_%'] = 0.40
df_plots.loc[(df_plots['t_%']<= 0.50) & (df_plots['t_%']> 0.40 ) , 'Assigned_%'] = 0.50
df_plots.loc[(df_plots['t_%']<= 0.60) & (df_plots['t_%']> 0.50 ) , 'Assigned_%'] = 0.60
df_plots.loc[(df_plots['t_%']<= 0.70) & (df_plots['t_%']> 0.60 ) , 'Assigned_%'] = 0.70
df_plots.loc[(df_plots['t_%']<= 0.80) & (df_plots['t_%']> 0.70 ) , 'Assigned_%'] = 0.80
df_plots.loc[(df_plots['t_%']<= 0.90) & (df_plots['t_%']> 0.80 ) , 'Assigned_%'] = 0.90
df_plots.loc[df_plots['t_%']> 0.90  , 'Assigned_%'] = 1.00

#df_plots.to_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/all_experiments_095/Test.csv')

df_plots.drop_duplicates(subset=None, keep="first", inplace=True, ignore_index=True)
if filter_out:
    df_plots = df_plots[~df_plots['Dance_mode'].str.contains("D0")]
    #df_plots = df_plots[~df_plots['Artist'].str.contains("G")]
#df_plots = df_plots[~df_plots['Dance_mode'].str.contains("D5")]
print(df_plots)
# Figures

#sns.violinplot(data=df_plots, x="Assigned_%", y="LZ", hue = 'Dance_mode')
fig = sns.lineplot(data = df_plots,  x="Assigned_%", y="y_var", hue = hue_var)
fig.set(xlabel='t [%]', ylabel = 'Subjective Rating', title = rating)
#plt.show()

plt.savefig(save_plot+ file_name + '.png')




# fig, axs = plt.subplots(5,1)
# i = 0
# for label, grp in df_plots.groupby('Condition'):
#     print(label, grp)
#     grp.plot(x = 't_', y = 'LZ', ax = axs[i], label = label)
#     i = i+1



