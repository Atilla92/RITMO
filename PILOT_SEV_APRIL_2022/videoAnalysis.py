import musicalgestures

source_video = musicalgestures.MgVideo('/Users/atillajv/CODE/FILES/PILOT_SEV_APRIL_2022/GoProFront/P3_D1_G1_M1_R1_T1.avi')
# source_video.motion()
# source_video.show(key= 'mgx')
# source_video.show(key = 'mgy')

motion_data = source_video.motiondata(target_name= './output/motionData_P3_D1_G1_M1_R1_T1.mp4')
#motionplot() histogram and centroid of motion plot
# area of motion.
# directomgram, visual beats, motion beats of the video. intensity is speed of motion. 
# directiograms.data['directogram'] numpy array. 


