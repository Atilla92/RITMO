import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy.fft import rfft, rfftfreq, fft, fftfreq 
import seaborn as sns; sns.set_theme()
from sklearn import preprocessing
from scipy.signal import argrelextrema
from scipy.io.wavfile import read
import matplotlib.pyplot as plt
import numpy as np
from functions import alignClapper


#Import FSR/Audio data
#df = pd.read_csv (r'FSR/12.02.2022/N21_P1_D1_T1_12022022_Rep_1.5.csv', sep = ',', skiprows=144, encoding= 'unicode_escape') 

# P1_D1_T2, Standing
input_data = read("AUDIO/P1_D1_T2-220212_1647.wav")
df = pd.read_csv (r'FSR/12.02.2022/N20_P1_D1_T1_12022022_Rep_1.4.csv', sep = ',', skiprows=144, encoding= 'unicode_escape') 

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






#print(input_data)
audio = input_data[1]
audio_SR = input_data[0]


def  labelColumns(df, p):

    df.columns.values[0] = "Time"
    df.columns.values[1] = "LA"
    df.columns.values[3] = "LB"
    df.columns.values[5] = "LC"
    df.columns.values[7] = "LD"
    df.columns.values[21] = "RA"
    df.columns.values[23] = "RB"
    df.columns.values[25] = "RC"
    df.columns.values[27] = "RD"
    df_new = df.filter(['Time', 'LA', 'LB', 'LC', 'RA', 'RB', 'RC'])
    if p:
        print(df)
    return df_new


def createFigure (df, p):
    ''' Plot raw data'''
    x = df['Time']
    y1 = df['LA']
    y2 = df['LB']
    y3 = df['LC']
    y4 = df['RA']
    y5 = df['RB']
    y6 = df['RC']
    #y4 = df['D']

    if p:
        fig = plt.figure()
        ax = plt.axes()
        ax.plot(x,y1)
        ax.plot(x,y2)
        ax.plot(x,y3)
        #ax.plot(x,y4)
        plt.show()

    return x, y1, y2, y3, y4, y5, y6 

df_new = labelColumns(df, True)

x, y1, y2, y3, y4, y5, y6 = createFigure(df_new,False)


def plot_audio_FSR(audio_data, audio_SR, x, y1, y2, y3, y4, y5, y6):
    f, (ax1, ax2, ax3, ax4, ax5, ax6, ax7) = plt.subplots(7, 1, sharex=True)
    x_array = np.arange(len(audio_data))
    x_array = np.divide(x_array,audio_SR)
    ax1.plot(x_array, audio_data, 'g', label = 'Audio')
    ax1.set(ylabel='Audio')
    ax2.plot(x, y1, label = 'L')
    #ax2.legend(loc="upper right")
    ax2.set(ylabel= 'Toe')
    ax3.plot(x, y4, 'r', label = 'R')
    #ax3.legend(loc="upper right")
    ax4.plot(x, y2, label = 'LB')
    ax4.set(ylabel= 'Meta')
    #ax4.legend(loc="upper right")
    ax5.plot(x, y5, 'r', label = 'RB')
    #ax5.legend(loc = "upper right")
    ax6.plot(x, y3)
    ax6.set(ylabel= 'Heel')
    ax7.plot(x, y6, 'r')
    f.supxlabel('Time [s]')
    f.supylabel('Amplitude [%]')
    plt.show()

plot_audio_FSR(audio, audio_SR, x, y1, y2, y3, y4, y5, y6)





# Paritioning data in steps


def get_sec(time_str):
    """Get Seconds from time."""
    m, s = time_str.split(':')
    return int(m) * 60 + int(s)

def list_sec (step_times):
    '''Get new list in seconds'''
    step_seconds = []
    for key in step_times:
        time_s = get_sec(key)
        step_seconds.append(time_s)
    return step_seconds



# Align with Beaper start D1
# start_reaper_D2 = 10.868 - 4.536

#df_peaks = df_new.loc[(df["Time"] >= start_reaper_D1 )] 



# Step times P1_D1_T2
start_reaper = 10.868
step_labels = [1,2,3,4]
step_times = ['0:57','3:01','4:37','5:02']
duration_s = [5.7,16.5,8.50,6.90]
steps_start_s = list_sec(step_times)

# Step times P1_D2_T1
# start_reaper = 10.868- 4.536
# step_labels = [1,2,5,6]
# step_times = ['0:37','1:35','4:37','4:57']
# duration_s = [30.2,59.4,20.7,23.3]
# steps_start_s = list_sec(step_times)

#audio_threshold, click_time = alignClapper(audio, audio_SR, threshold_clap)

##### Will have to find a way to loop this. 


def setTimeWindow(df,t_peaks, t0,t1):
    '''Reduce dataset to a certain time window '''
    tStart = t0 + t_peaks
    tEnd = t1 + t0 + t_peaks
    df_start = df.loc[(df["Time"] >= tStart ) &(df["Time"] <= tEnd ) ]
    print(df_start)
    df_length = int(len(df_start.index))

    return df_start, df_length


# Get time window for specific step and plot. 
step1_data, df_length = setTimeWindow(df_new, start_reaper, steps_start_s[0], duration_s[0] )
print(step1_data['Time'])
x, y1, y2, y3, y4, y5, y6 = createFigure(step1_data,False)
plot_audio_FSR(audio, audio_SR, x, y1, y2, y3, y4, y5, y6)


