import pandas as pd
import glob

# folder = "/Users/atillajv/CODE/RITMO/ENTROPY/output/main/"
# fileName = "Entropy_LZ_CTW_(w=4000_s=[]_ds=4_b=on_abs=on_t0=0)_P3_D0_G1_M6_R1_T1.csv"
# df = pd.read_csv(str(folder + fileName))
# dfSmall = df[1:]
# mean = dfSmall.mean(axis = 0)
# print(mean, df.iloc[0]) 


csv_files = []

for filepath in glob.iglob('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/*.csv'):
    if filepath.endswith('.csv'):
        filepath_split = filepath.partition(')_')
        print (filepath_split)
        csv_files.append(filepath_split[2])