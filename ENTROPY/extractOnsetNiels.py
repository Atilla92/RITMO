import glob
import pandas as pd

"""
Import onset .csv files from matlab onset detection from Niels (onsetNiels.m)
First row is onset times, second row represents onset intensity (estimated from the highest peak, so -4dB mean -4dB lower than the highest intensity registered for song)
Store in new .csv files transposed, easier for later analysis. 
Provide input (audio_path) and output_path to store files. 
"""


loop_on = True

audio_path = '/Volumes/WHITE LOTUS/FlamencoProject/AUDIO/HALF_AUDIO/OUTPUT_GUITAR/'
output_path = '/Users/atillajv/CODE/RITMO/ONSET/output_guitar/'
loop_off = 'P10_D6_G5_M6_R1_T1.csv'

audio_files = []
#Load Data
if loop_on:
    for filepath in glob.iglob(str(audio_path + '*.csv')):
        if filepath.endswith('.csv'):
            filepath_split = filepath.partition(audio_path[len(audio_path)-10:])
            print (filepath_split)
            #print('hello')
            audio_files.append(filepath_split[2])
else:
 audio_files = [loop_off]

for i, item in enumerate(audio_files):
   df = pd.read_csv(audio_path + item, header = None )
   #print(df)
   df_transposed = df.transpose()
   df_transposed.columns = ['t_onset', 'int_onset']
   df_transposed.to_csv(output_path + item, index = False)