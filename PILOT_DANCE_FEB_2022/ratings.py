import json 
import pandas as pd
from functions import get_sec, list_sec
import numpy as np
import glob


files_impro = []
files_duende = []
files = []
f = open('variables.json')
variables = json.load(f)

f_r = open('variables_ratings.json')
variables_r = json.load(f_r)


for filepath in glob.iglob('Ratings/*.csv'):
    if filepath.endswith('_DUENDE.csv'):
        files_duende.append(filepath)
    elif filepath.endswith('_IMPRO.csv'):
        files_impro.append(filepath)
        filepath_split = filepath.partition('/')
        filepath_split = filepath_split[2].partition('_IM')
        print(filepath_split, 'split')
        files.append(filepath_split[0])

print(files, 'imrpo', files_duende)



for i, currentFile in enumerate(files):


    #filename = 'P2_D1_T1'
    # df = pd.read_csv ('Ratings/' + filename + '_IMPRO.csv')
    # df_duende = pd.read_csv('Ratings/' + filename + '_DUENDE.csv')
    df = pd.read_csv (files_impro[i])
    df_duende = pd.read_csv(files_duende[i])

    

    for item in variables['details_files']:
        print(item, 'item', currentFile)
        if item['name'] == currentFile:
            steps_times  = list_sec(item["step_times"])
            start_reaper = item["start_reaper"]
            duration_s = item["duration_s"]


    for item in variables_r['ratings']:
        if item['name'] == currentFile:
            print (currentFile ,'True')
            time_to_peak = item['time_to_peak']

            df['Time'] = df['Time'] - get_sec(time_to_peak)
            print (df)
            step_num = 3
            t_delay = 0 #seconds of delay response
            list_ratings = []
            list_duende = []
            av_impro = []
            av_duende = []

            for step_num, step in enumerate(steps_times):

                # Start and end of each interval 
                tStart = steps_times[step_num] + t_delay
                tEnd = steps_times[step_num] + duration_s[step_num] + t_delay

            

                # Take the first value if no rating has been given yet. 
                if df['Time'].iloc[0]> tStart:
                    df_interval = df.iloc[[0]]


                # Take the values that fall withing the interval. 
                # If the interval is empy it takes the latest value (assuming it might not have changed)

                elif df['Time'].iloc[0] < tStart:
                    df_pre_int = (df.loc[(df["Time"]< tStart)]).iloc[-1]
                    df_interval = df.loc[(df["Time"] >= tStart ) &(df["Time"] <= tEnd ) ]
                    #print(df_interval[' Value'], 'medium')
                    if df_interval.empty:   
                        df_interval.loc[-1] = df_pre_int
                # Convert dataframe to array and add to list
                int_array = np.array(df_interval[" Value"]).tolist()
                list_ratings.append(int_array)
                av_impro.append(np.average(int_array))
                print(tStart, 'start', tEnd, 'ratings',list_ratings, av_impro)
                print(df_duende)

                # If duende in interval append, else fill with zero. 
                df_duende_int = df_duende.loc[(df_duende["Time"] >= tStart ) &(df_duende["Time"] <= tEnd ) ]
                if df_duende_int.empty:
                    df_duende_array = [0]
                
                else:
                    df_duende_array = np.array(df_duende_int[" Value"]).tolist()    
                
                list_duende.append(df_duende_array)
                av_duende.append(np.average(df_duende_array))
                print(list_duende,av_duende,'true')

                item["list_impro"] = list_ratings
                item["av_impro"]= av_impro
                item["list_duende"] = list_duende
                item["av_duende"] = av_duende

                with open("variables_ratings.json", "w+") as f_r: 
                    f_r.write(json.dumps(variables_r))

        






