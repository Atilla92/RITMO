import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from statsmodels.graphics.mosaicplot import mosaic

'''
Plots different statistics of the dataset
'''

file_input = '/Users/atillajv/CODE/RITMO/ENTROPY/output/main/all_experiments_095/'
save_plot = '/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/' 

df_file = '18042023_all_experiments_drums_guitar_zd'
df = pd.read_csv(file_input + df_file + '.csv', index_col=0)
df.drop_duplicates(subset=None, keep="first", inplace=True)

#drop MI, DC
#df = df[~((df['Music_Imp'].str.contains('MI')) & (df['Dance_Imp'].str.contains('DC')))]
print(df)
#print(df)

plot_violin = True #Plot Violinplot of variables. Variables is list 
save_violin_plot = True
plotBoxPlot = False #Plot Boxplot on top of violin plot
bar_plot = False #Plot bar plot of all variables
plot_heatmap = True #Plot sns heatmap and mosaic 
plot_scatterplot = False #Plot a scatterplot of 3 variables


def stdMean(column, variable, colour ):
    '''
    Computes mean and std of a categories within a column. 
        column: is the subcategories column you want to estimate mean and std of a certain variable. 
        variable: is the parameter you want to estimate the mean and std of. 
        colour: is used for a bar_plot, if you want to give each column its specific colour.
                it creates a list of same length as amount of subcategories. 
        e.g. variable = 'LZ', column = 'Baile_Level'
        In this case it would compute the average LZ for each subcategory in 'Baile_Level'
    '''
    list_column = df[column].unique().tolist()
    list_column = np.sort(list_column).tolist()
    #print(list_column, 'LIST COLUMNS')
    list_mean = []
    list_std = []
    list_colour = []
    list_data = []
    counts = []

    for i, item in enumerate(list_column):
        print(df[str(column)])
        MI = df[df[str(column)].str.contains(str(item))]
        print(MI)
        print('hello')
        counts.append(len(MI))
        MI_mean = MI[str(variable)].mean()
        MI_std = MI[str(variable)].std()
        list_mean.append(MI_mean)
        list_std.append(MI_std)
        list_colour.append(colour)
        data = MI[str(variable)]
        data = data[~np.isnan(data)]
        list_data.append(data)

    return list_mean, list_std, list_column, list_colour, list_data, counts


# def ViolinPots (variables, list_columns, list_colour = [], save_violin_plot = False):
# '''
# Give list of variables you want to create a violin plot off. 
#     e.g. variables = ['LZ', 'Imp_subj', 'Flow_subj', 'Abs_Av', 'Perf_Av', 'MIR_entropy', 'MIR_rms', 'MIR_novelty', 'Q1a', 'Q1b', 'Q3a', 'Q3b', 'var_entropy' ]
#     e.g.variables = ['var_entropy']

# Give a list of columns you want to look at:
#     e.g. list_columns = ['Music_Imp','Dance_Imp', 'Music_mode', 'Dance_mode', 'Palo',  'Guitarra_Level','Baile_Level']

# Give a list of colours you want to give each subcategory for simple barplot. Need to set barplot to True. 
#     e.g. list_colour = ['black', 'red', 'black', 'red','cyan', 'green', 'blue','green']

# '''

variables = ['Imp_subj', 'Flow_subj', 'LZ', 'p_LZ','g_LZ']
for j, itemj in enumerate(variables):
    list_columns = ['Music_Imp','Dance_Imp', 'Music_mode', 'Dance_mode', 'Palo',  'Guitarra_Level','Baile_Level']
    list_colour = ['black', 'red', 'black', 'red','cyan', 'green', 'blue','green']
    lsts_mean = []
    lsts_std  = []
    lsts_col  = []
    lsts_colour = []
    lsts_counts = []
    list_data = []
    
    plt.figure()

    for i, item in enumerate(list_columns):

        lst_mean, lst_std, lst_col, lst_colour,lst_data, lst_counts = stdMean(item, itemj, list_colour[i])
        lsts_mean = lsts_mean + lst_mean
        lsts_std = lsts_std + lst_std
        lsts_col = lsts_col + lst_col
        lsts_colour = lsts_colour + lst_colour
        list_data  = list_data + lst_data
        lsts_counts = lsts_counts + lst_counts

        x = np.arange(len(list_data))
        plt.ylabel(itemj)



        violin_parts = plt.violinplot(list_data, x, points=60, widths=0.9, showmeans=False,
                        showextrema=False, showmedians=False, bw_method=0.5,
                        
                        )
    
            
    for pc in violin_parts['bodies']:
            pc.set_facecolor('green')
            pc.set_edgecolor('black')
                        
    plt.boxplot(list_data, positions = x)
    plt.xticks(x,  lsts_col)

    #plt.show()


    if bar_plot: 
        plt.figure()
        x = np.arange(len(lsts_col))
        print(lsts_mean)
        y = lsts_mean
        plt.xticks(x, lsts_col)
        plt.ylabel(itemj)
        plt.bar(x,y, yerr = lsts_std,   align='center',
            #alpha=0.5,
            ecolor='black',
            color= lsts_colour,
            capsize=10)

        #plt.show() 
    
    if save_violin_plot:
    
        plt.savefig('/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/'+'ViolinPlots_'+ itemj +  '.png')



