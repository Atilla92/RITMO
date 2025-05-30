import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from glob import glob
import scipy
#from scipy.io import loadmat
#from scipy.signal import hilbert
#import scipy.signal as sg
import sys
import scipy.signal as sg


# Load Data

#data = pd.read_pickle('../data/applause1')





# Load LZ stuff
path_name = "/Users/atillajv/CODE/RITMO/ENTROPY/scripts/entropy_sources"
sys.path.append(path_name)
from lz76 import LZ76 
# Load CTW and Java stuff
sys.path.append(path_name)
import os
os.chdir(path_name)
import jpype as jp
jv_path = '/Library/Java/JavaVirtualMachines/jdk-18.0.2.1.jdk/Contents/MacOS/libjli.dylib'
if not jp.isJVMStarted():
    jp.startJVM(jv_path, '-ea', '-Xmx2048m', '-Djava.class.path=vmm.jar:trove.jar')
jstr = jp.JPackage('java.lang').String
assert(jp.isJVMStarted())

##Original version
#javify = lambda py_str, ab_dict: jstr(bytearray([ab_dict[s] for s in py_str])) 

## Small change to pass string instead of bytearray
#javify = lambda py_str, ab_dict: jstr(str([ab_dict[s] for s in py_str]))

def javify(py_str, ab_dict):
    s = bytes([ab_dict[s] for s in py_str])
    #print(s, jstr(s), 'hello')
    return jstr(s) 


def butter_filter(df, sampling_freq , f_ord = 4,lowcut = 0.05,cutoff = 100,plot=False):
    data = np.array(df)
    nyq = sampling_freq/2
    W_c = [lowcut/nyq,cutoff/nyq]
    fil_b,fil_a = sg.butter(int(f_ord/2),W_c,btype='bandpass',analog=False)
    #fil_b,fil_a = sg.butter(f_ord,cutoff/nyq,btype='lowpass',analog=False)
    fil_data = sg.filtfilt(fil_b,fil_a,data)

    return fil_data # See whether you need to return as df or array



#
#
#
#
def filter_signal( data, cutoff=100, lowcut=0.1, kind='bandpass', f_ord=4, sampling_freq=300):
#
    nyq = sampling_freq/2
    if kind=='lowpass':
        fil_b,fil_a = sg.butter( int(f_ord/2), cutoff/nyq, btype='lowpass', analog=False)
    elif kind=='bandpass':
        W_c = [lowcut/nyq,cutoff/nyq]
        fil_b,fil_a = sg.butter(int(f_ord/2),W_c,btype='bandpass',analog=False)
    fil_data = sg.filtfilt( fil_b, fil_a, data)
    return fil_data
#
#
#
def filter_df( df, cutoff=100, lowcut=0.1, kind='bandpass', f_ord=4, sampling_freq=300):
    res = df.copy()
    res[:] = np.nan
    for c in df.columns:
        data = df[c]
        data = data.replace([np.inf, -np.inf], np.nan)
        data = data.dropna()
        data_f = filter_signal(data.values, cutoff=cutoff, lowcut=lowcut, sampling_freq=sampling_freq)
        res.loc[ data.index, c] = data_f
    return res
#
#
#
#
#
def quantize_vector(data):
    data = np.array(data)
    data = data - data.mean()
    return (data>0).astype(int)
#
#
def quartile_vector(data, percentile):
    data = np.array(data)
    threshold = np.quantile(data, percentile)
    print('threshold:', threshold, 'mean:', np.mean(data))
    data = data - threshold
    print(np.sum((data> 0).astype(int))/len(data), 'LENGTH')
    return (data> 0).astype(int)

def lz_entropy(S, binarise):
    if binarise:
        X = S.values
        N = len(X)
    else: 
        X = quantize_vector(S.values)
        N = len(X)
    return LZ76(X) * np.log2(N)/N
#
#
def ctw_entropy(X, vmm_order=2, binarise = False, ab_dict ={}, ab_size = 0):
## Set training string and build alphabet dictionary (used extensively later)
    time = X.index.values
    if binarise: 
        Xq = X.values
    else:
        Xq = quantize_vector(X.values)
        alphabet = set(Xq)
        ab_size = len(alphabet)
        ab_dict = {cc: i for cc,i in zip(sorted(alphabet), range(ab_size))}
    #
    ## Initialise and train model
    vmm = jp.JPackage('vmm.algs').DCTWPredictor()
    vmm.init( ab_size, vmm_order) # perhaps change order of these
    #print(Xq, javify(Xq, ab_dict),'JAVIFY!!!!!!!!!!!!!!!!!!!!!')
    vmm.learn(javify(Xq, ab_dict))
 
    res = vmm.logEval(javify( Xq, ab_dict)) / len(Xq)
    return res
