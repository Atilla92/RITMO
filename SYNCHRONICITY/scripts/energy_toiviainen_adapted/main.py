
# Steps
# Create a dictionnary list, that maps joints to numbers
# String split at last _, if new name create new name in dictionarry, else add new element to list with name after _ and number: _ as the i-th iteration. 'Store name as well'. Store as a json to inspect. Either you can add the i-th iteration as name, or you can loop though dictionary and add element, from another dictionnarie's match. Could store that information in the general DF. If name of element matches JOINT_NAME_MP fetch JOINT_ID_MP    
# Based on dictionary add extra joints 33 - 36
# Create a ditionnary that relates joints numbers to segment
# Need to fetch csv with information from dataset .csv
# Need to save data in in a dictionary data = {1: {x:[], y:[], z:[]}} 
# Question is whether it should be made compatible with other inputs. Perhaps not to start with

###### DAY 2###

## For now created a json dictionnary with values, and body models male and female. 

## Now need to create a .csv with information participants. And probably set whether the analysis is on musicians or on dancers. Let's do dancers to start with. 
## Figure out how to work with classes and whether it is more efficient. Probaly nice to fetch the info from the csv and put it in the class, but also allow it to have input array. 



class Subject:
    def __init__(self, ID, gender, segment_array):
        self.ID = ID
        self.gender = gender
        self.segments = segment_array

    def my_method(self):
        # Accessing attributes within a method
        print("Attribute 1:", self.ID)
        print("Attribute 2:", self.gender)