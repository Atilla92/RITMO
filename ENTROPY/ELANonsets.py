from asyncore import file_dispatcher
import pandas as pd
import numpy as np
import glob
import json

#And have to add the response, from csv for subjective ratings. Does that make sense?

# One file or all in a specific folder
file_name = 'P11_D6_G6_M6_R1_T2' # Name file if loop_on = False
loop_on = True # True if you want to loop through folder
path_files = '/Users/atillajv/CODE/RITMO/FILES/ELAN/cleaned/'
#path_ratings = '/Users/atillajv/CODE/RITMO/FILES/Ratings/'
#file_output = '/Users/atillajv/CODE/RITMO/ENTROPY/output/main/all_experiments_097/' #check that this is the same as input file for entropy
file_output = '/Users/atillajv/CODE/RITMO/ENTROPY/output/main/24_Aug_2023/' #check that this is the same as input file 
# Default settings 
percentage = 0.1
frac_round = 1 #Round/frac_round for moving rating to the left 
dt_L = 2 #Number of seconds delay in rating of user. 
name_output = '23082023_ELAN_no_CDRS_onset_dt_LZ_1s_sync'

list_files = []
#error_files = []


if loop_on:
    for filepath in glob.iglob( str(path_files + '*.csv')):
        if filepath.endswith('.csv'):
            filepath_split = filepath.partition('cleaned/')
            filepath_split = filepath_split[2].strip('.csv')
            print(filepath_split.rsplit('_',1))

            list_files.append(filepath_split)
else:
    list_files = [file_name]


print(list_files)

# Initiate dataframe before loop 
store_i = 0
df_store = pd.DataFrame(columns=['Name', 'Duration', 'Participant', 'Music_Imp', 'Dance_Imp', 'Baile_Level','Guitarra_Level' ,'Step', 'Artist',
'CTW', 'LZ','Assigned_Cat', 'Rounds', 
'Q1a',
'Q1b',
'Q2a',
'Q2b',
'Q2c',
'Q2d',
'Q2e',
'Q2f',
'Q2g',
'Q2h',
'Q2i',
'Q2j',
'Q3a',
'Q3b',
'Q4a',
'Q4b',
'Q4c',
'Q5a',
'Q5b',
'Q6a',
'Q6b',
'Abs_Av',
'Perf_Av',
'SFS',
'Dance_mode',
'Music_mode',
'Palo',
# 'MIR_entropy',
# 'MIR_entropy_avg',
# 'MIR_rms',
# 'MIR_rms_avg',
# 'MIR_novelty',
# 'MIR_novelty_avg',
# 'var_entropy',
# 'var_entropy_avg',
# 'MIR_entropy',
# 'MIR_entropy_avg',
# 'MIR_rms',
# 'MIR_rms_avg',
# 'MIR_novelty',
# 'MIR_novelty_avg',
# 'var_entropy',
# 'var_entropy_avg',
'LZ',
'dt_LZ',
'LZ_avg',
'dt_LZ_avg',
'IOI',
'IOI_avg',
'p_LZ',
'p_dt_LZ',
'p_LZ_avg',
'p_dt_LZ_avg',
'p_IOI',
'p_IOI_avg',
# 'p_MIR_entropy',
# 'p_MIR_entropy_avg',
# 'p_MIR_rms',
# 'p_MIR_rms_avg',
# 'p_MIR_novelty',
# 'p_MIR_novelty_avg',
# 'p_var_entropy',
# 'p_var_entropy_avg',
'g_LZ',
'g_dt_LZ',
'g_LZ_avg',
'g_dt_LZ_avg',
'g_IOI',
'g_IOI_avg',
'p_lag_0', 
'g_lag_0' ,
'p_lag_avg',
'g_lag_avg',
# 'g_MIR_entropy',
# 'g_MIR_entropy_avg',
# 'g_MIR_rms',
# 'g_MIR_rms_avg',
# 'g_MIR_novelty',
# 'g_MIR_novelty_avg',
# 'g_var_entropy',
# 'g_var_entropy_avg',
'annot_frac',
'number',
])

