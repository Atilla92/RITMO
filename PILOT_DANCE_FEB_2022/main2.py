import enum
from fileinput import filename
from turtle import color
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

f_out = open('variables.json')
variables_export = json.load(f_out)


dateFile = '03.03.2022'
f_json = open('variables.json')
variables = json.load(f_json)



name_files = []
audio_files = []
FSR_files = []


for filepath in glob.iglob('AUDIO/'+ dateFile+'/*.wav'):
    if filepath.endswith('.wav'):
        filepath_split = filepath.partition('/')
        filepath_split = filepath_split[2].partition('/')
        filepath_split = filepath_split[2].partition('-')
        name_files.append(filepath_split[0])
        audio_files.append(filepath)

for filepath in glob.iglob('FSR/'+ dateFile + '/*.csv'):
    if filepath.endswith('.csv'):
        FSR_files.append(filepath)
print(name_files)


step_number = 0

empty_dict = []
for i_file, fileName in enumerate(name_files):
    currentFile = fileName
    
    print(fileName, 'filename')
    file_number = i_file
    print(FSR_files, FSR_files[file_number], '!!!!!')

    # LOAD FSR DATA

    df = pd.read_csv (FSR_files[file_number], sep = ',', skiprows=74, encoding= 'unicode_escape') 
    #print(df)
    df_new = labelColumns_2(df, False)
    print(df_new)

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

                print(step_labels, 'labels')

                audio_start, x_audio_start = setWindowAudio(audio, audio_SR, start_reaper,steps_start_s[step_number], duration_s[step_number] )
                step1_data, df_length = setTimeWindow(df_new, start_reaper, steps_start_s[step_number], duration_s[step_number] )
                split_y_FSR = np.array_split(step1_data, n_splits[step_number])
                #rint (split_y_FSR)
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


                f, axs = initiateSubplots2(labelx='Time [s]', labely='Amplitude [%]', number=4)
                
                for i_step, item_step in enumerate(split_y_FSR):
                    threshold_coord = audio_coord_th[i_step][1]
                    gradient_audio = np.gradient(split_y_audio[i_step],split_x_audio[i_step])
                    tStart_index = np.argmax(split_y_audio[i_step] >threshold_coord)
                    item_start = item_step.loc[(item_step["Time"] >= split_x_audio[i_step][tStart_index] ) ]  
                    plot_audio_FSR_split_2(split_y_audio[i_step][tStart_index:-1], split_x_audio[i_step][tStart_index:-1], item_start, True, axs)


                step_string = str(step_id) +"_" + str(step_number)
                axs[0].set_title(str(currentFile)+ " - " + 'Step '+ str(step_string), fontsize = 14 )
                plt.savefig('./Figures/'+dateFile + '/'+ str(currentFile)+ "_"+'FSR_Audio_Step_'+ str(step_string))
                #plt.show()

                
                av_steps = []
                av_y_steps = []
                av_x_steps = []
                means = []
                f,axs2 = initiateSubplots2(labelx='Repetition number', labely='Average intensity', number=3)
                for i_step, item_step in enumerate(split_y_FSR):
                    av_step = get_average_FSR_2(item_step)
                    av_steps.append(av_step)
            
                    axs2[0].errorbar(i_step,av_step[0][0],av_step[0][1], marker='^')
                    
                    axs2[1].errorbar(i_step,av_step[1][0],av_step[1][1], marker='^')
                    axs2[2].errorbar(i_step,av_step[2][0],av_step[2][1], marker='^')
                    # axs2[3].errorbar(i_step,av_step[3][0],av_step[3][1], marker='^')
                    # axs2[4].errorbar(i_step,av_step[4][0],av_step[4][1], marker='^')
                    # axs2[5].errorbar(i_step,av_step[5][0],av_step[5][1], marker='^')
                print(av_steps, 'average')
                
                for j in np.arange(3):
                    y1_av2 = [item[j] for item in av_steps]
                    print(y1_av2, 'second average')
                    y1_av = [item[0] for item in y1_av2]
                    print (j, 'j!!')
                #print(y1_av, 'y1 average')
                    axs2[j].plot(np.arange(len(y1_av)), y1_av, '--', color = 'k')

                
                axs2[0].set_title(str(currentFile)+ " - " + 'Step '+ str(step_string), fontsize = 14 )
                plt.savefig('./Figures/'+dateFile + '/Average/'+ str(currentFile)+ "_"+'Average_Step_'+ str(step_string))
                #f2,axs2 = initiateSubplots()
                

                item[step_string] = av_steps
                with open("variables.json", "w+") as f_json: 
                    f_json.write(json.dumps(variables))
            #print(item, 'is it working?')



        else: 
            print ('False', currentFile)
        
