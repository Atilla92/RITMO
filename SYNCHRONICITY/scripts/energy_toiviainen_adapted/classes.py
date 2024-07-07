
# Creates classes for Model, Participant

import pandas as pd
import json
from scipy.signal import butter, filtfilt
import numpy as np
from scipy.signal import savgol_filter


class Segment: 
    def __init__(self, Participant, Model, segment_ID ):

        self.id = int(segment_ID),
        self.j_prox = None
        self.j_dist = None
        self.mass = None
        self.rproxd = None
        self.kproxd = None
        self.rogcg = None
        self.length = None
        self.body_side = None
        self.E_trans = None
        self.E_trans_tot = None
        self.E_rot = None
        self.E_rot_tot = None
        self.E_kin = None
        self.E_kin_tot = None
        self.E_pot = None
        self.E_pot_tot = None
        self.vel_cog = None
        self.cog_y = None

        if Participant.gender == 'F':
            df = pd.read_csv(Model.model_female)
        
        if Participant.gender == 'M':
            df = pd.read_csv(Model.model_male)

        # Find the row with the participant ID
        participant_row = df[df['segment_ID'] == self.id]

        # If participant ID is found, fetch the mass, gender, and height values
        if not participant_row.empty:

            self.j_prox = participant_row['joint_prox'].iloc[0]
            self.j_dist = participant_row['joint_dist'].iloc[0]
            self.mass = participant_row['mass'].iloc[0]
            self.rproxd = participant_row['rproxd'].iloc[0]
            self.kproxd = participant_row['kproxd'].iloc[0]
            self.rogcg = participant_row['rogcg'].iloc[0]
            self.length = participant_row['length'].iloc[0]
            self.body_side = participant_row['body_side'].iloc[0]


    def display_info(self):
        print("Segment ID:", self.id)
        print("Joint Prox:", self.j_prox)
        print("Joint Dist:", self.j_dist)
        print("Mass:", self.mass)
        print("RProxD:", self.rproxd)
        print("KProxD:", self.kproxd)
        print("ROGCG:", self.rogcg)
        print("Length:", self.length)
        print("Body Side:", self.body_side)


class Joint:
    def __init__(self, ID, Model):
        self.id = ID
        self.raw_x = []
        self.raw_y = []
        self.raw_z = []
        self.pos_x = []
        self.pos_y = []
        self.delta_pos_y = []
        self.pos_z = []
        self.vel_x = []
        self.vel_y = []
        self.vel_z = []
        self.length_array = None
        self.fps = Model.fps
        self.vel_norm = []

        with open(Model.data_path) as json_file:
            json_data = json.load(json_file)

            for key, value in json_data.items():
                # print('Key:', key)
                # print('Elements:')
                for element_key, element_value in value.items():
                   # print(f"\t{element_key}")
                    if element_key == "ID" and element_value == self.id:
                        print('TRUE')
                        if "X" in value:
                            self.pos_x = value["X"]
                            self.raw_x = value["X"]
                        if "Y" in value:
                            self.pos_y = [1 - val for val in value["Y"]]
                            self.raw_y = [1 - val for val in value["Y"]]
                            
                        if "Z" in value:
                            self.pos_z = value["Z"]
                            self.raw_z = value["Z"]
                        break  # Exit the method once the matching element is found
        if Model.filter == 'bandpass' or Model.filter == 'lowpass': 
            print('Bandpass filter has been applied to data')
            fps = Model.fps
            normalized_lowcut = Model.lowcut / (fps/2)  # 0.01

            if Model.filter == 'bandpass':
         
                normalized_highcut = Model.highcut / (fps/2)  # 0.1
                b, a = butter(Model.order, [normalized_lowcut, normalized_highcut], btype='band')
            
            if Model.filter == 'lowpass':
                b, a = butter(Model.order, normalized_lowcut, btype='lowpass')

            # Center the data around the mean
            mean_pos_x = np.mean(self.pos_x)
            mean_pos_y = np.mean(self.pos_y)
            mean_pos_z = np.mean(self.pos_z)
            self.pos_x = self.pos_x - mean_pos_x
            self.pos_y = self.pos_y - mean_pos_y
            self.pos_z = self.pos_z - mean_pos_z

            # Apply the bandpass filter
            self.pos_x = filtfilt(b, a, self.pos_x)
            self.pos_y = filtfilt(b, a, self.pos_y)
            self.pos_z = filtfilt(b, a, self.pos_z)

            # Restore the mean
            self.pos_x = self.pos_x + mean_pos_x
            self.pos_y = self.pos_y + mean_pos_y
            self.pos_z = self.pos_z + mean_pos_z

        if Model.filter == 'savgol':
            self.pos_x = savgol_filter(self.pos_x, window_length=Model.window_savgol, polyorder=Model.or_savgol) 
            self.pos_y = savgol_filter(self.pos_y, window_length=Model.window_savgol, polyorder=Model.or_savgol) 
            self.pos_z = savgol_filter(self.pos_z, window_length=Model.window_savgol, polyorder=Model.or_savgol) 
        
        self.length_array = len(self.pos_x)
    
    def meanVelocity(self):
        delta_t = 1/self.fps
        for i in range(self.length_array - 1):

            # Calculate velocities using the first derivative formula
            vel_x = (self.pos_x[i + 1] - self.pos_x[i]) / delta_t
            self.vel_x.append(vel_x)
            vel_y = (self.pos_y[i + 1] - self.pos_y[i]) / delta_t
            self.vel_y.append(vel_y)
            vel_z = (self.pos_y[i + 1] - self.pos_y[i]) / delta_t
            self.vel_z.append(vel_z)
            delta_pos_y = self.pos_y[i + 1] - self.pos_y[i]
            self.delta_pos_y.append(delta_pos_y)
            self.vel_norm.append(np.sqrt(vel_x**2 + vel_y ** 2 + vel_z **2))

    def display_info(self):
        print("Joint ID:", self.id)
        print("Position (X):", len(self.pos_x))
        print("Position (Y):", len(self.pos_y))
        print("Position (Z):", len(self.pos_z))
        print("Velocity (Z):", len(self.vel_z))
        print("Velocity Norm:", len(self.vel_norm))