def loopThroughFiles (list_files, artist_label, percentage = percentage , frac_round = frac_round, dt_L = dt_L, error_files = [], store_i= 0 , df_store = df_store  ):

    for file_i, file_item in enumerate(list_files):
        print('FILE BEING ANALYSED: ', file_item)
        #prefix = file_item_long.partition('_')[1]
        #prefixParticipant = file_item_long.partition('_')[0]
        #file_item = file_item_long.split('_',1)[1]

        try:
            # ELAN folder with files with annotations
            dfI = pd.read_csv ('/Users/atillajv/CODE/RITMO/FILES/ELAN/cleaned/' + file_item + '.csv',  delimiter=';')
            # Csv file with during experiments results 
            dfS = pd.read_csv('/Users/atillajv/CODE/RITMO/FILES/Subjective/DuringExperiments_Andalucia_20072023_DropW.csv')
            p_dfL = pd.read_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/24_Aug_2023/LeadingFollowing_1s_Dancer.csv', skiprows=[1])
            g_dfL = pd.read_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/24_Aug_2023/LeadingFollowing_1s_Guitarist.csv', skiprows=[1])
            print('OK!!!!')
            # Features files based on original sound files
            dfE = pd.read_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/24_Aug_2023_all_Onset_1s/'+file_item+'.csv')[1:]
            #dfMIR_entropy = pd.read_csv('/Users/atillajv/CODE/RITMO/FILES/MIR/features_all_experiments/zoom/ENTROPY/' + file_item + '.csv')
            #dfMIR_novelty = pd.read_csv('/Users/atillajv/CODE/RITMO/FILES/MIR/features_all_experiments/zoom/NOVELTY/' + file_item + '.csv')
            #df_var = pd.read_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/all_experiments_095/var/'+file_item+'.csv')[1:]
            #print('ok')

            # Features files based on drums sound files
            p_dfE = pd.read_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/24_Aug_2023_all_Onset_drums_1s/'+file_item+'.csv')[1:]
            # p_dfMIR_entropy = pd.read_csv('/Users/atillajv/CODE/RITMO/FILES/MIR/features_all_experiments/drums/ENTROPY/' + file_item + '.csv')
            # p_dfMIR_novelty = pd.read_csv('/Users/atillajv/CODE/RITMO/FILES/MIR/features_all_experiments/drums/NOVELTY/' + file_item + '.csv')
            # p_df_var = pd.read_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/all_experiments_095_drums/var/'+file_item+'.csv')[1:]
            #print('ok2')
            # Features files based on drums sound files
            g_dfE = pd.read_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/24_Aug_2023_all_Onset_guitar_zd_1s/'+file_item+'.csv')[1:]
            # g_dfMIR_entropy = pd.read_csv('/Users/atillajv/CODE/RITMO/FILES/MIR/features_all_experiments/guitar_zoom/ENTROPY/' + file_item + '.csv')
            # g_dfMIR_novelty = pd.read_csv('/Users/atillajv/CODE/RITMO/FILES/MIR/features_all_experiments/guitar_zoom/NOVELTY/' + file_item + '.csv')
            # g_df_var = pd.read_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/all_experiments_095_guitar_zd/var/'+file_item+'.csv')[1:]
            # #print('ok1', file_item)


            # Estimate interval 
            # Add percentage 10%
            dtI = dfI['Duration - ss.msec']
            rounds = dfI['Bloques']
            tI_0 = dfI['Begin Time - ss.msec'] - (dtI * percentage )
            tI_1 = dfI['End Time - ss.msec'] + (dtI * percentage )
            dtI_2 = tI_1 - tI_0

        # Arrays for MIR values

            # Start a loop
            mean_array = []
            proportion_array = []
            mean_array_flow = []
            proportion_array_flow = []
            Imp_average = []
            LZ_average = []
            CTW_average = []
            MIR_entropy_avg = []
            MIR_rms_avg = []
            n=0
            m=0

            #print(dfR_flow, tR_end_flow, tI_0, tI_1, tR_end)

            for i, item in enumerate(tI_0):

                list_Entropy = dfE.loc[(dfE["t0"] >= tI_0.iloc[i] ) & (dfE['t0'] <= tI_1.iloc[i]  ) ]

                # # Fetching Spectral Entropy MIR in intervals
                # list_MIR_entropy = dfMIR_entropy.loc[(dfMIR_entropy["entropy_t0"] >= tI_0.iloc[i] ) & (dfMIR_entropy['entropy_t0'] <= tI_1.iloc[i]  ) ]
            
                # # Fetching Novelty MIR in intervals
                # list_MIR_novelty = dfMIR_novelty.loc[(dfMIR_novelty["novelty_t0"] >= tI_0.iloc[i] ) & (dfMIR_novelty['novelty_t0'] <= tI_1.iloc[i]  ) ]
            
                # # Fetching Variance Entropy within interval
                # list_var =  df_var.loc[(df_var["t0"] >= tI_0.iloc[i] ) & (df_var['t0'] <= tI_1.iloc[i]  ) ]

                #SAME FOR DRUMS
                #Fetching LZ entropy in intervals
                p_list_Entropy = p_dfE.loc[(p_dfE["t0"] >= tI_0.iloc[i] ) & (p_dfE['t0'] <= tI_1.iloc[i]  ) ]

                # # Fetching Spectral Entropy MIR in intervals
                # p_list_MIR_entropy = p_dfMIR_entropy.loc[(p_dfMIR_entropy["entropy_t0"] >= tI_0.iloc[i] ) & (p_dfMIR_entropy['entropy_t0'] <= tI_1.iloc[i]  ) ]
            
                # # Fetching Novelty MIR in intervals
                # p_list_MIR_novelty = p_dfMIR_novelty.loc[(p_dfMIR_novelty["novelty_t0"] >= tI_0.iloc[i] ) & (p_dfMIR_novelty['novelty_t0'] <= tI_1.iloc[i]  ) ]
            
                # # Fetching Variance Entropy within interval
                # p_list_var =  p_df_var.loc[(p_df_var["t0"] >= tI_0.iloc[i] ) & (p_df_var['t0'] <= tI_1.iloc[i]  ) ]

                # #SAME FOR Guitar
                #Fetching LZ entropy in intervals
                g_list_Entropy = g_dfE.loc[(g_dfE["t0"] >= tI_0.iloc[i] ) & (g_dfE['t0'] <= tI_1.iloc[i]  ) ]

                # Fetching Spectral Entropy MIR in intervals
                # g_list_MIR_entropy = g_dfMIR_entropy.loc[(g_dfMIR_entropy["entropy_t0"] >= tI_0.iloc[i] ) & (g_dfMIR_entropy['entropy_t0'] <= tI_1.iloc[i]  ) ]
            
                # # Fetching Novelty MIR in intervals
                # g_list_MIR_novelty = g_dfMIR_novelty.loc[(g_dfMIR_novelty["novelty_t0"] >= tI_0.iloc[i] ) & (g_dfMIR_novelty['novelty_t0'] <= tI_1.iloc[i]  ) ]
            
                # # Fetching Variance Entropy within interval
                # g_list_var =  g_df_var.loc[(g_df_var["t0"] >= tI_0.iloc[i] ) & (g_df_var['t0'] <= tI_1.iloc[i]  ) ]


                # Store values in new dataframe
                dfTest = dfS[ (dfS['Name'].str.contains(file_item))& (dfS['Participant'].str.contains(artist_label)) ]
                p_dFL_test = p_dfL[p_dfL[p_dfL.columns[0]].str.contains(file_item)]
                g_dFL_test = g_dfL[g_dfL[g_dfL.columns[0]].str.contains(file_item)]
            
                #print(dfTest, 'TESSST')
                df_store.loc[store_i] = {
                    'Name': file_item,
                    'Duration': dfI['Duration - ss.msec'].iloc[i],
                    'Participant' : dfTest['Participant'].iloc[0],
                    'Music_Imp': dfI['Music_Mode'].iloc[i],
                    'Dance_Imp': dfI['Category'].iloc[i],
                    'Step': dfI['Step'].iloc[i],
                    'Artist': dfTest['Artist'].iloc[0],
                    'Baile_Level': dfI['Baile'].iloc[i],
                    'Guitarra_Level': dfI['Guitarra'].iloc[i],
                    'Rounds':dfI['Bloques'].iloc[i],
                    "Q1a": dfTest["Q1a"].iloc[0],
                    "Q1b": dfTest["Q1b"].iloc[0],
                    "Q2a": dfTest["Q2a"].iloc[0],
                    "Q2b": dfTest["Q2b"].iloc[0],
                    "Q2c": dfTest["Q2c"].iloc[0],
                    "Q2d": dfTest["Q2d"].iloc[0],
                    "Q2e": dfTest["Q2e"].iloc[0],
                    "Q2f": dfTest["Q2f"].iloc[0],
                    "Q2g": dfTest["Q2g"].iloc[0],
                    "Q2h": dfTest["Q2h"].iloc[0],
                    "Q2i": dfTest["Q2i"].iloc[0],
                    "Q2j": dfTest["Q2j"].iloc[0],
                    "Q3a": dfTest["Q3a"].iloc[0],
                    "Q3b": dfTest["Q3b"].iloc[0],
                    "Q4a": dfTest["Q4a"].iloc[0],
                    "Q4b": dfTest["Q4b"].iloc[0],
                    "Q4b": dfTest["Q4b"].iloc[0],
                    "Q4c": dfTest["Q4c"].iloc[0],
                    "Q5a": dfTest["Q5a"].iloc[0],
                    "Q5b": dfTest["Q5b"].iloc[0],
                    "Q6a": dfTest["Q6a"].iloc[0],
                    "Q6b": dfTest["Q6b"].iloc[0],
                    "Abs_Av": dfTest["Abs_Av"].iloc[0],
                    "Perf_Av": dfTest["Perf_Av"].iloc[0],
                    "SFS": dfTest["SFS"].iloc[0],
                    "Dance_mode": dfTest["Dance_mode"].iloc[0],
                    "Music_mode": dfTest["Music_mode"].iloc[0],
                    "Palo": dfTest["Palo"].iloc[0],
                    'dt_LZ': list_Entropy['dt_LZ'].mean() ,
                    'LZ': list_Entropy['LZ'].mean(),
                    'IOI': list_Entropy['IOI'].mean(),
                    "LZ_avg": dfE["LZ"].mean(),
                    "dt_LZ_avg": dfE["dt_LZ"].mean(),
                    "IOI_avg": dfE["IOI"].mean(),
                    # 'MIR_entropy' : list_MIR_entropy['entropy'].mean() ,
                    # 'MIR_entropy_avg' : dfMIR_entropy['entropy'].mean(),
                    # 'MIR_rms' : list_MIR_entropy['rms'].mean(),
                    # 'MIR_rms_avg' : dfMIR_entropy['rms'].mean(),
                    # 'MIR_novelty' : list_MIR_novelty['novelty'].mean() ,
                    # 'MIR_novelty_avg' : dfMIR_novelty['novelty'].mean(),
                    # 'var_entropy': list_var['var'].mean(),
                    # 'var_entropy_avg': df_var['var'].mean(),
                    'p_dt_LZ' : p_list_Entropy['dt_LZ'].mean() ,
                    'p_LZ' : p_list_Entropy['LZ'].mean(),
                    "p_LZ_avg": p_dfE["LZ"].mean(),
                    "p_dt_LZ_avg": p_dfE["dt_LZ"].mean(),
                    'p_IOI': p_list_Entropy['IOI'].mean(),
                    "p_IOI_avg": p_dfE["IOI"].mean(),
                    # 'p_MIR_entropy' : p_list_MIR_entropy['entropy'].mean() ,
                    # 'p_MIR_entropy_avg' : p_dfMIR_entropy['entropy'].mean(),
                    # 'p_MIR_rms' : p_list_MIR_entropy['rms'].mean(),
                    # 'p_MIR_rms_avg' : p_dfMIR_entropy['rms'].mean(),
                    # 'p_MIR_novelty' : p_list_MIR_novelty['novelty'].mean() ,
                    # 'p_MIR_novelty_avg' : p_dfMIR_novelty['novelty'].mean(),
                    # 'p_var_entropy' : p_list_var['var'].mean(),
                    # 'p_var_entropy_avg' : p_df_var['var'].mean(),
                    'g_dt_LZ' : g_list_Entropy['dt_LZ'].mean() ,
                    'g_LZ' : g_list_Entropy['LZ'].mean(),
                    "g_LZ_avg" : g_dfE["LZ"].mean(),
                    "g_dt_LZ_avg" : g_dfE["dt_LZ"].mean(),
                    'g_IOI': g_list_Entropy['IOI'].mean(),
                    "g_IOI_avg": g_dfE["IOI"].mean(),
                    # 'g_MIR_entropy' : g_list_MIR_entropy['entropy'].mean() ,
                    # 'g_MIR_entropy_avg' : g_dfMIR_entropy['entropy'].mean(),
                    # 'g_MIR_rms' : g_list_MIR_entropy['rms'].mean(),
                    # 'g_MIR_rms_avg' : g_dfMIR_entropy['rms'].mean(),
                    # 'g_MIR_novelty' : g_list_MIR_novelty['novelty'].mean() ,
                    # 'g_MIR_novelty_avg' : g_dfMIR_novelty['novelty'].mean(),
                    # 'g_var_entropy' : g_list_var['var'].mean(),
                    # 'g_var_entropy_avg' : g_df_var['var'].mean(),
                    'p_lag_0' : p_dFL_test['Lag_0'].iloc[0],
                    'g_lag_0' : g_dFL_test['Lag_0'].iloc[0],
                    'p_lag_avg': p_dFL_test['Row_Avg'].iloc[0] ,
                    'g_lag_avg':g_dFL_test['Row_Avg'].iloc[0] ,
                    'annot_frac' : '',
                    'number': i,
                    }

                store_i = store_i+1

                mean_array = []
                proportion_array = []
                mean_array_flow = []
                proportion_array_flow = []
                
            dfI['Imp_subj'] = Imp_average

        except:
            print('file not found: ', file_item)
            error_files.append(file_item)         

            pass
        dfTest = dfS[ (dfS['Name'].str.contains(file_name)) ]
        #print(df_store)
    return df_store, error_files