def BarPlot(lsts_col, lsts_counts, df, save_plot):
    '''
    Create a barplot of data.
    Need to run violinPlot to fetch lsts_colour
    Need to fix this definition if you want to run again, or put in violinPlot
    '''
    lsts_colour = ViolinPots()
    fig, ax  = plt.subplots()
    x= np.arange(len(lsts_col))
    y = np.multiply(np.divide(lsts_counts,len(df)), 100)
    y = [ round(elem, 0) for elem in y ]
    ax.set_xticks(x, lsts_col)
    bars = ax.bar(x,y, align = 'center', ecolor = 'black', color = lsts_colour, capsize = 10, alpha = 0.5)

    ax.bar_label(bars)
    plt.ylabel('Subcategory Percentage')
    plt.title('Overview Subcategories')
    plt.savefig(save_plot + 'SubCat_Percentage' + '.png')


# Other statistics

def heatMapCategories(df, categories, save_fig, save_plot, name = ''):
    ds = df[categories].value_counts().reset_index(name='count')
    ds['percentage'] = (ds['count']/ds['count'].sum())*100
    
    ds = ds.sort_values(by = categories)  
    
    pivoted = ds.pivot(index= categories[0], columns= categories[1], values="percentage")


    fig,(ax1) = plt.subplots(1,1)
    sns.heatmap( ax = ax1, data = pivoted, annot = True, cmap="crest", cbar=False )
    ax1.set_title(name)
    #mosaic(df, categories , ax= ax2)
   #if not save_fig:
    #    plt.show()
    if save_fig :
        plt.savefig(save_plot + str(categories) + '_'+ name + '.png')


# Plot heatmaps

#if plot_heatmap:
    #heatMapCategories(df, ['Guitarra_Level', 'Condition'], False, save_plot )
    # heatMapCategories(['Palo', 'Baile_Level'], False, save_plot)
    # heatMapCategories(['Q1a', 'Dance_Imp'], False, save_plot)
    # heatMapCategories(['Dance_Imp', 'Music_Imp'], False, save_plot)
    #heatMapCategories(['Palo'], True, save_plot)



if plot_scatterplot: 

    #sns.scatterplot(x = 'Imp_subj', y = 'LZ', data=df, hue='Dance_Imp')
    sns.catplot(x = 'Imp_subj', y = 'Guitarra_Level', data=df, hue='Palo')

    plt.show()






# Plot for speficic Palo

def plotPalo(df):
    column = 'Palo'
    list_column = df[column].unique().tolist()
    list_column = np.sort(list_column).tolist()
    for i, item in enumerate(list_column):
        MI = df[df[str(column)].str.contains(str(item))]
        heatMapCategories(MI, ['Dance_Imp', 'Condition'], True, save_plot, name = str(item) )
        heatMapCategories(MI, ['Baile_Level', 'Condition'], True, save_plot, name = str(item) )
        #heatMapCategories(MI, ['Baile_Level', 'Palo'], True, save_plot, name = str(item) )




# Estimate annotation percentage based on rounds




def addFracAnnot(df):
    column = 'Name'
    list_files = df[column].unique().tolist()
    df['frac_annot'] = np.nan
    print(np)
    ds = df.groupby(['Name', 'Participant'])[['Rounds']].sum()

    i = 0
    for name, group in ds.index:
        sum_rounds = ds['Rounds'].iloc[i]
        i = i + 1    
        list_index = df[ (df['Name'].str.contains(name)) & (df['Participant'].str.contains(group)) ].index.tolist()
        df.loc[list_index, 'frac_annot'] =np.divide(np.array( df[ (df['Name'].str.contains(name)) & (df['Participant'].str.contains(group)) ]['Rounds']),sum_rounds)
        #print('SUM:',(np.divide(np.array( df[ (df['Name'].str.contains(name)) & (df['Participant'].str.contains(group)) ]['Rounds']),sum_rounds)).sum())
 


