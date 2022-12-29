import moviepy.editor
import numpy as np 
import matplotlib.pyplot as plt
from scipy.io.wavfile import read
import glob
import os

# Find peak in video
# Find peak in audio
# Substract Audio t_audio from video t_video.  
# e.g. t_audio = 6, t_video = 10, dt = 4, t_audio = t_audio + dt
# store as a dataframe or json
# name file, t_audio, t_video, dt

loop_on = True
loop_off  = "P3_D1_G1_M6_R2_T1"
audio_files = []
video_path = "/Users/atillajv/CODE/FILES/PILOT_SEV_APRIL_2022/VIDEOS_SMALL/" 
audio_path = '/Users/atillajv/CODE/FILES/PILOT_SEV_APRIL_2022/Audio/'
file_output ='/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/sanityCheck/'

error_files = []
if loop_on:
    for filepath in glob.iglob(str(audio_path + '*.wav')):
        if filepath.endswith('.wav'):
            filepath_split = filepath.partition('Audio/')
            print (filepath_split)
            audio_files.append(filepath_split[2].strip('.wav'))
else:
 audio_files = [loop_off]


for i, file_name in enumerate(audio_files):
    print('file being analysed: ', file_name)

    samplerate, data_raw = read(str( audio_path+ file_name + '.wav'))
   
    try:
        video = moviepy.editor.VideoFileClip(str(video_path+file_name + '.mp4'))
        audio = video.audio

        array_audio = audio.to_soundarray(fps = samplerate)

        f, (ax1, ax2) = plt.subplots(2, 1, sharex=False)
        #print(array_audio)
        ax1.plot(array_audio)
        ax2.plot(data_raw[:,1])
        plt.savefig(str(file_output + file_name + '.png'))

    except OSError:
        print('file not found: ', file_name)
        error_files.append(file_name)
        pass


print(error_files)