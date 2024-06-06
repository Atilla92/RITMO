import numpy as np
import matplotlib.pyplot as plt 
import pandas as pd
import json
from scipy.signal import butter, filtfilt
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from sympy import symbols, atan2, asin, acos
import numpy as np
from scipy.spatial.transform import Rotation as R
from pytransform3d.rotations import matrix_from_two_vectors, plot_basis, random_vector


df = pd.read_csv('/Users/atillajv/CODE/RITMO/SYNCHRONICITY/output/node_output/pose_data/pose_data_P3_D1_G1_M1_R2_T1.csv')

with open('/Users/atillajv/CODE/RITMO/SYNCHRONICITY/output/node_output/pose_data/pose_data_P3_D1_G1_M1_R2_T1.json') as json_file:
    data = json.load(json_file)

fps = data['fps']
list = df.keys()[1:-1]
time = df.iloc[:, 0]/fps

# Bandpass filter parameters
lowcut = 0.5  # Lower cutoff frequency in Hz
highcut = 10  # Upper cutoff frequency in Hz
order = 2  # Filter order
normalized_lowcut = 0.5 / (fps/2)  # 0.01
normalized_highcut = 5.0 / (fps/2)  # 0.1



b, a = butter(order, [normalized_lowcut, normalized_highcut], btype='band')
filtered_data_x = filtfilt(b, a, df['NOSE_X'])
filtered_data_y = filtfilt(b, a, df['NOSE_Y'])
filtered_data_z = filtfilt(b, a, df['NOSE_Z'])



def estimateVelocity (x_array, y_array, z_array, time ):
# Initialize empty lists to store velocities
    velocities_x = []
    velocities_y = []
    velocities_z = []
    z_angles = []
    y_angles = []
    x_angles = []
    rotations = []

    # Iterate through the position data to calculate velocities
    for i in range(len(x_array) - 1):  # Iterate up to the second-to-last index

        
        # Estimation of Euler angles
        # https://www.meccanismocomplesso.org/en/3d-rotations-and-euler-angles-in-python/
        # https://dfki-ric.github.io/pytransform3d/_auto_examples/plots/plot_matrix_from_two_vectors.html
        # https://dfki-ric.github.io/pytransform3d/_apidoc/pytransform3d.rotations.matrix_from_two_vectors.html#pytransform3d.rotations.matrix_from_two_vectors
        # https://docs.scipy.org/doc/scipy/reference/generated/scipy.spatial.transform.Rotation.html
        v1 = [x_array[i], y_array[i], z_array[i]]
        v2 = [x_array[i+1], y_array[i+1], z_array[i+1]]
        # Estimation of rotatin matrix
        #'https://docs.scipy.org/doc/scipy/reference/generated/scipy.spatial.transform.Rotation.align_vectors.html'
        rot, _ = R.align_vectors(v1, v2)
        angles = rot.as_euler('zyx', degrees = False)     
        z_angles.append(angles[0])
        y_angles.append(angles[1])
        x_angles.append(angles[2])
        rot_mat = rot.as_matrix()
        rotations.append(rot_mat)
        # Get Euler angles of rotation matrix

        



        delta_t = time[i + 1] - time[i]  # Calculate the time difference
        #delta_t = np.diff(time)

        # Calculate velocities using the first derivative formula

        velocity_x = (x_array[i + 1] - x_array[i]) / delta_t
        #velocity_x = np.diff(x_array)/delta_t
        velocity_y = (y_array[i + 1] - y_array[i]) / delta_t
        velocity_z = (z_array[i + 1] - z_array[i]) / delta_t
       

        # Append the calculated velocities to the respective lists
        velocities_x.append(velocity_x)
        velocities_y.append(velocity_y)
        velocities_z.append(velocity_z)
        

        

    velocity = np.sqrt(np.array(velocities_x)**2 + np.array(velocities_y) **2 + np.array(velocities_z) ** 2)
    return velocities_x, velocities_y, velocities_z, velocity, x_angles, y_angles, z_angles, rotations 



vx, vy, vz, v_tot, angle_x, angle_y, angle_z, rot_mat = estimateVelocity(df['NOSE_X'], df['NOSE_Y'], df['NOSE_Z'], time)
vx_filt, vy_filt, vz_filt, v_tot_filtered, angle_x_filt, angle_y_filt, angle_z_filt, rot_mat_filtered = estimateVelocity(filtered_data_x, filtered_data_y, filtered_data_z, time)




