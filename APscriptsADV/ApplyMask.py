# ---------------------------------------------------------------------------
# ApplyMask.py
# RJM: 2015-05-06
# Description:
#   Uses a mask to remove areas from gridded layers. We typically run this
#   on the topo metrics because they extend beyond the area covered by the
#   lidar point data.
#
#   This script will check for the output folder and it will OVERWRITE
#   output files. Be sure to include the final set of backslashes in the
#   input and output folder names
#
#   I tested this with IMAGINE format files but it should work with other
#   formats recognized by Arc if they are identified by a specific extension.
#   This logic may not work with GRIDS.
#
# 5/18/2015
#   Added the logic to set the cell size and snap alignment to the input raster.
#   This should allow the script to be used when the mask is a coarse resolution
#   and the raster being masked is a finer resolution.
#
# ---------------------------------------------------------------------------

# Import arcpy module
import arcpy

# import os module
import os

# Check out any necessary licenses
arcpy.CheckOutExtension("spatial")

# enable overwrites
arcpy.env.overwriteOutput = True

# set cell size to the minimum of the inputs...this will let us mask 1m rasters using a 30m mask
arcpy.env.cellSize = "MINOF"

# Local variables...you MUST change these folders to point to the correct
# locations. Use double slashes "\\"
#BaseFolder = 'I:\\OLC_KENO_2012\AP_RUN\\Products_KENO_2018-12-19\\FINAL_KENO_2018-12-19\\'
BaseFolder = 'J:\\NEW_OLC_UPPER_UMPQUA_2015\\AP_run_30m\\Products_UpperUmpqua_2020-12-23\\FINAL_UpperUmpqua_2020-12-23\\'

Units = 'feet'

# mask file...should have NODATA or 0 for areas outside the desired coverage,
# 1 for areas inside...haven't tested this with GRIDs (only tested IMAGINE format)
MaskRaster = 'J:\\NEW_OLC_UPPER_UMPQUA_2015\\Mask.img'

# build the folder names
Resolution = '30METERS'
if Units == 'feet':
    Resolution = '98p424FEET'

InputFolder = BaseFolder + 'TopoMetrics_' + Resolution + '\\'
OutputFolder = BaseFolder + 'MASKED_TopoMetrics_' + Resolution + '\\'
Extension = '.img'

# make sure the output folder exists...if not create it
if not os.path.exists(OutputFolder):
    os.makedirs(OutputFolder)
    
# get list of IMG files in InputFolder
IMG_files = [f for f in os.listdir(InputFolder) if f.endswith(Extension)]

# Process: Extract by Mask
for f in IMG_files:
    print(f)
    InputFile = InputFolder + f
    OutputFile = OutputFolder + f
    arcpy.env.snapRaster = InputFile
    arcpy.gp.ExtractByMask_sa(InputFile, MaskRaster, OutputFile)

print('Done!!!')
