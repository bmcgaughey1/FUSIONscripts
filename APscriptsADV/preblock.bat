rem Pre-processing batch file (before all blocks)

rem Environment variables defined for use:
rem    BASENAME          Base name for processing files...unique to each processing block
rem    AP_RUNDATE        Date in YYYY-MM-DD format that represents the date the job was started
rem    AP_INPUTTILES     Text file containing a list of all input tiles for the current processing block
rem    AP_RETURNDENSITY  Text file containing a list of all return density files for the current processing block
rem    AP_BAREGROUND     Text file containing a list of all bareground files for the current processing block
rem    AP_AREAMASK       Text file containing a list of all mask files for the current processing block
rem    AP_PROJECTIONFILE Name of the ESRI projection file used for all output data products
rem    AP_PROCESSINGHOME Name of the folder with auxiliary processing scripts
rem    AP_AREANAME       Area name provided in AreaProcessor
rem    AP_COORDSYSTEM    Coordinate system code provided in AreaProcessor (0=state plane, 1=UTM, 2=other)
rem    AP_COORDZONE      Coordinate system zone provided in AreaProcessor
rem    AP_LATITUDE       Latitude for the center of the area provided in AreaProcessor
rem    AP_UNITS          Measurement units provided in AreaProcessor
rem    AP_INTENSITYRANGE Range of intensity values provided in AreaProcessor
rem    AP_CLASSOPTION    Parameters for /class option provided in AreaProcessor

rem delete the file used to hold the list of block output folders
DEL "%WORKINGDIRNAME%\OutputFolders.txt"
