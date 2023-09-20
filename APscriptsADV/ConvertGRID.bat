rem %1=folder name for project
rem %2=UTM zone

IF "%1"=="info" GOTO end

rem translate the GRID folder to ASCII raster format
gdal_translate –co FORCE_CELLSIZE=YES –co DECIMAL_PRECISION=4 -of AAIGrid %1 %~n1.asc

rem translate to PLANS format
rem ASCII2DTM %1.dtm M M 1 %2 2 2 %1.asc
ASCII2DTM %~n1.dtm F F 0 0 0 0 %~n1.asc

rem delete the ASCII raster file
del %~n1.asc
del %~n1.asc.aux.xml
del %~n1.prj

rem move %1.dtm H:\PNW_PROCESSING\Bareground

:end
