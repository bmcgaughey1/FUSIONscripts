rem posttile.bat
rem 7-24-2015
rem Original name was buildlayers.bat...changed to better reflect what the script does
rem 10/29/2015 added /nofill when merging canopy surfaces and canopy surface metrics. This makes for cleaner outputs because the hole filling logic
rem will add data to areas with NODATA values.
rem 3/8/2016 changed the naming of canopy surface metrics to put the resolution last in the file name. The 
rem resolution was previously in the middle of the name and this was inconsistent with most other products. Also changed the name on the "normal" TPI metrics
rem so it uses "topo_tpi" instead of "tpi_tpi". The fine TPI layers were named correctly. Also change the naming of the topo metrics to move the
rem window size to a position just before the resolution.
rem 5/3/2016 moved coarse resolution CHMs into IF stmt so they are only merged when DOSPECIALCANOPY is true
rem 1/12/2017 added commands to move and convert special canopy model outputs. The original script missed some of the outputs
rem 7/10/2019 modified logic to allow runs to produce only first return metrics
rem 9/22/2020 added raster output layer for ground point count using class 2 points.
rem
rem extract metrics from CSV files and merge into a single coverage
rem batch runs from processing folder for each area
rem %FILEIDENTIFIER% is the cell size identifier added to each file name
rem %CANOPYFILEIDENTIFIER% is the cell size identifier added to each file name for canopy surface models
rem %GROUNDFILEIDENTIFIER% is the cell size identifier added to each file name for ground surface models

rem build the strings used to label layers
set MINHTLABEL=%HTCUTOFF:.=p%
set COVERHTLABEL=%COVERCUTOFF:.=p%

rem merge bare ground surfaces and convert to ASCII raster
rem The _BUFFERED surface tiles will probably have edge artifacts when merged. However, they are great for computing tile metrics.
IF /I [%DOGROUND%]==[true] (
REM	mergedtm /exactextent "%PRODUCTHOME%\BareGround_%GROUNDFILEIDENTIFIER%\BE_%GROUNDFILEIDENTIFIER%_BUFFERED.dtm" "%PRODUCTHOME%\BareGround_%GROUNDFILEIDENTIFIER%\*BE_%GROUNDFILEIDENTIFIER%_BUFFERED.dtm"
	mergedtm /exactextent "%PRODUCTHOME%\BareGround_%GROUNDFILEIDENTIFIER%\BE_%GROUNDFILEIDENTIFIER%_TRIMMED.dtm" "%PRODUCTHOME%\BareGround_%GROUNDFILEIDENTIFIER%\*BE_%GROUNDFILEIDENTIFIER%_TRIMMED.dtm"

REM	dtm2ascii "%PRODUCTHOME%\BareGround_%GROUNDFILEIDENTIFIER%\BE_%GROUNDFILEIDENTIFIER%_BUFFERED.dtm"
REM	rem copy base projection info
REM	if NOT "%BASEPRJ%"=="" (
REM		copy "%BASEPRJ%" "%PRODUCTHOME%\BareGround_%GROUNDFILEIDENTIFIER%\BE_%GROUNDFILEIDENTIFIER%_BUFFERED.prj"
REM	)

	dtm2ascii "%PRODUCTHOME%\BareGround_%GROUNDFILEIDENTIFIER%\BE_%GROUNDFILEIDENTIFIER%_TRIMMED.dtm"
	rem copy base projection info
	if NOT "%BASEPRJ%"=="" (
		copy "%BASEPRJ%" "%PRODUCTHOME%\BareGround_%GROUNDFILEIDENTIFIER%\BE_%GROUNDFILEIDENTIFIER%_TRIMMED.prj"
	)

	rem if we are not merging final outputs and we are working on a block, move the outputs. Can't move and rename in one command so we move first then rename the file
	if /I NOT "%MERGEBLOCKGROUND%"=="true" (
		if NOT "%BLOCKNAME%"=="" (
			call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\BareGround_%GROUNDFILEIDENTIFIER%" "BE_%GROUNDFILEIDENTIFIER%_TRIMMED.dtm" "%FINALPRODUCTHOME%\BareGround_%GROUNDFILEIDENTIFIER%" "%BLOCKNAME%_BE_%GROUNDFILEIDENTIFIER%_TRIMMED.dtm"
			call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\BareGround_%GROUNDFILEIDENTIFIER%" "BE_%GROUNDFILEIDENTIFIER%_TRIMMED.asc" "%FINALPRODUCTHOME%\BareGround_%GROUNDFILEIDENTIFIER%" "%BLOCKNAME%_BE_%GROUNDFILEIDENTIFIER%_TRIMMED.asc"
			call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\BareGround_%GROUNDFILEIDENTIFIER%" "BE_%GROUNDFILEIDENTIFIER%_TRIMMED.prj" "%FINALPRODUCTHOME%\BareGround_%GROUNDFILEIDENTIFIER%" "%BLOCKNAME%_BE_%GROUNDFILEIDENTIFIER%_TRIMMED.prj"

			CALL "%PROCESSINGHOME%\convert2img" "%FINALPRODUCTHOME%\BareGround_%GROUNDFILEIDENTIFIER%\%BLOCKNAME%_BE_%GROUNDFILEIDENTIFIER%_TRIMMED.asc" "%FINALPRODUCTHOME%\BareGround_%GROUNDFILEIDENTIFIER%"
		)
	)
)

