for %%i in (*.flt) do (
"C:\Program Files\GDAL\gdal_translate" -of AAIGrid -a_nodata 1.701410009187828e+038  %%i %%~ni.asc
ascii2dtm %%~ni.dtm m m 1 10 2 2 %%~ni.asc
)
