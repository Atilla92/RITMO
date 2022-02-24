import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import scipy as sp
from scipy.fft import rfft, rfftfreq, fft, fftfreq 
import seaborn as sns; sns.set_theme()
from sklearn import preprocessing
from scipy.signal import argrelextrema
from scipy.io.wavfile import read
import matplotlib.pyplot as plt
import numpy as np
from functions import *
import json
import glob

f_json = open('variables.json')
variables = json.load(f_json)


name_files = []
audio_files = []
FSR_files = []


for filepath in glob.iglob('AUDIO/*.wav'):
    if filepath.endswith('.wav'):
        filepath_split = filepath.partition('/')
        filepath_split = filepath_split[2].partition('-')
        name_files.append(filepath_split[0])
        audio_files.append(filepath)

for filepath in glob.iglob('FSR/*.csv'):
    if filepath.endswith('.csv'):
        FSR_files.append(filepath)


currentFile = name_files[3]
input_data = read(audio_files[3])
df = pd.read_csv (FSR_files[3], sep = ',', skiprows=144, encoding= 'unicode_escape') 


# Load variables steps P1_D1_T2
for item in variables['details_files']:
    if item['name'] == currentFile:
        print ('TRUE', currentFile)
        n_splits = item["n_splits"]
        start_reaper = item["start_reaper"]
        step_labels = item["step_labels"]
        step_times =item["step_times"]
        duration_s = item["duration_s"]
        steps_start_s = list_sec(step_times)
    else: 
        print ('False', currentFile)


#print(input_data)
audio = input_data[1]
audio_SR = input_data[0]
x_audio = np.divide(np.arange(len(audio)), audio_SR)


df_new = labelColumns(df, True)




    #plt.show()

#plot_audio_FSR(audio, x_audio, audio_SR, x, y1, y2, y3, y4, y5, y6)
# Paritioning data in steps

# Align with Beaper start D1




#audio_threshold, click_time = alignClapper(audio, audio_SR, threshold_clap)

##### Will have to find a way to loop this. 


audio_start, x_audio_start = setWindowAudio(audio, audio_SR, start_reaper,steps_start_s[0], duration_s[0] )
# Get time window for specific step and plot. 
step1_data, df_length = setTimeWindow(df_new, start_reaper, steps_start_s[0], duration_s[0] )

#plot_audio_FSR(audio_start,x_audio_start, audio_SR)




##### Split into section
# Define the number of splits you want
#n_splits = 11
split_y_FSR = np.array_split(step1_data, n_splits)
#split_x_FSR = np.array_split(x, 4)
split_y_audio = np.array_split(audio_start, n_splits)
split_x_audio = np.array_split(x_audio_start,n_splits)



if not variables['details_files'][0]["threshold"]:
    audio_coord_th = setThreshold(split_x_audio, split_y_audio)
    variables['details_files'][0]["threshold"] = audio_coord_th
    with open("variables.json", "w+") as f_json: 
        f_json.write(json.dumps(variables))


f, axs = initiateSubplots()
for i, item in enumerate(split_y_FSR):
    threshold_coord = audio_coord_th[i][1]
    gradient_audio = np.gradient(split_y_audio[i],split_x_audio[i])
    tStart_index = np.argmax(split_y_audio[i] >threshold_coord)
    print(tStart_index,'START', len(split_y_audio[i]))
    item_start = item.loc[(item["Time"] >= split_x_audio[i][tStart_index] ) ]
    
    
    plot_audio_FSR_split(split_y_audio[i][tStart_index:-1], split_x_audio[i][tStart_index:-1], item_start, True, axs)

plt.show()




# start_reaper_D2 = 10.868 - 4.536

# P1_D1_T3, Sitting
# input_data = read("AUDIO/P1_D1_T3-220212_1656.wav")
# df = pd.read_csv (r'FSR/12.02.2022/N21_P1_D1_T1_12022022_Rep_1.5.csv', sep = ',', skiprows=144, encoding= 'unicode_escape') 

# P1_D1_T4, Standing
# df = pd.read_csv (r'FSR/12.02.2022/N22_P1_D1_T1_12022022_Rep_1.6.csv', sep = ',', skiprows=144, encoding= 'unicode_escape') 
# input_data = read("AUDIO/P1_D1_T4-220212_1705.wav")

# # P1_D2_T1, Standing  
# df = pd.read_csv (r'FSR/12.02.2022/N23_P1_D2_T1_12022022_Rep_1.7.csv', sep = ',', skiprows=144, encoding= 'unicode_escape') 
# input_data = read("AUDIO/P1_D2_T1-220212_1808.wav")


# P1_D2_T2, Standing
# df = pd.read_csv (r'FSR/12.02.2022/N24_P1_D2_T2_12022022_Rep_1.8.csv', sep = ',', skiprows=144, encoding= 'unicode_escape') 
# input_data = read("AUDIO/P1_D2_T2-220212_1818.wav")

#Import FSR/Audio data
#df = pd.read_csv (r'FSR/12.02.2022/N21_P1_D1_T1_12022022_Rep_1.5.csv', sep = ',', skiprows=144, encoding= 'unicode_escape') 

# P1_D1_T2, Standing
