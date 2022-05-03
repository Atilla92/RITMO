import json
import numpy as np
import matplotlib.pyplot as plt
from functions import initiateSubplots2


f_json = open('variables.json')
variables = json.load(f_json)
dateFile = '12.02.2022'

f,axs = initiateSubplots2(labelx='Step Number', labely='Average intensity', number=6)

#axs.set_ylim([0, 5])

tag_imp = []
av_imp = []
tag_imi = []
av_imi = []
for item in variables["details_files"]: 
    


    if "D1" in item['name']:
        colour_dot = 'red'
    
    if "D2" in item['name']:
        colour_dot = 'blue'
    
    if 'avs_mean' in item:
        for i, item_i in enumerate (item["step_labels"]):
            #print(item['step_labels'][i], item['avs_mean'][i][0])
            axs[0].plot(item['step_labels'][i], item['avs_mean'][i][0],marker="o", markersize=8, markeredgecolor=colour_dot, markerfacecolor=colour_dot)    
            axs[1].plot(item['step_labels'][i], item['avs_mean'][i][1],marker="o", markersize=8, markeredgecolor=colour_dot, markerfacecolor=colour_dot) 
            axs[2].plot(item['step_labels'][i], item['avs_mean'][i][2],marker="o", markersize=8, markeredgecolor=colour_dot, markerfacecolor=colour_dot) 
            axs[3].plot(item['step_labels'][i], item['avs_mean'][i][3],marker="o", markersize=8, markeredgecolor=colour_dot, markerfacecolor=colour_dot) 
            axs[4].plot(item['step_labels'][i], item['avs_mean'][i][4],marker="o", markersize=8, markeredgecolor=colour_dot, markerfacecolor=colour_dot) 
            axs[5].plot(item['step_labels'][i], item['avs_mean'][i][5],marker="o", markersize=8, markeredgecolor=colour_dot, markerfacecolor=colour_dot) 
  
    



plt.savefig('./Figures_2/'+dateFile + '/Average/'+'Impro_vs_Choreo_Steps_Dots' )            
            
        

