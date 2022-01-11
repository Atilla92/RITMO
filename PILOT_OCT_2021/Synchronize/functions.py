import numpy as np 
def  labelColumns(df, p):

    df.columns.values[0] = "Time"
    df.columns.values[1] = "A"
    df.columns.values[2] = "B"
    df.columns.values[3] = "C"
    df.columns.values[4] = "D"
    if p:
        print(df)


def setStart(df,t0):
    '''Reduce dataset to a certain time window '''
    tStart = t0
    df_start = df.loc[(df["Time"] >= tStart ) ]
    df_length = int(len(df_start.index))

    return df_start, df_length


def separateData (df):
    ''' Separate data in arrays FSR'''
    x =  np.array(df['Time'])
    y1 = np.array(df['A'])
    y2 = np.array(df['B'])
    y3 = np.array(df['C'])
    #y4 = df['D']

    return x, y1, y2, y3