rem Deal with canopy surfaces and stats
IF /I [%DOCANOPY%]==[true] (
	rem merge canopy surface stats
	mergedtm /exactextent /nofill "%PRODUCTHOME%\CanopyMetrics_%CANOPYSTATSFILEIDENTIFIER%\canopy_rumple_%CANOPYSTATSFILEIDENTIFIER%.dtm" "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\*_rumple_%CANOPYSTATSFILEIDENTIFIER%.dtm"
	mergedtm /exactextent /nofill "%PRODUCTHOME%\CanopyMetrics_%CANOPYSTATSFILEIDENTIFIER%\canopy_FPV_%CANOPYSTATSFILEIDENTIFIER%.dtm" "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\*_FPV_%CANOPYSTATSFILEIDENTIFIER%.dtm"
	mergedtm /exactextent /nofill "%PRODUCTHOME%\CanopyMetrics_%CANOPYSTATSFILEIDENTIFIER%\canopy_stddev_height_%CANOPYSTATSFILEIDENTIFIER%.dtm" "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\*_sd_height_%CANOPYSTATSFILEIDENTIFIER%.dtm"
	mergedtm /exactextent /nofill "%PRODUCTHOME%\CanopyMetrics_%CANOPYSTATSFILEIDENTIFIER%\canopy_average_height_%CANOPYSTATSFILEIDENTIFIER%.dtm" "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\*_average_height_%CANOPYSTATSFILEIDENTIFIER%.dtm"
	mergedtm /exactextent /nofill "%PRODUCTHOME%\CanopyMetrics_%CANOPYSTATSFILEIDENTIFIER%\canopy_maximum_height_%CANOPYSTATSFILEIDENTIFIER%.dtm" "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\*_maximum_height_%CANOPYSTATSFILEIDENTIFIER%.dtm"

	rem convert to ASCII raster format...need /raster option
	dtm2ascii /raster "%PRODUCTHOME%\CanopyMetrics_%CANOPYSTATSFILEIDENTIFIER%\canopy_rumple_%CANOPYSTATSFILEIDENTIFIER%.dtm"
	dtm2ascii /raster "%PRODUCTHOME%\CanopyMetrics_%CANOPYSTATSFILEIDENTIFIER%\canopy_FPV_%CANOPYSTATSFILEIDENTIFIER%.dtm"
	dtm2ascii /multiplier:%MULTIPLIER% /raster "%PRODUCTHOME%\CanopyMetrics_%CANOPYSTATSFILEIDENTIFIER%\canopy_stddev_height_%CANOPYSTATSFILEIDENTIFIER%.dtm"
	dtm2ascii /multiplier:%MULTIPLIER% /raster "%PRODUCTHOME%\CanopyMetrics_%CANOPYSTATSFILEIDENTIFIER%\canopy_average_height_%CANOPYSTATSFILEIDENTIFIER%.dtm"
	dtm2ascii /multiplier:%MULTIPLIER% /raster "%PRODUCTHOME%\CanopyMetrics_%CANOPYSTATSFILEIDENTIFIER%\canopy_maximum_height_%CANOPYSTATSFILEIDENTIFIER%.dtm"

	rem merge canopy height models
	mergedtm /exactextent /nofill "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER%.dtm" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\*filled_3x_smoothed_%CANOPYFILEIDENTIFIER%.dtm"
	mergedtm /exactextent /nofill "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER%.dtm" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\*filled_not_smoothed_%CANOPYFILEIDENTIFIER%.dtm"
	IF /I [%DOSPECIALCANOPY%]==[true] (
		mergedtm /exactextent /nofill "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CHM_not_smoothed_%CANOPYFILEIDENTIFIER%_return_count.dtm" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\*not_smoothed_%CANOPYFILEIDENTIFIER%_return_count.dtm"
		mergedtm /exactextent /nofill "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CHM_not_smoothed_%CANOPYFILEIDENTIFIER%.dtm" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\*not_smoothed_%CANOPYFILEIDENTIFIER%.dtm"
		mergedtm /exactextent /nofill "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CHM_ltCoverCutoff_%CANOPYFILEIDENTIFIER%.dtm" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\*ltCoverCutoff_%CANOPYFILEIDENTIFIER%.dtm"
		mergedtm /exactextent /nofill "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CHM_lt0p25m_%CANOPYFILEIDENTIFIER%.dtm" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\*lt0p25m_%CANOPYFILEIDENTIFIER%.dtm"

		rem merge lower resolution canopy height models
		mergedtm /exactextent /nofill "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%\CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER1%.dtm" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%\*filled_3x_smoothed_%CANOPYFILEIDENTIFIER1%.dtm"
		mergedtm /exactextent /nofill "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%\CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER1%.dtm" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%\*filled_not_smoothed_%CANOPYFILEIDENTIFIER1%.dtm"
		mergedtm /exactextent /nofill "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%\CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER2%.dtm" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%\*filled_3x_smoothed_%CANOPYFILEIDENTIFIER2%.dtm"
		mergedtm /exactextent /nofill "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%\CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER2%.dtm" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%\*filled_not_smoothed_%CANOPYFILEIDENTIFIER2%.dtm"
	)

	rem convert to ASCII raster format...don't need raster option
	dtm2ascii /multiplier:%MULTIPLIER% "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER%.dtm"
	dtm2ascii /multiplier:%MULTIPLIER% "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER%.dtm"
	IF /I [%DOSPECIALCANOPY%]==[true] (
		dtm2ascii /multiplier:%MULTIPLIER% "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CHM_not_smoothed_%CANOPYFILEIDENTIFIER%_return_count.dtm"
		dtm2ascii /multiplier:%MULTIPLIER% "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CHM_not_smoothed_%CANOPYFILEIDENTIFIER%.dtm"
		dtm2ascii /multiplier:%MULTIPLIER% "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CHM_ltCoverCutoff_%CANOPYFILEIDENTIFIER%.dtm"
		dtm2ascii /multiplier:%MULTIPLIER% "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CHM_lt0p25m_%CANOPYFILEIDENTIFIER%.dtm"

		rem convert lower resolution canopy height models
		dtm2ascii /multiplier:%MULTIPLIER% "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%\CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER1%.dtm"
		dtm2ascii /multiplier:%MULTIPLIER% "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%\CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER1%.dtm"
		dtm2ascii /multiplier:%MULTIPLIER% "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%\CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER2%.dtm"
		dtm2ascii /multiplier:%MULTIPLIER% "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%\CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER2%.dtm"
	)

	rem copy base projection info
	if NOT "%BASEPRJ%"=="" (
		copy "%BASEPRJ%" "%PRODUCTHOME%\CanopyMetrics_%CANOPYSTATSFILEIDENTIFIER%\canopy_rumple_%CANOPYSTATSFILEIDENTIFIER%.prj"
		copy "%BASEPRJ%" "%PRODUCTHOME%\CanopyMetrics_%CANOPYSTATSFILEIDENTIFIER%\canopy_FPV_%CANOPYSTATSFILEIDENTIFIER%.prj"
		copy "%BASEPRJ%" "%PRODUCTHOME%\CanopyMetrics_%CANOPYSTATSFILEIDENTIFIER%\canopy_stddev_height_%CANOPYSTATSFILEIDENTIFIER%.prj"
		copy "%BASEPRJ%" "%PRODUCTHOME%\CanopyMetrics_%CANOPYSTATSFILEIDENTIFIER%\canopy_average_height_%CANOPYSTATSFILEIDENTIFIER%.prj"
		copy "%BASEPRJ%" "%PRODUCTHOME%\CanopyMetrics_%CANOPYSTATSFILEIDENTIFIER%\canopy_maximum_height_%CANOPYSTATSFILEIDENTIFIER%.prj"
		copy "%BASEPRJ%" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER%.prj"
		copy "%BASEPRJ%" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER%.prj"
		IF /I [%DOSPECIALCANOPY%]==[true] (
			copy "%BASEPRJ%" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CHM_not_smoothed_%CANOPYFILEIDENTIFIER%_return_count.prj"
			copy "%BASEPRJ%" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CHM_not_smoothed_%CANOPYFILEIDENTIFIER%.prj"
			copy "%BASEPRJ%" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CHM_ltCoverCutoff_%CANOPYFILEIDENTIFIER%.prj"
			copy "%BASEPRJ%" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CHM_lt0p25m_%CANOPYFILEIDENTIFIER%.prj"

			copy "%BASEPRJ%" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%\CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER1%.prj"
			copy "%BASEPRJ%" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%\CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER1%.prj"
			copy "%BASEPRJ%" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%\CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER2%.prj"
			copy "%BASEPRJ%" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%\CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER2%.prj"
		)
	)

	rem if we are not merging final canopy surfaces and we are working on a block, move the outputs
	if /I NOT "%MERGEBLOCKCANOPY%"=="true" (
		if NOT "%BLOCKNAME%"=="" (
			call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER%.dtm" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "%BLOCKNAME%_CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER%.dtm"
			call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER%.asc" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "%BLOCKNAME%_CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER%.asc"
			call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER%.prj" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "%BLOCKNAME%_CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER%.prj"
			CALL "%PROCESSINGHOME%\convert2img" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\%BLOCKNAME%_CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER%.asc" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%"

			call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER%.dtm" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "%BLOCKNAME%_CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER%.dtm"
			call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER%.asc" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "%BLOCKNAME%_CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER%.asc"
			call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER%.prj" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "%BLOCKNAME%_CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER%.prj"
			CALL "%PROCESSINGHOME%\convert2img" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\%BLOCKNAME%_CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER%.asc" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%"

			IF /I [%DOSPECIALCANOPY%]==[true] (
				call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "CHM_not_smoothed_%CANOPYFILEIDENTIFIER%_return_count.dtm" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "%BLOCKNAME%_CHM_not_smoothed_%CANOPYFILEIDENTIFIER%_return_count.dtm"
				call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "CHM_not_smoothed_%CANOPYFILEIDENTIFIER%_return_count.asc" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "%BLOCKNAME%_CHM_not_smoothed_%CANOPYFILEIDENTIFIER%_return_count.asc"
				call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "CHM_not_smoothed_%CANOPYFILEIDENTIFIER%_return_count.prj" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "%BLOCKNAME%_CHM_not_smoothed_%CANOPYFILEIDENTIFIER%_return_count.prj"
				CALL "%PROCESSINGHOME%\convert2img" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\%BLOCKNAME%_CHM_not_smoothed_%CANOPYFILEIDENTIFIER%_return_count.asc" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%"

				call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "CHM_not_smoothed_%CANOPYFILEIDENTIFIER%.dtm" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "%BLOCKNAME%_CHM_not_smoothed_%CANOPYFILEIDENTIFIER%.dtm"
				call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "CHM_not_smoothed_%CANOPYFILEIDENTIFIER%.asc" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "%BLOCKNAME%_CHM_not_smoothed_%CANOPYFILEIDENTIFIER%.asc"
				call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "CHM_not_smoothed_%CANOPYFILEIDENTIFIER%.prj" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "%BLOCKNAME%_CHM_not_smoothed_%CANOPYFILEIDENTIFIER%.prj"
				CALL "%PROCESSINGHOME%\convert2img" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\%BLOCKNAME%_CHM_not_smoothed_%CANOPYFILEIDENTIFIER%.asc" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%"

				call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "CHM_ltCoverCutoff_%CANOPYFILEIDENTIFIER%.dtm" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "%BLOCKNAME%_CHM_ltCoverCutoff_%CANOPYFILEIDENTIFIER%.dtm"
				call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "CHM_ltCoverCutoff_%CANOPYFILEIDENTIFIER%.asc" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "%BLOCKNAME%_CHM_ltCoverCutoff_%CANOPYFILEIDENTIFIER%.asc"
				call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "CHM_ltCoverCutoff_%CANOPYFILEIDENTIFIER%.prj" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "%BLOCKNAME%_CHM_ltCoverCutoff_%CANOPYFILEIDENTIFIER%.prj"
				CALL "%PROCESSINGHOME%\convert2img" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\%BLOCKNAME%_CHM_ltCoverCutoff_%CANOPYFILEIDENTIFIER%.asc" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%"

				call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "CHM_lt0p25m_%CANOPYFILEIDENTIFIER%.dtm" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "%BLOCKNAME%_CHM_lt0p25m_%CANOPYFILEIDENTIFIER%.dtm"
				call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "CHM_lt0p25m_%CANOPYFILEIDENTIFIER%.asc" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "%BLOCKNAME%_CHM_lt0p25m_%CANOPYFILEIDENTIFIER%.asc"
				call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "CHM_lt0p25m_%CANOPYFILEIDENTIFIER%.prj" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%" "%BLOCKNAME%_CHM_lt0p25m_%CANOPYFILEIDENTIFIER%.prj"
				CALL "%PROCESSINGHOME%\convert2img" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%\%BLOCKNAME%_CHM_lt0p25m_%CANOPYFILEIDENTIFIER%.asc" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%"

				call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%" "CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER1%.dtm" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%" "%BLOCKNAME%_CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER1%.dtm"
				call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%" "CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER1%.asc" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%" "%BLOCKNAME%_CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER1%.asc"
				call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%" "CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER1%.prj" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%" "%BLOCKNAME%_CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER1%.prj"
				CALL "%PROCESSINGHOME%\convert2img" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%\%BLOCKNAME%_CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER1%.asc" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%"

				call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%" "CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER1%.dtm" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%" "%BLOCKNAME%_CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER1%.dtm"
				call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%" "CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER1%.asc" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%" "%BLOCKNAME%_CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER1%.asc"
				call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%" "CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER1%.prj" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%" "%BLOCKNAME%_CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER1%.prj"
				call "%PROCESSINGHOME%\convert2img" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%\%BLOCKNAME%_CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER1%.asc" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%"

				call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%" "CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER2%.dtm" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%" "%BLOCKNAME%_CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER2%.dtm"
				call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%" "CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER2%.asc" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%" "%BLOCKNAME%_CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER2%.asc"
				call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%" "CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER2%.prj" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%" "%BLOCKNAME%_CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER2%.prj"
				CALL "%PROCESSINGHOME%\convert2img" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%\%BLOCKNAME%_CHM_filled_3x_smoothed_%CANOPYFILEIDENTIFIER2%.asc" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%"

				call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%" "CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER2%.dtm" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%" "%BLOCKNAME%_CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER2%.dtm"
				call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%" "CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER2%.asc" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%" "%BLOCKNAME%_CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER2%.asc"
				call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%" "CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER2%.prj" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%" "%BLOCKNAME%_CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER2%.prj"
				call "%PROCESSINGHOME%\convert2img" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%\%BLOCKNAME%_CHM_filled_not_smoothed_%CANOPYFILEIDENTIFIER2%.asc" "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%"
			)
		)
	)
)

