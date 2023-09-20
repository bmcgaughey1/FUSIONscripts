rem %1=folder name or file name for surface model
rem if GRID format, this will be the folder name with no trailing "\"

echo ********************* Converting: %~n1 ***************************

rem translate the surface to ASCII raster format
"C:\Program Files\GDAL\gdal_translate" -of AAIGrid "%1" "%~dpn1.asc"

rem translate to PLANS format
ASCII2DTM "%~dpn1.dtm" F F 0 0 0 0 "%~dpn1.asc"

rem delete the ASCII raster file
del %~dpn1.asc
del %~dpn1.asc.aux.xml
del %~dpn1.prj
