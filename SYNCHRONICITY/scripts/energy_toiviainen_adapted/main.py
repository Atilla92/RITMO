
import pandas as pd
import json
from classes import Model, Participant, Segment, Joint
from functions import KineticEnergy, PotentialEnergy
import matplotlib.pyplot as plt
import numpy as np
# Steps
# Create a dictionnary list, that maps joints to numbers
# String split at last _, if new name create new name in dictionarry, else add new element to list with name after _ and number: _ as the i-th iteration. 'Store name as well'. Store as a json to inspect. Either you can add the i-th iteration as name, or you can loop though dictionary and add element, from another dictionnarie's match. Could store that information in the general DF. If name of element matches JOINT_NAME_MP fetch JOINT_ID_MP    
# Based on dictionary add extra joints 33 - 36
# Create a ditionnary that relates joints numbers to segment
# Need to fetch csv with information from dataset .csv
# Need to save data in in a dictionary data = {1: {x:[], y:[], z:[]}} 
# Question is whether it should be made compatible with other inputs. Perhaps not to start with

###### DAY 2###

## For now created a json dictionnary with values, and body models male and female. 

## Now need to create a .csv with information participants. And probably set whether the analysis is on musicians or on dancers. Let's do dancers to start with. 
## Figure out how to work with classes and whether it is more efficient. Probaly nice to fetch the info from the csv and put it in the class, but also allow it to have input array. 

# And probably something to determine whether we are analysing guitarist or dancer. or both. Analyse string 


## Day 4##
# Need to plot energies, figure out whether we would like to have change in potential energy, or potential energy, since limb will become a negative Epot sometimes for segment. 

# Example usage
file_name = 'P3_D1_G1_M1_R2_T1'
# Create a participant object

with open('/Users/atillajv/CODE/RITMO/SYNCHRONICITY/output/node_output/pose_data/variables_pose_data_'+ file_name +'.json') as json_file:
    info = json.load(json_file)


participant_path = '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/energy_toiviainen_adapted/models/participants_info.csv'

data_input_path = '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/output/node_output/pose_data/dict_pose_data_'+ file_name +'.json'



# Create Participant, Model,
participant = Participant("P3", False, info_path= participant_path)

# Display participant information
participant.display_info()

model = Model('Dancer', 'center', filter = True) # Set filter to treue if you want to apply a bandpass filter. 
model.fps = info['fps']
model.data_path = data_input_path
model.display_info()



# Create Segment, Joint Prox, Dist. Need to loop over Model.segment_array later.  

E_pot_mat = []
E_rot_mat = []
E_trans_mat = []
E_kin_mat = []
E_pot_tot = []
E_trans_tot = []
E_rot_tot = []
E_kin_tot = []

for i, item in enumerate(model.segment_array):
    segment = Segment(participant, model, item )

    segment.display_info()
    joint_prox = Joint(segment.j_prox, model)
    joint_dist = Joint(segment.j_dist, model )

    joint_prox.meanVelocity()
    joint_dist.meanVelocity()
    joint_dist.display_info()

    KineticEnergy(joint_prox, joint_dist, segment, participant)
    PotentialEnergy(joint_prox, joint_dist, segment, participant)

    E_pot_mat.append(segment.E_pot)
    E_trans_mat.append(segment.E_trans)
    E_rot_mat.append(segment.E_rot)
    E_kin_mat.append(segment.E_kin)

    E_pot_tot.append(segment.E_pot_tot)
    E_kin_tot.append(segment.E_kin_tot)
    E_rot_tot.append(segment.E_rot_tot)
    E_trans_tot.append(segment.E_trans_tot)

    # plt.figure()
    # time1 = np.arange(len(segment.E_pot)) / model.fps
    # time2 = np.arange(len(segment.E_trans)) / model.fps
    # plt.plot(time1, segment.E_pot - np.mean(segment.E_pot))
    # #plt.plot(time1, joint_prox.pos_y)
    # #plt.plot(time1, joint_dist.pos_y)
    # plt.plot(time2, segment.E_trans)
    # plt.plot(time2, segment.E_rot)
    # plt.show()
    plt.figure()
    plt.plot(joint_dist.vel_norm)
    plt.plot(joint_prox.vel_norm)
    plt.show()

