from scipy.io.wavfile import read
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from scipy.fft import rfft, rfftfreq, fft, fftfreq 
import seaborn as sns; sns.set_theme()
from sklearn import preprocessing
from scipy.signal import argrelextrema
import sys

sys.path.insert(0, '../EMG')
from functions import labelColumns, setStart, separateData, estimateLoudness, readAudio, alignClapper, plot_FSR_EMG, countSpikes, storeSpikes

# Input parameters, time
t_start_click_video = 9.9   # Time before first clap in video and FSR data 
t_post_click_audio = 22.5   # Time after first clap until start of guitar playing
threshold_clap = 1.25 * 10**9 #Threshold for identifying spike of clap
sampleRate_FSR = 5.185185 *10**2
path_audio = "../Audio/Data/Buleria_IMP_P2_1.wav"
#df = pd.read_csv (r'../EMG/Data/Buleria_IMP_P1_1_Rep_1_5.csv', sep = ',', skiprows=32) #9.2 s,19.7 Good one
df = pd.read_csv (r'../EMG/Data/Buleria_IMP_P2_1_Rep_1_4.csv', sep = ',', skiprows=32) #9.9s, 22.5 //37, 90


# Audio - read samples
audio, audio_SR =readAudio(path_audio)
# Audio - Align with clapper 
audio_threshold, click_time = alignClapper(audio, audio_SR, threshold_clap)


# FSR - Align with Clapper (time in seconds from video)
labelColumns(df, False)
df_start, df_length =setStart(df,t_start_click_video)
x_FSR, y1_FSR, y2_FSR, y3_FSR, x_array_FSR = separateData(df_start, sampleRate_FSR)

plot_FSR_EMG(audio_threshold, audio_SR, x_array_FSR, y1_FSR, y2_FSR, y3_FSR )


# Intervals sound file [[start,end],[start,end]]
t_post_click = int(np.ceil(t_post_click_audio * audio_SR))
audio_intervals = audio_threshold[t_post_click:]


# Start FSR from audio start
t_start_FSR = t_start_click_video + t_post_click_audio
df_int, df_int_length =setStart(df,t_start_FSR)
x_int_FSR, y1_int_FSR, y2_int_FSR, y3_int_FSR, x_array_int_FSR = separateData(df_int, sampleRate_FSR) #data from where audio starts. 
# From here need to create the bins same size as audio, and then apply the mean plotting method/ filter 

# Buleria_IMP_P1_1
interval_type = ['entrada', 'marcaje', 'letra', 'letra', 'marcaje', 'falceta', 'bajada', 'cierre'  ] 
interval_compases = [1, 3, 4, 4, 1, 4, 1, 1 ]
durations = [3.9, 9.9, 13.6, 13.3, 3.5, 13.6, 3.4 , 3.1  ] 
durations_sum = np.cumsum(durations)
#print(np.sum(durations), len(audio_threshold)/sampleRate, durations_sum)


# Split in bins and loop through audio, estimate loudness, 
j = 0
k = t_start_FSR
intervals_audio = []
intervals_FSR_y1 = []
intervals_FSR_y2 = []
intervals_FSR_y3 = []

for i, item in enumerate(durations_sum):
    # Bin audio data
    sample_number = int(np.ceil(item * audio_SR))
    data_bin = audio_intervals[j:sample_number]
    loudness = estimateLoudness(data_bin, audio_SR)
    intervals_audio.append(data_bin)
    j = sample_number 

    # Bin FSR data
    sample_FSR = int(np.ceil(item*sampleRate_FSR))
    t_end = item + t_start_FSR
    FSR_bin = (df_int.loc[(df_int["Time"] >= k ) &(df_int["Time"] <= t_end ) ])
    x_int, y1_int, y2_int, y3_int, x_array_int = separateData(FSR_bin, sampleRate_FSR)
    k = t_end

    # Mean profile of FSR data
    max_counter, nSpikes = countSpikes(y2_int)
    x_array, y1_spikes, y2_spikes, y3_spikes, time_spikes = storeSpikes(y1_int, y2_int, y3_int, True, sampleRate_FSR, False, True, False, 50, False)
    plot_FSR_EMG(data_bin,audio_SR, x_array_int, y1_int, y2_int, y3_int)
    print( loudness,y1_int)


print(intervals_audio)
