#SCRIPTED 27.09.2024
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import scipy
from scipy.io.wavfile import read
import os, glob
#from takensEmbedding import find_optimal_delay, find_optional_dimension
from multiSyncPy import synchrony_metrics as sm
import json
from scipy.optimize import curve_fit

# # Filename
# file_name = 'P5_D5_G3_M5_R2_T1'
# # Audio input, raw or entropy
# save_dict_path = '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/mdQRA/output/'

# input_path = '/Users/atillajv/CODE/RITMO/ONSET/output_drums/'
# #input_audio = '/Volumes/WHITE LOTUS/AUDIO/DRUMS_DEMUCS/'
# input_audio = '/Volumes/Seagate/AUDIO/DRUMS_DEMUCS/'

# name_files = ['P5_D5_G3_M5_R2_T1', 'P5_D5_G3_M6_R1_T1', 'P5_D5_G3_M6_R2_T1', 'P5_D6_G3_M6_R1_T1', 'P5_D6_G3_M6_R2_T1', 'P6_D1_G1_M1_R1_T1', 'P6_D1_G1_M1_R2_T1', 'P6_D6_G1_M6_R1_T1', 'P6_D6_G1_M6_R2_T1', 'P7_D1_G1_M1_R1_T2', 'P7_D1_G1_M1_R2_T1', 'P7_D1_G1_M6_R1_T1', 'P7_D1_G1_M6_R2_T1', 'P7_D5_G1_M5_R1_T1', 'P7_D5_G1_M5_R2_T1', 'P7_D5_G1_M6_R1_T1', 'P7_D5_G1_M6_R2_T1', 'P7_D6_G1_M6_R1_T1', 'P10_D5_G5_M5_R2_T1', 'P10_D6_G5_M6_R2_T1', 'P11_D5_G6_M5_R1_T1', 'P11_D5_G6_M6_R2_T1', 'P12_D5_G7_M5_R1_T1', 'P12_D5_G7_M6_R1_T1', 'P12_D5_G7_M6_R2_T1', 'P12_D6_G7_M6_R1_T1', 'P7_D6_G1_M6_R2_T1', 'P10_D1_G5_M1_R2_T1', 'P10_D5_G5_M5_R1_T1', 'P10_D5_G5_M6_R1_T1', 'P10_D5_G5_M6_R2_T1', 'P10_D6_G5_M6_R1_T1', 'P10_D6_G5_M6_R1_T2', 'P10_D6_G5_M6_R2_T2', 'P11_D1_G6_M1_R1_T1', 'P11_D1_G6_M6_R1_T1', 'P11_D5_G6_M5_R2_T1', 'P11_D5_G6_M6_R1_T1', 'P11_D6_G6_M6_R1_T1', 'P11_D6_G6_M6_R2_T1', 'P11_D6_G6_M6_R2_T2', 'P12_D1_G7_M1_R1_T1', 'P12_D1_G7_M6_R1_T1', 'P12_D1_G7_M6_R2_T1', 'P12_D5_G7_M5_R2_T1', 'P12_D6_G7_M6_R2_T1']

path_json_files = '/Volumes/WHITE LOTUS/FlamencoProject/SYNCHED/SEPTEMBER_2024/POSE_DATA_DANCER'
#name_files = glob.glob(os.path.join(path_json_files, '*.json'))


# Use glob to search for matching files
def load_fps(folder_path, name_file):
    search_pattern = os.path.join(folder_path, f"*{name_file}*.json")
    file_matches = glob.glob(search_pattern)

    # Filter out files containing 'W' in their names
    without_w = [f for f in file_matches if 'W' not in os.path.basename(f)]
    with_w = [f for f in file_matches if 'W' in os.path.basename(f)]

    # Ensure we found exactly one match
    if len(without_w) == 1:
        file_path = without_w[0]
        try:
            with open(file_path, 'r') as json_file:
                data = json.load(json_file)
                return data['fps']
        except FileNotFoundError:
            print(f"File {file_path} not found.")
        except json.JSONDecodeError:
            print(f"File {file_path} contains invalid JSON.")
    elif len(without_w) > 1:
        print(f"Multiple files matched: {without_w}")
    #else:
        #print(f"No files matched the pattern with substring {name_file}.")

files_ok = []
name_files = ['P5_D5_G3_M5_R2_T1']