acc_tot = np.diff(v_tot)/np.diff(time[1:])
acc_tot_filtered = np.diff(v_tot_filtered)/np.diff(time[1:])





time_2 = time[1:] 
time_3 = time_2[1:]
# Create the figure and subplots
fig, axs = plt.subplots(2, 4, figsize=(12, 8))

# First row - Plot of vx, vy, vz
ax_3d = fig.add_subplot(2, 4, 1, projection='3d')  # This is the first subplot in a 2x4 grid
ax_3d.scatter(df['NOSE_X'], df['NOSE_Y'], df['NOSE_Z'], s=2, alpha = 0.5)
ax_3d.set_xlabel('X Position')
ax_3d.set_ylabel('Y Position')
ax_3d.set_zlabel('Z Position')
#ax_3d.set_axis_off()  # Hide the 2D frame
axs[0, 0].set_axis_off()  #

axs[0, 1].plot(time_2, v_tot)
axs[0, 1].set_xlabel('Time')
axs[0, 1].set_ylabel('v_tot')
axs[0, 2].plot(time_3, acc_tot)
axs[0, 2].set_xlabel('Time')
axs[0, 2].set_ylabel('acc_tot')
axs[0, 3].plot(time_2, angle_x)  # Use red for pitch
axs[0,3].plot(time_2, angle_y)
axs[0,3].plot(time_2, angle_z)


axs[1, 1].plot(time_2, v_tot_filtered)
axs[1, 1].set_xlabel('Time')
axs[1, 1].set_ylabel('v_tot_filt')
axs[1, 2].plot(time_3, acc_tot_filtered)
axs[1, 2].set_xlabel('Time')
axs[1, 2].set_ylabel('acc_tot_filt')
axs[1, 3].plot(time_2, angle_x_filt)  # Use red for pitch
axs[1,3].plot(time_2, angle_y_filt)
axs[1,3].plot(time_2, angle_z_filt)

# First row - Plot of vx, vy, vz
ax_3d = fig.add_subplot(2, 4, 5, projection='3d')  # This is the first subplot in a 2x4 grid
ax_3d.scatter(filtered_data_x, filtered_data_y, filtered_data_z, s=2, alpha = 0.5)
ax_3d.set_xlabel('X Position')
ax_3d.set_ylabel('Y Position')
ax_3d.set_zlabel('Z Position')
#ax_3d.set_axis_off()  # Hide the 2D frame
axs[1, 0].set_axis_off()  #

# Adjust the spacing between subplots
#plt.subplots_adjust(wspace=0.3)
# Adjust the spacing and margin between subplots
plt.subplots_adjust(wspace=0.5, hspace=0.3, left=0.1, right=0.9)


# Display the plot
plt.show()




# Assuming you have a list of rotation matrices called rotation_matrices
rotation_matrices = rot_mat_filtered
# Create a sphere
u = np.linspace(0, 2 * np.pi, 100)
v = np.linspace(0, np.pi, 50)
x = np.outer(np.cos(u), np.sin(v))
y = np.outer(np.sin(u), np.sin(v))
z = np.outer(np.ones(np.size(u)), np.cos(v))

# Create a 3D plot
fig = plt.figure(figsize=(12, 8))

# Add the subplots
ax1 = fig.add_subplot(2, 4, 1, projection='3d')
ax2 = fig.add_subplot(2, 4, 2)
ax3 = fig.add_subplot(2, 4, 3)
ax4 = fig.add_subplot(2, 4, 4, projection='3d')  # This will contain the rotation plot


# First row - Plot of vx, vy, vz
ax1.scatter(df['NOSE_X'], df['NOSE_Y'], df['NOSE_Z'], s=2, alpha=0.5)
ax1.set_xlabel('X Position')
ax1.set_ylabel('Y Position')
ax1.set_zlabel('Z Position')

ax2.plot(time_2, v_tot)
ax2.set_xlabel('Time')
ax2.set_ylabel('v_tot')

ax3.plot(time_3, acc_tot)
ax3.set_xlabel('Time')
ax3.set_ylabel('acc_tot')