df1_P, error_files_P = loopThroughFiles(list_files, 'P')
df1 = df1_P.copy()
df2, error_files_G = loopThroughFiles(list_files, 'G')
error_files = error_files_P + error_files_G
print(df2)

df_store = pd.concat([df1, df2])
# print(df_new, 'NEW')
df_store = df_store.reset_index(drop=True)

print(df_store)

def InfotoColumns(df):
    dance_array = []
    music_array = []
    palo_array = []
    participant_array = []
    condition_array = []
    pair_array = []
    for i, item in enumerate(df['Name']):

        split_array = item.split('_')
        participant_array.append(split_array[0])
        dance_array.append(split_array[1])
        music_array.append(split_array[3])
        palo_array.append(split_array[4])
        condition_array.append(str(split_array[1] +'_' + split_array[3]))
        pair_array.append(str(split_array[0]+ '_' + split_array[2]))
        #print(split_array)

    df['Dance_mode'] = dance_array
    df['Music_mode'] = music_array
    df['Palo'] = palo_array
    df['Condition']= condition_array
    df['Pair'] = pair_array
    #df['Participant'] = participant_array

InfotoColumns(df_store)


# Drop duplicates due to running code twice for flow and impro ratings. 

df_store.drop_duplicates(subset=None, keep="first", inplace=True)

df_store.to_csv(file_output + name_output + '.csv')



variables_dict = {
    "filesNotFound" : error_files,
}

# Store non found files, check why these are not found. 
json_object = json.dumps(variables_dict, indent = 4)
with open(str(file_output + "FilesNotFound_" + name_output + ".json"), "w") as outfile:
    outfile.write(json_object)



