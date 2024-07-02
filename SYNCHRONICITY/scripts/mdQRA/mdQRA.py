import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import scipy
from scipy.io.wavfile import read

#from takensEmbedding import find_optimal_delay, find_optional_dimension
from multiSyncPy import synchrony_metrics as sm
import json

# import plotly.express as px
# import plotly.graph_objects as go
# from sktime.datasets import load_airline, load_shampoo_sales, load_lynx


# Audio input, raw or entropy


input_path = '/Users/atillajv/CODE/RITMO/ONSET/output_drums/'
#input_audio = '/Volumes/WHITE LOTUS/AUDIO/DRUMS_DEMUCS/'
input_audio = '/Volumes/Seagate/AUDIO/DRUMS_DEMUCS/'
input_video = '/Users/atillajv/CODE/RITMO/PILOT_SEV_APRIL_2022/output/videoAnalysis/motionData_'
file_name = 'P3_D1_G1_M1_R2_T1'


# Dancer
input_audio_drums = '/Users/atillajv/CODE/FILES/SYNCH/AUDIO/DRUMS_DEMUCS/' # file_name.wav
input_ent_drums = '/Users/atillajv/CODE/RITMO/ENTROPY/output/main/09_Oct_2023_niels_drums_4s/' # file_name.csv ,t0,LZ,dt_LZ,IOI,nCounts

# Guitarist
input_audio_guitar = '/Users/atillajv/CODE/FILES/SYNCH/AUDIO/GUITAR_DEMUCS/' # file_name.wav
input_ent_guitar = '/Users/atillajv/CODE/RITMO/ENTROPY/output/main/09_Oct_2023_niels_guitar_4s/' # file_name.csv ,t0,LZ,dt_LZ,IOI,nCounts

# Energy 
body_model = 'whole_body'
input_energy = '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/energy_toiviainen_adapted/output/' # Energy_whole_body_P3_P3_D1_G1_M1_R2_T1.csv:  E_pot_sum,E_rot_sum,E_trans_sum,E_kin_sum,cum_E_pot,cum_E_kin,cum_E_rot,cum_E_trans 


participant_list = [file_name.split('_')[0], file_name.split('_')[2]]


# Note that dt = 0.01 is hardcoded here 
def import_csv_file(input_path, file_name, y_var = 'LZ', t0 = 't0'):
     

    df = pd.read_csv(input_path + file_name + '.csv')
    y = df[y_var]
    t_array = df[t0]

    #return data_array, t_start, t_end, samplerate, downsample_factor
    return df, y, t_array



def import_energy_file(input_path, file_name, participant, body_model, t_step = 4):
     

    df = pd.read_csv(input_path + 'Energy_' + body_model +'_' + participant + '_' + file_name + '.csv')

    with open(input_path +'model_' + body_model + '_' + file_name +'.json') as json_file:
        info = json.load(json_file)
    
    samplerate = info['fps']
    downsample_factor = int(samplerate / (1/t_step))

    dataDown = df.apply(lambda col: scipy.signal.decimate(col, downsample_factor) if col.dtype in [float, int] else col, axis=0)

    # Create a new column for time
    time = np.arange(0, len(dataDown)) * (t_step)
    dataDown['time'] = time

    #return data_array, t_start, t_end, samplerate, downsample_factor
    return dataDown




def main():
     # your code here....   
          
    # t = [i for i in np.arange(0, 20, 0.1)]
    # y = [np.sin(i) for i in t]
    df_ent_drums, y_ent_drums, t_ent_drums = import_csv_file(input_ent_drums, file_name)
    df_ent_guitar, y_ent_guitar, t_ent_guitar = import_csv_file(input_ent_guitar, file_name)
    df_E_drums = import_energy_file(input_energy, file_name, participant_list[0], body_model)
    df_E_guitar = import_energy_file(input_energy, file_name, participant_list[1], body_model)
  
    # plt.figure()
    # plt.plot(t_ent_drums, y_ent_drums)
    # plt.plot(t_ent_guitar, y_ent_guitar)
    # plt.plot(df_E_drums['time'], df_E_drums['E_pot_sum'])
    # plt.plot(df_E_guitar['time'], df_E_guitar['E_pot_sum'])
    # plt.show()

    print(len(t_ent_drums), len(t_ent_guitar), len(df_E_drums['time']), len(df_E_guitar['time']))

    print(t_ent_drums.iloc[-1], t_ent_guitar.iloc[-1], df_E_drums['time'].iloc[-1], df_E_guitar['time'].iloc[-1])


    # Priobably does not work on binary dataset. Need to either work with raw data. And then create a reconstruccted phase-state input. Or figure out 
    # optimal_tau_y1 = find_optimal_delay(y1,maxtau= 50)
    # optimal_dim_y1 = find_optional_dimension(y1, optimal_tau_y1)

    # optimal_tau_y2 = find_optimal_delay(y2,maxtau= 50)
    # optimal_dim_y2 = find_optional_dimension(y2, optimal_tau_y2)

    # print(optimal_tau_y1, optimal_dim_y1, optimal_tau_y2, optimal_dim_y2)


    #input_matrix = np.vstack((y_ent_guitar, df_E_guitar['E_pot_sum'][:-1],df_E_guitar['E_kin_sum'][:-1]))

    input_matrix = np.vstack((y_ent_drums,y_ent_guitar, df_E_drums['E_pot_sum'][:-1], df_E_drums['E_kin_sum'][:-1], df_E_guitar['E_pot_sum'][:-1],df_E_guitar['E_kin_sum'][:-1]))
    
    #input_matrix = np.vstack((y_ent_drums, df_E_drums['E_pot_sum'][:-1], df_E_drums['E_kin_sum'][:-1]))
    recurrence_matrix = sm.recurrence_matrix(input_matrix, radius= 0.85)
    rqa_metrics = sm.rqa_metrics(recurrence_matrix)

    print(rqa_metrics)

    dense_matrix = np.array(recurrence_matrix)

    #Display the dense matrix as a black and white image
    plt.matshow(dense_matrix, cmap='binary')

    plt.show()


    # # Create a heatmap using Seaborn

    # sns.heatmap(recurrence_matrix, annot=True, cmap='YlGnBu', cbar=False, linewidths=.5)

    # # Show the plot
    # plt.show()
        

if __name__ == "__main__":
     main()






# rqa_metrics = sm.rqa_metrics(recurrence_matrix)

# print(rqa_metrics)




