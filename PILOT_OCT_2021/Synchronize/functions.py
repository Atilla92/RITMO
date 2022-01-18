import numpy as np 
import pyloudnorm as pyln
from scipy.io.wavfile import read
import matplotlib.pyplot as plt
from scipy.signal import argrelextrema


def  labelColumns(df, p):

    df.columns.values[0] = "Time"
    df.columns.values[1] = "A"
    df.columns.values[2] = "B"
    df.columns.values[3] = "C"
    df.columns.values[4] = "D"
    if p:
        print(df)


def setStart(df,t0):
    '''Reduce dataset to a certain time window '''
    tStart = t0
    df_start = df.loc[(df["Time"] >= tStart ) ]
    df_length = int(len(df_start.index))

    return df_start, df_length


def separateData (df, sampleRate_FSR):
    ''' Separate data in arrays FSR'''
    x =  np.array(df['Time'])
    y1 = np.array(df['A'])
    y2 = np.array(df['B'])
    y3 = np.array(df['C'])
    #y4 = df['D']
    df_length = int(len(df.index))
    x_array = np.arange(df_length)
    x_array= np.divide(x_array, sampleRate_FSR)

    return x, y1, y2, y3, x_array


def estimateLoudness(data, rate):
    data = data.astype(np.float)
    rate = float(rate)
    meter = pyln.Meter(rate) # create BS.1770 meter
    loudness = meter.integrated_loudness(data) # measure loudness
    #print(loudness)
    return loudness


def readAudio(file_name):
    input_data = read(file_name)
    audio = input_data[1]
    sampleRate = input_data[0]
    return audio, sampleRate

def alignClapper(audio, sampleRate, threshold):
    click_position = np.argmax(audio > threshold)
    audio_threshold = audio[click_position:]
    click_time = click_position/sampleRate

    return audio_threshold, click_time

def plot_FSR_EMG(audio_data, audio_SR, x, y1, y2, y3):
    f, (ax1, ax2, ax3, ax4) = plt.subplots(4, 1, sharex=True)
    x_array = np.arange(len(audio_data))
    x_array = np.divide(x_array,audio_SR)
    ax1.plot(x_array, audio_data)
    ax2.plot(x, y1)
    ax3.plot(x, y2)
    ax4.plot(x, y3)
    plt.show()


def countSpikes(y_array):
    '''Get max length time of spike'''
    counter = 0
    max_counter = 0
    nSpikes = 0
    for i,item in enumerate(y_array):

        if item>0:
            counter = counter + 1
        else:
            max_counter = np.maximum(counter, max_counter)
            counter = 0
            nSpikes = nSpikes+1
    
    return max_counter, nSpikes



