# ---------------------------------------------------------------------------
# MergePatchRaster.py
# RJM: 1/26/2021
# Description:
#   Merges a "patch" into an existing raster layer. Assumes cell size and
#   grid alignment is the same for the source and patch rasters.
# ---------------------------------------------------------------------------

# Import arcpy module
import arcpy

# import os module
import os
from arcpy import env

# enable overwrites
env.overwriteOutput = "True"

# set cell size to the minimum of the inputs...this will help keep cell sizes consistent
arcpy.env.cellSize = "MINOF"

# Local variables...you MUST change these folders to point to the correct
# locations. Use double backslashes and include the final set of slashes in the
# folder name. Include the drive letter.
#InputFolder = 'J:\\UpperRogue_75ft\\Products_UpperRogue_2016-12-07\\FINAL_UpperRogue_2016-12-07\\Metrics_75FEET\\'
InputFolder = 'J:\\OLC_UPPER_ROGUE_2015\\AP_run\\Products_UpperRogue_2017-05-22\\FINAL_UpperRogue_2017-05-22\\CanopyHeight_3p2808FEET\\'

#PatchFolder = 'J:\\Upper_rogue_2015_2021\\AP_run\\Products_UpperRogue_2021-01-26\\FINAL_UpperRogue_2021-01-26\\Metrics_75FEET\\'
PatchFolder = 'J:\\Upper_rogue_2015_2021\\AP_run_30m\\Products_UpperRogue_2021-01-27\\FINAL_UpperRogue_2021-01-27\\CanopyHeight_3p2808FEET\\'
CellSize = 3.2808

# provide projection definition...a .prj file
ProjectionSource = 'J:\\Upper_rogue_2015_2021\\OR_OGIC_NAD83_2011.prj'

# output folder
OutputFolder = 'J:\\Upper_rogue_2015_2021\\PatchedRasters_30m\\CanopyHeight_3p2808FEET\\'

# extension for input files
Extension = '.img'

# set compression to RLE for IMAGINE files
arcpy.env.compression = "RLE"

# turn off pyramid creation
arcpy.env.pyramid = "NONE"

# ---------------------------------------------------------------------------------------------------------------------------
# do the processing...don't make changes below this line unless you know what you are doing and why!!
# ---------------------------------------------------------------------------------------------------------------------------

# make sure the output folder exists...if not create it
if not os.path.exists(OutputFolder):
    os.makedirs(OutputFolder)

arcpy.env.workspace = OutputFolder

######### All of this code assumes that the patch is fully contained within a layer. For
######### BLOCK products, it is harder as you have to mosaic the patch into the original
######### raster and then clip back to the original raster.
######### This is the code to use for Metrics folder
# get list of IMG files in InputFolder
#IMG_files = [f for f in os.listdir(InputFolder) if f.endswith(Extension)]

# Process: reset projection parameters
##for f in IMG_files:
##    print f
##    InputFile = InputFolder + f
##    PatchFile = PatchFolder + f
##    OutputFile = OutputFolder + f
##    # create empty raster for merged layer
##    arcpy.CreateRasterDataset_management(OutputFolder, f, CellSize, "32_BIT_FLOAT",\
##                                         ProjectionSource, "1", "", "PYRAMIDS 0 NEAREST JPEG",\
##                                         "128 128", "RLE", "")
##    # merge the patch into the larger raster
##    arcpy.Mosaic_management(InputFile+";"+PatchFile,OutputFile,"LAST", "", "", "-9999")

f = 'BLOCK155_CHM_filled_3x_smoothed_3p2808FEET.img'
InputFile = InputFolder + f
PatchFile = PatchFolder + 'BLOCK1_CHM_filled_3x_smoothed_3p2808FEET.img'
OutputFile = OutputFolder + 'temp.img'

# create empty raster for merged layer
arcpy.CreateRasterDataset_management(OutputFolder, "temp.img", CellSize, "32_BIT_FLOAT",\
                                     ProjectionSource, "1", "", "PYRAMIDS 0 NEAREST JPEG",\
                                     "128 128", "RLE", "")
