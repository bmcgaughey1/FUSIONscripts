@echo off
REM extract a specific metric from CSV files produced by Gridmetrics

if "%1"=="" goto syntax
if "%2"=="" goto syntax
if "%3"=="" goto syntax
if "%4"=="" goto syntax
goto process

:syntax
echo extractmetric fileidentifier column name multiplier [outputflag]
echo fileidentifier designates which CSV output file is used for the metrics
echo column is the column number in the GridMetrics CSV output
echo name is the name used for the merged output ASCII raster file (don't include the .asc extension)
echo multiplier used for each cell value (normally 1.0)
echo outputflag is used to direct outputs to specific folders. Use for TOPO and FINETOPO outputs

goto end

:process
@echo on

rem set up output folder
SET OUTPUTFOLDER=Metrics_%FILEIDENTIFIER%
if /I "%5"=="TOPO" SET OUTPUTFOLDER=TopoMetrics_%TOPOFILEIDENTIFIER%
if /I "%5"=="FINETOPO" SET OUTPUTFOLDER=FineTopoMetrics_%FINETOPOFILEIDENTIFIER%
if /I "%5"=="STRATA" SET OUTPUTFOLDER=StrataMetrics_%FILEIDENTIFIER%

REM do the extraction from each tile
cd "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%"

dir /b *%1.csv > csvlist.txt

rem loop through all CSV files in folder and do processing
for /F "eol=; tokens=1* delims=,. " %%i in (csvlist.txt) do call "%PROCESSINGHOME%\doextractmetric" %%i %2 %4

rem merge tiles...ASCII raster format
mergeraster /verbose /compare /overlap:new %3.asc *_tile.asc

rem delete ASCII raster tiles
del *_tile.asc

rem move layer to Metrics folder
move /Y %3.asc "%PRODUCTHOME%\%OUTPUTFOLDER%"

rem copy base projection info
if NOT "%BASEPRJ%"=="" (
	copy "%BASEPRJ%" "%PRODUCTHOME%\%OUTPUTFOLDER%\%3.prj"
)

rem if we are not merging final outputs and we are working on a block, move the outputs
if /I "%5"=="" (
	if /I NOT "%MERGEBLOCKMETRICS%"=="true" (
		if NOT "%BLOCKNAME%"=="" (
			move "%PRODUCTHOME%\%OUTPUTFOLDER%\%3.asc" "%FINALPRODUCTHOME%\%OUTPUTFOLDER%\%BLOCKNAME%_%3.asc"
			move "%PRODUCTHOME%\%OUTPUTFOLDER%\%3.prj" "%FINALPRODUCTHOME%\%OUTPUTFOLDER%\%BLOCKNAME%_%3.prj"
			CALL "%PROCESSINGHOME%\convert2img" "%FINALPRODUCTHOME%\%OUTPUTFOLDER%\%BLOCKNAME%_%3.asc" "%FINALPRODUCTHOME%\%OUTPUTFOLDER%"
		)
	)
)

if /I "%5"=="STRATA" (
	if /I NOT "%MERGEBLOCKMETRICS%"=="true" (
		if NOT "%BLOCKNAME%"=="" (
			move "%PRODUCTHOME%\%OUTPUTFOLDER%\%3.asc" "%FINALPRODUCTHOME%\%OUTPUTFOLDER%\%BLOCKNAME%_%3.asc"
			move "%PRODUCTHOME%\%OUTPUTFOLDER%\%3.prj" "%FINALPRODUCTHOME%\%OUTPUTFOLDER%\%BLOCKNAME%_%3.prj"
			CALL "%PROCESSINGHOME%\convert2img" "%FINALPRODUCTHOME%\%OUTPUTFOLDER%\%BLOCKNAME%_%3.asc" "%FINALPRODUCTHOME%\%OUTPUTFOLDER%"
		)
	)
)

if /I "%5"=="TOPO" (
	if /I NOT "%MERGEBLOCKTOPOMETRICS%"=="true" (
		if NOT "%BLOCKNAME%"=="" (
			move "%PRODUCTHOME%\%OUTPUTFOLDER%\%3.asc" "%FINALPRODUCTHOME%\%OUTPUTFOLDER%\%BLOCKNAME%_%3.asc"
			move "%PRODUCTHOME%\%OUTPUTFOLDER%\%3.prj" "%FINALPRODUCTHOME%\%OUTPUTFOLDER%\%BLOCKNAME%_%3.prj"
			CALL "%PROCESSINGHOME%\convert2img" "%FINALPRODUCTHOME%\%OUTPUTFOLDER%\%BLOCKNAME%_%3.asc" "%FINALPRODUCTHOME%\%OUTPUTFOLDER%"
		)
	)
)
if /I "%5"=="FINETOPO" (
	if /I NOT "%MERGEBLOCKFINETOPOMETRICS%"=="true" (
		if NOT "%BLOCKNAME%"=="" (
			move "%PRODUCTHOME%\%OUTPUTFOLDER%\%3.asc" "%FINALPRODUCTHOME%\%OUTPUTFOLDER%\%BLOCKNAME%_%3.asc"
			move "%PRODUCTHOME%\%OUTPUTFOLDER%\%3.prj" "%FINALPRODUCTHOME%\%OUTPUTFOLDER%\%BLOCKNAME%_%3.prj"
			CALL "%PROCESSINGHOME%\convert2img" "%FINALPRODUCTHOME%\%OUTPUTFOLDER%\%BLOCKNAME%_%3.asc" "%FINALPRODUCTHOME%\%OUTPUTFOLDER%"
		)
	)
)

rem delete list file
del csvlist.txt

cd "%PROCESSINGHOME%"

:end
@echo on
