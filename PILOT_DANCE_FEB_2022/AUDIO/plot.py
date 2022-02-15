from scipy.io.wavfile import read
import matplotlib.pyplot as plt
import numpy as np

# read audio samples
input_data = read("P1_D2_T2-220212_1818.wav")
#print(input_data)
audio = input_data[1]
sampleRate = input_data[0]


print(len(audio)/(sampleRate*60))


def plotAudio(audio, sampleRate, p):
    x_array = np.arange(len(audio))
    x_array = np.divide(x_array,sampleRate)
    # plot the first 1024 samples
    plt.plot(x_array, audio)
    # label the axes
    plt.ylabel("Amplitude")
    plt.xlabel("Time [s]")
    # set the title  
    plt.title("Sample Wav")
    # display the plot
    if p:
        plt.show()



def audioThreshold(audio, threshold):
    click_position = np.argmax(audio > threshold)
    audio_threshold = audio[click_position:]
    return audio_threshold, click_position

plotAudio(audio, sampleRate, True)
audio_threshold, click_position = audioThreshold(audio,threshold=1.25 * 10**9)
plotAudio(audio_threshold, sampleRate, True)
print (click_position/(sampleRate))