# merge the patch into the larger raster
arcpy.Mosaic_management(InputFile+";"+PatchFile,OutputFile,"LAST", "", "", "-9999")

# clip to match original layer
arcpy.Clip_management(OutputFile, "627351.2952 133850.0784 652649.544 150696.9864", OutputFolder + f)

# delete temp files
os.remove(OutputFolder + 'temp.img')
os.remove(OutputFolder + 'temp.rrd')
os.remove(OutputFolder + 'temp.img.xml')
os.remove(OutputFolder + 'temp.img.aux.xml')

f = 'BLOCK156_CHM_filled_3x_smoothed_3p2808FEET.img'
InputFile = InputFolder + f
PatchFile = PatchFolder + 'BLOCK1_CHM_filled_3x_smoothed_3p2808FEET.img'
OutputFile = OutputFolder + 'temp.img'

# create empty raster for merged layer
arcpy.CreateRasterDataset_management(OutputFolder, "temp.img", CellSize, "32_BIT_FLOAT",\
                                     ProjectionSource, "1", "", "PYRAMIDS 0 NEAREST JPEG",\
                                     "128 128", "RLE", "")
# merge the patch into the larger raster
arcpy.Mosaic_management(InputFile+";"+PatchFile,OutputFile,"LAST", "", "", "-9999")

# clip to match original layer
arcpy.Clip_management(OutputFile, "627351.2952 150483.7344 652656.1056 175788.5448", OutputFolder + f)

# delete temp files
os.remove(OutputFolder + 'temp.img')
os.remove(OutputFolder + 'temp.rrd')
os.remove(OutputFolder + 'temp.img.xml')
os.remove(OutputFolder + 'temp.img.aux.xml')

f = 'BLOCK155_CHM_filled_not_smoothed_3p2808FEET.img'
InputFile = InputFolder + f
PatchFile = PatchFolder + 'BLOCK1_CHM_filled_not_smoothed_3p2808FEET.img'
OutputFile = OutputFolder + 'temp.img'

# create empty raster for merged layer
arcpy.CreateRasterDataset_management(OutputFolder, "temp.img", CellSize, "32_BIT_FLOAT",\
                                     ProjectionSource, "1", "", "PYRAMIDS 0 NEAREST JPEG",\
                                     "128 128", "RLE", "")
# merge the patch into the larger raster
arcpy.Mosaic_management(InputFile+";"+PatchFile,OutputFile,"LAST", "", "", "-9999")

# clip to match original layer
arcpy.Clip_management(OutputFile, "627351.2952 133850.0784 652649.544 150696.9864", OutputFolder + f)

# delete temp files
os.remove(OutputFolder + 'temp.img')
os.remove(OutputFolder + 'temp.rrd')
os.remove(OutputFolder + 'temp.img.xml')
os.remove(OutputFolder + 'temp.img.aux.xml')

f = 'BLOCK156_CHM_filled_not_smoothed_3p2808FEET.img'
InputFile = InputFolder + f
PatchFile = PatchFolder + 'BLOCK1_CHM_filled_not_smoothed_3p2808FEET.img'
OutputFile = OutputFolder + 'temp.img'

# create empty raster for merged layer
arcpy.CreateRasterDataset_management(OutputFolder, "temp.img", CellSize, "32_BIT_FLOAT",\
                                     ProjectionSource, "1", "", "PYRAMIDS 0 NEAREST JPEG",\
                                     "128 128", "RLE", "")
# merge the patch into the larger raster
arcpy.Mosaic_management(InputFile+";"+PatchFile,OutputFile,"LAST", "", "", "-9999")

# clip to match original layer
arcpy.Clip_management(OutputFile, "627351.2952 150483.7344 652656.1056 175788.5448", OutputFolder + f)

# delete temp files
os.remove(OutputFolder + 'temp.img')
os.remove(OutputFolder + 'temp.rrd')
os.remove(OutputFolder + 'temp.img.xml')
os.remove(OutputFolder + 'temp.img.aux.xml')


print 'Done!!!'

