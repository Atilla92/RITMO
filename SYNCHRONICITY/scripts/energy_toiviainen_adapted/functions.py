# Functions for main.py
import numpy as np



def KineticEnergy(j_prox, j_dist, segment, participant):

    vel_cog = np.array(j_prox.vel_norm) + segment.rproxd * (np.array(j_dist.vel_norm) - np.array(j_prox.vel_norm))

    segment.E_trans = 0.5 * segment.mass * participant.mass * vel_cog**2
    segment.E_trans_tot = sum(segment.E_trans)
    print(len(segment.E_trans), segment.E_trans_tot,  'translational energy')

    segment.E_rot = 0.5 * participant.mass * segment.mass * segment.rogcg **2 * vel_cog **2 
    segment.E_rot_tot = sum(segment.E_rot)

    segment.E_kin = segment.E_rot + segment.E_trans
    segment.E_kin_tot = sum(segment.E_kin)
    print(len(segment.E_kin), segment.E_kin_tot, 'Kinetic Energy')


def PotentialEnergy (j_prox, j_dist, segment, participant):

    cog_y = np.array(j_prox.pos_y) + segment.rproxd * (np.array(j_dist.pos_y)- np.array(j_prox.pos_y)) 

    # Change in altitude as measure for potential energy
    #cog_y = np.array(j_prox.delta_pos_y) + segment.rproxd * (np.array(j_dist.delta_pos_y)- np.array(j_prox.delta_pos_y)) 

    segment.E_pot = participant.mass * segment.mass * 9.81 * cog_y 
    segment.E_pot_tot = sum(segment.E_pot)

    print (len(segment.E_pot), segment.E_pot_tot, 'Potential Energy')


