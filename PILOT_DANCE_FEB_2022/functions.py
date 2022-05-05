import numpy as np 
import pyloudnorm as pyln
from scipy.io.wavfile import read
import matplotlib.pyplot as plt
from scipy.signal import argrelextrema
from scipy.stats import norm




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
    df_new = df.filter(['Time', 'LA', 'LB', 'LC', 'RA', 'RB', 'RC']).copy()
    #print(df_new, 'new')
    if p:
        print(df)
    return df_new

def  labelColumns_2(df, p):
    #print(df.columns[0], 'what are you')
    df.columns.values[0] = "Time"
   # print(df.columns[0], 'what are you')
    df.columns.values[1] = "RA"
    df.columns.values[3] = "RB"
    df.columns.values[5] = "RC"
    
    df_new = df.filter(['Time','RA', 'RB', 'RC'])
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

def createFigure_2 (df, p):
    ''' Plot raw data'''
    x = df['Time']
    y1 = df['RA']
    y2 = df['RB']
    y3 = df['RC']
    #y4 = df['D']
    if p:
        fig = plt.figure()
        ax = plt.axes()
        ax.plot(x,y1)
        ax.plot(x,y2)
        ax.plot(x,y3)
        #ax.plot(x,y4)
        plt.show()
    return x, y1, y2, y3

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
    axs[1].set(ylabel= 'Toe_L')
    axs[2].plot(x, y4, label = 'R')
    #ax3.legend(loc="upper right")
    axs[3].plot(x, y2, label = 'LB')
    axs[3].set(ylabel= 'Meta_L')
    #ax4.legend(loc="upper right")
    axs[4].plot(x, y5, label = 'RB')
    #ax5.legend(loc = "upper right")
    axs[5].plot(x, y3)
    axs[5].set(ylabel= 'Heel_L')
    axs[6].plot(x, y6)

def plot_audio_FSR_split_2(audio_data,x_array, df_new, startZero, axs):
    x, y1, y2, y3 = createFigure_2(df_new, False)
    if startZero:
        x= np.array(x)
        x = x -x[0]
        x_array = x_array - x_array[0]  
    axs[0].plot(x_array, audio_data, label = 'Audio')
    axs[0].set(ylabel='Audio')
    axs[1].plot(x, y1, label = 'R')
    #ax2.legend(loc="upper right")
    axs[1].set(ylabel= 'Toe_R')
    axs[2].plot(x, y2, label = 'R')
    axs[2].set(ylabel= 'Meta_R')
    #ax3.legend(loc="upper right")
    axs[3].plot(x, y3, label = 'LB')
    axs[3].set(ylabel= 'Heel_R')
    #ax4.legend(loc="upper right")
    # axs[4].plot(x, y5, label = 'RB')
    #ax5.legend(loc = "upper right")
    # axs[5].plot(x, y3)
    # axs[5].set(ylabel= 'Heel_L')
    # axs[6].plot(x, y6)


def get_average_FSR(df):
    x, y1, y2, y3, y4, y5, y6 = createFigure(df,False)
    av_std = [[np.mean(y1), np.std(y1)],[np.mean(y2), np.std(y2)],[np.mean(y3), np.std(y3)] ,[np.mean(y4), np.std(y4)],[np.mean(y5) ,np.mean(y5)],[np.mean(y6), np.std(y6)]]
    av = [np.mean(y1),np.mean(y2), np.mean(y3),np.mean(y4), np.mean(y5), np.mean(y6) ]
    return av_std, av

def get_average_FSR_2(df):
    x, y1, y2, y3 = createFigure_2(df, False)
    av_std = [[np.mean(y1), np.std(y1)],[np.mean(y2), np.std(y2)],[np.mean(y3), np.std(y3)]]
    return av_std

def plot_average_FSR(df, axs2, step, label_list):
    x, y1, y2, y3, y4, y5, y6 = createFigure(df,False)
    label_step = str(step)
    label_list = label_list.append(label_step)
    axs2[0].boxplot(y1, labels =label_step) 
    #plt.show()

    return

def plot_average_FSR_2(df, axs2, step, label_list):
    x, y1, y2, y3 = createFigure_2(df, False)
    label_step = str(step)
    label_list = label_list.append(label_step)
    axs2[0].boxplot(y1, labels =label_step) 
    #plt.show()

    return




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
    #print(t0, t_peaks, 'times')
    tStart = t0 + t_peaks
    tStart_index = np.argmax(x_audio >=tStart)
    tEnd = t1 + t0 + t_peaks
    tEnd_index = np.argmax(x_audio >=tEnd)
    audio_start = audio[tStart_index:tEnd_index]
    x_audio_start = x_audio[tStart_index:tEnd_index]
    #print(audio_start)
    return audio_start, x_audio_start 



