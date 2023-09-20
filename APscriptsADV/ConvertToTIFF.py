# ---------------------------------------------------------------------------
# ConvertToTIFF.py
# RJM: 2015-06-16
# Description:
#   Converts all files with the specified extension in the InputFolder
#   to TIFF format in the OutputFolder.
#   
#   This script will check for the output folder and it will OVERWRITE
#   output files. Be sure to include the final set of backslashes in the
#   input and output folder names
#
#   I tested this with IMAGINE format files but it should work with other
#   formats recognized by Arc if they are identified by a specific extension.
#   This logic may not work with GRIDS.
#
# ---------------------------------------------------------------------------

# Import arcpy module
import arcpy

# import os module
import os

# enable overwrites
arcpy.env.overwriteOutput = True

# set cell size to the minimum of the inputs...this will let us mask 1m rasters using a 30m mask
arcpy.env.cellSize = "MINOF"

# Local variables...you MUST change these folders to point to the correct
# locations/ Use double backslashes and include the final set of slashes in the
# folder name
InputFolder = 'H:\\KingFire\\Processing\\Intensity\\Products_KingFire_2015-06-25\\FINAL_KingFire_2015-06-25\\Intensity_1p5METERS\\'
OutputFolder = 'H:\\KingFire\\Processing\\Intensity\\Products_KingFire_2015-06-25\\FINAL_KingFire_2015-06-25\\TIFF_Intensity_1p5METERS\\'
PRJFile = 'H:\\KingFire\\KingFire_UTM10.prj'
Extension = '.img'

# make sure the output folder exists...if not create it
if not os.path.exists(OutputFolder):
    os.makedirs(OutputFolder)

arcpy.env.workspace = OutputFolder

# get list of IMG files in InputFolder
IMG_files = [f for f in os.listdir(InputFolder) if f.endswith(Extension)]

# Process: Extract by Mask
for f in IMG_files:
    print f
    InputFile = InputFolder + f
    OutputFile = OutputFolder + f
    arcpy.DefineProjection_management(InputFile, PRJFile)
    arcpy.RasterToOtherFormat_conversion(InputFile, OutputFolder, "TIFF")

print 'Done!!!'