REM Deal with segment outputs
IF /I [%DOSEGMENTS%]==[true] (
	mergedtm /exactextent /nofill "%PRODUCTHOME%\CanopyHeight_%SEG_CANOPYFILEIDENTIFIER%\CHM_TreeSeg_%SEG_CANOPYFILEIDENTIFIER%.dtm" "%PRODUCTHOME%\CanopyHeight_%SEG_CANOPYFILEIDENTIFIER%\*TreeSeg_CHM_%SEG_CANOPYFILEIDENTIFIER%.dtm"
	dtm2ascii /multiplier:%MULTIPLIER% "%PRODUCTHOME%\CanopyHeight_%SEG_CANOPYFILEIDENTIFIER%\CHM_TreeSeg_%SEG_CANOPYFILEIDENTIFIER%.dtm"

	rem copy base projection info
	if NOT "%BASEPRJ%"=="" (
		copy "%BASEPRJ%" "%PRODUCTHOME%\CanopyHeight_%SEG_CANOPYFILEIDENTIFIER%\CHM_TreeSeg_%SEG_CANOPYFILEIDENTIFIER%.prj"
	)

	if /I NOT "%MERGEBLOCKCANOPY%"=="true" (
		if NOT "%BLOCKNAME%"=="" (
			call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%SEG_CANOPYFILEIDENTIFIER%" "CHM_TreeSeg_%SEG_CANOPYFILEIDENTIFIER%.dtm" "%FINALPRODUCTHOME%\CanopyHeight_%SEG_CANOPYFILEIDENTIFIER%" "%BLOCKNAME%_CHM_TreeSeg_%SEG_CANOPYFILEIDENTIFIER%.dtm"
			call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%SEG_CANOPYFILEIDENTIFIER%" "CHM_TreeSeg_%SEG_CANOPYFILEIDENTIFIER%.asc" "%FINALPRODUCTHOME%\CanopyHeight_%SEG_CANOPYFILEIDENTIFIER%" "%BLOCKNAME%_CHM_TreeSeg_%SEG_CANOPYFILEIDENTIFIER%.asc"
			call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\CanopyHeight_%SEG_CANOPYFILEIDENTIFIER%" "CHM_TreeSeg_%SEG_CANOPYFILEIDENTIFIER%.prj" "%FINALPRODUCTHOME%\CanopyHeight_%SEG_CANOPYFILEIDENTIFIER%" "%BLOCKNAME%_CHM_TreeSeg_%SEG_CANOPYFILEIDENTIFIER%.prj"
			call "%PROCESSINGHOME%\convert2img" "%FINALPRODUCTHOME%\CanopyHeight_%SEG_CANOPYFILEIDENTIFIER%\%BLOCKNAME%_CHM_TreeSeg_%SEG_CANOPYFILEIDENTIFIER%.asc" "%FINALPRODUCTHOME%\CanopyHeight_%SEG_CANOPYFILEIDENTIFIER%"
		)
	)
)


