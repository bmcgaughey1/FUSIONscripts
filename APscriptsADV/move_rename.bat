rem move a file then rename it
rem this was originally written because I didn't know about the /Y option and the ability to use MOVE to move a single file and rename it with a single command
rem %1 in original folder...no trailing \
rem %2 is the original file name
rem %3 is the new folder...no trailing \
rem %4 is the new file name

rem ~ removes quotation marks from string
rem move the original file to the new folder, /Y allow us to overwrite an exiting file in the new folder
move /Y "%~1\%~2" "%~3\%~4"

rem original code follows
rem move /Y "%~1\%~2" "%~3"
rem del "%~4"
rem ren "%~3\%~2" "%~4"
