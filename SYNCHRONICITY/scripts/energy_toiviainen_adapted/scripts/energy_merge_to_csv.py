import pandas as pd
import glob
import os

# Define paths for all three folders
paths = {
    'dancer': '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/energy_toiviainen_adapted/output/26092024_dancer/',
    'guitarist': '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/energy_toiviainen_adapted/output/26092024_guitarist/',
    'side': '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/energy_toiviainen_adapted/output/26092024_side/'
}

# List of energy types
energy_types = ['E_pot', 'E_rot', 'E_trans', 'E_kin']

# Function to process files and create DataFrame
def process_files(path, perspective):
    data = {}
    files = glob.glob(os.path.join(path, '*.csv'))
    
    for file in files:
        file_split = file.split('/Energy_')[-1].split('_')
        body_part = file_split[0]
        trial_name = '_'.join(file_split[2:]).replace('.csv', '')
        
        df = pd.read_csv(file)
        
        if trial_name not in data:
            data[trial_name] = {'trial_name': trial_name}
        
        for energy in energy_types:
            mean = df[f'{energy}_sum'].mean()
            std = df[f'{energy}_sum'].std()
            data[trial_name][f'{energy}_{body_part}_mean_{perspective}'] = mean
            data[trial_name][f'{energy}_{body_part}_std_{perspective}'] = std
    
    return pd.DataFrame(list(data.values()))

# Create DataFrames for each perspective
df_dancer = process_files(paths['dancer'], 'dancer')
df_guitarist = process_files(paths['guitarist'], 'guitarist')
df_side = process_files(paths['side'], 'side')

# Merge DataFrames
df_merged = pd.merge(df_dancer, df_guitarist, on='trial_name', how='outer')
df_merged = pd.merge(df_merged, df_side, on='trial_name', how='outer')

# Print the merged DataFrame for inspection
print("Merged DataFrame:")
# Define the output path
output_path = '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/energy_toiviainen_adapted/output/test/'
output_filename = 'merged_df_test_04102024.csv'

# Ensure the output directory exists
os.makedirs(output_path, exist_ok=True)

# Save the merged DataFrame to CSV
df_merged.to_csv(os.path.join(output_path, output_filename), index=False)

print(f"Merged DataFrame saved to: {os.path.join(output_path, output_filename)}")