rem 2/9/2015 added overlap:max when merging raster layers and changed overlap:average to overlap:max for DTM merges
rem 6/23/2015 added type 3 for images...don't have tools to merge images yet but this makes all other processing flows ready to deal with images
rem 3/5/2018 Changed so DTM files are converted to IMG format after the merge
rem 2/25/2019 Fixed missing quotation mark when converting DTM files to IMG format...also added /exactextent to mergedtm call
rem
rem merge all files with the name passed on the command line across all blocks of a job
rem %1 -- full file name (name + extension) for files to merge without drive or path
rem %2 -- format code (blank or 1 = ASCII raster, 2 = DTM, 3 = BMP...not currently supported)
rem %3 -- folder for merged output...assume folder exists

rem build list of input files
DIR /b /s "%PRODUCTHOME%\..\%1" > layerfiles.txt

rem do the merge...the ~ removes quotation marks from the variable
IF "%2"=="1" (
	rem ASCII raster format
	mergeraster /overlap:max "%~3\%1" layerfiles.txt
) ELSE (
	IF "%2"=="2" (
		rem DTM format
REM		mergedtm /overlap:max "%~3\%1" layerfiles.txt
		mergedtm /exactextent /overlap:max "%~3\%1" layerfiles.txt
	) ELSE (
		rem image format
	)
)

rem we don't know how to merge images so jump to end
IF "%2"=="3" GOTO END

rem copy base projection info
if NOT "%BASEPRJ%"=="" (
   copy "%BASEPRJ%" "%~3\%~n1.prj"
)

rem convert to imagine format...convert2img check to see if it supposed to do the conversion (checks CONVERTTOIMG)
IF "%2"=="1" (
	CALL "%PROCESSINGHOME%\convert2img" "%~3\%~1" "%~3"
) ELSE (
	IF "%2"=="2" (
		REM DTM format...need to convert to ASCII raster format then to IMG
		REM if CONVERTTOIMG is FALSE, you will end up with ASCII files but no IMG files...this may be good
		REM if you don't want the DTM->ASCII conversion to take place, test for CONVERTTOIMG and only run DTM2ASCII if it is TRUE
		DTM2ASCII "%~3\%~1" "%~3\%~n1.asc"

		CALL "%PROCESSINGHOME%\convert2img" "%~3\%~n1.asc" "%~3"
	)
)

:END
rem delete temporary list of layer files
DEL layerfiles.txt
