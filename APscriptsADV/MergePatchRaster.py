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
#InputFolder = 'J:\\OLC_UPPER_ROGUE_2015\\AP_run\\Products_UpperRogue_2017-05-22\\FINAL_UpperRogue_2017-05-22\\Metrics_98p424FEET\\'
#InputFolder = 'J:\\OLC_UPPER_ROGUE_2015\\AP_run\\Products_UpperRogue_2017-05-22\\FINAL_UpperRogue_2017-05-22\\CanopyMetrics_98p424FEET\\'
InputFolder = 'J:\\OLC_UPPER_ROGUE_2015\\AP_run\\Products_UpperRogue_2017-05-22\\FINAL_UpperRogue_2017-05-22\\StrataMetrics_98p424FEET\\'

#PatchFolder = 'J:\\Upper_rogue_2015_2021\\AP_run_30m\\Products_UpperRogue_2021-01-27\\FINAL_UpperRogue_2021-01-27\\Metrics_98p424FEET\\'
#PatchFolder = 'J:\\Upper_rogue_2015_2021\\AP_run_30m\\Products_UpperRogue_2021-01-27\\FINAL_UpperRogue_2021-01-27\\CanopyMetrics_98p424FEET\\'
PatchFolder = 'J:\\Upper_rogue_2015_2021\\AP_run_30m\\Products_UpperRogue_2021-01-27\\FINAL_UpperRogue_2021-01-27\\StrataMetrics_98p424FEET\\'

CellSize = 98.424

# provide projection definition...a .prj file
ProjectionSource = 'J:\\Upper_rogue_2015_2021\\OR_OGIC_NAD83_2011.prj'

# output folder
OutputFolder = 'J:\\Upper_rogue_2015_2021\\PatchedRasters_30m\\StrataMetrics_98p424FEET\\'

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
    PatchFile = PatchFolder + f
    OutputFile = OutputFolder + f
    # create empty raster for merged layer
    arcpy.CreateRasterDataset_management(OutputFolder, f, CellSize, "32_BIT_FLOAT",\
                                         ProjectionSource, "1", "", "PYRAMIDS 0 NEAREST JPEG",\
                                         "128 128", "RLE", "")
    # merge the patch into the larger raster
    arcpy.Mosaic_management(InputFile+";"+PatchFile,OutputFile,"LAST", "", "", "-9999")

print 'Done!!!'

