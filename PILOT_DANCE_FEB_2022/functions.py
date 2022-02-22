import numpy as np 
import pyloudnorm as pyln
from scipy.io.wavfile import read
import matplotlib.pyplot as plt
from scipy.signal import argrelextrema


def alignClapper(audio, sampleRate, threshold):
    click_position = np.argmax(audio > threshold)
    audio_threshold = audio[click_position:]
    click_time = click_position/sampleRate

    return audio_threshold, click_time