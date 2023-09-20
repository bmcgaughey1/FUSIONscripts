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
rem 7/13/2017 modified logic when doing mortality products to delete the intensity percentile output files.
rem 8/14/2017 modified logic to add point clips for TreeSeg crown polygons
rem 7/10/2019 modified logic to allow runs with only first return metrics
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

REM If doing bare ground filtering and surface creation, do it before any other tile processing.
REM Goal is to produce a ground surface model that will cover the buffered extent...needed to keep the edges of canopy models
REM and metrics cleaner. The *_TRIMMED.dtm surfaces are used to merge surfaces after all tile processing is complete.
if /I [%DOGROUND%]==[true] (
	IF /I [%FILTERPOINTS%]==[true] (
		GroundFilter %CLASSOPTION% /extent:%BUFFEREDEXTENT% "%PRODUCTHOME%\BareGround_%GROUNDFILEIDENTIFIER%\%1_BE_pts.las" %FILTERCELLSIZE% %6
		GridSurfaceCreate /gridxy:%BUFFEREDEXTENT% "%PRODUCTHOME%\BareGround_%GROUNDFILEIDENTIFIER%\%1_BE_%GROUNDFILEIDENTIFIER%_BUFFERED.dtm" %GROUNDCELLSIZE% %COORDINFO% "%PRODUCTHOME%\BareGround_%GROUNDFILEIDENTIFIER%\%1_BE_pts.las"
	) ELSE (
		GridSurfaceCreate /class:2 /gridxy:%BUFFEREDEXTENT% "%PRODUCTHOME%\BareGround_%GROUNDFILEIDENTIFIER%\%1_BE_%GROUNDFILEIDENTIFIER%_BUFFERED.dtm" %GROUNDCELLSIZE% %COORDINFO% %6
	)
	ClipDtm "%PRODUCTHOME%\BareGround_%GROUNDFILEIDENTIFIER%\%1_BE_%GROUNDFILEIDENTIFIER%_BUFFERED.dtm" "%PRODUCTHOME%\BareGround_%GROUNDFILEIDENTIFIER%\%1_BE_%GROUNDFILEIDENTIFIER%_TRIMMED.dtm" %2 %3 %4 %5
)

REM set the command line options for CanopyModel
SET CM_OPTIONS=/gridxy:%BUFFEREDEXTENT% "/ground:%DTMSPEC%" /outlier:%OUTLIER% %CLASSOPTION%

