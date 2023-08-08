import glob
import os
import pandas as pd
import numpy as np


path_data = '/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/all_experiments_07072023_095/data/'
path_FLOW = '/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/all_experiments_07072023_095/data/ratings/t%_ratings_FLOW.csv'
path_IMPRO = '/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/all_experiments_07072023_095/data/ratings/t%_ratings_IMPRO.csv'
loop_on = True
name_files = []
dataframes = []
file_name = ''

if loop_on:
    for filepath in glob.iglob( str(path_data + '*.csv')):
        if filepath.endswith('.csv'):
            filepath_split = filepath.partition('data/')
            filepath_split = filepath_split[-1].strip('.csv')
            # print(filepath_split.rsplit('_',1))
            df = pd.read_csv(filepath)
            df = df.groupby(["Name", "Assigned_%"])['y_var'].mean().reset_index()
            dataframes.append(df)
            name_files.append(filepath_split)

            # list_files.append(filepath_split.rsplit('_',1)[0])
else:
    list_files = [file_name]


print(name_files)
# merged_df = pd.merge(dataframes[0][['Name', 't_%','y_var','t_0','Participant','Dance_mode','Music_mode','Palo','Condition','Assigned_%']], 
#                      dataframes[1][['Name', 't_%','y_var','t_0','Assigned_%']],                 
#                      on=['Name', 'Assigned_%'], how='outer', copy = False)


#averaged_df_1 = dataframes[0].groupby(["Name", "Assigned_%"])['y_var'].mean().reset_index()
#averaged_df_2 = dataframes[2].groupby(["Name", "Assigned_%"])['y_var'].mean().reset_index()
#print(averaged_df_2)

# for i, item in enumerate(dataframes[1:]):
#     averaged_df_1 = pd.merge(averaged_df_1, 
#                      item[['Name', 'Assigned_%', 'y_var']],                 
#                      on=['Name', 'Assigned_%'],how = 'left', copy = False)
#     print(averaged_df_1)



averaged_merged = pd.read_csv(path_FLOW)
print(averaged_merged)
averaged_merged = averaged_merged.groupby(["Name", "Assigned_%", "Rater"])['y_var'].mean().reset_index()
averaged_merged = averaged_merged.rename(columns = {'y_var': 'FLOW'})
print(averaged_merged)
for i, item in enumerate(dataframes):
    averaged_merged = pd.merge(averaged_merged, 
                        item[['Name', 'Assigned_%', 'y_var']],                 
                        on=['Name', 'Assigned_%'],how = 'left', copy = False)

    averaged_merged.rename(columns ={"y_var": name_files[i]} , inplace=True)
# #print(averaged_df_1)

df_impro =pd.read_csv(path_IMPRO).rename(columns = {'y_var': 'IMPRO'})

df_impro = df_impro.groupby(["Name", "Assigned_%", 'Rater'])['IMPRO'].mean().reset_index()


averaged_merged = pd.merge(averaged_merged, 
                        df_impro[['Name', 'Assigned_%', 'IMPRO', 'Rater']],                 
                        on=['Name', 'Assigned_%', 'Rater'],how = 'left', copy = False)




def InfotoColumns(df):
    dance_array = []
    music_array = []
    palo_array = []
    condition_array = []
    participant_array = []
    pair_array = []
    for i, item in enumerate(df['Name']):

        split_array = item.split('_')
        participant_array.append(split_array[0])
        dance_array.append(split_array[1])
        music_array.append(split_array[3])
        palo_array.append(split_array[4])
        condition_array.append(str(split_array[1] +'_' + split_array[3]))
        pair_array.append(str(split_array[0] +'_' + split_array[2]))
        #print(split_array)
    df['Participant'] = participant_array
    df['Dance_mode'] = dance_array
    df['Music_mode'] = music_array
    df['Palo'] = palo_array
    df['Condition'] = condition_array
    df['Pair'] = pair_array

print(averaged_merged)
averaged_merged['Artist'] = averaged_merged['Rater'].str[0]
InfotoColumns(averaged_merged)
print(averaged_merged)
averaged_merged.to_csv(path_data + 't%_merged_average.csv')
