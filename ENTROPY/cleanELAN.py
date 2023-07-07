

import glob
import csv


path_ratings = "/Users/atillajv/CODE/RITMO/FILES/ELAN/"
path_output = "/Users/atillajv/CODE/RITMO/FILES/ELAN/cleaned/"

loop_on = True
list_files = []
error_files = []
file_name = ""


if loop_on:
    for filepath in glob.iglob( str(path_ratings + '*.csv')):
        if filepath.endswith('.csv'):
            filepath_split = filepath.partition('ELAN/')
            # filepath_split = filepath_split[2].strip('.csv')
            # print(filepath_split.rsplit('_',1))

            list_files.append(filepath_split[2])
else:
    list_files = [file_name]



print (list_files)


for i, item in enumerate(list_files):
# Open the input and output files
    with open(path_ratings + item, 'r') as csv_file:
        with open(path_output + item, 'w', newline='') as output_file:
            # Create a CSV reader and writer objects
            csv_reader = csv.reader(csv_file)
            csv_writer = csv.writer(output_file, delimiter=';')

            # Loop through each row in the input file
            for row in csv_reader:
                # Remove double quotes and replace commas with semicolons
                cleaned_row = [cell.replace('"', '').replace(',', ';') for cell in row]
                cleaned_row = [cell.strip('"') for cell in cleaned_row]

                # Write the cleaned row to the output file
                csv_writer.writerow(cleaned_row)
