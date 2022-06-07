import glob
from scipy.io.wavfile import read

name_files = []
audio_files = []

for filepath in glob.iglob('Audio/*.wav'):
    if filepath.endswith('.wav'):
        # filepath_split = filepath.partition('/')
        # filepath_split = filepath_split[2].partition('/')
        # filepath_split = filepath_split[2].partition('-')
        audio_files.append(filepath)


print (audio_files[0])


#for i, item in enumerate(audio_files):

data_audio = read(str(audio_files[0]))