def HeatMapCategoriesFrac(df, categories, loopName = '', name = ''):
    '''
    df: DataFrame
    categories: two columns you want to create the heatmap from. 
    addFracAnnot adds column with fraction of each annotation within song based on number of rounds annotation. 
    '''
    addFracAnnot(df)
    result =  df.groupby(by= categories)["frac_annot"].sum().reset_index(name = 'count')
    #result['percentage'] = result['count']/result.groupby(categories[1]).sum()['count']*100
    cond = result.groupby(categories[1]).sum()

    result = result.sort_values(by = categories)  
        
    pivoted = result.pivot(index= categories[0], columns= categories[1], values="count")
    percentage = pivoted.div(np.array(cond['count'].T))*100
    
    print(str(categories),' :',percentage, 'SUM: ',percentage.sum())

    fig,(ax1) = plt.subplots(1,1)
    sns.heatmap( ax = ax1, data = percentage, annot = True, cmap="crest", cbar=False )
    #ax1.set_title('Distribution(%) ' + str(name) +': '+ str(categories[0]) + ' vs. ' + str(categories[1]))
    ax1.set_title('Distribution(%) ' + str(name))
    plt.savefig(save_plot + str(categories) + '_HeatMap_FracAnnot_' +str(loopName) +'.png')

HeatMapCategoriesFrac(df,["Baile_Level", 'Dance_Imp'] )
HeatMapCategoriesFrac(df,["Baile_Level", 'Condition'] )
HeatMapCategoriesFrac(df,["Dance_Imp", 'Condition'] )
HeatMapCategoriesFrac(df,["Dance_Imp", 'Palo'] )
HeatMapCategoriesFrac(df,["Guitarra_Level", 'Condition'] )
HeatMapCategoriesFrac(df,["Music_Imp", 'Condition'] )
HeatMapCategoriesFrac(df,["Baile_Level", 'Palo'] )
HeatMapCategoriesFrac(df,["Baile_Level", 'Guitarra_Level'] )
HeatMapCategoriesFrac(df,["Baile_Level", 'Music_Imp'] )


#Plot for specific condition

def loopOverColumn(df, column, categories, funcName):
    
    list_column = df[column].unique().tolist()
    list_column = np.sort(list_column).tolist()
   # print(list_column)
    for i, item in enumerate(list_column):
        MI = df[df[str(column)].str.contains(str(item))]


        if funcName == 1:
            heatMapCategories(MI, categories, True, save_plot, name = str(item) )
        
        elif funcName == 2:
            HeatMapCategoriesFrac(MI, categories, str(item), str(item))
        #heatMapCategories(MI, ['Baile_Level', 'Palo'], True, save_plot, name = str(item) )
    #heatMapCategories(['Guitarra_Level', 'Condition'], True, save_plot )

loopOverColumn(df, 'Dance_Imp', ['Baile_Level', 'Condition'], 2 )



# fig, ax = plt.subplots()

# for label, grp in df.groupby('Condition'):
#     grp = np.sort()
#     grp.plot(x = 'Condition_order', y = 'Q1b', ax = ax, label = label)
#     #print( label)
#     plt.show()


#result2 =  df.groupby(by=["Guitarra_Level", 'Condition'])["frac_annot"].count()
#print(df['frac_annot'])
#print( result) 

#print(df)
#df.to_csv(file_input + df_file + '_Filtered_2.csv')   

#Need to now somehow fetch percetnages, sum them, classify them. Which is similar to what you hae done with the groupby. 

    
    #print(df[ (df['Name'].str.contains(name)) & (df['Participant'].str.contains(group)) ]['frac_annot'])
    #df[df[str(column)].str.contains(str(item))]
    

# for i, item in ds:
#     #print(item)
#     print 
    
    #ds['Name', 'Rounds'] = (df.groupby('Name')[['Rounds']].sum())
    #print (ds)
    #print(item, ds[ds[str(column)].str.contains(str(item))])
    #sum_rounds = ds['Rounds'].sum()
    #df['frac_annot'] = (df['Rounds']/ds['Rounds'].sum())*100




#https://pandas.pydata.org/pandas-docs/stable/user_guide/groupby.html