REM intensity images...does not use the buffered extent
if /I [%DOINTENSITY%]==[true] (
	if /I [%DODENSITY%]==[true] (
		catalog %CLASSOPTION% /rawcounts /density:%INTENSITYCELLAREA%,4,20 /bmp /noclasssummary /intensity:%INTENSITYCELLAREA%,%INTENSITYRANGE% /imageextent:%BLOCKEXTENT% "%AP_INPUTTILES%" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%\temp.csv"
	) ELSE (
		catalog %CLASSOPTION% /bmp /noclasssummary /intensity:%INTENSITYCELLAREA%,%INTENSITYRANGE% /imageextent:%BLOCKEXTENT% "%AP_INPUTTILES%" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%\temp.csv"
	)

	rem deal with the intensity image from Catalog
	if NOT "%BASEPRJ%"=="" (
		copy "%BASEPRJ%" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%\temp_intensity.prj"
	)

	if NOT "%BLOCKNAME%"=="" (
		rem rename intensity image and world file using block name
		call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "temp_intensity.bmp" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "%BLOCKNAME%_Intensity_Mean_%INTENSITYFILEIDENTIFIER%.bmp"
		call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "temp_intensity.bmpw" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "%BLOCKNAME%_Intensity_Mean_%INTENSITYFILEIDENTIFIER%.bmpw"
		call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "temp_intensity.prj" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "%BLOCKNAME%_Intensity_Mean_%INTENSITYFILEIDENTIFIER%.prj"

		rem if we are not merging final images and we are working on a block, move the outputs
		if /I NOT "%MERGEBLOCKINTENSITY%"=="true" (
			rem move files to final products folder
			call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "%BLOCKNAME%_Intensity_Mean_%INTENSITYFILEIDENTIFIER%.bmp" "%FINALPRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "%BLOCKNAME%_Intensity_Mean_%INTENSITYFILEIDENTIFIER%.bmp"
			call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "%BLOCKNAME%_Intensity_Mean_%INTENSITYFILEIDENTIFIER%.bmpw" "%FINALPRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "%BLOCKNAME%_Intensity_Mean_%INTENSITYFILEIDENTIFIER%.bmpw"
			call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "%BLOCKNAME%_Intensity_Mean_%INTENSITYFILEIDENTIFIER%.prj" "%FINALPRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "%BLOCKNAME%_Intensity_Mean_%INTENSITYFILEIDENTIFIER%.prj"

			CALL "%PROCESSINGHOME%\convert2img" "%FINALPRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%\%BLOCKNAME%_Intensity_Mean_%INTENSITYFILEIDENTIFIER%.bmp" "%FINALPRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%"

			rem delete world file
			if /I NOT "%KEEPASCIIFILES%"=="true" (
				del "%FINALPRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%\%BLOCKNAME%_Intensity_Mean_%INTENSITYFILEIDENTIFIER%.bmpw"
			)
		) ELSE (
			CALL "%PROCESSINGHOME%\convert2img" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%\%BLOCKNAME%_Intensity_Mean_%INTENSITYFILEIDENTIFIER%.bmp" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%"

			rem delete world file
			if /I NOT "%KEEPASCIIFILES%"=="true" (
				del "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%\%BLOCKNAME%_Intensity_Mean_%INTENSITYFILEIDENTIFIER%.bmpw"
			)
		)
	) ELSE (
		rem rename intensity image and world file
		call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "temp_intensity.bmp" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "Intensity_Mean_%INTENSITYFILEIDENTIFIER%.bmp"
		call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "temp_intensity.bmpw" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "Intensity_Mean_%INTENSITYFILEIDENTIFIER%.bmpw"
		call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "temp_intensity.prj" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "Intensity_Mean_%INTENSITYFILEIDENTIFIER%.prj"

		CALL "%PROCESSINGHOME%\convert2img" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%\Intensity_Mean_%INTENSITYFILEIDENTIFIER%.bmp" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%"

		rem delete world file
		if /I NOT "%KEEPASCIIFILES%"=="true" (
			del "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%\Intensity_Mean_%INTENSITYFILEIDENTIFIER%.bmpw"
		)
	)

	if /I [%DODENSITY%]==[true] (
		rem deal with the detailed_return_density image from Catalog
		rem It would be better to use the DTM outputs and convert them to ASCII raster format
		if NOT "%BASEPRJ%"=="" (
			copy "%BASEPRJ%" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%\temp_detailed_return_density.prj"
		)

		if NOT "%BLOCKNAME%"=="" (
			rem rename intensity image and world file using block name
			call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "temp_detailed_return_density.bmp" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "%BLOCKNAME%_Return_Density_%INTENSITYFILEIDENTIFIER%.bmp"
			call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "temp_detailed_return_density.bmpw" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "%BLOCKNAME%_Return_Density_%INTENSITYFILEIDENTIFIER%.bmpw"
			call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "temp_detailed_return_density.prj" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "%BLOCKNAME%_Return_Density_%INTENSITYFILEIDENTIFIER%.prj"

			rem if we are not merging final images and we are working on a block, move the outputs
			if /I NOT "%MERGEBLOCKINTENSITY%"=="true" (
				rem move files to final products folder
				call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "%BLOCKNAME%_Return_Density_%INTENSITYFILEIDENTIFIER%.bmp" "%FINALPRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "%BLOCKNAME%_Return_Density_%INTENSITYFILEIDENTIFIER%.bmp"
				call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "%BLOCKNAME%_Return_Density_%INTENSITYFILEIDENTIFIER%.bmpw" "%FINALPRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "%BLOCKNAME%_Return_Density_%INTENSITYFILEIDENTIFIER%.bmpw"
				call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "%BLOCKNAME%_Return_Density_%INTENSITYFILEIDENTIFIER%.prj" "%FINALPRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "%BLOCKNAME%_Return_Density_%INTENSITYFILEIDENTIFIER%.prj"

				CALL "%PROCESSINGHOME%\convert2img" "%FINALPRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%\%BLOCKNAME%_Return_Density_%INTENSITYFILEIDENTIFIER%.bmp" "%FINALPRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%"

				rem delete world file
				if /I NOT "%KEEPASCIIFILES%"=="true" (
					del "%FINALPRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%\%BLOCKNAME%_Return_Density_%INTENSITYFILEIDENTIFIER%.bmpw"
				)
			) ELSE (
				CALL "%PROCESSINGHOME%\convert2img" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%\%BLOCKNAME%_Return_Density_%INTENSITYFILEIDENTIFIER%.bmp" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%"

				rem delete world file
				if /I NOT "%KEEPASCIIFILES%"=="true" (
					del "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%\%BLOCKNAME%_Return_Density_%INTENSITYFILEIDENTIFIER%.bmpw"
				)
			)
		) ELSE (
			rem rename intensity image and world file
			call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "temp_detailed_return_density.bmp" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "Return_Density_%INTENSITYFILEIDENTIFIER%.bmp"
			call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "temp_detailed_return_density.bmpw" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "Return_Density_%INTENSITYFILEIDENTIFIER%.bmpw"
			call "%PROCESSINGHOME%\move_rename" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "temp_detailed_return_density.prj" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%" "Return_Density_%INTENSITYFILEIDENTIFIER%.prj"

			CALL "%PROCESSINGHOME%\convert2img" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%\Return_Density_%INTENSITYFILEIDENTIFIER%.bmp" "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%"

			rem delete world file
			if /I NOT "%KEEPASCIIFILES%"=="true" (
				del "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%\Return_Density_%INTENSITYFILEIDENTIFIER%.bmpw"
			)
		)
	)

	rem delete other files produced by Catalog
	del "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%\temp*.*"
	del "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%\temp.*"
)