REM do canopy surface and GridSurfaceStats
IF /I [%DOCANOPY%]==[true] (
	CanopyModel %CM_OPTIONS% "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\%1_filled_not_smoothed_%CANOPYFILEIDENTIFIER%.dtm" %CANOPYCELLSIZE% %COORDINFO% %6
	CanopyModel /smooth:3 %CM_OPTIONS% "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\%1_filled_3x_smoothed_%CANOPYFILEIDENTIFIER%.dtm" %CANOPYCELLSIZE% %COORDINFO% %6
	IF /I [%DOSPECIALCANOPY%]==[true] (
		CanopyModel /pointcount %CM_OPTIONS% "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\%1_not_smoothed_%CANOPYFILEIDENTIFIER%.dtm" %CANOPYCELLSIZE% %COORDINFO% %6
		CanopyModel /gridxy:%BUFFEREDEXTENT% "/ground:%DTMSPEC%" /outlier:-25,%COVERCUTOFF% "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\%1_ltCoverCutoff_%CANOPYFILEIDENTIFIER%.dtm" %CANOPYCELLSIZE% %COORDINFO% %6
		CanopyModel /gridxy:%BUFFEREDEXTENT% "/ground:%DTMSPEC%" /outlier:-25,0.25 "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\%1_lt0p25m_%CANOPYFILEIDENTIFIER%.dtm" %CANOPYCELLSIZE% %COORDINFO% %6

		rem create the lower resolution canopy height models
		CanopyModel %CM_OPTIONS% "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%\%1_filled_not_smoothed_%CANOPYFILEIDENTIFIER1%.dtm" %CANOPYCELLSIZE1% %COORDINFO% %6
		CanopyModel /smooth:3 %CM_OPTIONS% "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%\%1_filled_3x_smoothed_%CANOPYFILEIDENTIFIER1%.dtm" %CANOPYCELLSIZE1% %COORDINFO% %6
		CanopyModel %CM_OPTIONS% "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%\%1_filled_not_smoothed_%CANOPYFILEIDENTIFIER2%.dtm" %CANOPYCELLSIZE2% %COORDINFO% %6
		CanopyModel /smooth:3 %CM_OPTIONS% "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%\%1_filled_3x_smoothed_%CANOPYFILEIDENTIFIER2%.dtm" %CANOPYCELLSIZE2% %COORDINFO% %6
	)

	rem compute grid surface stats and clip these to the unbuffered tile extent
REM	gridsurfacestats /halfcell "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\%1_filled_3x_smoothed_%CANOPYFILEIDENTIFIER%.dtm" "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_%CANOPYSTATSFILEIDENTIFIER%" %CANOPYSTATSCELLMULTIPLIER%
	gridsurfacestats "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\%1_filled_3x_smoothed_%CANOPYFILEIDENTIFIER%.dtm" "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_%CANOPYSTATSFILEIDENTIFIER%" %CANOPYSTATSCELLMULTIPLIER%
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

	ren "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\%1_filled_3x_smoothed_%CANOPYFILEIDENTIFIER%.dtm" "CSM_temp.dtm"
	clipdtm /shrink "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CSM_temp.dtm" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\%1_filled_3x_smoothed_%CANOPYFILEIDENTIFIER%.dtm" %CELLSIZE% %CELLSIZE% %CELLSIZE% %CELLSIZE%
	del "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CSM_temp.dtm"

	IF /I [%DOSPECIALCANOPY%]==[true] (
		rem return counts associated with CHM
		ren "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\%1_not_smoothed_%CANOPYFILEIDENTIFIER%_return_count.dtm" "CSM_temp.dtm"
		clipdtm /shrink "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CSM_temp.dtm" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\%1_not_smoothed_%CANOPYFILEIDENTIFIER%_return_count.dtm" %CELLSIZE% %CELLSIZE% %CELLSIZE% %CELLSIZE%
		del "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CSM_temp.dtm"

		ren "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\%1_not_smoothed_%CANOPYFILEIDENTIFIER%.dtm" "CSM_temp.dtm"
		clipdtm /shrink "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CSM_temp.dtm" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\%1_not_smoothed_%CANOPYFILEIDENTIFIER%.dtm" %CELLSIZE% %CELLSIZE% %CELLSIZE% %CELLSIZE%
		del "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CSM_temp.dtm"

		ren "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\%1_ltCoverCutoff_%CANOPYFILEIDENTIFIER%.dtm" "CSM_temp.dtm"
		clipdtm /shrink "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CSM_temp.dtm" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\%1_ltCoverCutoff_%CANOPYFILEIDENTIFIER%.dtm" %CELLSIZE% %CELLSIZE% %CELLSIZE% %CELLSIZE%
		del "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CSM_temp.dtm"

		ren "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\%1_lt0p25m_%CANOPYFILEIDENTIFIER%.dtm" "CSM_temp.dtm"
		clipdtm /shrink "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CSM_temp.dtm" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\%1_lt0p25m_%CANOPYFILEIDENTIFIER%.dtm" %CELLSIZE% %CELLSIZE% %CELLSIZE% %CELLSIZE%
		del "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CSM_temp.dtm"

		rem clip the lower resolution canopy height models to remove the buffered area
		ren "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%\%1_filled_not_smoothed_%CANOPYFILEIDENTIFIER1%.dtm" "CSM_temp.dtm"
		clipdtm /shrink "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%\CSM_temp.dtm" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%\%1_filled_not_smoothed_%CANOPYFILEIDENTIFIER1%.dtm" %CELLSIZE% %CELLSIZE% %CELLSIZE% %CELLSIZE%
		del "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%\CSM_temp.dtm"

		ren "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%\%1_filled_3x_smoothed_%CANOPYFILEIDENTIFIER1%.dtm" "CSM_temp.dtm"
		clipdtm /shrink "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%\CSM_temp.dtm" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%\%1_filled_3x_smoothed_%CANOPYFILEIDENTIFIER1%.dtm" %CELLSIZE% %CELLSIZE% %CELLSIZE% %CELLSIZE%
		del "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%\CSM_temp.dtm"

		ren "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%\%1_filled_not_smoothed_%CANOPYFILEIDENTIFIER2%.dtm" "CSM_temp.dtm"
		clipdtm /shrink "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%\CSM_temp.dtm" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%\%1_filled_not_smoothed_%CANOPYFILEIDENTIFIER2%.dtm" %CELLSIZE% %CELLSIZE% %CELLSIZE% %CELLSIZE%
		del "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%\CSM_temp.dtm"

		ren "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%\%1_filled_3x_smoothed_%CANOPYFILEIDENTIFIER2%.dtm" "CSM_temp.dtm"
		clipdtm /shrink "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%\CSM_temp.dtm" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%\%1_filled_3x_smoothed_%CANOPYFILEIDENTIFIER2%.dtm" %CELLSIZE% %CELLSIZE% %CELLSIZE% %CELLSIZE%
		del "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%\CSM_temp.dtm"
	)

	rem delete the grid surface stat outputs that have a buffer around them
	del "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_%CANOPYSTATSFILEIDENTIFIER%_surface_area_ratio.dtm"
	del "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_%CANOPYSTATSFILEIDENTIFIER%_surface_volume_ratio.dtm"
	del "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_%CANOPYSTATSFILEIDENTIFIER%_stddev_height.dtm"
rem	del "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_%CANOPYSTATSFILEIDENTIFIER%_mean_height.dtm"
	del "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_%CANOPYSTATSFILEIDENTIFIER%_max_height.dtm"
	del "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_%CANOPYSTATSFILEIDENTIFIER%_surface_volume.dtm"
	del "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_%CANOPYSTATSFILEIDENTIFIER%_potential_volume.dtm"
)

