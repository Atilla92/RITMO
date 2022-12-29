import pandas as pd
import glob

folder = "/Users/atillajv/CODE/RITMO/ENTROPY/output/main/"
file_output = '/Users/atillajv/CODE/RITMO/ENTROPY/output/mean/means.csv'
# fileName = "Entropy_LZ_CTW_(w=4000_s=[]_ds=4_b=on_abs=on_t0=0)_P3_D0_G1_M6_R1_T1.csv"
# df = pd.read_csv(str(folder + fileName))
# dfSmall = df[1:]
# mean = dfSmall.mean(axis = 0)
# print(mean, df.iloc[0]) 

fileName = "Entropy_LZ_CTW_(w=4000_s=[]_ds=4_b=on_abs=on_t0=0)_"
csv_files = []

for filepath in glob.iglob('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/*.csv'):
    if filepath.endswith('.csv'):
        filepath_split = filepath.partition(')_')
        #print (filepath_split)
        csv_files.append(filepath_split[2].strip('.csv'))


mean_CTW = []
mean_LZ = []
for i, item in enumerate(csv_files):
    df = pd.read_csv(str(folder + fileName + item + '.csv'))
    mean_LZ.append(df.iloc[0,2])
    mean_CTW.append( df.iloc[0,3])
    df_new = pd.DataFrame()



df_new = pd.DataFrame({
    'Name': csv_files,
    'LZ': mean_LZ,
    'CTW': mean_CTW})


def InfotoColumns(df):
    """ Create columns with mode, music and palo information seperately"""

    dance_array = []
    music_array = []
    palo_array = []
    participant_array = []
    for i, item in enumerate(df['Name']):

        split_array = item.split('_')
        participant_array.append(split_array[0])
        dance_array.append(split_array[1])
        music_array.append(split_array[3])
        palo_array.append(split_array[4])
        print(split_array)

    df['Dance_mode'] = dance_array
    df['Music_mode'] = music_array
    df['Palo'] = palo_array
    df['Participant'] = participant_array

InfotoColumns(df_new)
print(df_new)

df_new.to_csv(file_output, index = False)


# I would say just add two columns to PD, if finds a match, insert. 
# Loop through long csv, find matching entropy, append.
