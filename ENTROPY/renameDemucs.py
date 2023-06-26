"""
This script will rename the files created and stored by demucs in one folder. 
"""
import glob
import os


#old_folder = '/Users/atillajv/Ritmo/L-Lausanne/DEMUCS/separated/htdemucs_6s/'
old_folder = '/Volumes/Seagate/FlamencoProject/F_Andalucia/DEMUCS/separated/htdemucs_6s/'
#new_folder = '/Users/atillajv/CODE/FILES/PILOT_SEV_APRIL_2022/Audio_Lausanne/htdemucs_6s/all_guitar/'
new_folder = '/Volumes/Seagate/FlamencoProject/F_Andalucia/DEMUCS/separated/drums/'


# 1. Name all files in the path 
# Get last string (name file) and add /drums.wav
# Rename to name file and store in a different location (/separated)
# Create new folder where to store 

for file in os.listdir(old_folder):
    print (file)

    oldName = str(old_folder + file + "/drums.wav")
    newName = str(new_folder + file + '.wav')    
    try:
        os.rename(oldName, newName)

    except: 
        print('file not found:', file)
        pass

    


