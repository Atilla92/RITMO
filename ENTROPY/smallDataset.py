'''
Create a small set of the data, with only LZ and varEnropy averaged as extra ouput. 
'''

import pandas as pd

file_output = '/Users/atillajv/CODE/RITMO/ENTROPY/output/mean/macroDataset_05_Jan_2023_095.csv'

df = pd.read_csv('/Users/atillajv/CODE/RITMO/FILES/Subjective/DuringExperiments_Sevilla_06102022_DropW_Entropy.csv')
print(df)
df['LZ_avg'] = ''
df['var_entropy_avg'] = ''
df['MIR_entropy_avg'] = ''
df['MIR_novelty_avg'] = ''
error_files = []
print (df)
for ind in df.index:
    name_file = df['Name'][ind]
    df_LZ = pd.read_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/05_Jan_2023_095/' + name_file + '.csv')
    df_var = pd.read_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/05_Jan_2023_095/var/' + name_file + '.csv')

    df['LZ_avg'].loc[ind] = df_LZ['LZ'].mean()
    df['var_entropy_avg'][ind] = df_var['var'].mean()
    try:    
        dfMIR_entropy = pd.read_csv('/Users/atillajv/CODE/RITMO/FILES/MIR/ENTROPY/' + name_file + '.csv')
        dfMIR_novelty = pd.read_csv('/Users/atillajv/CODE/RITMO/FILES/MIR/NOVELTY/' + name_file + '.csv')
        #print(df_LZ)
        print( df_LZ['LZ'].mean())

        df['MIR_entropy_avg'][ind] = dfMIR_entropy['entropy'].mean()
        df['MIR_novelty_avg'][ind] = dfMIR_novelty['novelty'].mean()

    except: 
        print('file not found: ', name_file)
        error_files.append(name_file)
        pass


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
        pair_array.append(str(split_array[0]+ '_' + split_array[1]))
        #print(split_array)

    df['Dance_mode'] = dance_array
    df['Music_mode'] = music_array
    df['Palo'] = palo_array
    df['Condition']= condition_array
    df['Pair'] = pair_array
    
    #df['Participant'] = participant_array

InfotoColumns(df)
#print(df_store)

#print(dfS)

df.loc[df['Condition']== 'D6_M6' , 'Condition_order'] = 0
df.loc[df['Condition']== 'D5_M6' , 'Condition_order'] = 1
df.loc[df['Condition']== 'D1_M6' , 'Condition_order'] = 2
df.loc[df['Condition']== 'D5_M5' , 'Condition_order'] = 3
df.loc[df['Condition']== 'D1_M1' , 'Condition_order'] = 4

print(df)

df.to_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/mean/macroDataset_05_Jan_2023_095.csv')
print('hello')