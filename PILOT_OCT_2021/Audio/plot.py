# import matplotlib.pyplot as plt
# import numpy as np
# import wave
# import sys


# spf = wave.open("Data/Buleria_IMP_P1_1.wav", "r")

# # Extract Raw Audio from Wav File
# signal = spf.readframes(-1)
# signal = np.fromstring(signal, "Int16")


# # If Stereo
# if spf.getnchannels() == 2:
#     print("Just mono files")
#     sys.exit(0)

# plt.figure(1)
# plt.title("Signal Wave...")
# plt.plot(signal)
# plt.show()

from scipy.io.wavfile import read
import matplotlib.pyplot as plt

# read audio samples
input_data = read("Data/Buleria_IMP_P1_1.wav")
audio = input_data[1]


sampleRate = 44.1 *10**2

print(len(audio))
# plot the first 1024 samples
plt.plot(audio)
# label the axes
plt.ylabel("Amplitude")
plt.xlabel("Time")
# set the title  
plt.title("Sample Wav")
# display the plot
plt.show()