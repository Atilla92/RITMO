# This file will plot entropy time-series
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from statsmodels.graphics.mosaicplot import mosaic
import glob
import os
from itertools import repeat

y_var = 'LZ'

file_input = '/Users/atillajv/CODE/RITMO/ENTROPY/output/main/all_experiments_095/'
save_plot = '/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/' 

#Import dataset
#df_file = '18042023_all_experiments_drums_guitar_zd'
# df = pd.read_csv(file_input + df_file + '.csv', index_col=0)


loop_on = True
loop_off = 'P7_D5_G1_M6_R1_T1.csv'
entropy_files = []
array_x = []
array_y = []

df_plots = pd.DataFrame(columns = ['Name', 't_%', y_var])
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
    name_list.extend(repeat(str(item),len(np.array(df_i['t0']))))
    #print(len(array_y))
    #print(name_list)
    df_plot = pd.DataFrame( {
        'Name': name_list,
        't_%': array_x,
        'y_var': array_y,
        't_0': np.array(df_i['t0'])

    })
    #print(df_plot)
    df_plots = pd.concat([df_plots, df_plot], axis =0 )
    j = j+1 

    
#plt.show()

#df_plots.to_csv(file_input + 'Test' + '.csv')


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

#df = df.dropna()
#AverageFlowtoDF(df)
InfotoColumns(df_plots)


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
print(df_plots)
df_plots.to_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/all_experiments_095/Test.csv')
df_plots.drop_duplicates(subset=None, keep="first", inplace=True, ignore_index=True)
print(df_plots)
#sns.violinplot(data=df_plots, x="Assigned_%", y="LZ", hue = 'Dance_mode')

fig = sns.lineplot(data = df_plots,  x="Assigned_%", y="y_var", hue = 'Condition')
fig.set(xlabel='t [%]', ylabel = 'LZ')
#plt.show()
file_name = 'LZ_t_%_condition'
plt.savefig('/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/all_experiments_095/'+ file_name + '.png')


#FILTER BY GROUPS, PLOT DFS



# fig, axs = plt.subplots(5,1)
# i = 0
# for label, grp in df_plots.groupby('Condition'):
#     print(label, grp)
#     grp.plot(x = 't_', y = 'LZ', ax = axs[i], label = label)
#     i = i+1

#plt.show

# fig, ax = plt.subplots()
# for label, grp in df_plots.groupby('Condition'):
#     grp.plot(x = 't_0', y = 'LZ',ax = ax, label = label)

# plt.show()
# plt.figure()
# plt.scatter(array_x, array_y)
# plt.show()