setlocal ENABLEDELAYEDEXPANSION
rem do topo metrics for multiple cell sizes...this is done after all other processing because the TopoMetrics tool can handle larger
rem areas (entire blocks) and you may want to have merged ground models that were created and merged for the blocks
IF /I [%DOMULTITOPO%]==[true] (
	rem step through the strata...label the strata using the bottom and top heights
	rem parse topo window size and run metrics
	for %%i in (%MULTITOPOWINDOWSIZES%) do (
		set MTCELLSIZE=%%i
		set TOPOLABEL=!MTCELLSIZE:.=p!%UNITS:~0,1%
		if NOT "%BLOCKNAME%"=="" (
			topometrics /verbose /annuluswidth:%TOPOCELLSIZE% /gridxy:%BLOCKEXTENT% "%DTMSPEC%" %TOPOCELLSIZE% %%i %LATITUDE% %TOPOCELLSIZE% "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%BLOCKNAME%_TOPO_!TOPOLABEL!.csv"
			call "%PROCESSINGHOME%\extract_metric" _!TOPOLABEL!_topo_metrics 5 topo_elevation_!TOPOLABEL!_%TOPOFILEIDENTIFIER% %MULTIPLIER% TOPO
			call "%PROCESSINGHOME%\extract_metric" _!TOPOLABEL!_topo_metrics 6 topo_slope_!TOPOLABEL!_%TOPOFILEIDENTIFIER% 1 TOPO
			call "%PROCESSINGHOME%\extract_metric" _!TOPOLABEL!_topo_metrics 7 topo_aspect_!TOPOLABEL!_%TOPOFILEIDENTIFIER% 1 TOPO
			call "%PROCESSINGHOME%\extract_metric" _!TOPOLABEL!_topo_metrics 8 topo_profilecurv_!TOPOLABEL!_%TOPOFILEIDENTIFIER% 1 TOPO
			call "%PROCESSINGHOME%\extract_metric" _!TOPOLABEL!_topo_metrics 9 topo_plancurv_!TOPOLABEL!_%TOPOFILEIDENTIFIER% 1 TOPO
			call "%PROCESSINGHOME%\extract_metric" _!TOPOLABEL!_topo_metrics 10 topo_sri_!TOPOLABEL!_%TOPOFILEIDENTIFIER% 1 TOPO
			call "%PROCESSINGHOME%\extract_metric" _!TOPOLABEL!_topo_metrics 11 topo_curvature_!TOPOLABEL!_%TOPOFILEIDENTIFIER% 1 TOPO
		) ELSE (
			topometrics /verbose /annuluswidth:%TOPOCELLSIZE% /gridxy:%BLOCKEXTENT% "%DTMSPEC%" %TOPOCELLSIZE% %%i %LATITUDE% %TOPOCELLSIZE% "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\TOPO_!TOPOLABEL!.csv"
			call "%PROCESSINGHOME%\extract_metric" _!TOPOLABEL!_topo_metrics 5 topo_elevation_!TOPOLABEL!_%TOPOFILEIDENTIFIER% %MULTIPLIER% TOPO
			call "%PROCESSINGHOME%\extract_metric" _!TOPOLABEL!_topo_metrics 6 topo_slope_!TOPOLABEL!_%TOPOFILEIDENTIFIER% 1 TOPO
			call "%PROCESSINGHOME%\extract_metric" _!TOPOLABEL!_topo_metrics 7 topo_aspect_!TOPOLABEL!_%TOPOFILEIDENTIFIER% 1 TOPO
			call "%PROCESSINGHOME%\extract_metric" _!TOPOLABEL!_topo_metrics 8 topo_profilecurv_!TOPOLABEL!_%TOPOFILEIDENTIFIER% 1 TOPO
			call "%PROCESSINGHOME%\extract_metric" _!TOPOLABEL!_topo_metrics 9 topo_plancurv_!TOPOLABEL!_%TOPOFILEIDENTIFIER% 1 TOPO
			call "%PROCESSINGHOME%\extract_metric" _!TOPOLABEL!_topo_metrics 10 topo_sri_!TOPOLABEL!_%TOPOFILEIDENTIFIER% 1 TOPO
			call "%PROCESSINGHOME%\extract_metric" _!TOPOLABEL!_topo_metrics 11 topo_curvature_!TOPOLABEL!_%TOPOFILEIDENTIFIER% 1 TOPO
		)
	)
	for %%i in (%MULTITPIWINDOWSIZES%) do (
		set MTCELLSIZE=%%i
		set TOPOLABEL=!MTCELLSIZE:.=p!%UNITS:~0,1%
		if NOT "%BLOCKNAME%"=="" (
			topometrics /verbose /annuluswidth:%TOPOCELLSIZE% /gridxy:%BLOCKEXTENT% "%DTMSPEC%" %TOPOCELLSIZE% %TOPOCELLSIZE% %LATITUDE% %%i "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%BLOCKNAME%_TOPO_!TOPOLABEL!.csv"
			call "%PROCESSINGHOME%\extract_metric" !TOPOLABEL!_topo_metrics 12 topo_tpi_!TOPOLABEL!_%TOPOFILEIDENTIFIER% 1 TOPO
		) ELSE (
			topometrics /verbose /annuluswidth:%TOPOCELLSIZE% /gridxy:%BLOCKEXTENT% "%DTMSPEC%" %TOPOCELLSIZE% %TOPOCELLSIZE% %LATITUDE% %%i "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\TOPO_!TOPOLABEL!.csv"
			call "%PROCESSINGHOME%\extract_metric" !TOPOLABEL!_topo_metrics 12 topo_tpi_!TOPOLABEL!_%TOPOFILEIDENTIFIER% 1 TOPO
		)
	)
)
endlocal