#
#

def var_entropy(S):
    #print(S)
    X = S.values.var()
    #print(X)
    #X = np.sqrt(X)
    #print(X)
    ent_X = 0.5 * np.log2(2* np.pi * X) + 0.5
    
    return ent_X


def calc_lz_df_2(df, style='LZ', hil=False, window=2000, max_windows=np.inf, binarise = False):
  
    
    # find time indices
    n_windows = int( len(df) / window ) 
    n_windows = int( np.min( [max_windows, n_windows] ) )
    lz = pd.Series(index=df.columns, dtype=float)
    temp = []
    for c in df.columns:
        data = df[c]
        data = data.dropna()
        if len(data) <= 30:
            continue
        #print('Going with channel ',c)
        data = df[c]

        alphabet = set(data)
        ab_size = len(alphabet)
        ab_dict = {cc: i for cc,i in zip(sorted(alphabet), range(ab_size))}

        window_array = []
        for n in range(n_windows):
            w = data.iloc[ n*window : (n+1)*window ]

            #
            if hil:
                w_vals = np.abs( hilbert(w) )
            else:
                w_vals = w.values
                #print('yes')
            #
            w = pd.Series(index=w.index, data=w_vals)
            if style=='LZ':
                temp.append( lz_entropy( w,  binarise = binarise ) )
                
            if style=='CTW':
                temp.append( ctw_entropy( w, binarise=binarise, ab_size = ab_size, ab_dict = ab_dict ) )
            if style == 'var':
                temp.append(var_entropy(w))

        lz[c] = np.array(temp).mean()
    return lz, temp


def InterOnsetInterval(df, window, t_window):
    n_windows = int( len(df) / window )
    IOIs = []
    nCounts = []
    for c in df.columns:
        data = df[c]
        for n in range(n_windows):
            w = data.iloc[ n*window : (n+1)*window ] 
            n_counts = w.sum()
            if n_counts == 0:
                interOI = 0.0  # Set a default value or handle the case as needed
            else:
                interOI = t_window * window / n_counts
            IOIs.append(interOI)
            nCounts.append(n_counts)

    return IOIs, nCounts  


def findDivisor(target_divisor, sr):
    # Find divisors of the number
    divisors = [i for i in range(1, sr+1) if sr % i == 0]

    # Find the closest divisor to the target divisor
    closest_divisor = min(divisors, key=lambda x: abs(x - target_divisor))

    # Calculate the result of the division
    result = sr // closest_divisor
    dFactor = closest_divisor

    return dFactor
    
            


def calc_lz_df_3(df, style='LZ', hil=False, window=2000, max_windows=np.inf):
    
    # find time indices
    n_windows = int( len(df) / window ) 
    n_windows = int( np.min( [max_windows, n_windows] ) )
    lz = pd.Series(index=df.columns, dtype=float)
    temp = []
    for c in df.columns:
        data = df[c]
        data = data.dropna()
        if len(data) <= 30:
            continue
        #print('Going with channel ',c)
        data = df[c]
        window_array = []
        for n in range(n_windows):
            w = data.iloc[ n*window : (n+1)*window ]
            #
            if hil:
                w_vals = np.abs( hilbert(w) )
            else:
                w_vals = w.values
                #print('yes')
            #
            w = pd.Series(index=w.index, data=w_vals)
            if style=='LZ':
                temp.append( lz_entropy( w ) )
                
            if style=='CTW':
                temp.append( ctw_entropy( w ) )

        lz[c] = np.array(temp).mean()
    return lz, temp


