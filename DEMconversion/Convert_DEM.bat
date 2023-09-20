rem %1=folder name for ground model in GRID format

echo ********************* Converting: %~n1 ***************************

rem check for existing model
if exist Ground\%~n1.dtm (
	echo Duplicate tile: %~n1>>ERRORS.txt
	goto end
)

rem translate the GRID folder to ASCII raster format
"C:\Program Files\GDAL\gdal_translate" -of AAIGrid "%1" "Ground\%~n1.asc"

rem translate to PLANS format
ASCII2DTM "Ground\%~n1.dtm" F F 0 0 0 0 "Ground\%~n1.asc"

rem delete the ASCII raster file
del Ground\%~n1.asc
del Ground\%~n1.asc.aux.xml
del Ground\%~n1.prj

:split
rem split the DTM into smaller tiles
splitdtm /maxcells "Ground\%~n1.dtm" "Ground\LIDAR\%~n1.dtm" 2 2

:end
