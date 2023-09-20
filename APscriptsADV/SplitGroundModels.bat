rem split DTM files into more managable blocks
rem this uses the /maxcells option in SplitDTM with the default of 25,000,000 cells in the model to keep the blocks about 5000 by 5000 cells
rem
rem %1 is the base file name...with DTM extension
rem %2 is the output folder...no trailing "\"

mkdir %2

SplitDTM /maxcells "%1" "%2\%1" 1 1
