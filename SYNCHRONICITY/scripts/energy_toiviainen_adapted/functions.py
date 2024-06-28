# Functions for main.py
import numpy as np
from classes import Segment, Joint
import matplotlib.pyplot as plt
import pandas as pd



def KineticEnergy(j_prox, j_dist, segment, participant):

    segment.vel_cog = np.array(j_prox.vel_norm) + segment.rproxd * (np.array(j_dist.vel_norm) - np.array(j_prox.vel_norm))

    segment.E_trans = 0.5 * segment.mass * participant.mass * segment.vel_cog**2
    segment.E_trans_tot = sum(segment.E_trans)
    print(len(segment.E_trans), segment.E_trans_tot,  'translational energy')

    segment.E_rot = 0.5 * participant.mass * segment.mass * segment.rogcg **2 * segment.vel_cog**2 
    segment.E_rot_tot = sum(segment.E_rot)

    segment.E_kin = segment.E_rot + segment.E_trans
    segment.E_kin_tot = sum(segment.E_kin)
    print(len(segment.E_kin), segment.E_kin_tot, 'Kinetic Energy')


def PotentialEnergy (j_prox, j_dist, segment, participant):
    # Potential energy as a function of pixel/ image height
    #segment.cog_y = np.array(j_prox.pos_y) + segment.rproxd * (np.array(j_dist.pos_y)- np.array(j_prox.pos_y)) 

    # Change in pixel height as measure for potential energy
    #cog_y = np.abs(np.array(j_prox.delta_pos_y) + segment.rproxd * (np.array(j_dist.delta_pos_y)- np.array(j_prox.delta_pos_y))) 
   # Change in pixel height as measure for potential energy
    segment.cog_y = np.abs(np.array(j_prox.delta_pos_y) + segment.rproxd * (np.array(j_dist.delta_pos_y)- np.array(j_prox.delta_pos_y))) 

    segment.E_pot = participant.mass * segment.mass * 9.81 * segment.cog_y 
    segment.E_pot_tot = sum(segment.E_pot)

    print (len(segment.E_pot), segment.E_pot_tot, 'Potential Energy')


def calculate_cumulative_energy(potential_energy):
    cumulative_energy = []
    energy_sum = 0

    for energy in potential_energy:
        #print(energy)
        energy_sum += energy
        cumulative_energy.append(energy_sum)

    return cumulative_energy


def EstimateEnergy(participant, model, out_path, name_file):
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

    E_tot = np.sum(E_kin_sum) + np.sum(E_pot_sum)
    prop_E_kin = np.sum(E_kin_sum)/ E_tot * 100
    prop_E_pot = np.sum(E_pot_sum)/ E_tot * 100
    prop_E_rot = np.sum(E_rot_sum)/ np.sum(E_kin_sum) * 100

    print('Kin prop:', prop_E_kin, 'Pot prop:', prop_E_pot, 'Rot prop:', prop_E_rot)



    cum_E_pot = np.array(calculate_cumulative_energy(E_pot_sum))
    cum_E_kin = calculate_cumulative_energy(E_kin_sum)
    cum_E_rot = calculate_cumulative_energy(E_rot_sum)
    cum_E_trans = calculate_cumulative_energy(E_trans_sum)
    print(len(cum_E_pot), cum_E_pot[-1], len(E_pot_sum))
    plt.figure()
    #plt.plot(time2, cum_E_kin)
    plt.plot(time1,cum_E_pot, label = 'Potential Energy')
    plt.plot(time2,cum_E_kin, label = 'Kinetic Energy')
    plt.plot(time2,cum_E_rot, label = 'Rotational Energy')
    plt.plot(time2,cum_E_trans, label = 'Translational Energy')
    plt.xlabel('Time [s]')
    plt.ylabel('Energy [J/pixel]')
    plt.legend()
    plt.savefig(out_path + 'Energy_'+ str(model.body_parts) + '_'+ str(model.artist) + '_' + name_file + '.png')


    df_store = pd.DataFrame()

    df_store['E_pot_sum'] = E_pot_sum
    df_store['E_rot_sum'] = E_rot_sum
    df_store['E_trans_sum'] = E_trans_sum
    df_store['E_kin_sum'] = E_kin_sum
    df_store['cum_E_pot'] = cum_E_pot
    df_store['cum_E_kin'] = cum_E_kin
    df_store['cum_E_rot'] = cum_E_rot
    df_store['cum_E_trans'] = cum_E_trans

    df_store.to_csv(out_path + 'Energy_'+ str(model.body_parts) + '_'+ str(model.artist) + '_' + name_file + '.csv'  )





# plt.figure()
# time1 = np.arange(len(segment.E_pot)) / model.fps
# time2 = np.arange(len(segment.E_trans)) / model.fps
# plt.plot(time1, segment.E_pot - np.mean(segment.E_pot))
# #plt.plot(time1, joint_prox.pos_y)
# #plt.plot(time1, joint_dist.pos_y)
# plt.plot(time2, segment.E_trans)
# plt.plot(time2, segment.E_rot)
# plt.show()

# Plotting joints position
# plt.figure()
# #plt.plot(joint_dist.vel_x)
# plt.plot(segment.vel_cog)
# plt.plot(segment.E_kin)
# plt.show()

# plt.figure()
# plt.plot(segment.cog_y)
# plt.plot(segment.E_pot)
# plt.show()


# plt.figure()

# # plt.plot(time2, E_kin_sum)
# plt.plot(time1, E_pot_sum)
# plt.show()

# dt = 1/model.fps
# dt_E_pot= np.gradient(E_pot_sum, dt)
# dt_E_kin = np.gradient(E_kin_sum, dt)

# plt.figure()
# plt.plot(time2, dt_E_kin)
# plt.plot(time1, dt_E_pot)
# plt.show()