rem enable delayed expansion for environment variables...this lets us redefine the same variable in a loop or if stmt since the loop or if stmt is read as 
rem a single command by the command interpreter
setlocal ENABLEDELAYEDEXPANSION

rem run treeseg for tiles using filled_not_smoothed and the full buffered area and output everything
rem RJM: I don't know what the code is that references the BLOCKNAME. I think we always have a blockname when running scripts generated by AreaProcessor
rem The way the code reads, if there is no BLOCKNAME defined, the file names would start with "_"...doesn't make any sense but I'm afraid to change it.
SET CLIP_OPTIONS="/clipfolder:%PRODUCTHOME%\SegmentClips\" "/points:%~6" /ptheight "/ground:%DTMSPEC%"

IF /I [%DOSEGMENTS%]==[true] (
	CanopyModel /verbose %SEG_CHM_OPTIONS% %CM_OPTIONS% "%PRODUCTHOME%\CanopyHeight_%SEG_CANOPYFILEIDENTIFIER%\%1_TreeSeg_CHM_%SEG_CANOPYFILEIDENTIFIER%.dtm" %SEG_CANOPYCELLSIZE% %COORDINFO% %6

	rem 8/14/2017
	rem set CL options for segment clips
	IF /I NOT [%DOSEGMETRICS%]==[true] (
		SET CLIP_OPTIONS=
	)

	rem 8/14/2017 added CLIP_OPTIONS to command line for TreeSeg
	if "%BLOCKNAME%"=="" (
		TreeSeg !CLIP_OPTIONS! "/projection:%BASEPRJ%" /verbose /shape /htmultiplier:%MULTIPLIER% "%PRODUCTHOME%\CanopyHeight_%SEG_CANOPYFILEIDENTIFIER%\%1_TreeSeg_CHM_%SEG_CANOPYFILEIDENTIFIER%.dtm" %SEG_HTCUTOFF% "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%\%BLOCKNAME%_%1_segments.csv"
		CALL "%PROCESSINGHOME%\convert2img" "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%\%BLOCKNAME%_%1_segments_Basin_Map.asc" "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%"
		CALL "%PROCESSINGHOME%\convert2img" "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%\%BLOCKNAME%_%1_segments_Max_Height_Map.asc" "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%"
	) else (
		TreeSeg !CLIP_OPTIONS! "/projection:%BASEPRJ%" /verbose /shape /htmultiplier:%MULTIPLIER% "%PRODUCTHOME%\CanopyHeight_%SEG_CANOPYFILEIDENTIFIER%\%1_TreeSeg_CHM_%SEG_CANOPYFILEIDENTIFIER%.dtm" %SEG_HTCUTOFF% "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%\%1_segments.csv"
		CALL "%PROCESSINGHOME%\convert2img" "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%\%1_segments_Basin_Map.asc" "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%"
		CALL "%PROCESSINGHOME%\convert2img" "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%\%1_segments_Max_Height_Map.asc" "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%"
	)

	SET CLIP_OPTIONS=

	rem 8/14/2017
	rem clip canopy surface models used for the segmentation back by 1 analysis cell to remove problems around the edges
	rem rename the target CSM to a temp name, clip the temp file and name the output using the original target CSM, delete the temp file
	ren "%PRODUCTHOME%\CanopyHeight_%SEG_CANOPYFILEIDENTIFIER%\%1_TreeSeg_CHM_%SEG_CANOPYFILEIDENTIFIER%.dtm" "CSM_temp.dtm"
	clipdtm /shrink "%PRODUCTHOME%\CanopyHeight_%SEG_CANOPYFILEIDENTIFIER%\CSM_temp.dtm" "%PRODUCTHOME%\CanopyHeight_%SEG_CANOPYFILEIDENTIFIER%\%1_TreeSeg_CHM_%SEG_CANOPYFILEIDENTIFIER%.dtm" %CELLSIZE% %CELLSIZE% %CELLSIZE% %CELLSIZE%
	del "%PRODUCTHOME%\CanopyHeight_%SEG_CANOPYFILEIDENTIFIER%\CSM_temp.dtm"
)