# Plot the rotation matrices in the fourth column
ax4.plot_surface(x, y, z, color='b', alpha=0.3)
for R in rotation_matrices:
    vector_end = R.dot([1, 0, 0])
    ax4.scatter(vector_end[0], vector_end[1], vector_end[2], color='r')

# Set the aspect of the rotation plot axes to be equal
ax4.set_box_aspect([1, 1, 1])

# Adjust the spacing and margin between subplots
plt.subplots_adjust(wspace=0.5, hspace=0.3, left=0.1, right=0.9)

# Display the plot
plt.show()

# Assuming you have a list of rotation matrices called rotation_matrices
rotation_matrices = rot_mat_filtered
# Create a sphere
u = np.linspace(0, 2 * np.pi, 100)
v = np.linspace(0, np.pi, 50)
x = np.outer(np.cos(u), np.sin(v))
y = np.outer(np.sin(u), np.sin(v))
z = np.outer(np.ones(np.size(u)), np.cos(v))

# Create a 3D plot
fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')

# Plot the sphere
ax.plot_surface(x, y, z, color='b', alpha=0.3)

# Plot the end points of the vectors on the sphere for each rotation matrix
for R in rotation_matrices:
    vector_end = R.dot([1, 0, 0])
    ax.scatter(vector_end[0], vector_end[1], vector_end[2], color='r')

# Set the aspect of the axes to be equal
ax.set_box_aspect([1, 1, 1])

# Show the plot
plt.show()



# # Calculate the Cartesian coordinates for pitch, yaw, and roll angles
# plt.figure()
# pitch_x = np.cos(angle_y)
# pitch_y = np.sin(angle_y)

# yaw_x = np.cos(angle_z)
# yaw_y = np.sin(angle_z)

# roll_x = np.cos(angle_x)
# roll_y = np.sin(angle_x)

# # Create a scatter plot for all angles with different colors
# plt.scatter(pitch_x, pitch_y, c='r', label='Pitch')  # Use red for pitch
# plt.scatter(yaw_x, yaw_y, c='g', label='Yaw')  # Use green for yaw
# plt.scatter(roll_x, roll_y, c='b', label='Roll')  # Use blue for roll

# # Plot the unit circle
# circle = plt.Circle((0, 0), 1, color='black', fill=False)
# plt.gca().add_artist(circle)

# # Set the aspect ratio to 'equal' to make the plot circular
# plt.gca().set_aspect('equal', adjustable='box')

# # Add a legend
# plt.legend()

# # Show the plot
# plt.show()


# plt.figure()
# pitch_x = np.cos(angle_y)
# pitch_y = np.sin(angle_y)

# yaw_x = np.cos(angle_z)
# yaw_y = np.sin(angle_z)

# roll_x = np.cos(angle_x)
# roll_y = np.sin(angle_x)

# # Create a scatter plot for all angles with different colors

# plt.scatter(roll_x, roll_y, c='b', label='Roll')  # Use blue for roll

# # Plot the unit circle
# circle = plt.Circle((0, 0), 1, color='black', fill=False)
# plt.gca().add_artist(circle)

# # Set the aspect ratio to 'equal' to make the plot circular
# plt.gca().set_aspect('equal', adjustable='box')

# # Add a legend
# plt.legend()

# # Show the plot
# plt.show()



# # Adjust the spacing between subplots
# plt.subplots_adjust(hspace=0.5)

# # Display the plot
# plt.show()


# plt.figure()
# plt.plot(time[1:], v_tot)
# plt.plot(time[1:], v_tot_filtered)
# plt.plot(time[1:], v_tot_filtered)
# plt.show()






# for i in range(0, len(list), 3):
#     plt.figure()

#     plt.plot(time, df[list[i]], label= list[i])
#     plt.plot(time, df[list[i+1]], label= list[i+1])
#     plt.plot(time, df[list[i+2]], label= list[i+2])
#     # plt.plot(time, list[i+2], label='NOSE_Z')

#     # Add labels and title
#     plt.xlabel('Time (s)')
#     plt.ylabel('Value')
#     plt.title('Values over Time')

#     # Add a legend
#     plt.legend()

#     # Display the plot
#     plt.show()