for file in name_files: 
    file_name = file.split('_pose_data')[-1].strip('_dancer.json')
    input_json_directory = '/Volumes/WHITE LOTUS/FlamencoProject/SYNCHED/SEPTEMBER_2024/POSE_DATA_'
    #FPS for files
    fps_side =  load_fps(input_json_directory + 'SIDE/', file_name)
    fps_dancer = load_fps(input_json_directory + 'DANCER/', file_name )
    fps_guitar = load_fps(input_json_directory + 'GUITARIST/', file_name)

    if fps_dancer != None and fps_guitar != None and fps_side != None:
        files_ok.append(file_name)


    print(file_name,'dancer: ', fps_dancer, ' side: ',fps_side,' guitar: ' , fps_guitar)

    # Energy

    input_motion_data = '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/energy_toiviainen_adapted/output/26092024'

    body_model_guitar = 'head'
    body_model_dancer = 'upper'
    dancer = file_name.split('_')[0]
    guitarist = file_name.split('_')[2]
                                     

    energy_dacer_df = pd.read_csv(input_motion_data + '_dancer/' + 'Energy_' + body_model_dancer + '_' + dancer + '_' + file_name + '.csv')
    energy_dacer_side = pd.read_csv(input_motion_data + '_side/' + 'Energy_' + body_model_dancer + '_' + dancer + '_' +  file_name + '.csv')
    energy_guitarist_df = pd.read_csv(input_motion_data + '_guitarist/' + 'Energy_' + body_model_guitar + '_' + guitarist + '_' + file_name + '.csv')

    # Input drums 


print('Files ok: ', files_ok)



# # Dancer

input_audio_drums = '/Users/atillajv/CODE/FILES/SYNCH/AUDIO/DRUMS_DEMUCS/' 

input_ent_drums = '/Users/atillajv/CODE/RITMO/ENTROPY/output/main/05_Oct_2023_niels_drums_1s/' # file_name.csv ,t0,LZ,

# input_ent_guitar = '/Users/atillajv/CODE/RITMO/ENTROPY/output/main/05_Oct_2023_niels_guitar_1s/' # file_name.csv ,t0,LZ,

# # Energy 
# body_model_guitar = 'head'
# body_model_dancer = 'upper'
# input_energy = '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/energy_toiviainen_adapted/output/' # Energy_whole_body_P3_P3_D1_G1_M1_R2_T1.csv:  E_pot_sum,E_rot_sum,E_trans_sum,E_kin_sum,cum_E_pot,cum_E_kin,cum_E_rot,cum_E_trans 

# t_step = 1
# participant_list = [file_name.split('_')[0], file_name.split('_')[2]]


# # Note that dt = 0.01 is hardcoded here 
# def import_csv_file(input_path, file_name, y_var = 'dt_LZ', t0 = 't0'):
     

#     df = pd.read_csv(input_path + file_name + '.csv')
#     y = df[y_var]
#     t_array = df[t0]

#     #return data_array, t_start, t_end, samplerate, downsample_factor
#     return df, y, t_array



# def import_energy_file(input_path, file_name, participant, body_model, t_step = 1):
     

#     df = pd.read_csv(input_path + 'Energy_' + body_model +'_' + participant + '_' + file_name + '.csv')

#     with open(input_path +'model_' + body_model + '_' + file_name +'.json') as json_file:
#         info = json.load(json_file)
    
#     samplerate = info['fps']
#     downsample_factor = int(samplerate / (1/t_step))

#     dataDown = df.apply(lambda col: scipy.signal.decimate(col, downsample_factor) if col.dtype in [float, int] else col, axis=0)

#     # Create a new column for time
#     time = np.arange(0, len(dataDown)) * (t_step)
#     dataDown['time'] = time

#     #return data_array, t_start, t_end, samplerate, downsample_factor
#     return dataDown




# def main():

#     df_ent_drums, y_ent_drums, t_ent_drums = import_csv_file(input_ent_drums, file_name)
#     df_ent_guitar, y_ent_guitar, t_ent_guitar = import_csv_file(input_ent_guitar, file_name)
#     df_E_drums = import_energy_file(input_energy, file_name, participant_list[0], body_model_dancer, t_step)
#     df_E_guitar = import_energy_file(input_energy, file_name, participant_list[1], body_model_guitar, t_step)
  
