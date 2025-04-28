
import pandas as pd
import glob
import os
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import stats
import numpy as np
def get_concatenated_df(input_path, body_model):
    path_to_ELAN = '/Users/atillajv/CODE/RITMO/FILES/ELAN/cleaned/'
    df_clap_times = pd.read_csv('/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/synch_audio_video/output/peak_times_video_front_small.csv')
    # Check if concatenated file already exists
    concat_file = os.path.join(input_path, f'statistics/{body_model}/Concatenated_ELAN_Energy_{body_model}.csv')
    
    if os.path.exists(concat_file):
        df_all = pd.read_csv(concat_file)
    else:
        # Get all energy CSV files
        energy_files = glob.glob(os.path.join(input_path, f'Energy_{body_model}_*.csv'))
 
        # Initialize list to store dataframes
        dfs = []
        
        # Read and process each file
        for file in energy_files:
            filename = os.path.basename(file)
            parts = filename.split('_') 
            name = filename.split(f'Energy_{body_model}_', 1)[-1].strip('.csv').split('_', 1)[1]
            name_2 =filename.split(f'Energy_{body_model}_', 1)[-1].strip('.csv')
            print(name_2,'NAME 2')
            clap_time = df_clap_times[df_clap_times['filename'] == name]['peak_time'].iloc[0]
            print(os.path.join(input_path, f'model_{body_model}_{ name_2}.json'))
            body_model_info = pd.read_json(os.path.join(input_path, f'model_{body_model}_{ name_2}.json'), typ='series')
            fps = body_model_info['fps']
            # df ELAN
            df_ELAN = pd.read_csv(path_to_ELAN + name + '.csv', sep=';')
            t_ELAN_start = df_ELAN['Begin Time - ss.msec'].iloc[0]
            t_ELAN_end = df_ELAN['End Time - ss.msec'].iloc[-1]
            t_start = np.floor((t_ELAN_start - clap_time)*fps)
            t_end = np.floor((t_ELAN_end - clap_time)*fps)
            # df motion capture
            df = pd.read_csv(file)
            print(len(df), 'RAW length df Mocap')
            df = df.iloc[int(t_start):int(t_end)]
            print(len(df), 'length df Mocap after ELAN cropping', t_start, t_end)
            
            # Extract participant and trial info from filename
           
            # Add metadata columns
            #temp_name =  filename.split('Energy_wholebody_')[-1].strip('.csv')
            df['Name'] = name
            df['Participant'] = parts[2]
            df['Artist']= parts[2][0]
            df['Condition'] = str(parts[4] +'_' + parts[6])
            df['Pair'] = str(parts[3] +'_' + parts[5])
            df['Dance_mode'] =parts[4]
            df['Music_mode'] = parts[6]
            df['Palo'] = parts[7]
            df['Take'] = parts[8].strip('.csv')
            dfs.append(df)
        
        # Concatenate all dataframes
        df_all = pd.concat(dfs, ignore_index=True)
        print(df_all['Name'].head())
        
        # Save concatenated data
        df_all.to_csv(concat_file, index=False)
        
    return df_all

def create_energy_distribution_plots(input_path, body_model):
    df_all = get_concatenated_df(input_path, body_model)

    # Create distribution plots
    energy_cols = ['E_pot_sum', 'E_kin_sum', 'E_rot_sum', 'E_trans_sum']
    
    # Set up the figures
    fig1, axes1 = plt.subplots(2, 2, figsize=(15, 10))
    fig1.suptitle(f'Energy Distribution Plots - {body_model}')
    
    # Flatten axes for easier iteration
    axes1 = axes1.flatten()
    
    # Create distribution plot for each energy type
    for i, col in enumerate(energy_cols):
        sns.histplot(data=df_all, x=col, ax=axes1[i], kde=True, 
                    bins=int(2/0.01),  # Set number of bins based on range/bin_size
                    binrange=(0, 2))    # Set range from 0 to 2
        axes1[i].set_title(f'Distribution of {col}')
        axes1[i].set_xlabel('Energy')
        axes1[i].set_ylabel('Count')
        axes1[i].set_xlim(0, 2)         # Set x-axis limits
    
    plt.tight_layout()
    plt.savefig(os.path.join(input_path, f'statistics/{body_model}/cropped/energy_distributions_{body_model}.png'))
    plt.close()

    # Create mean and std plot
    fig2, ax2 = plt.subplots(figsize=(10, 6))
    fig2.suptitle(f'Mean and Standard Deviation of Energies - {body_model}')
    
    # Calculate means and stds
    means = df_all[energy_cols].mean()
    stds = df_all[energy_cols].std()
    
    # Create bar plot with error bars
    x = range(len(energy_cols))
    ax2.bar(x, means, yerr=stds, capsize=5)
    ax2.set_xticks(x)
    ax2.set_xticklabels(energy_cols, rotation=45)
    ax2.set_ylabel('Energy')
    ax2.set_title('Mean Energy Values with Standard Deviation')
    
    plt.tight_layout()
    plt.savefig(os.path.join(input_path, f'statistics/{body_model}/cropped/energy_mean_std_{body_model}.png'))
    plt.close()

    return df_all