rem MORTALITY---------------------------------------------------------
rem run intensity-related processing and metrics to correspond to the segments

set CLOUD_OPTIONS=/rid /new /quiet /minht:%HTCUTOFF% /above:%COVERCUTOFF% /outlier:%OUTLIER%

IF /I [%DOSEGMENTS%]==[true] (
	IF /I [%DOMORTALITY%]==[true] (
		IF /I [%DOSEGMETRICS%]==[true] (
			rem 8/14/2017 process the segment point clips
			if /I [%DOSTRATA%]==[true] SET CLOUD_OPTIONS=!CLOUD_OPTIONS! /strata:%STRATAHEIGHTS%

			if "%BLOCKNAME%"=="" (
				cloudmetrics !CLOUD_OPTIONS! "%PRODUCTHOME%\SegmentClips\*.lda" "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%\%BLOCKNAME%_%1_clipmetrics.csv"

				rem merge the metrics with the polygon attributes
				JoinDB "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%\%BLOCKNAME%_%1_segments_Polygons.csv" 1 "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%\%BLOCKNAME%_%1_clipmetrics.csv" 1 4 "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%\%BLOCKNAME%_%1_segments_Polygon_metrics.csv"

				rem clean up segment metrics
				del "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%\%BLOCKNAME%_%1_clipmetrics.csv"

				rem do metrics using only first returns
				cloudmetrics !CLOUD_OPTIONS! /first "%PRODUCTHOME%\SegmentClips\*.lda" "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%\%BLOCKNAME%_%1_clipmetrics.csv"

				rem merge the metrics with the polygon attributes
				JoinDB "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%\%BLOCKNAME%_%1_segments_Polygons.csv" 1 "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%\%BLOCKNAME%_%1_clipmetrics.csv" 1 4 "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%\%BLOCKNAME%_%1_segments_Polygon_first_metrics.csv"

				rem clean up segment metrics
				del "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%\%BLOCKNAME%_%1_clipmetrics.csv"
			) else (
				cloudmetrics !CLOUD_OPTIONS! "%PRODUCTHOME%\SegmentClips\*.lda" "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%\%1_clipmetrics.csv"

				rem merge the metrics with the polygon attributes
				JoinDB "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%\%1_segments_Polygons.csv" 1 "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%\%1_clipmetrics.csv" 1 4 "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%\%1_segments_Polygon_metrics.csv"

				rem clean up segment metrics
				del "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%\%1_clipmetrics.csv"

				rem do metrics using only first returns
				cloudmetrics !CLOUD_OPTIONS! /first "%PRODUCTHOME%\SegmentClips\*.lda" "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%\%1_clipmetrics.csv"

				rem merge the metrics with the polygon attributes
				JoinDB "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%\%1_segments_Polygons.csv" 1 "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%\%1_clipmetrics.csv" 1 4 "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%\%1_segments_Polygon_first_metrics.csv"

				rem clean up segment metrics
				del "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%\%1_clipmetrics.csv"
			)

			rem delete segment point clips
			del "%PRODUCTHOME%\SegmentClips\*.lda"
		)

		rem reclip the current tile to get the points above 2m...need to use the ground models. I have added the /height option but we don't really need it. This should make it harder
		rem to confuse the clip with "normal" data.
		ClipData /verbose "/ground:%DTMSPEC%" /height /zmin:%SEG_HTCUTOFF% %CLASSOPTION% "%WORKINGDIRNAME%\%1.las" "%WORKINGDIRNAME%\%1_GE_2m.las" %BUFFER_MINX% %BUFFER_MINY% %BUFFER_MAXX% %BUFFER_MAXY%
			rem run ReturnDensity on the original clipped tile...need /class option (if used)
		ReturnDensity /ascii %CLASSOPTION% "%WORKINGDIRNAME%\%1_segments_all_count.dtm" %SEG_CANOPYCELLSIZE% "%WORKINGDIRNAME%\%1.las"
		rem copy base projection info
		if NOT "%BASEPRJ%"=="" (
			copy "%BASEPRJ%" "%WORKINGDIRNAME%\%1_segments_all_count.prj"
		)
		CALL "%PROCESSINGHOME%\convert2img" "%WORKINGDIRNAME%\%1_segments_all_count.asc" "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%"

		rem run ReturnDensity on the clipped tile with points > 2m...don't need /class option since we used it when clipping the points
		ReturnDensity /ascii "%WORKINGDIRNAME%\%1_segments_GE_2m_count.dtm" %SEG_CANOPYCELLSIZE% "%WORKINGDIRNAME%\%1_GE_2m.las"
		rem copy base projection info
		if NOT "%BASEPRJ%"=="" (
			copy "%BASEPRJ%" "%WORKINGDIRNAME%\%1_segments_GE_2m_count.prj"
		)
		CALL "%PROCESSINGHOME%\convert2img" "%WORKINGDIRNAME%\%1_segments_GE_2m_count.asc" "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%"

		rem run IntensityImage using all points...need /class option (if used)
		IntensityImage /rasterorigin "/projection:%BASEPRJ%" /intrange:%INTENSITYRANGE% /void:0,0,0 %CLASSOPTION% %SEG_CANOPYCELLSIZE% "%WORKINGDIRNAME%\%1_segments_INT_GE_2m_%SEG_CANOPYFILEIDENTIFIER%.bmp" "%WORKINGDIRNAME%\%1_GE_2m.las"
		CALL "%PROCESSINGHOME%\convertGS2img" "%WORKINGDIRNAME%\%1_segments_INT_GE_2m_%SEG_CANOPYFILEIDENTIFIER%.bmp" "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%"

		rem run IntensityImage using the points > 2m...don't need /class option since we used it when clipping the points
		IntensityImage /rasterorigin "/projection:%BASEPRJ%" /intrange:%INTENSITYRANGE% /void:0,0,0 %SEG_CANOPYCELLSIZE% "%WORKINGDIRNAME%\%1_segments_INT_allpts_%SEG_CANOPYFILEIDENTIFIER%.bmp" "%WORKINGDIRNAME%\%1.las"
		CALL "%PROCESSINGHOME%\convertGS2img" "%WORKINGDIRNAME%\%1_segments_INT_allpts_%SEG_CANOPYFILEIDENTIFIER%.bmp" "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%"

		rem clean up...delete the clipped point tile and world files for the intensity images
		del "%WORKINGDIRNAME%\%1_GE_2m.las"
		if /I NOT "%KEEPASCIIFILES%"=="true" (
			del "%WORKINGDIRNAME%\%1_segments_INT_GE_2m_%SEG_CANOPYFILEIDENTIFIER%.bmpw"
			del "%WORKINGDIRNAME%\%1_segments_INT_allpts_%SEG_CANOPYFILEIDENTIFIER%.bmpw"
		)
		del "%WORKINGDIRNAME%\%1_segments_all_count_IntensityPercentiles.csv"
		del "%WORKINGDIRNAME%\%1_segments_GE_2m_count_IntensityPercentiles.csv"
	)
)

