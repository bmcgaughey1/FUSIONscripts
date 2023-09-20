# ---------------------------------------------------------------------------
# ComputeRelativePercentiles.py
# RJM: 2018-11-26
# Description:
#   Computes relative percentile layers.
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
from arcpy.sa import *


# Check out any necessary licenses
arcpy.CheckOutExtension("spatial")

# enable overwrites
env.overwriteOutput = "True"

# set cell size to the minimum of the inputs...this will help keep cell sizes consistent
arcpy.env.cellSize = "MINOF"

# Local variables...you MUST change these folders to point to the correct
# locations. Use double backslashes and include the final set of slashes in the
# folder name. Include the drive letter.
#BaseFolder = 'K:\\LaneCounty_75ft\\Products_LaneCounty_2016-11-17\\FINAL_LaneCounty_2016-11-17\\'
#BaseFolder = 'K:\\SouthCoast_75ft\\AP_run\\Products_SouthCoast_2017-02-27\\FINAL_SouthCoast_2017-02-27\\'
#BaseFolder = 'K:\\UpperRogue_75ft\\Products_UpperRogue_2016-12-07\\FINAL_UpperRogue_2016-12-07\\'
#BaseFolder = 'K:\\UpperUmpqua_75ft\\Products_Upper_Umpqua_2016-11-23\\FINAL_Upper_Umpqua_2016-11-23\\'
#BaseFolder = 'J:\\RogueValley\\AP_run\\FINAL_RogueValley_2020-02-24\\'
#BaseFolder = 'H:\\SouthUmpquaExpForestCoyoteWatershed\\AP_run_20m\\Products_SUEP_CoyoteCreek_2020-09-08\\FINAL_SUEP_CoyoteCreek_2020-09-08\\'
#BaseFolder = 'H:\\SouthUmpquaExpForestCoyoteWatershed\\AP_run_23m\\Products_SUEP_CoyoteCreek_2020-09-09\\FINAL_SUEP_CoyoteCreek_2020-09-09\\'
#BaseFolder = 'J:\\NEW_OLC_UPPER_UMPQUA_2015\\AP_run\\Products_UpperUmpqua_2020-12-15\\FINAL_UpperUmpqua_2020-12-15\\'
#BaseFolder = 'J:\\NEW_OLC_UPPER_UMPQUA_2015\\AP_run_30m\\Products_UpperUmpqua_2020-12-23\\FINAL_UpperUmpqua_2020-12-23\\'
#BaseFolder = 'J:\\Upper_rogue_2015_2021\\PatchedRasters_30m\\'
BaseFolder = 'J:\\Roseburg_75ft_Deliverables\\'

# choices are 'meters' or 'feet'
Units = 'feet'

# these variables will most likely not change unless you are using 'feet'...choices are 'meters' or 'feet'
RPOutputFolder = 'RelativePercentileMetrics'
Extension = '.img'

# set compression to RLE for IMAGINE files
arcpy.env.compression = "RLE"

# turn off pyramid creation
arcpy.env.pyramid = "NONE"

# ---------------------------------------------------------------------------------------------------------------------------
# do the processing...don't make changes below this line unless you know what you are doing and why!!
# ---------------------------------------------------------------------------------------------------------------------------

# pay attention to the base layer and the list of layer names. If you change to use P95 as the base,
# you need to remove P95 from the list of layer names.
Resolution = '30METERS'
PercentileLabels = ["P01", "P05", "P10", "P20", "P25", "P30", "P40", "P50", "P60", "P70", "P75", "P80", "P90", "P95"]
BaseLabel = 'P95'
HeightThreshold = '2plus'

# change units if working in feet
if Units == 'feet':
    Resolution = '75FEET'
#    Resolution = '98p424FEET'
#    HeightThreshold = '6p5616plus'
    HeightThreshold = '3p2808plus'
    
# build path names
InputPath = BaseFolder + 'Metrics_' + Resolution + '\\'
OutputPath = BaseFolder + RPOutputFolder + '_' + BaseLabel + "_" + Resolution + '\\'

# make sure the output folder exists...if not create it
if not os.path.exists(OutputPath):
    os.makedirs(OutputPath)

# Compute relative percentiles...relative to P99
BasePercentile = Plus(InputPath + 'elev_' + BaseLabel + '_' + HeightThreshold + '_' + Resolution + Extension, 0)
Counter = 0

print 'Computing relative percentile layers (PercentileLayer / ', BaseLabel, ')'
for f in PercentileLabels:
    LayerFile = InputPath + 'elev_' + f + '_' + HeightThreshold + '_' + Resolution + Extension
    print 'Percentile: ' + f
    RP = Divide(LayerFile, BasePercentile)
    RP.save(OutputPath + 'temp_R' + f + '_' + HeightThreshold + '_' + Resolution + Extension)
    arcpy.CopyRaster_management(OutputPath + 'temp_R' + f + '_' + HeightThreshold + '_' + Resolution + Extension, OutputPath + 'elev_R' + f + '_' + HeightThreshold + '_' + Resolution + Extension)
    arcpy.Delete_management(OutputPath + 'temp_R' + f + '_' + HeightThreshold + '_' + Resolution + Extension)
    print '   Percentile done!!!'

print 'Done with percentile layers!!!'