setlocal ENABLEDELAYEDEXPANSION
rem do topo metrics for multiple cell sizes...this is done after all other processing because the TopoMetrics tool can handle larger
rem areas (entire blocks) and you may want to have merged ground models that were created and merged for the blocks
IF /I [%DOFINEMULTITOPO%]==[true] (
	rem step through the strata...label the strata using the bottom and top heights
	rem parse topo window size and run metrics
	for %%i in (%FINEMULTITOPOWINDOWSIZES%) do (
		set MTCELLSIZE=%%i
		set TOPOLABEL=!MTCELLSIZE:.=p!%UNITS:~0,1%
		if NOT "%BLOCKNAME%"=="" (
			topometrics /verbose /annuluswidth:%FINETOPOCELLSIZE% /gridxy:%BLOCKEXTENT% "%DTMSPEC%" %FINETOPOCELLSIZE% %%i %LATITUDE% %FINETOPOCELLSIZE% "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%BLOCKNAME%_TOPO_!TOPOLABEL!.csv"
			call "%PROCESSINGHOME%\extract_metric" _!TOPOLABEL!_topo_metrics 5 topo_elevation_!TOPOLABEL!_%FINETOPOFILEIDENTIFIER% %MULTIPLIER% FINETOPO
			call "%PROCESSINGHOME%\extract_metric" _!TOPOLABEL!_topo_metrics 6 topo_slope_!TOPOLABEL!_%FINETOPOFILEIDENTIFIER% 1 FINETOPO
			call "%PROCESSINGHOME%\extract_metric" _!TOPOLABEL!_topo_metrics 7 topo_aspect_!TOPOLABEL!_%FINETOPOFILEIDENTIFIER% 1 FINETOPO
			call "%PROCESSINGHOME%\extract_metric" _!TOPOLABEL!_topo_metrics 8 topo_profilecurv_!TOPOLABEL!_%FINETOPOFILEIDENTIFIER% 1 FINETOPO
			call "%PROCESSINGHOME%\extract_metric" _!TOPOLABEL!_topo_metrics 9 topo_plancurv_!TOPOLABEL!_%FINETOPOFILEIDENTIFIER% 1 FINETOPO
			call "%PROCESSINGHOME%\extract_metric" _!TOPOLABEL!_topo_metrics 10 topo_sri_!TOPOLABEL!_%FINETOPOFILEIDENTIFIER% 1 FINETOPO
			call "%PROCESSINGHOME%\extract_metric" _!TOPOLABEL!_topo_metrics 11 topo_curvature_!TOPOLABEL!_%FINETOPOFILEIDENTIFIER% 1 FINETOPO
		) ELSE (
			topometrics /verbose /annuluswidth:%FINETOPOCELLSIZE% /gridxy:%BLOCKEXTENT% "%DTMSPEC%" %FINETOPOCELLSIZE% %%i %LATITUDE% %FINETOPOCELLSIZE% "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\TOPO_!TOPOLABEL!.csv"
			call "%PROCESSINGHOME%\extract_metric" _!TOPOLABEL!_topo_metrics 5 topo_elevation_!TOPOLABEL!_%FINETOPOFILEIDENTIFIER% %MULTIPLIER% FINETOPO
			call "%PROCESSINGHOME%\extract_metric" _!TOPOLABEL!_topo_metrics 6 topo_slope_!TOPOLABEL!_%FINETOPOFILEIDENTIFIER% 1 FINETOPO
			call "%PROCESSINGHOME%\extract_metric" _!TOPOLABEL!_topo_metrics 7 topo_aspect_!TOPOLABEL!_%FINETOPOFILEIDENTIFIER% 1 FINETOPO
			call "%PROCESSINGHOME%\extract_metric" _!TOPOLABEL!_topo_metrics 8 topo_profilecurv_!TOPOLABEL!_%FINETOPOFILEIDENTIFIER% 1 FINETOPO
			call "%PROCESSINGHOME%\extract_metric" _!TOPOLABEL!_topo_metrics 9 topo_plancurv_!TOPOLABEL!_%FINETOPOFILEIDENTIFIER% 1 FINETOPO
			call "%PROCESSINGHOME%\extract_metric" _!TOPOLABEL!_topo_metrics 10 topo_sri_!TOPOLABEL!_%FINETOPOFILEIDENTIFIER% 1 FINETOPO
			call "%PROCESSINGHOME%\extract_metric" _!TOPOLABEL!_topo_metrics 11 topo_curvature_!TOPOLABEL!_%FINETOPOFILEIDENTIFIER% 1 FINETOPO
		)
	)
	for %%i in (%FINEMULTITPIWINDOWSIZES%) do (
		set MTCELLSIZE=%%i
		set TOPOLABEL=!MTCELLSIZE:.=p!%UNITS:~0,1%
		if NOT "%BLOCKNAME%"=="" (
			topometrics /verbose /annuluswidth:%FINETOPOCELLSIZE% /gridxy:%BLOCKEXTENT% "%DTMSPEC%" %FINETOPOCELLSIZE% %FINETOPOCELLSIZE% %LATITUDE% %%i "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\%BLOCKNAME%_TOPO_!TOPOLABEL!.csv"
			call "%PROCESSINGHOME%\extract_metric" !TOPOLABEL!_topo_metrics 12 topo_tpi_!TOPOLABEL!_%FINETOPOFILEIDENTIFIER% 1 FINETOPO
		) ELSE (
			topometrics /verbose /annuluswidth:%FINETOPOCELLSIZE% /gridxy:%BLOCKEXTENT% "%DTMSPEC%" %FINETOPOCELLSIZE% %FINETOPOCELLSIZE% %LATITUDE% %%i "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%\TOPO_!TOPOLABEL!.csv"
			call "%PROCESSINGHOME%\extract_metric" !TOPOLABEL!_topo_metrics 12 topo_tpi_!TOPOLABEL!_%FINETOPOFILEIDENTIFIER% 1 FINETOPO
		)
	)
)
endlocal

