import numpy as np
import scipy
from multiSyncPy import data_generation as dg
from multiSyncPy import synchrony_metrics as sm
import scipy.signal
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.io.wavfile import read
from pyrqa.time_series import TimeSeries
from pyrqa.settings import Settings
from pyrqa.analysis_type import Classic
from pyrqa.neighbourhood import FixedRadius
from pyrqa.metric import EuclideanMetric
from pyrqa.computation import RQAComputation

#Need to add phase-space reconstruction of the signal before proceeding. 


input_path = '/Users/atillajv/CODE/RITMO/ONSET/output_drums/'
input_audio = '/Volumes/WHITE LOTUS/AUDIO/DRUMS_DEMUCS/'
input_video = '/Users/atillajv/CODE/RITMO/PILOT_SEV_APRIL_2022/output/videoAnalysis/motionData_'

file_name = 'P3_D1_G1_M1_R1_T1'

df = pd.read_csv(input_path + file_name + '.csv')
df_video = pd.read_csv(input_video + file_name + '.csv')
print(df)


samplerate, data_raw = read(str( input_audio + file_name + '.wav'))
print(samplerate,'samplerate')
channel_num = 1




t_start = df['t_onset'].iloc[0]
t_end = df['t_onset'].iloc[-1]
t_step = 0.01



t_array = np.zeros(int(t_end / t_step) + 1)
t_array_2 = np.zeros(int(t_end / t_step) + 1)


indices = (df['t_onset'] / t_step).astype(int)
print(indices)
t_array[indices] = 1

t_array_2[indices] = df['int_onset'].iloc[indices.index]


# Audio data downsampled
data = data_raw[indices.iloc[0]*samplerate : indices.iloc[-1]*samplerate,channel_num]
downsample_factor = int(samplerate / (1/t_step))
dataDown = scipy.signal.decimate(data, downsample_factor)
data_array = dataDown[0:len(t_array)]

print(t_start, t_end, 'Downsampling: ' ,downsample_factor, len(data_array))


# Video data, ms
samplerate_video = int(1/0.017)
dt_video = 0.001
factor = 1/dt_video
print('times:', factor,  t_end * factor, t_end)

closest_idx = (df_video['Time'] - t_end * factor).abs().idxmin()

# Print the index

t_end_video = df_video['Time'].loc[closest_idx]
video_subset = df_video[:closest_idx]

df_video['timestamp'] = pd.to_datetime(df_video['Time'], unit='ms')

df_video.set_index('timestamp', inplace=True)
df_resampled = df_video.resample('10ms').mean()  # Change '10ms' to '100ms' for 0.1s interval
df_resampled = df_resampled.reset_index()
# Interpolate mi
df_resampled = df_resampled.interpolate()


video_array = df_resampled['ComX'][:len(data_array)]

print(len(video_array), len(data_array))
# Stack t_array and t_array_2




stacked_array = np.vstack((t_array, t_array_2, data_array, video_array))



time_series = TimeSeries(data_array,
                         embedding_dimension=2,
                         time_delay= int(3 * samplerate/downsample_factor))



settings = Settings(time_series,
                    analysis_type=Classic,
                    neighbourhood=FixedRadius(0.3),
                    similarity_measure=EuclideanMetric,
                    theiler_corrector=1)
computation = RQAComputation.create(settings,
                                    verbose=True)
result = computation.run()
result.min_diagonal_line_length = 2
result.min_vertical_line_length = 2
result.min_white_vertical_line_length = 2
print(result)




delayed_data_array = np.roll(data_array, int(3 * samplerate/downsample_factor))  # 30 steps time delay

stacked_data = np.vstack((data_array, delayed_data_array))

recurrence_matrix = sm.recurrence_matrix(
    stacked_array, radius= 0.3
)
rqa_metrics = sm.rqa_metrics(recurrence_matrix)

print(rqa_metrics)


# Create a heatmap using Seaborn
# sns.heatmap(recurrence_matrix, annot=True, cmap='YlGnBu', cbar=False, linewidths=.5)

# # Show the plot
# plt.show()

dense_matrix = np.array(recurrence_matrix)

# Display the dense matrix as a black and white image
plt.matshow(dense_matrix, cmap='binary')
plt.show()


# from pyrqa.computation import RPComputation
# from pyrqa.image_generator import ImageGenerator
# computation = RPComputation.create(settings)
# result = computation.run()
# ImageGenerator.save_recurrence_plot(result.recurrence_matrix_reverse,
#                                     'recurrence_plot.png')




# #Plot the array to check it is binarised 
# t_x = np.arange(0,t_end + t_step, t_step)

# print(len(t_x), len(t_array))
# plt.plot(t_x,t_array)
# plt.show()

# ndarray = np.tile(t_array, (2, 1))
# print(ndarray.shape)

# symbolic_entropy_windowed = sm.apply_windowed(
#     stacked_array,
#     sm.symbolic_entropy,
#     window_length= 400,
#     step = 400 # if step 100, window length 100, there is no overlap
# )

# print(symbolic_entropy_windowed)

# # plt.plot(symbolic_entropy_windowed)
# # plt.show()


# recurrence_matrix = sm.recurrence_matrix(
#     stacked_array, radius= 0.4
# )
# rqa_metrics = sm.rqa_metrics(recurrence_matrix)

# print(rqa_metrics)


# # Create a heatmap using Seaborn
# # sns.heatmap(recurrence_matrix, annot=True, cmap='YlGnBu', cbar=False, linewidths=.5)

# # # Show the plot
# # plt.show()

# dense_matrix = np.array(recurrence_matrix)

# # Display the dense matrix as a black and white image
# plt.matshow(dense_matrix, cmap='binary')
# plt.show()