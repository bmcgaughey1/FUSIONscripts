rem 7/10/2019 modified logic to allow runs that only produce first return metrics
rem
rem Final processing batch file run after all block processing is complete
rem

rem file name for the list of block outputs...this is needed to merge block outputs into single layers
SET FOLDERLIST=%WORKINGDIRNAME%\OutputFolders.txt

rem build strings used to build file names
rem set FILEIDENTIFIER=%CELLSIZE:.=p%%UNITS%

rem read first folder containing block outputs
SET /p TEMPLATE=< "%FOLDERLIST%"

rem do the metrics
if /I "%MERGEBLOCKMETRICS%"=="true" (
	if /I "%DOMETRICS%"=="true" (
		rem build a list of all the files in the folder
		DIR /b "%TEMPLATE%\Metrics_%FILEIDENTIFIER%\*.asc">layerlist.txt

		rem step through the list of layers and merge each layer with the same name across the blocks
		FOR /F %%i IN (layerlist.txt) DO CALL "%PROCESSINGHOME%\mergelayer" %%i 1 "%FINALPRODUCTHOME%\Metrics_%FILEIDENTIFIER%"

		rem look for strata
		if /I "%DOSTRATA%"=="true" (
			rem build a list of all the files in the folder
			DIR /b "%TEMPLATE%\StrataMetrics_%FILEIDENTIFIER%\*.asc">layerlist.txt

			rem step through the list of layers and merge each layer with the same name across the blocks
			FOR /F %%i IN (layerlist.txt) DO CALL "%PROCESSINGHOME%\mergelayer" %%i 1 "%FINALPRODUCTHOME%\StrataMetrics_%FILEIDENTIFIER%"
		)
	) else (
		rem deal with runs that only produce first return metrics
		if /I "%DOFIRSTMETRICS%"=="true" (
			rem build a list of all the files in the folder
			DIR /b "%TEMPLATE%\Metrics_%FILEIDENTIFIER%\*.asc">layerlist.txt

			rem step through the list of layers and merge each layer with the same name across the blocks
			FOR /F %%i IN (layerlist.txt) DO CALL "%PROCESSINGHOME%\mergelayer" %%i 1 "%FINALPRODUCTHOME%\Metrics_%FILEIDENTIFIER%"
		)

		rem look for strata
		if /I "%DOFIRSTSTRATA%"=="true" (
			rem build a list of all the files in the folder
			DIR /b "%TEMPLATE%\StrataMetrics_%FILEIDENTIFIER%\*.asc">layerlist.txt

			rem step through the list of layers and merge each layer with the same name across the blocks
			FOR /F %%i IN (layerlist.txt) DO CALL "%PROCESSINGHOME%\mergelayer" %%i 1 "%FINALPRODUCTHOME%\StrataMetrics_%FILEIDENTIFIER%"
		)
	)

	rem look for canopy surface metrics
	if /I "%DOCANOPY%"=="true" (
		rem build a list of all the files in the folder
		DIR /b "%TEMPLATE%\CanopyMetrics_%CANOPYSTATSFILEIDENTIFIER%\*.asc">layerlist.txt

		rem step through the list of layers and merge each layer with the same name across the blocks
		FOR /F %%i IN (layerlist.txt) DO CALL "%PROCESSINGHOME%\mergelayer" %%i 1 "%FINALPRODUCTHOME%\CanopyMetrics_%CANOPYSTATSFILEIDENTIFIER%"
	)
)

rem do the canopy
if /I "%MERGEBLOCKCANOPY%"=="true" (
	if /I "%DOCANOPY%"=="true" (
		rem build a list of all the files in the folder
		DIR /b "%TEMPLATE%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CHM_*.dtm">layerlist.txt

		rem step through the list of layers and merge each layer with the same name across the blocks
		FOR /F %%i IN (layerlist.txt) DO CALL "%PROCESSINGHOME%\mergelayer" %%i 2 "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%"

		IF /I [%DOSPECIALCANOPY%]==[true] (
			rem merge the lower resolution canopy surfaces...same logic as above but different folders
			DIR /b "%TEMPLATE%\CanopyHeight_%CANOPYFILEIDENTIFIER1%\CHM_*.dtm">layerlist.txt
			FOR /F %%i IN (layerlist.txt) DO CALL "%PROCESSINGHOME%\mergelayer" %%i 2 "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%"

			DIR /b "%TEMPLATE%\CanopyHeight_%CANOPYFILEIDENTIFIER2%\CHM_*.dtm">layerlist.txt
			FOR /F %%i IN (layerlist.txt) DO CALL "%PROCESSINGHOME%\mergelayer" %%i 2 "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%"
		)
	)

	IF /I [%DOSEGMENTS%]==[true] (
		DIR /b "%TEMPLATE%\CanopyHeight_%SEG_CANOPYFILEIDENTIFIER%\CHM_*.dtm">layerlist.txt
		FOR /F %%i IN (layerlist.txt) DO CALL "%PROCESSINGHOME%\mergelayer" %%i 2 "%FINALPRODUCTHOME%\CanopyHeight_%SEG_CANOPYFILEIDENTIFIER%"
	)
)

