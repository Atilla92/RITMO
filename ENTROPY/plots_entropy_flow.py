import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from statsmodels.graphics.mosaicplot import mosaic
import glob
import os
from itertools import repeat



# Parameters of plotting function.
y_var = 'LZ'
hue_var = 'Dance_mode'
title_plot = 'Guitar (zd)'
#file_input = '/Users/atillajv/CODE/RITMO/ENTROPY/output/main/all_experiments_095_drums/var/'
save_plot = '/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/all_experiments_095/'
hue_var = 'Dance_mode'
rating = 'FLOW'

file_name = str(y_var + '_t_%' + '_drums_' + hue_var +'_filtered' )

# Loop or single file 
loop_on = True #Set to false if only analysing one file. 
loop_off = 'P7_D5_G1_M6_R1_T1.csv'
filter_out = True


df_plots = pd.read_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/all_experiments_095/data/t%_LZ_guitar_zd.csv')
df_plots_2 = pd.read_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/all_experiments_095/data/t%_LZ_drums.csv')
df_plots_r = pd.read_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/all_experiments_095/data/t%_ratings_FLOW.csv')
df_plots_imp = pd.read_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/all_experiments_095/data/t%_ratings_IMPRO.csv')
df_plots_var_g = pd.read_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/all_experiments_095/data/t%_var_guitar_zd.csv')
df_plots_var_d = pd.read_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/all_experiments_095/data/t%_var_drums.csv')
#df_plots_imp = pd.read_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/all_experiments_095/data/t%_.csv')

if filter_out:
    df_plots = df_plots[~df_plots['Dance_mode'].str.contains("D0")]
    df_plots_2 = df_plots_2[~df_plots_2['Dance_mode'].str.contains("D0")]
    df_plots_r = df_plots_r[~df_plots_r['Dance_mode'].str.contains("D0")]
    df_plots_var_g = df_plots_var_g[~df_plots_var_g['Dance_mode'].str.contains("D0")]
    df_plots_var_d = df_plots_var_d[~df_plots_var_d['Dance_mode'].str.contains("D0")]
    df_plots_imp = df_plots_imp[~df_plots_imp['Dance_mode'].str.contains("D0")]


fig, axes = plt.subplots(nrows = 2,ncols =4, sharex=True)

palette ={"D1": "C0", "D5": "C1", "D6": "C2", "D0": "k"}

hue_order = ['D1', 'D5', 'D6']

# fig = sns.lineplot(legend = False, ax = axes[1,0], data = df_plots,  x="Assigned_%", y="y_var", hue = hue_var, hue_order = hue_order, palette=palette)
# fig.set(xlabel='t [%]', ylabel = y_var)
# axes[0,1].set_ylim([0, 7])
# axes[0,0].set_ylim([0, 7])

# fig = sns.lineplot( ax = axes[0,1], data = df_plots_r,  x="Assigned_%", y="y_var", hue = hue_var, hue_order=hue_order, palette=palette)
# fig.set(xlabel='t [%]', ylabel = 'Flow Rating')


# fig = sns.lineplot(legend = False, ax = axes[1,1], data = df_plots_var,  x="Assigned_%", y="y_var", hue = hue_var, hue_order=hue_order, palette=palette)
# fig.set(xlabel='t [%]', ylabel = 'Entropy (var)',)

# fig = sns.lineplot( legend = False, ax = axes[0,0], data = df_plots_imp,  x="Assigned_%", y="y_var", hue = hue_var, hue_order=hue_order, palette=palette)
# fig.set(xlabel='t [%]', ylabel = 'Impro Rating', title = title_plot)
# axes[0,1].legend(loc='lower center', bbox_to_anchor=(0.5, 1.0),
#           fancybox=True, ncol=3)

fig = sns.lineplot(legend = False, ax = axes[0,0], data = df_plots_imp[~df_plots_imp['Artist'].str.contains("G")],  x="Assigned_%", y="y_var", hue = 'Dance_mode',  hue_order=hue_order, palette=palette)
fig.set(xlabel='t [%]', ylabel = 'Impro Rating', title = 'Dancer')
axes[1,0].set_ylim([0, 7])
axes[0,0].set_ylim([0, 7])

fig = sns.lineplot(legend=False, ax = axes[1,0], data = df_plots_imp[~df_plots_imp['Artist'].str.contains("P")],  x="Assigned_%", y="y_var", hue = 'Dance_mode', hue_order=hue_order, palette=palette)
fig.set(xlabel='t [%]', ylabel = 'LZ', title = 'Guitarist')


fig = sns.lineplot(legend = False, ax = axes[0,1], data = df_plots_r[~df_plots_r['Artist'].str.contains("G")],  x="Assigned_%", y="y_var", hue = 'Dance_mode',  hue_order=hue_order, palette=palette)
fig.set(xlabel='t [%]', ylabel = 'Impro Rating')
axes[1,1].set_ylim([0, 7])
axes[0,1].set_ylim([0, 7])

data_plot_r = df_plots_r[~df_plots_r['Artist'].str.contains("G")]
fig = sns.lineplot(legend=False, ax = axes[0,2], data = df_plots_2,  x="Assigned_%", y="y_var", hue = 'Dance_mode', hue_order=hue_order, palette=palette)
fig.set(xlabel='t [%]', ylabel = 'LZ')


fig = sns.lineplot(legend = False, ax = axes[1,1], data = df_plots_r[~df_plots_r['Artist'].str.contains("P")],  x="Assigned_%", y="y_var", hue = 'Dance_mode' , hue_order=hue_order, palette=palette)
fig.set(xlabel='t [%]', ylabel = 'Flow rating')

fig = sns.lineplot( legend = False, ax = axes[1,2], data = df_plots,  x="Assigned_%", y="y_var", hue = 'Dance_mode', hue_order=hue_order, palette=palette)
fig.set(xlabel='t [%]', ylabel = 'LZ')



data_plot_r = df_plots_r[~df_plots_r['Artist'].str.contains("G")]
fig = sns.lineplot(  ax = axes[0,3], data = df_plots_var_d,  x="Assigned_%", y="y_var", hue = 'Dance_mode', hue_order=hue_order, palette=palette)
fig.set(xlabel='t [%]', ylabel = 'var')
axes[0,3].legend(loc='lower center', bbox_to_anchor=(0.5, 1.0),
          fancybox=True, ncol=3)

fig = sns.lineplot( legend = False, ax = axes[1,3], data = df_plots_var_g,  x="Assigned_%", y="y_var", hue = 'Dance_mode', hue_order=hue_order, palette=palette)
fig.set(xlabel='t [%]', ylabel = 'var')
#axes[0,1].legend(loc='lower center', bbox_to_anchor=(0.5, 1.0),
  #        fancybox=True, ncol=3)



plt.show()
#plt.savefig(save_plot + 'Combined_2x2_t%_guitar_zd.png')
