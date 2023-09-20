rem convert output ASCII raster files to Imagine format
rem %1 full input filename with extension, drive letter, and folder for ASCII raster file
rem %2 output folder...no closing "\"...does not check to make sure output folder exists

if /I "%CONVERTTOIMG%"=="true" (
	"%GDAL_TRANSLATE_LOCATION%" -a_nodata 0 -b 1 -a_srs "%~dpn1.prj" -of HFA -co COMPRESSED=YES "%~1" "%~2\%~n1.img"

	rem delete the XML file created by gdal_translate...this file may not always be created
	del "%~2\%~n1.img.aux.xml"

	rem make sure the .img file was created, then delete the .asc file and .prj file
	if EXIST "%~2\%~n1.img" (
		if /I NOT "%KEEPASCIIFILES%"=="true" (
			del "%~1"
			del "%~dpn1.prj"
		)
	)
)