def storeSpikes(y1, y2, y3, p, sampleRate, p_spikes, p_mean, windowSpikes, tEnd, localMin):
    '''
    Data 
        y1 : first sensor A
        y2 : second sensor B
        y2 : third sensor C
    
    Input variables from sript
        sampleRate : estimated prior in calculateSampleRate

    Set parameters:
        tEnd : if windowSpikes = True, deine 0:tEnd, range of analysis

    Set to True if you want to call function
        p_spikes : plot all individual spikes
        p_mean : plot mean
        windowSpikes : remove tail of data, so takes data from 0:tEnd
        localMin: include local minimum in plots

    '''
    #Initiate arrays
    y1_store = []
    y2_store = []
    y3_store = []
    y2_time = []

    # Create array
    y1_array = np.array(y1)
    y2_array  = np.array(y2)
    y3_array = np.array(y3)

    max_counter, nSpikes = countSpikes(y2_array)
            
    y1_spikes = np.zeros((nSpikes, max_counter))
    y2_spikes = np.zeros((nSpikes, max_counter))
    y3_spikes = np.zeros((nSpikes, max_counter))
    time_spikes = np.zeros((nSpikes, max_counter))
    
    j = 0

    for i, item in enumerate(y2_array):

        if item>0: #it can get stuck here
            y2_store.append(item)
            y2_time.append(i)
            y1_store.append(y1_array[i])
            y3_store.append(y3_array[i])
        
        else:
            y1_spikes[j][0:len(y1_store)] = y1_store
            y2_spikes[j][0:len(y2_store)] = y2_store
            y3_spikes[j][0:len(y3_store)] = y3_store
            j = j+1
            y1_store =[]
            y2_store = []
            y3_store = []
            y2_time = [] 

    x_array =np.arange(max_counter)
    x_array = np.divide(x_array, sampleRate)

    if windowSpikes:
        y1_spikes = y1_spikes[:,:tEnd]
        y2_spikes =y2_spikes[:,:tEnd] 
        y3_spikes = y3_spikes[:,:tEnd]
        x_array = x_array[:tEnd]

    # Estimating mean
    y1_mean = np.nanmean(np.where(y1_spikes!=0,y1_spikes,np.nan),0)
    y2_mean = np.nanmean(np.where(y2_spikes!=0,y2_spikes,np.nan),0)
    y3_mean = np.nanmean(np.where(y3_spikes!=0,y3_spikes,np.nan),0)  

    # Finding local max
    y1_local_max = argrelextrema(y1_mean, np.greater)
    y2_local_max = argrelextrema(y2_mean, np.greater)
    y3_local_max = argrelextrema(y3_mean, np.greater)


    if localMin:
        y1_local_min = argrelextrema(y1_mean, np.less)
        y1_local =[*y1_local_max[0] , *y1_local_min[0]]
        y2_local_min = argrelextrema(y2_mean, np.less)
        y2_local =[*y2_local_max[0] , *y2_local_min[0]]
        y3_local_min = argrelextrema(y3_mean, np.less)
        y3_local =[*y3_local_max[0] , *y3_local_min[0]]
    
    else:
        y1_local =y1_local_max[0]
        y2_local = y2_local_max[0]
        y3_local = y3_local_max[0]


    y1_local_may = y1_mean[y1_local]
    y2_local_may = y2_mean[y2_local]
    y3_local_may = y3_mean[y3_local]

    y1_local_time = np.divide(y1_local, sampleRate)
    y2_local_time = np.divide(y2_local, sampleRate)
    y3_local_time = np.divide(y3_local, sampleRate)

    if p:
        
        f, (ax1, ax2, ax3) = plt.subplots(3, 1, sharex=True)
        #f, ax1 = plt.subplots(1, 1, sharex=True)

        if p_spikes:

            ax1.plot(x_array, y1_spikes.T)
            ax2.plot(x_array, y2_spikes.T)
            ax3.plot(x_array,y3_spikes.T)

        if p_mean:


            # for i, item in enumerate(y1_local_may):
            #     ax1.annotate("{:.3f},{:.2f}".format(y1_local_time[i], item), (y1_local_time[i], item))
            # for i, item in enumerate(y2_local_may):
            #     ax2.annotate("{:.3f},{:.2f}".format(y2_local_time[i], item), (y2_local_time[i], item))
            # for i, item in enumerate(y3_local_may):
            #     ax3.annotate("{:.3f},{:.2f}".format(y3_local_time[i], item), (y3_local_time[i], item))


            ax1.plot(x_array, y1_mean, '--', c='k', linewidth = '1')
            #ax1.vlines(y1_max_time, 0 , (y1_max_value), 'r')
            ax1.vlines(y1_local_time, 0 , y1_local_may, 'r')
            ax2.plot(x_array, y2_mean, '--', c='k', linewidth = '1')
            #ax2.vlines(y2_max_time, 0 , (y2_max_value), 'r')
            ax2.vlines(y2_local_time, 0 , y2_local_may, 'r')
            ax3.plot(x_array, y3_mean, '--', c='k', linewidth = '1')
            #ax3.vlines(y3_max_time, 0 , (y3_max_value), 'r')
            ax3.vlines(y3_local_time, 0 , y3_local_may, 'r')
        
        ax1.set_title('Y1')
        ax2.set_title('Y2')
        ax3.set_title('Y3')


        plt.show()
    
    return x_array, y1_spikes, y2_spikes, y3_spikes, time_spikes 