# Apply Bandpass if needed. 

# Bandpass filter parameters

time1 = np.arange(len(segment.E_pot)) / model.fps
time2 = np.arange(len(segment.E_trans)) / model.fps
E_pot_mat = np.array(E_pot_mat)
E_rot_mat = np.array(E_rot_mat)
E_trans_mat = np.array(E_trans_mat)
E_kin_mat = np.array(E_kin_mat)

E_pot_sum = np.sum(E_pot_mat, axis = 0)
E_rot_sum = np.sum(E_rot_mat, axis = 0)
E_trans_sum = np.sum(E_trans_mat, axis = 0)
E_kin_sum = np.sum(E_kin_mat, axis = 0)

print(E_kin_sum.shape)
# plt.figure

plt.plot(time2, E_kin_sum)
plt.plot(time1, E_pot_sum)
plt.show()

# def normVelocity (Segment):
# # Initialize empty lists to store velocities
#     velocities_x = []
#     velocities_y = []
#     velocities_z = []
#     z_angles = []
#     y_angles = []
#     x_angles = []
#     rotations = []

#     x_pos = 


    

#     # Iterate through the position data to calculate velocities
#     for i in range(len(x_array) - 1):  # Iterate up to the second-to-last index

        
#         # Estimation of Euler angles
#         # https://www.meccanismocomplesso.org/en/3d-rotations-and-euler-angles-in-python/
#         # https://dfki-ric.github.io/pytransform3d/_auto_examples/plots/plot_matrix_from_two_vectors.html
#         # https://dfki-ric.github.io/pytransform3d/_apidoc/pytransform3d.rotations.matrix_from_two_vectors.html#pytransform3d.rotations.matrix_from_two_vectors
#         # https://docs.scipy.org/doc/scipy/reference/generated/scipy.spatial.transform.Rotation.html
#         v1 = [x_array[i], y_array[i], z_array[i]]
#         v2 = [x_array[i+1], y_array[i+1], z_array[i+1]]
#         # Estimation of rotatin matrix
#         #'https://docs.scipy.org/doc/scipy/reference/generated/scipy.spatial.transform.Rotation.align_vectors.html'
#         rot, _ = R.align_vectors(v1, v2)
#         angles = rot.as_euler('zyx', degrees = False)     
#         z_angles.append(angles[0])
#         y_angles.append(angles[1])
#         x_angles.append(angles[2])
#         rot_mat = rot.as_matrix()
#         rotations.append(rot_mat)
#         # Get Euler angles of rotation matrix

        



#         delta_t = time[i + 1] - time[i]  # Calculate the time difference
#         #delta_t = np.diff(time)

#         # Calculate velocities using the first derivative formula

#         velocity_x = (x_array[i + 1] - x_array[i]) / delta_t
#         #velocity_x = np.diff(x_array)/delta_t
#         velocity_y = (y_array[i + 1] - y_array[i]) / delta_t
#         velocity_z = (z_array[i + 1] - z_array[i]) / delta_t
       

#         # Append the calculated velocities to the respective lists
#         velocities_x.append(velocity_x)
#         velocities_y.append(velocity_y)
#         velocities_z.append(velocity_z)
        

        

#     velocity = np.sqrt(np.array(velocities_x)**2 + np.array(velocities_y) **2 + np.array(velocities_z) ** 2)
#     return velocities_x, velocities_y, velocities_z, velocity, x_angles, y_angles, z_angles, rotations 



# vx, vy, vz, v_tot, angle_x, angle_y, angle_z, rot_mat = estimateVelocity(df['LEFT_HIP_X'], df['LEFT_HIP_Y'], df['LEFT_HIP_Z'], time)
# vx_filt, vy_filt, vz_filt, v_tot_filtered, angle_x_filt, angle_y_filt, angle_z_filt, rot_mat_filtered = estimateVelocity(filtered_data_x, filtered_data_y, filtered_data_z, time)




# acc_tot = np.diff(v_tot)/np.diff(time[1:])
# acc_tot_filtered = np.diff(v_tot_filtered)/np.diff(time[1:])


