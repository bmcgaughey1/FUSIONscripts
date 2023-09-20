rem %1 is the layer number
rem %2 is the name that includes the bottom and top heights

rem extract a single strata layer from the overall strata output
rem in each record for a cell, column 1 is the row# and column 2 is the column#
rem there are 11 additional variables for each layer

rem syntax extract_strata_layer layernum
rem layernum is the layer number to extract...note this has no direct reference to the height range of the layer

rem do math to compute the starting column
set /A COLUMN=(%1-1)*11+3

rem extract the layer
call "%PROCESSINGHOME%\extract_metric" _strata_stats %COLUMN%  strata_%2_total_return_cnt_%FILEIDENTIFIER% 1 STRATA
set /A COLUMN+=1
call "%PROCESSINGHOME%\extract_metric" _strata_stats %COLUMN%  strata_%2_return_proportion_%FILEIDENTIFIER% 1 STRATA
set /A COLUMN+=1
call "%PROCESSINGHOME%\extract_metric" _strata_stats %COLUMN%  strata_%2_min_%FILEIDENTIFIER% %MULTIPLIER% STRATA
set /A COLUMN+=1
call "%PROCESSINGHOME%\extract_metric" _strata_stats %COLUMN%  strata_%2_max_%FILEIDENTIFIER% %MULTIPLIER% STRATA
set /A COLUMN+=1
call "%PROCESSINGHOME%\extract_metric" _strata_stats %COLUMN%  strata_%2_mean_%FILEIDENTIFIER% %MULTIPLIER% STRATA
set /A COLUMN+=1
call "%PROCESSINGHOME%\extract_metric" _strata_stats %COLUMN%  strata_%2_mode_%FILEIDENTIFIER% %MULTIPLIER% STRATA
set /A COLUMN+=1
call "%PROCESSINGHOME%\extract_metric" _strata_stats %COLUMN%  strata_%2_median_%FILEIDENTIFIER% %MULTIPLIER% STRATA
set /A COLUMN+=1
call "%PROCESSINGHOME%\extract_metric" _strata_stats %COLUMN% strata_%2_stddev_%FILEIDENTIFIER% %MULTIPLIER% STRATA
set /A COLUMN+=1
call "%PROCESSINGHOME%\extract_metric" _strata_stats %COLUMN% strata_%2_CV_%FILEIDENTIFIER% 1 STRATA
set /A COLUMN+=1
call "%PROCESSINGHOME%\extract_metric" _strata_stats %COLUMN% strata_%2_skewness_%FILEIDENTIFIER% 1 STRATA
set /A COLUMN+=1
call "%PROCESSINGHOME%\extract_metric" _strata_stats %COLUMN% strata_%2_kurtosis_%FILEIDENTIFIER% 1 STRATA

rem clear COLUMN variable
set COLUMN=