rem extract elevation metrics to layers
IF /I [%DOMETRICS%]==[true] (
	ReturnDensity /nointpercentile /ascii /class:2 "/projection:%BASEPRJ%" /gridxy:%BLOCKEXTENT% "%PRODUCTHOME%\Metrics_%FILEIDENTIFIER%\grnd_cnt_%FILEIDENTIFIER%.asc" %CELLSIZE% "%AP_INPUTTILES%"

	CALL %PROCESSINGHOME%\buildlayers_allreturns.bat

:topo
	rem extract topo metrics to layers
	if /I [%DOTOPO%]==[true] (
		call "%PROCESSINGHOME%\extract_metric" _topo_metrics 5 topo_elevation_%FILEIDENTIFIER% %MULTIPLIER%
		call "%PROCESSINGHOME%\extract_metric" _topo_metrics 6 topo_slope_%FILEIDENTIFIER% 1
		call "%PROCESSINGHOME%\extract_metric" _topo_metrics 7 topo_aspect_%FILEIDENTIFIER% 1
		call "%PROCESSINGHOME%\extract_metric" _topo_metrics 8 topo_profilecurv_%FILEIDENTIFIER% 1
		call "%PROCESSINGHOME%\extract_metric" _topo_metrics 9 topo_plancurv_%FILEIDENTIFIER% 1
		call "%PROCESSINGHOME%\extract_metric" _topo_metrics 10 topo_sri_%FILEIDENTIFIER% 1
		call "%PROCESSINGHOME%\extract_metric" _topo_metrics 11 topo_curvature_%FILEIDENTIFIER% 1
	)

:strata
	if /I [%DOSTRATA%]==[true] (
		call "%PROCESSINGHOME%\buildstrata"
	)
)

rem extract first return metrics to layers
IF /I [%DOFIRSTMETRICS%]==[true] (
	CALL %PROCESSINGHOME%\buildlayers_firstreturns.bat

	if /I [%DOFIRSTSTRATA%]==[true] (
		call "%PROCESSINGHOME%\buildstrata"
	)
)

:end

rem clear label variables
set MINHTLABEL=
set COVERHTLABEL=
rem set FILEIDENTIFIER=
