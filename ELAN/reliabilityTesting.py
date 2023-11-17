"""This code will test the reliability of ELAN annotations made by different flamenco experst

1. Loop through folders. 
2. Create csv 
3. Check whether they are the same. 

"""

import pandas as pd
import glob
import os

path_files_1 = '/Users/atillajv/CODE/RITMO/ELAN/FILES/00' 
path_files_2 = '/Users/atillajv/CODE/RITMO/ELAN/FILES/01' 


df1 = pd.read_csv('/Users/atillajv/CODE/RITMO/ELAN/FILES/00/P3_D6_G1_M6_R2_T1.csv', sep = ";")

df2 = pd.read_csv('/Users/atillajv/CODE/RITMO/ELAN/FILES/01/P3_D6_G1_M6_R2_T1.csv', sep = ",")

print(df1)
print(df2)

# Create an empty DataFrame to store the concatenated data
concatenated_df = pd.DataFrame()

# Loop through each .csv file in the folder
for file_name in os.listdir(path_files_1):
    if file_name.endswith('.csv'):
        # Read the .csv file as a new DataFrame
        file_path = os.path.join(path_files_1, file_name)
        df = pd.read_csv(file_path, sep =';')
        print(len(df), 'lenght, name:', file_name)
        # Add a new column with the name of the .csv file
        df['Name'] = file_name
        
        
        # Concatenate the new DataFrame with the existing one
        concatenated_df = pd.concat([concatenated_df, df], ignore_index=True)

# Print the concatenated DataFrame
print(concatenated_df)


concatenated_df_2 = pd.DataFrame()
for file_name in os.listdir(path_files_2):
    if file_name.endswith('.csv'):
        print(len(df), 'lenght, name:', file_name)
        # Read the .csv file as a new DataFrame
        file_path = os.path.join(path_files_2, file_name)
        df = pd.read_csv(file_path, sep =',')
        
        # Add a new column with the name of the .csv file
        df['Name'] = file_name
        
        # Concatenate the new DataFrame with the existing one
        concatenated_df_2 = pd.concat([concatenated_df_2, df], ignore_index=True)

# Print the concatenated DataFrame
print(concatenated_df_2)



# list_files = []
# for filepath in glob.iglob( str(path_files_1 + '*.csv')):
#     if filepath.endswith('.csv'):
#         filepath_split = filepath.partition('cleaned/')
#         filepath_split = filepath_split[2].strip('.csv')
#         print(filepath_split.rsplit('_',1))

#         list_files.append(filepath_split)
# else:
#     list_files = [file_name]


# print(list_files)