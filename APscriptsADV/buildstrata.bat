rem extract strata metrics from CSV files and merge into a single coverage for each layer and metric
rem this batch file shouldn't be called unless the user specified that they were doing strata metrics in the setup batch file

rem enable delayed expansion of environment variable to allow us to change variables in a loop
setlocal ENABLEDELAYEDEXPANSION

rem step through the strata...label the strata using the bottom and top heights
set STRATABOTTOM=0
set STRATA=1
rem parse strata breaks and build name for the strata
for %%i in (%STRATAHEIGHTS%) do (
	set STRATATOP=%%i
	set STRATALABEL=!STRATABOTTOM:.=p!to!STRATATOP:.=p!%UNITS:~0,1%
	call "%PROCESSINGHOME%\extract_strata_layer" !STRATA! !STRATALABEL!
	set /A STRATA=!STRATA!+1
	set STRATABOTTOM=%%i
)
rem make last call for the final strata
set STRATALABEL=!STRATABOTTOM:.=p!%UNITS:~0,1%_plus
call "%PROCESSINGHOME%\extract_strata_layer" !STRATA! !STRATALABEL!

set STRATABOTTOM=
set STRATATOP=
set STRATA=
set STRATALABEL=
