import pandas as pd
import json
from classes import Model, Participant, Segment, Joint
from functions import KineticEnergy, PotentialEnergy, calculate_cumulative_energy, EstimateEnergy
import matplotlib.pyplot as plt
import numpy as np
from scipy.optimize import curve_fit
# Steps

participant_path = '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/energy_toiviainen_adapted/models/participants_info.csv'




# Example usage
file_name = 'P3_D1_G1_M1_R2_T1'



with open('/Users/atillajv/CODE/RITMO/SYNCHRONICITY/output/node_output/pose_data/variables_pose_data_'+ file_name +'.json') as json_file:
    info = json.load(json_file)

date = ''

analysis = '0' # 0 for dancer, 1 for guitaris, 2 for both

if analysis == '2' :
    participant_list = [file_name.split('_')[0], file_name.split('_')[2]]
if analysis == '0':
    participant_list = [file_name.split('_')[0]]

if analysis == '1':
    participant_list = [file_name.split('_')[1]]

for i, item in enumerate(participant_list):
    data_input_path = '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/output/node_output/pose_data/'+date +'dict_pose_data_'+ item +'_' + file_name +'.json'

    # Create Participant, Model,
    participant = Participant(item, False, info_path= participant_path)

    # Display participant information
    participant.display_info()

    segment_arrays = [1,3]


    model1 = Model(artist = item, segment_array= segment_arrays, filter = 'lowpass', lowcut = 0.5, highcut= 15) # Set filter to treue if you want to apply a bandpass filter. 
    model2 = Model(artist = item, segment_array= segment_arrays, filter = 'savgol', window_savgol=60, or_savgol=2)
    model1.fps = info['fps']
    model1.data_path = data_input_path

    model2.data_path = data_input_path
    model2.fps = info['fps']

    model1.display_info()

    for i, item in enumerate(model1.segment_array):
        # First filter
        segment1 = Segment(participant, model1, item )
        segment1.display_info()
        joint_prox1 = Joint(segment1.j_prox, model1)
        joint_dist1 = Joint(segment1.j_dist, model1 )
        
        # Second filter
        segment2 = Segment(participant, model2, item )
        segment2.display_info()
        joint_prox2 = Joint(segment2.j_prox, model2)
        joint_dist2 = Joint(segment2.j_dist, model2 )

        # joint_prox1.meanVelocity()
        # joint_dist1.meanVelocity()
        # joint_dist1.display_info()

        time_array = (np.arange(0,len(joint_prox1.raw_x)))/model1.fps

        fig, axs = plt.subplots(3, 3, figsize=(10, 10), sharey= True, sharex= True)

        axs[0,0].plot(time_array,joint_prox1.raw_x)
        axs[0,1].plot(time_array,joint_prox1.raw_y)
        axs[0,2].plot(time_array,joint_prox1.raw_z)
        axs[0, 0].set_ylabel('Raw')
        axs[0, 0].set_title('POS X')
        axs[0, 1].set_title('POS Y')
        axs[0, 2].set_title('POS Z')

        axs[1,0].plot(time_array, joint_prox1.pos_x)
        axs[1,1].plot(time_array, joint_prox1.pos_y)
        axs[1,2].plot(time_array, joint_prox1.pos_z)
       
        axs[1, 0].set_ylabel(model1.filter + ' l/h =' +str(model1.lowcut) +'/' + str(model1.highcut) )

        axs[2,0].plot(time_array, joint_prox2.pos_x)
        axs[2,1].plot(time_array, joint_prox2.pos_y)
        axs[2,2].plot(time_array, joint_prox2.pos_z)
        axs[2,0].set_xlabel('Time [s]')
        axs[2,1].set_xlabel('Time [s]')
        axs[2,2].set_xlabel('Time [s]')
 
        axs[2, 0].set_ylabel(model2.filter +' w/o =' +str(model2.window_savgol) + '/'+ str(model2.or_savgol))

        plt.show()

        joint_prox1.meanVelocity()
        joint_prox2.meanVelocity()


        time_array2 = (np.arange(0,len(joint_prox1.vel_x)))/model1.fps

        fig, axs = plt.subplots(3, 3, figsize=(10, 10), sharey= True, sharex= True)

        axs[0,0].plot(time_array,joint_prox1.raw_x)
        axs[0,1].plot(time_array,joint_prox1.raw_y)
        axs[0,2].plot(time_array,joint_prox1.raw_z)
        axs[0, 0].set_ylabel('Raw Position')
        axs[0, 0].set_title('X')
        axs[0, 1].set_title('Y')
        axs[0, 2].set_title('Z')

        axs[1,0].plot(time_array, joint_prox1.pos_x)
        axs[1,1].plot(time_array, joint_prox1.pos_y)
        axs[1,2].plot(time_array, joint_prox1.pos_z)
        axs[1, 0].set_ylabel( model1.filter + ' l/h =' +str(model1.lowcut) +'/' + str(model1.highcut) )

        axs[2,0].plot(time_array2, joint_prox1.vel_x)
        axs[2,1].plot(time_array2, joint_prox1.vel_y)
        axs[2,2].plot(time_array2, joint_prox1.vel_z)
        axs[2,0].set_xlabel('Time [s]')
        axs[2,1].set_xlabel('Time [s]')
        axs[2,2].set_xlabel('Time [s]')
 
        axs[2, 0].set_ylabel('Velocity')

        plt.show()


        fig, axs = plt.subplots(3, 3, figsize=(10, 10), sharey= True, sharex= True)

        axs[0,0].plot(time_array,joint_prox2.raw_x)
        axs[0,1].plot(time_array,joint_prox2.raw_y)
        axs[0,2].plot(time_array,joint_prox2.raw_z)
        axs[0, 0].set_ylabel('Raw Position')
        axs[0, 0].set_title('X')
        axs[0, 1].set_title('Y')
        axs[0, 2].set_title('Z')

        axs[1,0].plot(time_array, joint_prox2.pos_x)
        axs[1,1].plot(time_array, joint_prox2.pos_y)
        axs[1,2].plot(time_array, joint_prox2.pos_z)
        axs[1, 0].set_ylabel(model2.filter +' w/o =' +str(model2.window_savgol) + '/'+ str(model2.or_savgol))

        axs[2,0].plot(time_array2, joint_prox2.vel_x)
        axs[2,1].plot(time_array2, joint_prox2.vel_y)
        axs[2,2].plot(time_array2, joint_prox2.vel_z)
        axs[2,0].set_xlabel('Time [s]')
        axs[2,1].set_xlabel('Time [s]')
        axs[2,2].set_xlabel('Time [s]')
 
        axs[2, 0].set_ylabel('Velocity')
        plt.show()


        plot_hist = True
        if plot_hist:
    # Create the histogram
        #plt.hist(values, bins=np.arange(0, 0.6, 0.01), edgecolor='black')
        # Plot the histogram
            
            
            fig, axs = plt.subplots(2, 3, figsize=(10, 10), sharey= True, sharex= True)
            
            axs[0,0].hist(joint_prox1.vel_x, bins=np.arange(0, 0.6, 0.01), color='black', alpha=0.7)

            axs[0,1].hist(joint_prox1.vel_y, bins=np.arange(0, 0.6, 0.01), color='black', alpha=0.7)

            axs[0,2].hist(joint_prox1.vel_z, bins=np.arange(0, 0.6, 0.01), color='black', alpha=0.7)

            axs[1,0].hist(joint_prox2.vel_x, bins=np.arange(0, 0.6, 0.01), color='black', alpha=0.7)

            axs[1,1].hist(joint_prox2.vel_y, bins=np.arange(0, 0.6, 0.01), color='black', alpha=0.7)

            axs[1,2].hist(joint_prox2.vel_z, bins=np.arange(0, 0.6, 0.01), color='black', alpha=0.7)

            # Set the x-axis label
            # plt.xlabel('Values')
            # # Set the y-axis label
            # plt.ylabel('Frequency')
            # Show the plot
            plt.show()
  





