import numpy as np 
import pyloudnorm as pyln
from scipy.io.wavfile import read
import matplotlib.pyplot as plt
from scipy.signal import argrelextrema


def alignClapper(audio, sampleRate, threshold):
    click_position = np.argmax(audio > threshold)
    audio_threshold = audio[click_position:]
    click_time = click_position/sampleRate

    return audio_threshold, click_time


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

def plot_audio_FSR(audio_data,x_array, df_new):
    x, y1, y2, y3, y4, y5, y6 = createFigure(df_new,False)
    f, (ax1, ax2, ax3, ax4, ax5, ax6, ax7) = plt.subplots(7, 1, sharex=True)
    ax1.plot(x_array, audio_data, 'g', label = 'Audio')
    ax1.set(ylabel='Audio')
    ax2.plot(x, y1, label = 'L')
    #ax2.legend(loc="upper right")
    ax2.set(ylabel= 'Toe - L')
    ax3.plot(x, y4, 'r', label = 'R')
    #ax3.legend(loc="upper right")
    ax4.plot(x, y2, label = 'LB')
    ax4.set(ylabel= 'Meta - L')
    #ax4.legend(loc="upper right")
    ax5.plot(x, y5, 'r', label = 'RB')
    #ax5.legend(loc = "upper right")
    ax6.plot(x, y3)
    ax6.set(ylabel= 'Heel - L')
    ax7.plot(x, y6, 'r')
    f.supxlabel('Time [s]')
    f.supylabel('Amplitude [%]')
    plt.show()

def plot_audio_FSR_split(audio_data,x_array, df_new, startZero, axs):
    x, y1, y2, y3, y4, y5, y6 = createFigure(df_new,False)
    if startZero:
        x= np.array(x)
        x = x -x[0]
        x_array = x_array - x_array[0]  
    axs[0].plot(x_array, audio_data, label = 'Audio')
    axs[0].set(ylabel='Audio')
    axs[1].plot(x, y1, label = 'L')
    #ax2.legend(loc="upper right")
    axs[1].set(ylabel= 'Toe')
    axs[2].plot(x, y4, label = 'R')
    #ax3.legend(loc="upper right")
    axs[3].plot(x, y2, label = 'LB')
    axs[3].set(ylabel= 'Meta')
    #ax4.legend(loc="upper right")
    axs[4].plot(x, y5, label = 'RB')
    #ax5.legend(loc = "upper right")
    axs[5].plot(x, y3)
    axs[5].set(ylabel= 'Heel')
    axs[6].plot(x, y6)


def get_sec(time_str):
    """Get Seconds from time."""
    m, s, ms = time_str.split(':')
    return int(m) * 60 + int(s) + np.divide(int(ms),(100))

def list_sec (step_times):
    '''Get new list in seconds'''
    step_seconds = []
    for key in step_times:
        time_s = get_sec(key)
        step_seconds.append(time_s)
    return step_seconds


def setTimeWindow(df,t_peaks, t0,t1):
    '''
    Reduce dataset to a certain time window of steps
        df : dataframe 
        t_peaks : first peak of 6
        t0 : start of step
        t1 : end of step
    '''
    tStart = t0 + t_peaks
    tEnd = t1 + t0 + t_peaks
    df_start = df.loc[(df["Time"] >= tStart ) &(df["Time"] <= tEnd ) ]
    df_length = int(len(df_start.index))
    return df_start, df_length

def setWindowAudio(audio, audio_SR, t_peaks, t0,t1):
    '''Reduce dataset to a certain time window of the step
       audio : audio data
       audio_SR : sampling rate audio
       t_peaks : first peak of 6
       t0 : start of step
       t1 : end of step
     '''
    x_audio = np.divide(np.arange(len(audio)), audio_SR)
    tStart = t0 + t_peaks
    tStart_index = np.argmax(x_audio >=tStart)
    tEnd = t1 + t0 + t_peaks
    tEnd_index = np.argmax(x_audio >=tEnd)
    audio_start = audio[tStart_index:tEnd_index]
    x_audio_start = x_audio[tStart_index:tEnd_index]
    #print(audio_start)
    return audio_start, x_audio_start 



def setThreshold(split_x_audio, split_y_audio):
    audio_coord_th = []
    coords = []
    for i, item in enumerate(split_y_audio):
            coords = plotFig_SetCoord(split_x_audio[i], split_y_audio[i])
            print(coords, 'coords')
            audio_coord_th.append(coords)
    return audio_coord_th


def plotFig_SetCoord(x, y):
    """
    Fetch coordinates when clicking on plot
    Fetches the last clicked event
    x: list 
    y: list
    returns coordinates [x,y]
    """
    fig = plt.figure()
    plt.plot(x, y)

    def onclick(event):
        global ix, iy
        ix, iy = event.xdata, event.ydata
        print ('x = %d, y = %d'%(
            ix, iy))

        global coords
        coords = [ix, iy]
        return coords

    cid = fig.canvas.mpl_connect('button_press_event', onclick)
    plt.show()
    return coords


def initiateSubplots():
    f, axs = plt.subplots(7, 1, sharex=True)
    f.supxlabel('Time [s]')
    f.supylabel('Amplitude [%]') 
    return f, axs