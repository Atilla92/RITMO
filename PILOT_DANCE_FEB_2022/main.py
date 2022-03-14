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


dateFile = '12.02.2022'
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


                #f, axs = initiateSubplots()
                
                
    
                # for i_step, item_step in enumerate(split_y_FSR):
                #     threshold_coord = audio_coord_th[i_step][1]
                #     gradient_audio = np.gradient(split_y_audio[i_step],split_x_audio[i_step])
                #     tStart_index = np.argmax(split_y_audio[i_step] >threshold_coord)
                #     item_start = item_step.loc[(item_step["Time"] >= split_x_audio[i_step][tStart_index] ) ]  
                #     plot_audio_FSR_split(split_y_audio[i_step][tStart_index:-1], split_x_audio[i_step][tStart_index:-1], item_start, True, axs)


                
                # axs[0].set_title(str(currentFile)+ " - " + 'Step '+ str(step_id), fontsize = 14 )
                # #plt.savefig('./Figures/'+dateFile + '/'+ str(currentFile)+ "_"+'FSR_Audio_Step_'+ str(step_id))
                # #plt.show()
                av_steps = []
                av_y_steps = []
                av_x_steps = []
                means = []
                f,axs2 = initiateSubplots2()
                for i_step, item_step in enumerate(split_y_FSR):
                    av_step = get_average_FSR(item_step)
                    av_steps.append(av_step)
        

                    #print(av_step,'!!!!!average step')
                    # av_y_steps.append(av_step[0][0])
                    # av_x_steps.append(i_step)
            
                    axs2[0].errorbar(i_step,av_step[0][0],av_step[0][1], marker='^')
                    
                    axs2[1].errorbar(i_step,av_step[1][0],av_step[1][1], marker='^')
                    axs2[2].errorbar(i_step,av_step[2][0],av_step[2][1], marker='^')
                    axs2[3].errorbar(i_step,av_step[3][0],av_step[3][1], marker='^')
                    axs2[4].errorbar(i_step,av_step[4][0],av_step[4][1], marker='^')
                    axs2[5].errorbar(i_step,av_step[5][0],av_step[5][1], marker='^')
                    #axs2[0].boxplot(split_y_audio[1], positions = [i_step])
                print(av_steps, 'average')
                

                # for i_loc, item_loc in enumerate(av_steps):
                #     print (item_loc, 'item loc', i_loc)
                #     y1_av = [item[0] for item in item_loc]
                #     print(y1_av, 'y1 average')
                #     axs2[i_loc].plot(np.arange(len(y1_av)), y1_av, '--', color = 'k')
                
                for j in np.arange(6):
                    y1_av2 = [item[j] for item in av_steps]
                    print(y1_av2, 'second average')
                    y1_av = [item[0] for item in y1_av2]
                    print (j, 'j!!')
                #print(y1_av, 'y1 average')
                    axs2[j].plot(np.arange(len(y1_av)), y1_av, '--', color = 'k')
                # axs2[1].plot(av_x_steps, av_y_steps, '--', color = 'k')
                # axs2[2].plot(av_x_steps, av_y_steps, '--', color = 'k')
                # axs2[3].plot(av_x_steps, av_y_steps, '--', color = 'k')
                # axs2[4].plot(av_x_steps, av_y_steps, '--', color = 'k')
                #plt.show()
                axs2[0].set_title(str(currentFile)+ " - " + 'Step '+ str(step_id), fontsize = 14 )
                plt.savefig('./Figures/'+dateFile + '/'+ str(currentFile)+ "_"+'Average_Step_'+ str(step_id))
                #f2,axs2 = initiateSubplots()


                item[str(step_id)] = av_steps
                with open("variables.json", "w+") as f_json: 
                    f_json.write(json.dumps(variables))
            #print(item, 'is it working?')



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