#     # plt.figure()
#     # plt.plot(t_ent_drums, y_ent_drums)
#     # plt.plot(t_ent_guitar, y_ent_guitar)
#     # plt.plot(df_E_drums['time'], df_E_drums['E_pot_sum'])
#     # plt.plot(df_E_guitar['time'], df_E_guitar['E_pot_sum'])
#     # plt.show()

#     print(len(t_ent_drums), len(t_ent_guitar), len(df_E_drums['time']), len(df_E_guitar['time']))

#     print(t_ent_drums.iloc[-1], t_ent_guitar.iloc[-1], df_E_drums['time'].iloc[-1], df_E_guitar['time'].iloc[-1])


#     # Guitarist
#     #input_matrix = np.vstack((y_ent_guitar, df_E_guitar['E_pot_sum'][:-1],df_E_guitar['E_kin_sum'][:-1]))

#     # Both
#     #input_matrix = np.vstack((y_ent_drums,y_ent_guitar, df_E_drums['E_pot_sum'][:-1], df_E_drums['E_kin_sum'][:-1], df_E_guitar['E_pot_sum'][:-1],df_E_guitar['E_kin_sum'][:-1]))
    

#     # Dancer
#     min_length = min(len(t_ent_drums), len(t_ent_guitar), len(df_E_drums['time']), len(df_E_guitar['time']))

#     # Take the values up to the smallest length for each dataframe
#     y_ent_drums = y_ent_drums[:min_length]
#     y_ent_guitar = y_ent_guitar[:min_length]
#     e_pot_sum_drums = df_E_drums['E_pot_sum'][:min_length]
#     e_kin_sum_drums = df_E_drums['E_kin_sum'][:min_length]

#     #input_matrix = np.vstack((y_ent_drums, df_E_drums['E_pot_sum'], df_E_drums['E_kin_sum']))
#     input_matrix = np.vstack((y_ent_drums, e_pot_sum_drums, e_kin_sum_drums))

#     mdqra_whole = False
#     if mdqra_whole:
#         recurrence_matrix = sm.recurrence_matrix(input_matrix, radius= 0.6)
#         rqa_metrics = sm.rqa_metrics(recurrence_matrix)

#         dense_matrix = np.array(recurrence_matrix)
#         #print(rqa_metrics)
#         #Display the dense matrix as a black and white image
#         plt.matshow(dense_matrix, cmap='binary')

#         plt.show()
    

#     ### Split in X equal sizes and do mdQRA for all through loop and store in json dict. 
#     num_columns = input_matrix.shape[1]
#     split_indices = np.array_split(np.arange(num_columns), 5)

#     #print(split_indices, num_columns)

#     split_equal_bins = False
#     if split_equal_bins:

#         rqa_metrics_list = []
#         for indices in split_indices:
#             split_matrix = input_matrix[:, indices]
#             recurrence_matrix = sm.recurrence_matrix(split_matrix, radius=0.6)
#             rqa_metrics = sm.rqa_metrics(recurrence_matrix)
#             rqa_metrics_list.append(rqa_metrics)

#             show_figure = False
#             if show_figure:
#                 # Create a figure with two subplots
#                 fig, (ax1, ax2) = plt.subplots(2, 1)
#                 # Display split_matrix in the first subplot
#                 ax1.matshow(np.array(split_matrix), cmap='jet')
#                 # Display recurrence_matrix in the second subplot
#                 ax2.matshow(np.array(recurrence_matrix), cmap='binary')
#                 # Remove the x-axis ticks and labels for the second subplot
#                 ax2.set_xticks([])
#                 ax2.set_xlabel('')
#                 # Adjust the spacing between subplots
#                 plt.subplots_adjust(wspace=0.3)
#                 plt.show()
#         print(rqa_metrics_list)

#             # Save metrics as JSON
#         metrics_dict = {}
#         for i, metrics in enumerate(rqa_metrics_list):
#             metrics_dict[f'metrics_{i+1}'] = metrics
#         with open(save_dict_path + 'mdQRA_metrics_'+ file_name +'.json', 'w') as f:
#             json.dump(metrics_dict, f)


#     # Define the window size and time step
#     window_size = 32
#     dt_steps = 4

#     # Calculate the number of iterations based on the input matrix shape and window size
#     num_iterations = (input_matrix.shape[1] - window_size) // dt_steps + 1

#     # Initialize an empty dictionary to store the RQA metrics
#     rqa_metrics_dict = {}
#     # Initialize an empty list to store the RQA metrics
#     rqa_metrics_list = []


