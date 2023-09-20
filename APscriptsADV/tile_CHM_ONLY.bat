rem 2/9/2015 moved the calculation of the gridsurfacestats to happen before canopy surface models are clipped
rem 10/2/2015 made changes for segmentation logic so we use a special CHM and smoothing options for segmentation
rem 10/29/2015 added the /halfcell option when computing canopy surface metrics. This is needed due to some
rem changes to GridSurfaceStats to correct the alignment of metrics (surface and point metrics).
rem 3/8/2016 changed the naming of canopy surface metrics to put the resolution last in the file name. The 
rem resolution was previously in the middle of the name and this was inconsistent with most other products.
rem 3/10/2016 modified the logic used to do tree segmentation to add the /projection option and removed
rem the copy commands for the projection file
rem 4/25/2016 made changes to add mortality-related point counts and intensity images. Look for "MORTALITY--"
rem to find the added code (only one block of code and only in tile.bat.
rem 5/3/2016 moved coarse resolution CHMs into IF stmt so they are only merged when DOSPECIALCANOPY is true
rem 11/1/2016 added folder to new data clips and intensity images created when DOSEGMENTS and DOMORTALITY
rem are TRUE...I think this only caused problems for runs that used an old job-specific setup batch file.
rem 7/13/2017 modifed logic when doing mortality products to delete the intensity percentile output files.
rem 8/14/2017 modifed logic to add point clips for TreeSeg crown polygons
rem
rem 2/26/2020 removing all code except that needed to create an unsmoothed CHM and canopy metrics
rem
REM Tile processing batch file for use with AreaProcessor

REM Expected command line parameters:
REM    %1     Name of the buffered tile containing LIDAR data
REM    %2     Minimum X value for the unbuffered tile
REM    %3     Minimum Y value for the unbuffered tile
REM    %4     Maximum X value for the unbuffered tile
REM    %5     Maximum Y value for the unbuffered tile
REM    %6     Minimum X value for the buffered tile
REM    %7     Minimum Y value for the buffered tile
REM    %8     Maximum X value for the buffered tile
REM    %9     Maximum Y value for the buffered tile
REM The buffered tile file name looks like this: TILE_C00001_R00002_S00001. The row (R) and column (C) numbers
REM specify the tile location and the subtile designation identifies the tile within an analysis grid cell when
REM tile sizes have been optimized. The origin of the row and column coordinate system is the lower left corner
REM of the data extent.

REM Initially, the values for %2, %3, %4, %5 can be used to clip data products produced using the buffered tile

REM Insert commands that use the original tile corners before the the block of SHIFT commands

REM save the variables for the buffered tile corners so we can use them after the SHIFT
set BUFFER_MINX=%6
set BUFFER_MINY=%7
set BUFFER_MAXX=%8
set BUFFER_MAXY=%9

set BUFFEREDEXTENT=%6,%7,%8,%9

REM ------------------------------------------------------
REM After the 4 SHIFT commands, variables %6, %7, %8, %9 contain the following values:

REM    %6     Name of the text file containing a list of all data files
REM    %7     Buffer size
REM    %8     Width of the unbuffered analysis tile
REM    %9     Height of the unbuffered analysis tile

REM SHIFT command moves command line parameters one position. For example, %10 moves to %9.
REM This is necessary because DOS cannot directly reference more than 9 command line parameters
REM since %10 would be interpreted as %1.

REM Shift last four variables (%10-%14) into positions %6-%9
SHIFT /6
SHIFT /6
SHIFT /6
SHIFT /6

REM Insert commands that use the buffer width and all data files after the block of SHIFT commands

REM set the command line options for CanopyModel
SET CM_OPTIONS=/gridxy:%BUFFEREDEXTENT% "/ground:%DTMSPEC%" /outlier:%OUTLIER% %CLASSOPTION%

REM do canopy surface and GridSurfaceStats
IF /I [%DOCANOPY%]==[true] (
	CanopyModel %CM_OPTIONS% "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\%1_filled_not_smoothed_%CANOPYFILEIDENTIFIER%.dtm" %CANOPYCELLSIZE% %COORDINFO% %6

	rem compute grid surface stats and clip these to the unbuffered tile extent
	gridsurfacestats /halfcell "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\%1_filled_not_smoothed_%CANOPYFILEIDENTIFIER%.dtm" "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_%CANOPYSTATSFILEIDENTIFIER%" %CANOPYSTATSCELLMULTIPLIER%
	clipdtm "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_%CANOPYSTATSFILEIDENTIFIER%_surface_area_ratio.dtm" "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_rumple_%CANOPYSTATSFILEIDENTIFIER%.dtm" %2 %3 %4 %5
	clipdtm "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_%CANOPYSTATSFILEIDENTIFIER%_surface_volume_ratio.dtm" "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_FPV_%CANOPYSTATSFILEIDENTIFIER%.dtm" %2 %3 %4 %5
	clipdtm "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_%CANOPYSTATSFILEIDENTIFIER%_stddev_height.dtm" "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_sd_height_%CANOPYSTATSFILEIDENTIFIER%.dtm" %2 %3 %4 %5
	clipdtm "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_%CANOPYSTATSFILEIDENTIFIER%_mean_height.dtm" "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_average_height_%CANOPYSTATSFILEIDENTIFIER%.dtm" %2 %3 %4 %5
	clipdtm "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_%CANOPYSTATSFILEIDENTIFIER%_max_height.dtm" "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_maximum_height_%CANOPYSTATSFILEIDENTIFIER%.dtm" %2 %3 %4 %5

	rem clip canopy surface models back by 1 analysis cell to remove problems around the edges related to smoothing
	rem rename the target CSM to a temp name, clip the temp file and name the output using the original target CSM, delete the temp file
	ren "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\%1_filled_not_smoothed_%CANOPYFILEIDENTIFIER%.dtm" "CSM_temp.dtm"
	clipdtm /shrink "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CSM_temp.dtm" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\%1_filled_not_smoothed_%CANOPYFILEIDENTIFIER%.dtm" %CELLSIZE% %CELLSIZE% %CELLSIZE% %CELLSIZE%
	del "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CSM_temp.dtm"

	rem delete the grid surface stat outputs that have a buffer around them
	del "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_%CANOPYSTATSFILEIDENTIFIER%_surface_area_ratio.dtm"
	del "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_%CANOPYSTATSFILEIDENTIFIER%_surface_volume_ratio.dtm"
	del "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_%CANOPYSTATSFILEIDENTIFIER%_stddev_height.dtm"
	del "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_%CANOPYSTATSFILEIDENTIFIER%_mean_height.dtm"
	del "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_%CANOPYSTATSFILEIDENTIFIER%_max_height.dtm"
	del "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_%CANOPYSTATSFILEIDENTIFIER%_surface_volume.dtm"
	del "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_%CANOPYSTATSFILEIDENTIFIER%_potential_volume.dtm"
)