def setThreshold(split_x_audio, split_y_audio):
    """"Set threshold for analysis"""
    audio_coord_th = []
    coords = []
    for i, item in enumerate(split_y_audio):
            coords = plotFig_SetCoord(split_x_audio[i], split_y_audio[i])
            #print(coords, 'coords')
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
        #print ('x = %d, y = %d'%(ix, iy))

        global coords
        coords = [ix, iy]
        return coords

    cid = fig.canvas.mpl_connect('button_press_event', onclick)
    plt.show()
    return coords


def initiateSubplots():
    """Create a subplots of 7"""
    f, axs = plt.subplots(7, 1, sharex=True)
    f.supxlabel('Time [s]')
    f.supylabel('Amplitude [%]') 
    return f, axs


def initiateSubplots2(labelx, labely, number):
    """Create a subplots of 6"""
    f, axs = plt.subplots(number, 1, sharex=True, sharey=True)
    f.supxlabel(labelx)
    f.supylabel(labely) 
    return f, axs

def initiateSubplots3(labelx, labely, number):
    """Create a subplots of 6"""
    f, axs = plt.subplots(3, 2, sharex=True, sharey=False, )
    f.supxlabel(labelx)
    f.supylabel(labely) 
    return f, axs
    


def plot_Steps(split_y_FSR,audio_coord_th,split_y_audio,split_x_audio,currentFile,step_id,dateFile):
    f, axs = initiateSubplots()
    
    av_steps = []
    label_list = []
    for i_step, item_step in enumerate(split_y_FSR):
        threshold_coord = audio_coord_th[i_step][1]
        gradient_audio = np.gradient(split_y_audio[i_step],split_x_audio[i_step])
        tStart_index = np.argmax(split_y_audio[i_step] >threshold_coord)
        item_start = item_step.loc[(item_step["Time"] >= split_x_audio[i_step][tStart_index] ) ]  
        plot_audio_FSR_split(split_y_audio[i_step][tStart_index:-1], split_x_audio[i_step][tStart_index:-1], item_start, True, axs)


    
    axs[0].set_title(str(currentFile)+ " - " + 'Step '+ str(step_id), fontsize = 14 )
    plt.savefig('./Figures/'+dateFile + '/'+ str(currentFile)+ "_"+'FSR_Audio_Step_'+ str(step_id))



def plotAudio_FSR(audio, sampleRate, df, p):
    f, axs = initiateSubplots2(labelx = 'Time [s]', labely = 'Amplitude', number = 4)
    x, y1, y2, y3 = createFigure_2(df,False)
    x_array = np.arange(len(audio))
    x_array = np.divide(x_array,sampleRate)
    axs[0].plot(x_array, audio)
    axs[1].plot(x,y1)
    axs[2].plot(x,y2)
    axs[3].plot(x,y3)
    # label the axes
    # plt.ylabel("Amplitude")
    # plt.xlabel("Time [s]")
    # set the title  
    plt.title("Hello")
    # display the plot
    if p:
        plt.show()

def plotNDF(data, i_data, min_val, max_val, n_bins, axs3, plot_r, plot_c, y_lim ):
    '''' Plot histogram and normal distribution of data

        data: ndarray of data
        i_data: row of data you want to analyse
        min_val: lower threshold for data values to include
        max_val: upper threshold for data values to include
        n_bins: number of bins for histogram
        axs3: subplots axes
        plot_r : row of subplot to plot data on
        plot_c : column of subplots to plot data on
        y_lim : upper limit of yaxis for all subplots
    
    '''
    data_1 = np.array(data)[:,i_data]
    data_1 = data_1[np.where(data_1> min_val)]
    data_1 = data_1[np.where(data_1 < max_val)]
    _, bins, _ = axs3[plot_r,plot_c].hist(data_1, bins = n_bins,  range=(min_val, max_val), density= True)
    mu, sigma = norm.fit(data_1)
    print(mu, sigma, 'mu sigma') 
    best_fit_line = norm.pdf(bins, mu, sigma)
    axs3[plot_r,plot_c].hist(data_1, bins = n_bins,  range=(min_val, max_val),  density= True)         
    axs3[plot_r,plot_c].plot(bins, best_fit_line, label = str(mu))
    axs3[plot_r,plot_c].set_ylim([0,y_lim])
    axs3[plot_r, plot_c].vlines( mu, 0, y_lim,  color = 'b', linestyles = 'dashed', label = str('mu =' + str(mu)))