def create_condition_energy_plots(input_path, body_model, group_by):
    df_all = get_concatenated_df(input_path, body_model)
    energy_cols = ['E_pot_sum', 'E_kin_sum', 'E_rot_sum', 'E_trans_sum']
    
    # Get unique conditions
    conditions = df_all[group_by].unique()
    
    # Create a plot for each condition
    for condition in conditions:
        condition_df = df_all[df_all[group_by] == condition]
        
        fig, ax = plt.subplots(figsize=(10, 6))
        fig.suptitle(f'Mean and Standard Deviation of Energies\nCondition: {condition} - {body_model}')
        
        # Calculate means and stds for this condition
        means = condition_df[energy_cols].mean()
        stds = condition_df[energy_cols].std()
        
        # Create bar plot with error bars
        x = range(len(energy_cols))
        ax.bar(x, means, yerr=stds, capsize=5)
        ax.set_xticks(x)
        ax.set_xticklabels(energy_cols, rotation=45)
        ax.set_ylabel('Energy')
        ax.set_title(f'Mean Energy Values with Standard Deviation - {condition}')
        
        plt.tight_layout()
        plt.savefig(os.path.join(input_path, f'statistics/{body_model}/cropped/energy_mean_std_{condition}_{body_model}.png'))
        plt.close()

def paired_ttest_analysis(input_path, body_model, group_by_col):
    df_all = get_concatenated_df(input_path, body_model)
    
    # Remove D0 conditions
    df_all = df_all[df_all['Dance_mode'] != 'D0']
    
    energy_cols = ['E_pot_sum', 'E_kin_sum', 'E_rot_sum', 'E_trans_sum']
    
    # Calculate mean and std for each participant/condition combination
    summary_stats = df_all.groupby(['Participant', group_by_col])[energy_cols].agg(['mean', 'std']).reset_index()
    
    # Calculate overall mean and std for each condition
    overall_stats = df_all.groupby(group_by_col)[energy_cols].agg(['mean', 'std']).reset_index()
    
    # Save overall stats
    overall_stats_file = os.path.join(input_path, f'statistics/{body_model}/cropped/overall_stats_{group_by_col}_{body_model}.csv')
    overall_stats.to_csv(overall_stats_file, index=False)
    
    # Get unique conditions
    conditions = sorted(df_all[group_by_col].unique())
    
    # Initialize lists to store results
    ttest_results = []
    
    # Perform paired t-test for each pair of conditions
    for i in range(len(conditions)):
        for j in range(i + 1, len(conditions)):
            cond1, cond2 = conditions[i], conditions[j]
            
            for energy_col in energy_cols:
                # Get data for each condition
                data1 = summary_stats[summary_stats[group_by_col] == cond1][(energy_col, 'mean')]
                data2 = summary_stats[summary_stats[group_by_col] == cond2][(energy_col, 'mean')]
                
                # Perform paired t-test
                t_stat, p_val = stats.ttest_rel(data1, data2)
                
                # Store results
                ttest_results.append({
                    'Energy_Type': energy_col,
                    'Condition_1': cond1,
                    'Condition_2': cond2,
                    'T_statistic': t_stat,
                    'P_value': p_val
                })
    
    # Create results dataframe
    ttest_df = pd.DataFrame(ttest_results)
    
    # Save results
    output_file = os.path.join(input_path, f'statistics/{body_model}/cropped/paired_ttest_results_{group_by_col}_{body_model}.csv')
    ttest_df.to_csv(output_file, index=False)
    
    # Save summary statistics
    stats_file = os.path.join(input_path, f'statistics/{body_model}/cropped/summary_statistics_grouped_by_{group_by_col}_{body_model}.csv')
    summary_stats.to_csv(stats_file, index=False)
    
    return ttest_df, summary_stats, overall_stats


# Input parameters
body_model = 'upper'
group_by = 'Dance_mode'
input_path = '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/energy_toiviainen_adapted/output/28032025_dancer/'

# Run the functions
create_energy_distribution_plots(input_path, body_model)
create_condition_energy_plots(input_path, body_model, group_by)
paired_ttest_analysis(input_path, body_model, group_by)