class Model:
    def __init__(self, artist, segment_array=None, model_male = None, model_female = None, filter = False, lowcut = 0.5, highcut = 10, order = 2, window_savgol = 20, or_savgol = 2):
        self.artist = artist
        self.body_parts = segment_array
        self.filter = filter
        self.fps = None
        self.lowcut = lowcut  # Lower cutoff frequency in Hz
        self.highcut = highcut  # Upper cutoff frequency in Hz
        self.order = order  # Filter order
        self.data_path = None
        self.window_savgol = window_savgol
        self.or_savgol = or_savgol

        if model_male: 
            self.model_male = model_male
        else:
            self.model_male = '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/energy_toiviainen_adapted/models/body_model_plagenhoef_1993_male.csv'
        
        if model_female:
            self.model_female = model_female
        else:
            self.model_female = '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/energy_toiviainen_adapted/models/body_model_plagenhoef_1993_female.csv'      

        if segment_array is None:
            segment_array = "whole_body"  # Default segment array type

        if segment_array == "whole_body":
            self.segment_array = [1,2,3,5,6,7,14,15,16,18,19,20,9,10,11,12,13]  # Default whole body segment array
        
        elif segment_array == "right_side":
            self.segment_array = [1,2,3,5,6,7]  # Default right side segment array
        
        elif segment_array == 'left_side':
            self.segment_array = [14,15,16,18,19,20]
        
        elif segment_array == 'center':
            self.segment_array = [9, 10, 11, 12, 13]
        
        elif segment_array == 'lower':
            self.segment_array = [5,6,7,18,19,20]
        
        elif segment_array == 'upper':
            self.segment_array = [1,2,3, 14,15,16]
        
        else:
            self.segment_array = segment_array

    def display_info(self):
        print("Artist:", self.artist)
        print("Segment Array:", self.segment_array)
        print("Filter:", self.filter)
        print("Model Male:", self.model_male)

class Participant:
    def __init__(self, participant_id, default_values, info_path):
        self.participant_id = participant_id
        self.mass = None
        self.gender = None
        self.height = None

        # Read the CSV file as a DataFrame
        df = pd.read_csv(info_path)

        # Find the row with the participant ID
        participant_row = df[df['ID'] == self.participant_id]

        # If participant ID is found, fetch the mass, gender, and height values
        if not participant_row.empty:
            self.mass = participant_row['Mass'].iloc[0]
            self.gender = participant_row['Gender'].iloc[0]
            self.height = participant_row['Height'].iloc[0]

            # Set default mass values based on gender if no value is provided
            if pd.isnull(self.mass) or default_values:
                if self.gender == 'Female':
                    self.mass = 63.4
                    self.height = 164
                else:
                    self.mass = 74.1
                    self.mass = 176

    def display_info(self):
        print("Participant ID:", self.participant_id)
        print("Mass:", self.mass)
        print("Gender:", self.gender)
        print("Height:", self.height)
