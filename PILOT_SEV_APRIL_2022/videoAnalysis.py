import musicalgestures
import glob

video_files = []

for filepath in glob.iglob('../../FILES/PILOT_SEV_APRIL_2022/Video/*.mp4'):
    #print (filepath)
    if filepath.endswith('.mp4'):
        filepath_split = filepath.partition('Video/')
        print (filepath_split)
        video_files.append(filepath_split[2])


print (video_files)
print(filepath)

for i, item in enumerate(video_files):
    targetName = './output/videoAnalysis/motionData_'+ str(item)
    targetPath = '../../FILES/PILOT_SEV_APRIL_2022/Video/' + str(item)
    source_video = musicalgestures.MgVideo(targetPath)
    motion_data = source_video.motiondata(target_name= targetName)



#OTHER COMMANDS
# source_video.motion()
# source_video.show(key= 'mgx')
# source_video.show(key = 'mgy')
# motionplot() histogram and centroid of motion plot
# area of motion.
# directomgram, visual beats, motion beats of the video. intensity is speed of motion. 
# directiograms.data['directogram'] numpy array. 


