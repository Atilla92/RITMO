

import numpy as np

# Example time series of rotation matrices
rotation_matrices = np.array([
    [[0.707, -0.707, 0.000],
     [0.707, 0.707, 0.000],
     [0.000, 0.000, 1.000]],
     
    [[0.667, -0.741, 0.082],
     [0.730, 0.663, -0.163],
     [-0.154, 0.102, 0.983]],
     
    # Add more rotation matrices here...
])

# Calculate the time interval between rotation matrices
time_interval = 1.0  # Assuming a time interval of 1 second

# Iterate over the rotation matrices to estimate the angular velocities
angular_velocities = []
for i in range(1, len(rotation_matrices)):
    # Calculate the difference between two consecutive rotation matrices
    R_diff = np.dot(rotation_matrices[i], np.linalg.inv(rotation_matrices[i-1]))
    
    # Calculate the skew-symmetric matrix from the difference
    omega = np.arccos((np.trace(R_diff) - 1) / 2) * (R_diff - R_diff.T) / (2 * np.sin(omega))
    
    # Extract the angular velocity components
    w_x = omega[2, 1]
    w_y = omega[0, 2]
    w_z = omega[1, 0]
    
    # Adjust the angular velocities based on the time interval
    w_x /= time_interval
    w_y /= time_interval
    w_z /= time_interval
    
    # Append the angular velocities to the list
    angular_velocities.append([w_x, w_y, w_z])

# Print the angular velocities
print("Angular velocities:")
for i, w in enumerate(angular_velocities):
    print("Time:", i)
    print("w_x:", w[0])
    print("w_y:", w[1])
    print("w_z:", w[2])
    print()