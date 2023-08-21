import numpy as np
import matplotlib.pyplot as plt
import sounddevice as sd
import time
from scipy.signal import decimate

def play_and_plot_sound(original_sound_file, downsampled_sound_file):
    # Load the original sound file
    original_sample_rate, original_audio_data = sd.read(original_sound_file)

    # Load the downsampled WAV file
    downsampled_sample_rate, downsampled_audio_data = sd.read(downsampled_sound_file)

    # Downsample the original audio data
    downsampling_factor = 32
    downsampled_audio_data = decimate(original_audio_data, downsampling_factor)

    # Create a figure and subplots for plotting
    plt.ion()  # Enable interactive mode for real-time plotting
    fig, (ax1, ax2) = plt.subplots(2, 1)
    
    # Plot the downsampled audio on the first subplot
    downsampled_time_points = np.linspace(0, len(downsampled_audio_data) / downsampled_sample_rate, len(downsampled_audio_data))
    ax1.plot(downsampled_time_points, downsampled_audio_data)
    ax1.set_title('Downsampled Audio')
    ax1.set_xlabel('Time (s)')
    ax1.set_ylabel('Amplitude')

    # Plot the original audio waveform on the second subplot
    original_time_points = np.linspace(0, len(original_audio_data) / original_sample_rate, len(original_audio_data))
    ax2.plot(original_time_points, original_audio_data)
    ax2.set_title('Original Audio')
    ax2.set_xlabel('Time (s)')
    ax2.set_ylabel('Amplitude')
    
    plt.tight_layout()

    # Play the original audio using sounddevice
    sd.play(original_audio_data, original_sample_rate)

    # Initialize time variables for plotting and synchronization
    start_time = time.time()
    play_start_time = start_time
    downsampled_index = 0
    update_interval = 0.1

    # Your loop to update subplots and playback progress
    while sd.get_stream().active:
        elapsed_time = time.time() - start_time
        current_time = elapsed_time

        # Synchronize the downsampled plot with the playback of the original audio
        while downsampled_index < len(downsampled_time_points) and downsampled_time_points[downsampled_index] < current_time:
            downsampled_index += 1

        # Clear the previous plots and re-plot
        ax1.clear()
        ax2.clear()
        
        ax1.plot(downsampled_time_points[:downsampled_index], downsampled_audio_data[:downsampled_index])
        ax1.set_title('Downsampled Audio')
        ax1.set_xlabel('Time (s)')
        ax1.set_ylabel('Amplitude')

        ax2.plot(original_time_points, original_audio_data)
        ax2.set_title('Original Audio')
        ax2.set_xlabel('Time (s)')
        ax2.set_ylabel('Amplitude')

        # Update the plots in interactive mode
        plt.pause(update_interval)

    # Stop audio playback
    sd.stop()

    # Close the plots
    plt.ioff()
    plt.close()

if __name__ == "__main__":
    original_sound_file = 'original_sound.wav'  # Replace with the path to your original sound file
    downsampled_sound_file = 'downsampled_output.wav'  # Replace with the path to your downsampled sound file
    play_and_plot_sound(original_sound_file, downsampled_sound_file)