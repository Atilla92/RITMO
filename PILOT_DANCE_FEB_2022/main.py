from fileinput import filename
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
print(name_files)


step_number = 0

for i_file, fileName in enumerate(name_files):
    currentFile = fileName
    print(fileName, 'filename')
    file_number = i_file
    print(FSR_files, FSR_files[file_number], '!!!!!')

    # LOAD FSR DATA
    df = pd.read_csv (FSR_files[file_number], sep = ',', skiprows=144, encoding= 'unicode_escape') 
    df_new = labelColumns(df, False)


    #Load audio files
    input_data = read(audio_files[file_number])
    audio = input_data[1]
    audio_SR = input_data[0]
    x_audio = np.divide(np.arange(len(audio)), audio_SR)

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

            # Get steps data, split per step  
            for step_number, step_id in enumerate(step_labels):

                audio_start, x_audio_start = setWindowAudio(audio, audio_SR, start_reaper,steps_start_s[step_number], duration_s[step_number] )
                step1_data, df_length = setTimeWindow(df_new, start_reaper, steps_start_s[step_number], duration_s[step_number] )
                split_y_FSR = np.array_split(step1_data, n_splits[step_number])
                split_y_audio = np.array_split(audio_start, n_splits[step_number])
                split_x_audio = np.array_split(x_audio_start,n_splits[step_number])

                if not item["threshold"][step_number]:
                    audio_coord_th = setThreshold(split_x_audio, split_y_audio)
                    #print(audio_coord_th, 'hello threshold')
                    item["threshold"][step_number] = audio_coord_th
                    audio_coord_th = item["threshold"][step_number]
                    with open("variables.json", "w+") as f_json: 
                        f_json.write(json.dumps(variables))

                else:
                    audio_coord_th = item["threshold"][step_number]
                
                print(audio_coord_th)


                f, axs = initiateSubplots()
                for i_step, item_step in enumerate(split_y_FSR):
                    threshold_coord = audio_coord_th[i_step][1]
                    print(threshold_coord, 'threshold taken')
                    gradient_audio = np.gradient(split_y_audio[i_step],split_x_audio[i_step])
                    tStart_index = np.argmax(split_y_audio[i_step] >threshold_coord)
                    item_start = item_step.loc[(item_step["Time"] >= split_x_audio[i_step][tStart_index] ) ]  

                    plot_audio_FSR_split(split_y_audio[i_step][tStart_index:-1], split_x_audio[i_step][tStart_index:-1], item_start, True, axs)
                plt.title('Step number '+ str(step_id) + " " + str(currentFile))
                plt.show()

        else: 
            print ('False', currentFile)







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




    #plt.show()

#plot_audio_FSR(audio, x_audio, audio_SR, x, y1, y2, y3, y4, y5, y6)
# Paritioning data in steps

# Align with Beaper start D1




#audio_threshold, click_time = alignClapper(audio, audio_SR, threshold_clap)

##### Will have to find a way to loop this. 