rem do the ground
if /I "%MERGEBLOCKGROUND%"=="true" (
	if /I "%DOGROUND%"=="true" (
		rem build a list of all the files in the folder
		DIR /b "%TEMPLATE%\BareGround_%GROUNDFILEIDENTIFIER%\BE_*.dtm">layerlist.txt

		rem step through the list of layers and merge each layer with the same name across the blocks
		FOR /F %%i IN (layerlist.txt) DO CALL "%PROCESSINGHOME%\mergelayer" %%i 2 "%FINALPRODUCTHOME%\BareGround_%GROUNDFILEIDENTIFIER%"
	)
)

rem do the intensity images...currently there is no way to merge image outputs
if /I "%MERGEBLOCKINTENSITY%"=="true" (
	if /I "%DOINTENSITY%"=="true" (
		rem build a list of all the files in the folder
		DIR /b "%TEMPLATE%\Intensity_%INTENSITYFILEIDENTIFIER%\*.bmp">layerlist.txt

		rem step through the list of layers and merge each layer with the same name across the blocks
		FOR /F %%i IN (layerlist.txt) DO CALL "%PROCESSINGHOME%\mergelayer" %%i 3 "%FINALPRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%"
	)
)

rem do the topo metrics
rem if DOTOPO or DOMULTITOPO are not set to true, there will be a DOS error for the DIR command...not a problem but the error will show
rem in the command prompt window at the end of the processing. We have to live with this one because there is no good way to do a logical
rem OR in an IF statement in DOS.
if /I "%MERGEBLOCKTOPOMETRICS%"=="true" (
	rem build a list of all the files in the folder
	DIR /b "%TEMPLATE%\TopoMetrics_%TOPOFILEIDENTIFIER%\*.asc">layerlist.txt

	rem step through the list of layers and merge each layer with the same name across the blocks
	FOR /F %%i IN (layerlist.txt) DO CALL "%PROCESSINGHOME%\mergelayer" %%i 1 "%FINALPRODUCTHOME%\TopoMetrics_%TOPOFILEIDENTIFIER%"
)

rem do the fine topo metrics
if /I "%MERGEBLOCKFINETOPOMETRICS%"=="true" (
	if /I "%DOFINEMULTITOPO%"=="true" (
		rem build a list of all the files in the folder
		DIR /b "%TEMPLATE%\FineTopoMetrics_%FINETOPOFILEIDENTIFIER%\*.asc">layerlist.txt

		rem step through the list of layers and merge each layer with the same name across the blocks
		FOR /F %%i IN (layerlist.txt) DO CALL "%PROCESSINGHOME%\mergelayer" %%i 1 "%FINALPRODUCTHOME%\FineTopoMetrics_%FINETOPOFILEIDENTIFIER%"
	)
)

rem clean up
rem SET FILEIDENTIFIER=

rem copy the tile and block shapefiles again so we have a record of the processing status in the FINAL output folder
COPY "%WORKINGDIRNAME%\%RUNIDENTIFIER%_ProcessingTiles.*" "%FINALPRODUCTHOME%\Layout_shapefiles"
COPY "%WORKINGDIRNAME%\%RUNIDENTIFIER%_ProcessingBlocks.*" "%FINALPRODUCTHOME%\Layout_shapefiles"

rem removed following line 3/2/2018...not needed and usually won't work since the PROCESSINGHOME folder won't be on the same drive as the AP-written processing scripts
rem CD %PROCESSINGHOME%

setlocal ENABLEDELAYEDEXPANSION

rem experimental code to "chain" runs together
rem in the main folder of the current run (where the main processing batch file is located) create a file named "run_next.txt" that contains the name of the main batch file
rem for the area you want to run next
IF EXIST RUN_NEXT.TXT (
	set /p dothis=<run_next.txt
	CALL "!dothis!"
)