#     for i in range(num_iterations):
#         start_idx = i * dt_steps
#         end_idx = start_idx + window_size

#         # Get the specific window of data
#         window_data = input_matrix[:, start_idx:end_idx]

#         # Run the RQA algorithm on the window data
#         recurrence_matrix = sm.recurrence_matrix(window_data, radius=0.6)
#         rqa_metrics = sm.rqa_metrics(recurrence_matrix)
#         # Store the RQA metrics in the list
#         rqa_metrics_list.append(rqa_metrics)

#         # Store the RQA metrics in the dictionary
#         rqa_metrics_dict[i] = rqa_metrics

#     # Convert the dictionary to JSON format
#     rqa_metrics_json = json.dumps(rqa_metrics_dict)
#     # Print or save the JSON string
#     print(rqa_metrics_json)
#     # Extract the second element from each array in the list
#     values = [arr[1] for arr in rqa_metrics_list]


#     plot_bar = True
#     if plot_bar: 
#         # Create an array of x values spaced at intervals of 0.1 from 0 to 1
#         x = np.arange(0, len(values), 1)
#         # Create the bar plot
#         plt.bar(x, values, width=0.2)
#         coefficients = np.polyfit(x, values, 4)
#         polynomial = np.poly1d(coefficients)

#         # Generate x values for the polynomial
#         x_fit = np.linspace(x.min(), x.max(), 100)

#         # Evaluate the polynomial for the x values
#         y_fit = polynomial(x_fit)

#         # Plot the polynomial curve
#         plt.plot(x_fit, y_fit, color='red')

#         plt.show()
#         # Set the x-axis ticks and labels
#         #plt.xticks(x, ['Array 1', 'Array 2', 'Array 3', 'Array 4', 'Array 5'])


#     plot_hist = True
#     if plot_hist:
#     # Create the histogram
#         #plt.hist(values, bins=np.arange(0, 1.01, 0.01), edgecolor='black')
#         # Plot the histogram
#         n, bins, _ = plt.hist(values, bins=np.arange(0, 1.01, 0.01), color='black', alpha=0.7)

#         # Fit a polynomial of degree 3 to the histogram
#         coefficients = np.polyfit(bins[:-1], n, 4)
#         polynomial = np.poly1d(coefficients)

#         # Generate x values for the polynomial
#         x_fit = np.linspace(bins.min(), bins.max(), 100)

#         # Evaluate the polynomial for the x values
#         y_fit = polynomial(x_fit)

#         # Plot the polynomial curve
#         plt.plot(x_fit, y_fit, color='red')


#         # Define an exponential function
#         def exponential_func(x, a, b):
#             return a * np.exp(-b * x)

#         # Get the bin centers
#         bin_centers = 0.5 * (bins[1:] + bins[:-1])

#         # Fit the exponential function to the histogram data
#         popt, _ = curve_fit(exponential_func, bin_centers, n)

#         # Generate y values for the fitted exponential curve
#         y_fit = exponential_func(bin_centers, *popt)
#         plt.plot(bin_centers, y_fit, color='green', label='Exponential Fit')


#         # Define a Gaussian function
#         def gaussian_func(x, mu, sigma, A):
#             return A * np.exp(-(x - mu)**2 / (2 * sigma**2))

#         # Get the bin centers
#         bin_centers = 0.5 * (bins[1:] + bins[:-1])

#         # Fit the Gaussian function to the histogram data
#         popt, _ = curve_fit(gaussian_func, bin_centers, n)

#         # Generate y values for the fitted Gaussian curve
#         y_fit = gaussian_func(bin_centers, *popt)

#         # Plot the histogram with the fitted Gaussian curve
#         plt.plot(bin_centers, y_fit, color='orange', label='Gaussian Fit')

#         # Set the x-axis label
#         plt.xlabel('Values')
#         # Set the y-axis label
#         plt.ylabel('Frequency')
#         # Show the plot
#         plt.show()
    
#     metrics_dict = {}
#     for i, metrics in enumerate(rqa_metrics_list):
#         metrics_dict[f'metrics_{i+1}'] = metrics

#     with open(save_dict_path + 'mdQRA_metrics_windowed_'+ file_name +'.json', 'w') as f:
#         json.dump(metrics_dict, f)



        

# if __name__ == "__main__":
#      main()







