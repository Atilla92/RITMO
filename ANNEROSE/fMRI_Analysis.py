import nibabel as nib
img = nib.load('/Users/atillajv/CODE/FILES/data_annerose/ImImpro/BD5T/functional/swudata.nii')
img2 = nib.load('/Users/atillajv/CODE/FILES/data_annerose/ImImpro/BDAT/functional/swudata.nii')

print (img.shape, img2.shape)
data = img.get_fdata()

#data2 = img2.get_fdata()
#print(data)
