import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import scipy
from scipy.io.wavfile import read

from SYNCHRONICITY.scripts.mdQRA.takensEmbedding import find_optimal_delay, find_optional_dimension
from multiSyncPy import synchrony_metrics as sm
import musicalgestures

# import plotly.express as px
# import plotly.graph_objects as go
# from sktime.datasets import load_airline, load_shampoo_sales, load_lynx


# Audio input, raw or entropy


input_path = '/Users/atillajv/CODE/RITMO/ONSET/output_drums/'
#input_audio = '/Volumes/WHITE LOTUS/AUDIO/DRUMS_DEMUCS/'
input_audio = '/Volumes/Seagate/AUDIO/DRUMS_DEMUCS/'
input_video = '/Users/atillajv/CODE/RITMO/PILOT_SEV_APRIL_2022/output/videoAnalysis/motionData_'
file_name = 'P3_D1_G1_M1_R1_T1'



# Note that dt = 0.01 is hardcoded here 
def import_audio_file(input_path, file_name):
     

    df = pd.read_csv(input_path + file_name + '.csv')

    samplerate, data_raw = read(str( input_audio + file_name + '.wav'))
    print(samplerate,'samplerate')
    channel_num = 1
    t_start = df['t_onset'].iloc[0]
    t_end = df['t_onset'].iloc[-1]
    t_step = 0.01
    data_array_onset = np.zeros(int(t_end / t_step) + 1)
    data_array_intensity = np.zeros(int(t_end / t_step) + 1)


    indices = (df['t_onset'] / t_step).astype(int)
    data_array_onset[indices] = 1
    data_array_intensity[indices] = df['int_onset'].iloc[indices.index]

    data = data_raw[indices.iloc[0]*samplerate : indices.iloc[-1]*samplerate,channel_num]
    downsample_factor = int(samplerate / (1/t_step))
    dataDown = scipy.signal.decimate(data, downsample_factor)
    data_array = dataDown[0:len(data_array_onset)]

    #return data_array, t_start, t_end, samplerate, downsample_factor
    return data_array, data_array_onset, data_array_intensity





def import_video_file(input_video, file_name, t_end, length_array):
    df_video = pd.read_csv(input_video + file_name + '.csv')


    df_video['timestamp'] = pd.to_datetime(df_video['Time'], unit='ms')
    df_video.set_index('timestamp', inplace=True)
    df_resampled = df_video.resample('10ms').mean()  # Change '10ms' to '100ms' for 0.1s interval
    df_resampled = df_resampled.reset_index()
    # Interpolate missing values
    df_resampled = df_resampled.interpolate()
    video_array = df_resampled['ComX'][:length_array]

    return video_array




def main():
     # your code here....   
          
    # t = [i for i in np.arange(0, 20, 0.1)]
    # y = [np.sin(i) for i in t]
    y, y1, y2 = import_audio_file(input_path, file_name)
    print(y1, '!!!!!!')

    # Priobably does not work on binary dataset. Need to either work with raw data. And then create a reconstruccted phase-state input. Or figure out 
    optimal_tau_y1 = find_optimal_delay(y1,maxtau= 50)
    optimal_dim_y1 = find_optional_dimension(y1, optimal_tau_y1)

    optimal_tau_y2 = find_optimal_delay(y2,maxtau= 50)
    optimal_dim_y2 = find_optional_dimension(y2, optimal_tau_y2)

    print(optimal_tau_y1, optimal_dim_y1, optimal_tau_y2, optimal_dim_y2)


    input_matrix = np.vstack((y1,y2))
    recurrence_matrix = sm.recurrence_matrix(input_matrix, radius= 0.3)
    rqa_metrics = sm.rqa_metrics(recurrence_matrix)

    print(rqa_metrics)


        

if __name__ == "__main__":
     main()






# rqa_metrics = sm.rqa_metrics(recurrence_matrix)

# print(rqa_metrics)


# # Create a heatmap using Seaborn
# # sns.heatmap(recurrence_matrix, annot=True, cmap='YlGnBu', cbar=False, linewidths=.5)

# # # Show the plot
# # plt.show()

# dense_matrix = np.array(recurrence_matrix)

# # Display the dense matrix as a black and white image
# plt.matshow(dense_matrix, cmap='binary')