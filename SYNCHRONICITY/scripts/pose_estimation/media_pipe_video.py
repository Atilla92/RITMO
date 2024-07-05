# %%
# imports
import cv2
import mediapipe as mp
import pandas as pd
import musicalgestures
import platform
import time
import json
import numpy as np
# %%
#video_path = musicalgestures.examples.dance
output_path = "/itf-fi-ml/home/atillajv/SYNCH/files/output/"
file_name = "P3_D1_G1_M1_R2_T1"
video_path = "/itf-fi-ml/home/atillajv/SYNCH/files/" + file_name +  ".mp4"
print(f"Processing video: {video_path}")
start = time.time()
# %%
# # Initialize MediaPipe Pose and Drawing utilities
# mp_pose = mp.solutions.pose
# mp_drawing = mp.solutions.drawing_utils
# pose = mp_pose.Pose()


# Initialize MediaPipe Pose and Drawing utilities with custom parameters
mp_pose = mp.solutions.pose
mp_drawing = mp.solutions.drawing_utils
pose = mp_pose.Pose()



BaseOptions = mp.tasks.BaseOptions
PoseLandmarker = mp.tasks.vision.PoseLandmarker
PoseLandmarkerOptions = mp.tasks.vision.PoseLandmarkerOptions
VisionRunningMode = mp.tasks.vision.RunningMode

cap = cv2.VideoCapture(video_path)
df = None


if platform.system() == "Darwin":
    cv2.startWindowThread()

# Process the video frame by frame
fps = cap.get(cv2.CAP_PROP_FPS) # Get the fps resolution
print(f"Frame per seconds resolution: {fps}")
total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT)) # Get the total number of frames
frame_number = 0




# Read the first frame to get the dimensions
ret, frame = cap.read()
if not ret:
    print("Error reading the video frame")
    exit()

# Get the dimensions of the frame
frame_height, frame_width, _ = frame.shape

# Create a VideoWriter object to save the output video
output_video_path = output_path + "landmarks_video_" + file_name + ".mp4"
fourcc = cv2.VideoWriter_fourcc(*"mp4v")
output_video = cv2.VideoWriter(output_video_path, fourcc, fps, (frame_width, frame_height))



while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break

    print(f'Processing frame {frame_number}/{total_frames}...', end='\r')

    # Convert the frame to RGB
    frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

    # Process the frame with MediaPipe Pose
    result = pose.process(frame_rgb)

    # Draw the pose landmarks on the frame
    if result.pose_landmarks:
        mp_drawing.draw_landmarks(
            frame, result.pose_landmarks, mp_pose.POSE_CONNECTIONS)
        
            # Save the first frame with landmarks
        if frame_number == 0:
            cv2.imwrite(output_path + "landmarks_frame1_" + file_name + ".jpg", frame)

        # Save the frame at half of the total number of frames with landmarks
        if frame_number == total_frames // 2:
            cv2.imwrite(output_path + "landmarks_frame_half_" + file_name + ".jpg", frame)

        # Create a black background image to draw the landmarks on
        black_frame = np.zeros_like(frame)

        # Draw the pose landmarks on the black background
        mp_drawing.draw_landmarks(
            black_frame, result.pose_landmarks, mp_pose.POSE_CONNECTIONS)

        # Write the black background image with landmarks to the output video
        output_video.write(black_frame)

        # Add the landmark coordinates to the list and print them
        df_row = {}
        for idx, landmark in enumerate(result.pose_landmarks.landmark):
            name = mp_pose.PoseLandmark(idx).name
            df_row[f"{name}_X"] = landmark.x
            df_row[f"{name}_Y"] = landmark.y
            df_row[f"{name}_Z"] = landmark.z
        if frame_number == 0:
            # create dataframe with first row
            df = pd.DataFrame(df_row, index=[frame_number])
        else:
            # append row to dataframe
            df = pd.concat([df, pd.DataFrame(df_row, index=[frame_number])])

    # Calculate time in seconds for the current frame
        time_in_seconds = frame_number / fps

        # Add the time column to the DataFrame
        df['time_s'] = time_in_seconds

    # # Show the frame
    # cv2.imshow('MediaPipe Pose', frame)
    # cv2.waitKey(1)

    # increment frame number
    frame_number += 1

if platform.system() == "Darwin":
    cv2.destroyAllWindows()
    cv2.waitKey(1)

# %%
# Save the dataframe to a CSV file
df.to_csv( output_path + "pose_data_"+ file_name + ".csv", index=True)
print("Data saved to "+ output_path + "pose_data_"+ file_name + ".csv")

# %%

end = time.time()
# total time taken
print (end-start, 'runtime')


# Release the video capture and output video objects
cap.release()
output_video.release()


# Create a json
variables_dict = {
    "fps": fps,
    'total_frames': total_frames,
}


json_object = json.dumps(variables_dict, indent = 4)
with open(str(output_path + "pose_data_"+ file_name +  ".json"), "w") as outfile:
    outfile.write(json_object)