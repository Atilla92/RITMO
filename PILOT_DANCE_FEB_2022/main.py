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
from scipy.stats import norm
import matplotlib.pyplot as plt
import numpy as np
from functions import *
import json
import glob
import matplotlib.mlab as mlab  

### Set date of files to fetch 
dateFile = '12.02.2022'


# Bandpass filter
f_low = 0.5
f_high = 10
fs = 1.481481*10**2


### Load JSON with information of files 
f_json = open('variables.json')
variables = json.load(f_json)

### Initiate variables
name_files = []
audio_files = []
FSR_files = []
step_number = 0
empty_dict = []

### Fetch all files for analysis
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



### Loop through files
for i_file, fileName in enumerate(name_files):
    currentFile = fileName  
    file_number = i_file
    
    ### LOAD FSR DATA
    df = pd.read_csv (FSR_files[file_number], sep = ',', skiprows=144, encoding= 'unicode_escape') 
    df_new = labelColumns(df, False)

    ### Apply Bandpass Filter, set f_low, f_high
    BandPassFilterData(df, f_low, f_high, fs, 4)
 

    ### Load audio files
    input_data = read(audio_files[file_number])
    audio = input_data[1]
    audio_SR = input_data[0]
    x_audio = np.divide(np.arange(len(audio)), audio_SR)


    ### Load variables steps
    for item in variables['details_files']:
        
        store_avs = []
        if item['name'] == currentFile: 
            print ('TRUE', currentFile)
            n_splits = item["n_splits"]
            start_reaper = item["start_reaper"]
            step_labels = item["step_labels"]
            step_times =item["step_times"]
            duration_s = item["duration_s"]
            steps_start_s = list_sec(step_times)

            ### Get steps data, split per step  
            for step_number, step_id in enumerate(step_labels):

                audio_start, x_audio_start = setWindowAudio(audio, audio_SR, start_reaper,steps_start_s[step_number], duration_s[step_number] )
                step1_data, df_length = setTimeWindow(df_new, start_reaper, steps_start_s[step_number], duration_s[step_number] )
                split_y_FSR = np.array_split(step1_data, n_splits[step_number])
                split_y_audio = np.array_split(audio_start, n_splits[step_number])
                split_x_audio = np.array_split(x_audio_start,n_splits[step_number])
                print(np.shape(np.array(step1_data).tolist()),'FSR')
                print(step1_data)

                ### Set threshold for step onset
                if not item["threshold"][step_number]:
                    audio_coord_th = setThreshold(split_x_audio, split_y_audio)
                    item["threshold"][step_number] = audio_coord_th
                    audio_coord_th = item["threshold"][step_number]
                    print(audio_coord_th)
                    with open("variables.json", "w+") as f_json: 
                        f_json.write(json.dumps(variables))
                        print('Coordinates Saved')

                else:
                    audio_coord_th = item["threshold"][step_number]

                ### Split audio in equal sections for number of repetitions per step
                ### Plot audio and FSR for step repititions
                f, axs = initiateSubplots()
                for i_step, item_step in enumerate(split_y_FSR):
                    threshold_coord = audio_coord_th[i_step][1]
                    gradient_audio = np.gradient(split_y_audio[i_step],split_x_audio[i_step])
                    tStart_index = np.argmax(split_y_audio[i_step] >threshold_coord)
                    item_start = item_step.loc[(item_step["Time"] >= split_x_audio[i_step][tStart_index] ) ] 
                    plot_audio_FSR_split(split_y_audio[i_step][tStart_index:-1], split_x_audio[i_step][tStart_index:-1], item_start, True, axs)


                ### Save plots per step
                step_string = str(step_id) +"_" + str(step_number)
                axs[0].set_title(str(currentFile)+ " - " + 'Step '+ str(step_string), fontsize = 14 )
                plt.savefig('./Figures/'+dateFile + '/'+ str(currentFile)+ "_"+'FSR_Audio_Step_'+ str(step_string))
                #plt.show()


                ### Estimate average and std
                ### Initiate variables for storage
                av_steps = []
                av_y_steps = []
                av_x_steps = []
                means = []
                avs = []
                f,axs2 = initiateSubplots2(labelx='Repetition number', labely='Average intensity', number=6)
                for i_step, item_step in enumerate(split_y_FSR):
                    av_step, av = get_average_FSR(item_step)
                    av_steps.append(av_step)
                    avs.append(av)
                    axs2[0].errorbar(i_step,av_step[0][0],av_step[0][1], marker='^')   
                    axs2[1].errorbar(i_step,av_step[1][0],av_step[1][1], marker='^')
                    axs2[2].errorbar(i_step,av_step[2][0],av_step[2][1], marker='^')
                    axs2[3].errorbar(i_step,av_step[3][0],av_step[3][1], marker='^')
                    axs2[4].errorbar(i_step,av_step[4][0],av_step[4][1], marker='^')
                    axs2[5].errorbar(i_step,av_step[5][0],av_step[5][1], marker='^') 

                for j in np.arange(6):
                    y1_av2 = [item[j] for item in av_steps]
                    y1_av = [item[0] for item in y1_av2]
                    axs2[j].plot(np.arange(len(y1_av)), y1_av, '--', color = 'k')

                
                ### Additional Computations ####
                ### Compute average intensity per step
                avs_mean = np.mean(avs, axis = 0)
                store_avs.append(avs_mean.tolist())



                ### Save figures
                step_string = str(step_id) +"_" + str(step_number)
                axs2[0].set_title(str(currentFile)+ " - " + 'Step '+ str(step_string), fontsize = 14 )
                plt.savefig('./Figures_2/'+dateFile + '/Average/'+ str(currentFile)+ "_"+'Average_Step_'+ str(step_string))

                ### Store average per step in json
                item[step_string] = avs
                with open("variables.json", "w+") as f_json: 
                    f_json.write(json.dumps(variables))
                

                                ### Entropy

                f,axs3 = initiateSubplots3(labelx='Pressure - Intensity', labely='', number=6)

            
                plotNDF(step1_data, 1, 5, 60, 100, axs3, 0,0, 0.15 )
                plotNDF(step1_data, 2, 5, 60, 100, axs3, 1,0, 0.15 )
                plotNDF(step1_data, 3, 2, 60, 100, axs3, 2,0, 0.25 )
                plotNDF(step1_data, 4, 5, 60, 100, axs3, 0,1, 0.15 )
                plotNDF(step1_data, 5, 5, 60, 100, axs3, 1,1, 0.15 )
                plotNDF(step1_data, 6, 2, 60, 100, axs3, 2,1, 0.25 )
                axs3[0,0].set_title('Left Foot', fontsize = 14 )
                axs3[0,1].set_title('Right Foot', fontsize = 14 )
                axs3[0,0].set( ylabel = 'Toe' )
                axs3[1,0].set( ylabel = 'Metatarsal' )
                axs3[2,0].set( ylabel = 'Heel' )
 
 
                f.suptitle("Histogram Plot " + str(currentFile)+ " - " + 'Step '+ str(step_id), fontsize=16)
                plt.savefig('./Figures_2/'+dateFile + '/Histogram/'+ str(currentFile)+ "_"+'Histogram_Step_'+ str(step_string))


                

            ### Store average all steps per file in json
            item["avs_mean"] = store_avs 
            #item[""]    
            with open("variables.json", "w+") as f_json: 
                f_json.write(json.dumps(variables))
            
            #print(np.shape(split_y_FSR), 'FSR ')
            

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