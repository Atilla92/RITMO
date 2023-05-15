import glob
import os
import pandas as pd
import numpy as np


path_data = '/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/all_experiments_095/data/'
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



print(dataframes[0], dataframes[1])
averaged_merged = dataframes[0].rename(columns = {'y_var': name_files[0]})

for i, item in enumerate(dataframes[1:]):
    averaged_merged = pd.merge(averaged_merged, 
                        item[['Name', 'Assigned_%', 'y_var']],                 
                        on=['Name', 'Assigned_%'],how = 'left', copy = False)

    averaged_merged.rename(columns ={"y_var": name_files[i+1]} , inplace=True)
# #print(averaged_df_1)

print(averaged_merged)
averaged_merged.to_csv(path_data + 't%_merged_average.csv')
