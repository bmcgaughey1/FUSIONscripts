# ---------------------------------------------------------------------------
# ComputeStrataCover.py
# RJM: 2015-09-15
# Description:
#   Computes "cover" values using strata count layers. 
#
#   This script will check for the output folder and it will OVERWRITE
#   output files. Be sure to include the final set of backslashes in the
#   input and output folder names
#
#   4/6/2016 changed the names on the topographic layers for TPI and aspect to
#   match the new naming. Puts "topo_tpi" and "topo_aspect" and "topo_aspect_cosine"
#   at the beginning of the layer names instead of the window size.
#
#   8/3/2017 changed the variable ProductFolder to BaseFolder to make the
#   script match my mask script...now you can just copy the entire line
#   from one script to the other
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
#BaseFolder = 'I:\\OLC_KENO_2012\\AP_RUN\\Products_KENO_2018-12-19\\FINAL_KENO_2018-12-19\\'
#BaseFolder = 'H:\\SouthUmpquaExpForestCoyoteWatershed\\AP_run_20m\\Products_SUEP_CoyoteCreek_2020-09-08\\FINAL_SUEP_CoyoteCreek_2020-09-08\\'
#BaseFolder = 'H:\\SouthUmpquaExpForestCoyoteWatershed\\AP_run_23m\\Products_SUEP_CoyoteCreek_2020-09-09\\FINAL_SUEP_CoyoteCreek_2020-09-09\\'
BaseFolder = 'H:\\SRS_Processing\\AP_run\\Products_SRS_2018_2018-08-27\\FINAL_SRS_2018_2018-08-27\\'
BaseFolder = 'J:\\Upper_rogue_2015_2021\\PatchedRasters_30m\\'

# choices are 'meters' or 'feet'
Units = 'feet'

# these variables will most likely not change unless you are using 'feet'...choices are 'meters' or 'feet'
StrataOutputFolder = 'StrataCoverMetrics'
TPIOutputFolder = 'NormalizedTPIMetrics'
Extension = '.img'

# ---------------------------------------------------------------------------------------------------------------------------
# do the processing...don't make changes below this line unless you know what you are doing and why!!
# ---------------------------------------------------------------------------------------------------------------------------

Resolution = '30METERS'
StrataLabels = ["0to0p5M","0p5to1M","1to2M","2to4M","4to8M","8to16M","16to32M","32to48M","48to64M","64M_plus"]
TopoLabels = ["15M", "45M", "135M", "270M"]
TPILabels = ["200M", "500M", "1000M", "2000M", "4000M"]

# change units if working in feet
if Units == 'feet':
    Resolution = '98p424FEET'
    StrataLabels = ["0to1p6404F", "1p6404to3p2808F","3p2808to6p5616F","6p5616to13p1232F","13p1232to26p2464F","26p2464to52p4928F","52p4928to104p9856F","104p9856to157p4784F","157p4784to209p9712F","209p9712F_plus"]
    TopoLabels = ["49p212F", "147p636F", "442p908F","885p816F"]
    TPILabels = ["656p16F", "1640p40F", "3280p80F", "6561p60F", "13123p2F"]
    
# build path names
InputPath = BaseFolder + 'StrataMetrics_' + Resolution + '\\'
OutputPath = BaseFolder + StrataOutputFolder + '_' + Resolution + '\\'

# make sure the output folder exists...if not create it
if not os.path.exists(OutputPath):
    os.makedirs(OutputPath)

# Process strata layers
# need running sum of return counts so start by adding 0 to the first strata
StrataSum = Plus(InputPath + 'strata_' + StrataLabels[0] + '_total_return_cnt_' + Resolution + Extension, 0)
Counter = 0

print 'Computing strata proportions (#returns_in_layer / sum_#returns(current_layer + all_layers_below_current_layer))...'
for f in StrataLabels:
    if Counter > 0:
        LayerFile = InputPath + 'strata_' + f + '_total_return_cnt_' + Resolution + Extension
        print 'Strata: ' + f
        StrataSum = Plus(LayerFile, StrataSum)
        Cover = Divide(LayerFile, StrataSum)
        Cover = Times(Cover, 100.0)
        Cover.save(OutputPath + 'strata_' + f + '_cover_' + Resolution + Extension)
        print '   Strata done!!!'
    else:
        print 'First strata: ' + f + ' skipped'

    Counter = Counter + 1

print 'Done with strata layers!!!'

# re-build path names
InputPath = BaseFolder + 'MASKED_TopoMetrics_' + Resolution + '\\'
OutputPath = BaseFolder + TPIOutputFolder + '_' + Resolution + '\\'

# make sure the output folder exists...if not create it
if not os.path.exists(OutputPath):
    os.makedirs(OutputPath)

# Process TPI normalization
print ''
print 'Normalizing TPI ((TPI - mean_for_layer) / STD_for_layer)...'
for f in TPILabels:
    LayerFile = InputPath + 'topo_tpi_' + f + '_' + Resolution + Extension
    print 'TPI window size: ' + f
    arcpy.CalculateStatistics_management(LayerFile, "1", "1")
    LayerMeanResult = arcpy.GetRasterProperties_management(LayerFile, "MEAN")
    LayerMean = LayerMeanResult.getOutput(0)
    LayerSTDResult = arcpy.GetRasterProperties_management(LayerFile, "STD")
    LayerSTD = LayerSTDResult.getOutput(0)

    nTPI = Minus(LayerFile, float(LayerMean))
    nTPI = Divide(nTPI, float(LayerSTD))

    nTPI.save(OutputPath + 'topo_tpi_normalized_' + f + '_' + Resolution + Extension)
    print '   Layer done!!!'

print 'Done with TPI!!!'

# re-build path names
InputPath = BaseFolder + 'MASKED_TopoMetrics_' + Resolution + '\\'
OutputPath = InputPath

# Compute cosine of aspect
print ''
print 'Computing cos(180 - aspect)...'
for f in TopoLabels:
    LayerFile = InputPath + 'topo_aspect_' + f + '_' + Resolution + Extension
    print 'Topo window size: ' + f

    # make relative to south
    aspect = Minus(180.0, LayerFile)
    # convert to radians
    aspect = Times(aspect, 0.017453293)
    aspect = Cos(aspect)

    aspect.save(OutputPath + 'topo_aspect_cosine_' + f + '_' + Resolution + Extension)
    print '   Layer done!!!'

print 'Done with cos(aspect)!!!'