def calc_lz_df(df, style='LZ', hil=False, window=2000, max_windows=np.inf):
    # find time indices
    #n_windows = int( len(df) / window ) 
    #n_windows = int( np.min( [max_windows, n_windows] ) )
    lz = pd.Series(index=df.columns, dtype=float)
    for c in df.columns:
        data = df[c]
        data = data.dropna()
        if len(data) <= 30:
            continue
        temp = []

        # for n in range(n_windows):
        #     w = data.iloc[ n*window : (n+1)*window ]
        #     #
        #     if hil:
        #         w_vals = np.abs( hilbert(w) )
        #     else:
        #         w_vals = w.values
        #     #
        #     w = pd.Series(index=w.index, data=w_vals)
        if style=='LZ':
            temp.append( lz_entropy( data ) )
        if style=='CTW':
            temp.append( ctw_entropy( data ) )
        print(temp, 'TEMP!!!!!!!')
        lz[c] = np.array(temp).mean()
    return lz


def plotAudio_2(data, samplerate, length_df, ax, start_time = 0):
    """Plot left and right channel of Audio Data"""
    if length_df:
        data = data[start_time:(start_time + length_df)]
    length = data.shape[0] / samplerate
    time = np.linspace(0., length, data.shape[0])
    ax.plot(time, data[:], label="Left channel")


def plotAudio(data, samplerate):
    """Plot left and right channel of Audio Data"""
    length = data.shape[0] / samplerate
    time = np.linspace(0., length, data.shape[0])
    plt.plot(time, data[:, 0], label="Left channel")
    plt.plot(time, data[:, 1], label="Right channel")
    plt.legend()
    plt.xlabel("Time [s]")
    plt.ylabel("Amplitude")
    plt.show()

def preProcessing(data, downsample_on = False, absolute_on = False, downsample_factor = 1, preBinarise_on = False ):
    # Downsample
    if downsample_on:
        data = scipy.signal.decimate(data, downsample_factor)
    
    if absolute_on:
        data = np.abs(data)

    if preBinarise_on:
        data = quantize_vector(data)
    
    return data



#you need to redo quite a lot of the script, need 2 binaries, now there is a window of zeros because of absolute value. 

####PLOTS FUNCTIONS ######
#Put df in bins for t% plots
def binningPlots(df_plots):
    df_plots['Assigned_%'] = 0
    df_plots.loc[df_plots['t_%']<= 0.10 , 'Assigned_%'] = 0.10
    df_plots.loc[(df_plots['t_%']<= 0.20) & (df_plots['t_%']> 0.10 ) , 'Assigned_%'] = 0.20
    df_plots.loc[(df_plots['t_%']<= 0.30) & (df_plots['t_%']> 0.20 ) , 'Assigned_%'] = 0.30
    df_plots.loc[(df_plots['t_%']<= 0.40) & (df_plots['t_%']> 0.30 ) , 'Assigned_%'] = 0.40
    df_plots.loc[(df_plots['t_%']<= 0.50) & (df_plots['t_%']> 0.40 ) , 'Assigned_%'] = 0.50
    df_plots.loc[(df_plots['t_%']<= 0.60) & (df_plots['t_%']> 0.50 ) , 'Assigned_%'] = 0.60
    df_plots.loc[(df_plots['t_%']<= 0.70) & (df_plots['t_%']> 0.60 ) , 'Assigned_%'] = 0.70
    df_plots.loc[(df_plots['t_%']<= 0.80) & (df_plots['t_%']> 0.70 ) , 'Assigned_%'] = 0.80
    df_plots.loc[(df_plots['t_%']<= 0.90) & (df_plots['t_%']> 0.80 ) , 'Assigned_%'] = 0.90
    df_plots.loc[df_plots['t_%']> 0.90  , 'Assigned_%'] = 1.00


def InfotoColumnsPlots(df):
    dance_array = []
    music_array = []
    palo_array = []
    condition_array = []
    participant_array = []
    rater_array = []
    artist_array = []
    for i, item in enumerate(df['file']):

        split_array = item.split('_')
        print(split_array)
        rater_array.append(split_array[0])
        artist_array.append(split_array[0][0])
        participant_array.append(split_array[1])
        dance_array.append(split_array[2])
        music_array.append(split_array[4])
        palo_array.append(split_array[5])
        condition_array.append(str(split_array[2] +'_' + split_array[4]))
        #print(split_array)
    df['Artist'] = artist_array
    df['Rater'] = rater_array
    df['Participant'] = participant_array
    df['Dance_mode'] = dance_array
    df['Music_mode'] = music_array
    df['Palo'] = palo_array
    df['Condition'] = condition_array
