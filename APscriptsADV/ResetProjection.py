# ---------------------------------------------------------------------------
# ResetProjection.py
# RJM: 2021-1-11
# Description:
#   Resets projection parameters to match the source projection. Does not
#   reproject data...just cleans up the projection definition.
#
#   This script will check for the output folder and it will OVERWRITE
#   output files. Be sure to include the final set of backslashes in the
#   input and output folder names
#
#   2/19/2020
#   I found that I had to use the arcpy.CopyRaster_management() function
#   to get the desired compression. The RP.save() call did not do compression.
#   Also had to use arcpy.Delete_management() to get the deletion of the
#   temporary file to work. Using os.remove() caused and error because
#   arcpy.CopyRaster_management() wasn't done with the file when os.remove()
#   was called.
#
# ---------------------------------------------------------------------------

# Import arcpy module
import arcpy

# import os module
import os
from arcpy import env

# enable overwrites
env.overwriteOutput = True

# set cell size to the minimum of the inputs...this will help keep cell sizes consistent
arcpy.env.cellSize = "MINOF"

# Local variables...you MUST change these folders to point to the correct
# locations. Use double backslashes and include the final set of slashes in the
# folder name. Include the drive letter.
InputFolder = 'G:\\R_Stuff\\BLM_2020\\Medford\\Layers\\'

# provide a source for the projection definition...not a .prj file
ProjectionSource = 'J:\\OLC_UPPER_ROGUE_2015\\Boundary\\OLC_UPPER_ROGUE_TAF_NAD83_2011_OGIC.shp'

# output folder
OutputFolder = 'G:\\R_Stuff\\BLM_2020\\Medford\\Layers_proj_fixed\\'

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

# get source projection
# get the coordinate system by describing a feature class
dsc = arcpy.Describe(ProjectionSource)
coord_sys = dsc.spatialReference

# get list of IMG files in InputFolder
IMG_files = [f for f in os.listdir(InputFolder) if f.endswith(Extension)]

# Process: reset projection parameters
for f in IMG_files:
    print f
    InputFile = InputFolder + f
    OutputFile = OutputFolder + f
    arcpy.DefineProjection_management(InputFile, coord_sys)
    arcpy.RasterToOtherFormat_conversion(InputFile, OutputFolder, "IMAGINE Image")

print 'Done!!!'
