import soundfile as sf
import pyloudnorm as pyln
from scipy.io.wavfile import read
import matplotlib.pyplot as plt
import numpy as np

input_data = read("Data/Seguirya_IMP_P2_1.wav")
audio = input_data[1]


threshold = 1.25 * 10**9
click_position = np.argmax(audio > threshold)
audio_threshold = audio[click_position:]


data = audio_threshold.astype(np.float)

rate = float(input_data[0])


#data, rate = sf.read("Buleria_IMP_P1_1.wav") # load audio (with shape (samples, channels))
meter = pyln.Meter(rate) # create BS.1770 meter
loudness = meter.integrated_loudness(data) # measure loudness
print(loudness)