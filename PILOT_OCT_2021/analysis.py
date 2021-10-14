import pandas as pd
import numpy as np
from sklearn import preprocessing
df = pd.read_csv (r'DataAnalysis.csv')

buleria  = (df.loc[df["Palo"]=="Buleria"])
day1 = (df.loc[df['Day']==1])
day2 = (df.loc[df['Day']==2])


#Basic operators:
def addMeanStd(x):
    x = np.append(x, np.mean(x))
    x = np.append(x, np.std(x))
    return x

def standardizeArray(x):  #Standardizes a 1xn array

        x = x.reshape(-1,1)
        std_scale = preprocessing.StandardScaler().fit(x)
        df_std = std_scale.transform(x)
        df_std = np.concatenate(df_std, axis=0)
        return df_std

def appendMeanStd(x):
    name = np.array(x['Name'])
    addEl =['mean','std']
    name = np.append(name,addEl)
    return name

def meanStd(x):
    x_stnd = standardizeArray(x)
    x = addMeanStd(x)
    x_stnd = addMeanStd (x_stnd)
    return x, x_stnd


# Analysis
def estimating_One(x,variable):
    x = np.array(x[variable])
    x, x_stnd = meanStd(x)
    return x, x_stnd

def estimating_sum(x,variable):
    x_new =np.array(x.shape[0])
    print('this is a', x.shape[0],'shape')
    for i, word in enumerate(variable):
        x_old = np.array(x[word])
        x_new = x_new + x_old
        print(i,'i',word, x_new)
    x_new = np.divide(x_new,x.shape[0])
    x, x_stnd = meanStd(x_new)
    return x, x_stnd



def estimating_P(subA,a): #estimates the P value

    P_sum_plus = np.array((subA[a[0]]+subA[a[1]]+subA[a[2]]).values.tolist())
    P_sum_min = np.array((subA[a[3]] + subA[a[4]] + subA[a[5]]).values.tolist())
    P = P_sum_plus - P_sum_min #Positive elements - negative elements
    # P_plus = np.where(P < 0, 0, P).tolist()
    # P_min = np.where(P >= 0, 0, P).tolist()
    P_scale = standardizeArray(P)
    # Add mean and std to list of arrays
    P = addMeanStd(P)
    P_scale =addMeanStd(P_scale)
    return(P,P_scale)



def createMatrix(x): #creating PAT
# Defining variables
    Pleasure = ['Pleasant','Positive','Good','Unpleasant', 'Negative', 'Bad']
    Awakeness = ["Awake","Alert","Wakeful","Sleepy", "Tired","Drowsy"]
    Tension = ["Restless","Tense","Jittery","At rest","Relaxed","Calm"]
    Morten = ["Move","Pleasure experienced"]
    Meaning = ["Meaningful","Valuable"]
    Elevating = ["In awe","Deeply appreciating","Emotionally moved","Morally elevated","Inspired","Enriched","Connected with a greater whole","Part of something greater than myself"]


# Operations
    name_col = appendMeanStd(x)

    PAT = {
            'name':name_col,
            'P': estimating_P(x,Pleasure)[0],
            'A': estimating_P(x,Awakeness)[0],
            'T': estimating_P(x,Tension)[0],
            'P_stnd': estimating_P(x,Pleasure)[1],
            'A_stnd': estimating_P(x,Awakeness)[1],
            'T_stnd': estimating_P(x,Tension)[1],
            'Move':estimating_One(x,Morten[0])[0],
            'Move_stnd':estimating_One(x,Morten[0])[1],
            'Pleasure':estimating_One(x,Morten[1])[0],
            'Pleasure_stnd':estimating_One(x,Morten[1])[1],
            'Meaning': estimating_sum(x,Meaning)[0],
            'Meaning_stnd': estimating_sum(x,Meaning)[1],
            'Elevating': estimating_sum(x,Elevating)[0],

    }
    return PAT



def storeDF(x, title): #store values in DataFrame

    dfPAT = pd.DataFrame(data=x)
    print(f'{title}\n', np.round(dfPAT,decimals = 2))
    file_name = str("export/" + title+'.csv')
    dfPAT.to_csv(file_name,float_format='%.2f', index = False)
    return dfPAT




def workflow(x, PAT_analysis, store, title):
    if PAT_analysis:
        PAT = createMatrix(x)
    if store:
        storeDF(PAT,title)


PAT_df = workflow(df, True, True, "All values")
Day1_df = workflow(day1, True, True, "Day1")
Day2_df = workflow(day2, True, True, "Day2")
# PAT_df = createMatrix(day1, True, "Day1")
