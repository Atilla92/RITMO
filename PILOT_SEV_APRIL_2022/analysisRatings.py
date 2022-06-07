import glob
import matplotlib.pyplot as plt
import pandas as pd
import os
import scipy as sp
import numpy as np
from scipy.io.wavfile import read

### Initiate variables
name_files = []
audio_files = []
FSR_files = []
step_number = 0
empty_dict = []

### Fetch all files for analysis
path = '/Users/atillajv/CODE/FILES/PILOT_SEV_APRIL_2022/Audio'
paths_audio = glob.glob(os.path.join(path, '*.wav'))

audio_files = os.listdir(path)
print(paths_audio)
# print(filelist)
fig = plt.figure()
filelist = []
for filepath in glob.iglob('Ratings/'+'*.csv'):
    
    
    #print(file_split, 'splitted file')
    # filelist.append(filepath)

   # if (filepath.endswith('_IMPRO.csv') and  'R1' in file_split and 'P3' in file_split):
    if (filepath.endswith('_IMPRO.csv')):
        current_file  = filepath.rsplit('_', 1)[0].rsplit('/')[1].split('_',1)[1] 
        df= pd.read_csv(filepath, sep = ',')
       
        path_audio_file = path + '/' + current_file + '.wav'
        audio_data = read(path_audio_file)[1][100]
        print(audio_data)
        x_array = np.arange(len(audio_data))
    
       # print (filepath) 
        #interpolator = sp.interpolate.interp1d(df['Time'], df[' Value'], kind = 'zero') 
        #plt.scatter(df['Time'], df[' Value'], color = 'red')
        #plt.step(df['Time'], df[' Value'], where='post')
        plt.plot(x_array,audio_data)
        #plt.show()
    # if filepath.endswith('_FLOW.csv'):
    #     plt.scatter(df['Time'], df[' Value'], color = 'blue')

#print(filelist.sort())
#plt.show()
    




        # filepath_split = filepath.partition('/')
        # filepath_split = filepath_split[2].partition('/')
        # filepath_split = filepath_split[2].partition('-')
        # name_files.append(filepath_split[0])
        # audio_files.append(filepath)

# for filepath in glob.iglob('FSR/'+ dateFile + '/*.csv'):
#     if filepath.endswith('.csv'):
#         FSR_files.append(filepath)
