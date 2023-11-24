"""This code will test the reliability of ELAN annotations made by different flamenco experst

1. Loop through folders. 
2. Create csv 
3. Check whether they are the same. 

"""

import pandas as pd
import glob
import os
import json
import numpy as np

path_files_1 = '/Users/atillajv/CODE/RITMO/ELAN/FILES/00' 
path_files_2 = '/Users/atillajv/CODE/RITMO/ELAN/FILES/01' 
file_output = '/Users/atillajv/CODE/RITMO/ELAN/output/'

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
        df['Name'] = file_name.strip('.csv')
        df['number'] = np.arange(len(df))
        
        
        # Concatenate the new DataFrame with the existing one
        concatenated_df = pd.concat([concatenated_df, df], ignore_index=True)
    
# Print the concatenated DataFrame
print(concatenated_df)


concatenated_df_2 = pd.DataFrame()
for file_name in os.listdir(path_files_2):

    if file_name.endswith('.csv'):
        
        # Read the .csv file as a new DataFrame
        file_path = os.path.join(path_files_2, file_name)
        df = pd.read_csv(file_path, sep =',')
        
        # Add a new column with the name of the .csv file
        df['Name'] = file_name.strip('.csvm')
        df['number'] = np.arange(len(df))
        print(len(df), 'lenght, name:', file_name)
        
        # Concatenate the new DataFrame with the existing one
        concatenated_df_2 = pd.concat([concatenated_df_2, df], ignore_index=True)


# Print the concatenated DataFrame
print(concatenated_df_2)


merged_df = pd.merge(concatenated_df, concatenated_df_2, on=["Name","number"], suffixes=("_df1", "_df2"), how="inner")

merged_df["Comparison"] = merged_df["Baile_df1"] == merged_df["Baile_df2"]
merged_df["Comparison_G"] = merged_df["Guitarra_df1"] == merged_df["Guitarra_df2"]
print(merged_df)


# Calculate the number of True values in the "Comparison" column
num_true = merged_df["Comparison"].sum()
num_true_G = merged_df["Comparison_G"].sum()
# Calculate the percentage of True values out of the total number of rows
percent_true = num_true / len(merged_df) * 100
percent_true_G = num_true_G / len(merged_df) * 100
# Print the result
print("Percentage of True B values:", percent_true)
print("Percentage of True G values:", percent_true_G)

df_out = pd.DataFrame({
    'Name' : merged_df['Name'],
    'Sequence': merged_df['Sequence_df1'],
    'Baile_1': merged_df['Baile_df1'],
    'Baile_2': merged_df['Baile_df2'],
    'Comparisson_Baile': merged_df['Comparison'],
    'Guitarra_1': merged_df['Guitarra_df1'],
    'Guitarra_2': merged_df['Guitarra_df2'],
    'Comparisson_Guitarra': merged_df['Comparison_G']
})



df_out.to_csv(file_output + 'df_comparisson_2.csv')



variables_dict = {
   'percentage_true_baile:': percent_true,
   'percentage_true_guitar' : percent_true_G
}
json_object = json.dumps(variables_dict, indent = 4)
with open(str(file_output + "variables.json"), "w") as outfile:
    outfile.write(json_object)