REM set the command line options for GridMetrics
SET GM_OPTIONS=/verbose /minht:%HTCUTOFF% /buffer:%7 /outlier:%OUTLIER% %CLASSOPTION%

if /I [%CANOPYALIGNTORUMPLE%]==[true] (
	SET GM_OPTIONS=%GM_OPTIONS% "/align:%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_rumple_%CANOPYSTATSFILEIDENTIFIER%.dtm"
) ELSE (
	SET GM_OPTIONS=%GM_OPTIONS% /gridxy:%2,%3,%4,%5 
)
if /I [%OMITINTENSITY%]==[true] SET GM_OPTIONS=%GM_OPTIONS% /nointensity
if /I [%DOSTRATA%]==[true] SET GM_OPTIONS=%GM_OPTIONS% /strata:%STRATAHEIGHTS%
if /I [%DOTOPO%]==[true] SET GM_OPTIONS=%GM_OPTIONS% /topo:%TOPOCELLSIZE%,%LATITUDE%

IF /I [%DOMETRICS%]==[true] (
	gridmetrics %GM_OPTIONS% "%DTMSPEC%" %COVERCUTOFF% %CELLSIZE% "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_metrics.csv" %6
)

IF /I [%DOFIRSTMETRICS%]==[true] (
	rem get intensity metrics for first returns...ignore strata, topo, omitintensity	
	SET GM_OPTIONS=/verbose /first /minht:%HTCUTOFF% /buffer:%7 /outlier:%OUTLIER% %CLASSOPTION%

	if /I [%CANOPYALIGNTORUMPLE%]==[true] (
		SET GM_OPTIONS=!GM_OPTIONS! "/align:%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_rumple_%CANOPYSTATSFILEIDENTIFIER%.dtm"
	) ELSE (
		SET GM_OPTIONS=!GM_OPTIONS! /gridxy:%2,%3,%4,%5 
	)
	if /I [%DOFIRSTSTRATA%]==[true] SET GM_OPTIONS=!GM_OPTIONS! /strata:%STRATAHEIGHTS%
	gridmetrics !GM_OPTIONS! "%DTMSPEC%" %COVERCUTOFF% %CELLSIZE% "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%1_metrics.csv" %6
)

endlocal
