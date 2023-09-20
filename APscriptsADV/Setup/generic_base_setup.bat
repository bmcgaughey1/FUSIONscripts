rem **************************************************************************************************************
rem *****             setup batch file used in conjunction with FUSION's AreaProcessor tool                  *****
rem *****                                                                                                    *****
rem *****     Used to set up folder structure for data and variables to control run for producing output     *****
rem *****                                 from point and surface data                                        *****
rem **************************************************************************************************************
rem REVISION HISTORY
rem Pre June 2015...lots of changes
rem Jun 23, 2015: Added intensity image related settings and cleaned up some comments
rem Sept 1, 2015: Added AP_PROCESSINGHOME variable and logic to record the folder name for secondary scripts to the output folder
rem Oct 2, 2015: changed logic for segmentation to let us use a higher-resolution CHM
rem Apr 28, 2016: added DOMORTALITY switch
rem June 17, 2016: major changes to use area-specific parameters/options from AreaProcessor. If you use this
rem setup script with a version of AreaProcessor prior to V1.60 or with a parameter file from earlier versions
rem you need to really check the "default" values for all of the area-specific information (just below the "line").
rem June 27, 2016: rearranged this file to better group related items and to move to a generic setup file
rem for all runs. This setup file now reads area-specific information from the variables created by AreaProcessor
rem so you don't have to have area-specific information in the file.
rem Aug 14, 2017 made changes to clip points using tree segments. Tied to DOSEGMETRICS. Change deals with creating
rem a new folder for the point clips in the BLOCKs...this folder should be empty after a run is finished.
rem July 12, 2019 made changes to create correct folders when doing runs that produce first return metrics but
rem not all return metrics.
rem **************************************************************************************************************

rem ###########################################################
rem           Overall options to compute metrics
rem ###########################################################

rem DOMETRICS controls whether gridmetrics is run using all returns
rem DOFIRSTMETRICS controls whether gridmetrics is separately run to calculate metrics using only first returns
rem DOSTRATA controls whether gridmetrics using all returns produces metrics for strata breaks at 0.5,1,2,4,8,16,32,48,64 m
rem DOCANOPY controls whether canopy surface models are created and whether gridsurfacestats is run
rem DOSPECIALCANOPY controls whether specialized canopy surfaces are created...in general the extra products provide information to assess canopy penetration
rem DOGROUND controls whether a ground model is created; if not, the vendor's ground model is used
rem DOINTENSITY controls whether intensity images ae created
rem DOMULTITOPO controls whether landscape, 30 m topographic metrics are calculated for radii of 500,1000,2000,4000 m
rem DOFINEMULTITOPO controls whether local, 1 m topographic metrics are calculated for radii of 10,20,30,60 m
rem DOSEGMENTS controls whether or not the segmentation is run on the blocks (TAOs)...you must have DOCANOPY set to true to do the segmentation
rem DOSEGMETRICS controls whether or not metrics for individual crown polygons are created...you must have DOCANOPY and DOSEGMENTS set to true to do the metrics
rem DOMORTALITY controls whether or not intensity images and return count layers are produced to look at possible mortality detection using the tree segments
rem You must set DOCANOPY, DOSEGMENTS, DOSEGMETRICS and DOMORTALITY to true to produce the intensity images, return count layers, and tree segment metrics
rem
rem For the current set of processing scripts, you always have to create canopy height models when doing any of the other metrics because we adjust all of 
rem the other layers to match the extent of the CHM stats (rumple). This means that DOCANOPY is always TRUE unless you are only doing ground or intensity images.
rem if DOCANOPY is FALSE and CANOPYALIGNTORUMPLE is TRUE, things will not process correctly and you will have lots of errors.
rem
SET DOMETRICS=TRUE
SET DOFIRSTMETRICS=TRUE
SET DOSTRATA=TRUE
SET DOCANOPY=TRUE
SET DOSPECIALCANOPY=TRUE
SET DOGROUND=FALSE
SET DOINTENSITY=TRUE
SET DOMULTITOPO=TRUE
SET DOFINEMULTITOPO=FALSE
SET DOSEGMENTS=FALSE
SET DOSEGMETRICS=FALSE
SET DOMORTALITY=FALSE

rem the "line"
rem ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rem = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
rem ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rem nothing below the "line" should require changes for "standard" processing

rem compute strata metrics using only first returns
SET DOFIRSTSTRATA=FALSE

rem We generally don't use the /topo option in GridMetrics (controlled by DOTOPO). 
rem Instead we run the separate TopoMetrics program (controlled by DOMULTITOPO and DOFINEMULTITOPO). TopoMetrics
rem allows you to compute topographic metrics using different window sizes in a single run.
SET DOTOPO=FALSE

rem flag to control conversion of all outputs to IMAGINE format. the default format is ASCII raster. IMAGINE format is much more compact
rem and the files contain embedded projection information. projection info for ASCII raster files is help in a separate .PRJ file.
SET CONVERTTOIMG=TRUE

rem flag to delete intermediate ASCII raster files and intermediate BMP files (intensity images). You can set this to TRUE to keep the "fluffy" files
rem but they use up quite a bit of disk space.
SET KEEPASCIIFILES=FALSE

rem flag to omit intensity metrics when running GridMetrics. This really doesn't save much time so we leave it FALSE
SET OMITINTENSITY=FALSE

rem FILTERPOINTS controls the behavior used to identify bare-ground points. If TRUE and DOGROUND is TRUE, GroundFilter is used to 
rem identify bare-ground points from the full point cloud and the resulting point files are used to create the gridded ground models.
rem If FALSE and DOGROUND is TRUE, points classified as bare ground (class 2) in LAS files are used to build ground surfaces.
SET FILTERPOINTS=FALSE

rem set variables to control merging of block outputs after all processing is complete. The final merge only occurs for jobs processed using blocks.
rem These variables are also set in the standard preblock.bat file but the values specified here will override those set in preblock.bat.
rem In general, we merge 30m metrics and other products using larger cells and do not merge any of the high-resolution outputs.
SET MERGEBLOCKMETRICS=TRUE
SET MERGEBLOCKCANOPY=FALSE
SET MERGEBLOCKGROUND=FALSE
SET MERGEBLOCKTOPOMETRICS=TRUE
SET MERGEBLOCKFINETOPOMETRICS=FALSE

rem we currently have no way to merge image outputs so MERGEBLOCKINTENSITY should always be FALSE
SET MERGEBLOCKINTENSITY=FALSE

rem if CANOPYALIGNTORUMPLE is TRUE, you must also have DOCANOPY set to TRUE so there are CHMs and canopy surface metrics to use for alignment
rem we don't need to align things to rumple layers any more (4/28/2016) so this should always be FALSE
SET CANOPYALIGNTORUMPLE=FALSE

rem ###########################################################
rem           Pick up variables from AreaProcessor
rem ###########################################################

rem set the overall name for the area. This will be incorporated into output folder names
rem pick up the value from the area-specific parameters in AreaProcessor, otherwise use a default
IF "%AP_AREANAME%"=="" (
   SET AREA=MyArea
) ELSE (
   SET AREA=%AP_AREANAME%
)

rem coordinate system 0=state plane, 1=UTM, 2=other
rem coordinate system info is not used for much...if using something other than state plane or UTM, set COORDSYSTEM=2 and COORDZONE=0
rem if you try to merge data with different coordinate systems, the merge tools will report the difference and fail gracefully.
IF "%AP_COORDSYSTEM%"=="" (
   SET COORDSYSTEM=1
) ELSE (
   SET COORDSYSTEM=%AP_COORDSYSTEM%
)
IF "%AP_COORDZONE%"=="" (
   SET COORDZONE=10
) ELSE (
   SET COORDZONE=%AP_COORDZONE%
)

rem set the latitude for the approximate center of the project area. This is only used for solar radiation index calculations.
IF "%AP_LATITUDE%"=="" (
   SET LATITUDE=40.00
) ELSE (
   SET LATITUDE=%AP_LATITUDE%
)

rem set UNITS for the project...can be FEET or METERS
rem these are the units for the input data; output will be in METERS
IF "%AP_UNITS%"=="" (
   SET UNITS=METERS
) ELSE (
   SET UNITS=%AP_UNITS%
)

rem range for Catalog call to create intensity images...must be min,max with no extra spaces
rem You will need to examine some LAS files to figure out this range. Intensity can be 8 bit (values from 0-255) or 16-bit (values from 0-64,536)
rem Use a range from -1 to the maximum value-1. this will prevent any pixels in the image from having a value of 0 when the cell contains data. The background of
rem the image is set to RGB(0,0,0) so you can identify all areas with a value of 0 in the grayscale image as NODATA.
rem Many data sets don't use the full range of values so youi really need to look at some data to figure out a good range. You can do this in FUSION using the 
rem Tools...Miscellaneous utilities...Create an image using LIDAR point data menu option or by experimenting with the sample options using "Color by intensity"
rem and examining the range of values in samples.
rem
IF "%AP_INTENSITYRANGE%"=="" (
   SET INTENSITYRANGE=-1,254
) ELSE (
   SET INTENSITYRANGE=%AP_INTENSITYRANGE%
)

rem CLASSOPTION is used to include/exclude points with specific LAS classification values
rem The option should include the leading "/" character
rem The CLASSOPTION is added to calls to GroundFilter, CanopyModel, Catalog (for intensity images) and GridMetrics in tile.bat
rem Class 7 points are low noise, class 9 is water. NCALM has been known to set noise points to class 9
IF "%AP_CLASSOPTION%"=="" (
   SET CLASSOPTION=/class:~7,9
) ELSE (
   SET CLASSOPTION=%AP_CLASSOPTION%
)

rem directory where the user-supplied auxiliary processing scripts are stored...this can be anywhere but we try to use the same set of
rem scripts for all runs. All of the files in the specified folder will be copied to the FINAL products folder so you should always try
rem to keep all of the auxiliary scripts in the same folder. Auxiliary scripts are those that are called from the scripts specified in 
rem AreaProcesor's "Processing scripts" dialog.
rem If this folder is specified in AreaProcessor, it will be used through all the scripts. If a folder is not specified in AreaProcessor
rem the folder must be explicitly specified in the setup batch file.
rem
rem Use the folder specified in AreaProcessor. This folder should stay the same for all runs unless you have a good reason to change it.
rem original location just in case someone changes things: C:\FUSION\AP_ProcessingScripts
IF "%AP_PROCESSINGHOME%"=="" (
   SET PROCESSINGHOME=C:\FUSION\AP_ProcessingScripts
) ELSE (
   SET PROCESSINGHOME=%AP_PROCESSINGHOME%
)

rem Set the file used to associate projection info with all output layers...this file is associated with all ASCII raster file outputs.
rem The projection file is a .PRJ file that will be copied for each layer of metrics. This is not a required file but it makes the output layers
rem much easier to work with in GIS. In AreaProcessor, you can optionally specify the projection file. If this is done, the AP_PROJECTIONFILE
rem will contain the file name. Otherwise, AP_PROJECTIONFILE will not be defined so you must specify your own projection file name.
rem Make sure the projection file is the correct format (all data on 1 line) or else the conversion from ASCII raster to ither formats
rem will not have projection info (gdal_translate doesn't recognize multi-line projection files)
IF "%AP_PROJECTIONFILE%"=="" (
   SET BASEPRJ=%PROCESSINGHOME%\utm10.prj
) ELSE (
   SET BASEPRJ=%AP_PROJECTIONFILE%
)

rem ###########################################################
rem           GDAL installation information
rem ###########################################################
rem location where gdal_translate is installed...full path with drive letter...DO NOT enclose the path in quotation marks
rem look for a separate configuration file and use it if found, otherwise set the "standard" GDAL install location
IF EXIST "%PROCESSINGHOME%\ComputerSpecific\GDALconfig.bat" (
   CALL %PROCESSINGHOME%\ComputerSpecific\GDALconfig.bat
) ELSE (
   SET GDAL_TRANSLATE_LOCATION=C:\Program Files\GDAL\gdal_translate
   SET GDAL_DATA=C:\Program Files\GDAL\gdal-data
)

rem ###########################################################
rem           Parameters for ground filtering
rem ###########################################################
rem set variables for ground point filtering and surface creation
IF /I [%UNITS%]==[feet] (
	SET GROUNDCELLSIZE=5
	SET FILTERCELLSIZE=20
) ELSE (
	SET GROUNDCELLSIZE=1
	SET FILTERCELLSIZE=6
)
SET GROUNDFILEIDENTIFIER=%GROUNDCELLSIZE:.=p%%UNITS%

rem ###########################################################
rem           Parameters for general processing
rem ###########################################################
rem set variables to establish grid cell size, height cutoffs, coordinate system info for grids, and outlier limits
rem set up for topo metrics using multiple window sizes...also uses the TOPOCELLSIZE and LATITUDE variables
IF /I [%UNITS%]==[feet] (
	SET CELLSIZE=98.424
	SET HTCUTOFF=6.5616
	SET COVERCUTOFF=6.5616
	SET COORDINFO=f f %COORDSYSTEM% %COORDZONE% 2 2
	SET OUTLIER=-98.424,492.12
	SET MULTIPLIER=0.3048
	SET TOPOCELLSIZE=98.424
	SET INTENSITYCELLSIZE=4.9212
	SET INTENSITYCELLAREA=24.2182
	SET MULTITOPOWINDOWSIZES=49.212,147.636,442.908,885.816
	SET MULTITPIWINDOWSIZES=656.16,1640.40,3280.80,6561.60,13123.2
	SET FINETOPOCELLSIZE=3.2808
	SET FINEMULTITOPOWINDOWSIZES=16.404,32.808,49.212,98.424,196.848
	SET FINEMULTITPIWINDOWSIZES=32.808,65.616,98.424,196.848,393.696
) ELSE (
	SET CELLSIZE=30
	SET HTCUTOFF=2
	SET COVERCUTOFF=2
	SET COORDINFO=m m %COORDSYSTEM% %COORDZONE% 2 2
	SET OUTLIER=-30,150
	SET MULTIPLIER=1
	SET TOPOCELLSIZE=30
	SET INTENSITYCELLSIZE=1.5
	SET INTENSITYCELLAREA=2.25
 	SET MULTITOPOWINDOWSIZES=15,45,135,270
	SET MULTITPIWINDOWSIZES=200,500,1000,2000,4000
	SET FINETOPOCELLSIZE=1
	SET FINEMULTITOPOWINDOWSIZES=5,10,15,30,60
	SET FINEMULTITPIWINDOWSIZES=10,20,30,60,120
)

rem set variables for strata calculation and output
rem number of layers is figured out from the list of height breaks
IF /I [%UNITS%]==[feet] (
	SET STRATAHEIGHTS=1.6404,3.2808,6.5616,13.1232,26.2464,52.4928,104.9856,157.4784,209.9712
) ELSE (
	SET STRATAHEIGHTS=0.5,1,2,4,8,16,32,48,64
)

rem set variables for canopy height models and GridSurfaceStats
rem The coarse resolution CHMs only get created when DOSPECIALCANOPY is true.
IF /I [%UNITS%]==[feet] (
	SET CANOPYCELLSIZE=3.2808
	SET CANOPYCELLSIZE1=4.9212
	SET CANOPYCELLSIZE2=6.5616
	SET CANOPYSTATSCELLMULTIPLIER=30
) ELSE (
	SET CANOPYCELLSIZE=1.0
	SET CANOPYCELLSIZE1=1.5
	SET CANOPYCELLSIZE2=2.0
	SET CANOPYSTATSCELLMULTIPLIER=30
)

rem ###########################################################
rem           Parameters for TAO segmentation
rem ###########################################################
rem set identifers for the segmentation
IF /I [%UNITS%]==[feet] (
	SET SEG_CANOPYCELLSIZE=2.4606
	SET SEG_HTCUTOFF=6.5616
) ELSE (
	SET SEG_CANOPYCELLSIZE=0.75
	SET SEG_HTCUTOFF=2
)

rem command line options for the CHM for segmentation...you can use /smooth or /median...additional options are added in the tile processing script
rem /rasterorigin forces the CHM used for segmentation to have an origin such that the segment raster layers will align with our standard metric layers
SET SEG_CHM_OPTIONS=/smooth:3 /rasterorigin

rem ###########################################################
rem           Labels for output folders and files
rem ###########################################################
rem set file identifiers for topo metrics
SET TOPOFILEIDENTIFIER=%TOPOCELLSIZE:.=p%%UNITS%
SET FINETOPOFILEIDENTIFIER=%FINETOPOCELLSIZE:.=p%%UNITS%

rem set file identifier for intensity images
SET INTENSITYFILEIDENTIFIER=%INTENSITYCELLSIZE:.=p%%UNITS%

REM Set file identifier for intensity images
SET CANOPYFILEIDENTIFIER=%CANOPYCELLSIZE:.=p%%UNITS%

REM Build identifiers for canopy metrics...This assumes that the canopy metrics use the same cell size as the basic cell size. If this is not the
REM case, you must must set the identifier for the canopy stats explicitly since we can't do floating point math using the SET /A command.
REM The size would be CANOPYCELLSIZE * CANOPYSTATSCELLMULTIPLIER if we could do the math.
SET CANOPYSTATSFILEIDENTIFIER=%CELLSIZE:.=p%%UNITS%

REM IF /I [%UNITS%]==[feet] (
REM	SET CANOPYSTATSFILEIDENTIFIER=98p424%UNITS%
REM ) ELSE (
REM	SET CANOPYSTATSFILEIDENTIFIER=30%UNITS%
REM)

SET CANOPYFILEIDENTIFIER1=%CANOPYCELLSIZE1:.=p%%UNITS%
SET CANOPYFILEIDENTIFIER2=%CANOPYCELLSIZE2:.=p%%UNITS%

SET SEG_CANOPYFILEIDENTIFIER=%SEG_CANOPYCELLSIZE:.=p%%UNITS%

rem build cell size identifier...used for folders and filenames
SET FILEIDENTIFIER=%CELLSIZE:.=p%%UNITS%

rem ###########################################################
rem           Set up folder names for outputs
rem ###########################################################
rem directory where outputs will be stored...WORKINGDIRECTORY is defined in the master script for the job
rem The output folder is named using the AREA name and the RUNDATE
IF "%BLOCKNAME%"=="" (
   SET PRODUCTHOME=%WORKINGDIRNAME%\Products_%AREA%_%AP_RUNDATE%
   SET FINALPRODUCTHOME=%WORKINGDIRNAME%\Products_%AREA%_%AP_RUNDATE%
) ELSE (
   SET PRODUCTHOME=%WORKINGDIRNAME%\Products_%AREA%_%AP_RUNDATE%\%BLOCKNAME%

   rem create the directory name for the merged layers
   SET FINALPRODUCTHOME=%WORKINGDIRNAME%\Products_%AREA%_%AP_RUNDATE%\FINAL_%AREA%_%AP_RUNDATE%
)

rem file specifier for bare-ground .DTM files...can be path and name of text file with list of .DTM files, a single file name, or a file
rem specifier that uses wild card characters.
rem AP_BAREGROUND is defined in the scripts generated by the AreaProcessor tool if the user specifies bare-ground files.
rem If you are building ground files on-the-fly (DOGROUND is TRUE), we need to set the specifier to point to the files created by
rem GridSurfaceCreate or any other tool used to produce the gridded surface files.
IF /I [%DOGROUND%]==[true] (
	SET DTMSPEC=%PRODUCTHOME%\BareGround_%GROUNDFILEIDENTIFIER%\*_BUFFERED.dtm
) ELSE (
	SET DTMSPEC=%AP_BAREGROUND%
)

rem Set up a file to record output folders for all blocks. As blocks are processed, the output folder will be added to the file.
rem The post-block processing script will use this list to build a list of outputs for the blocks. We expect this file to only get
rem some of the block output folders for multi-process jobs since different processes will try to write to the file at the same time.
rem This is OK as we only need the name of one output folder (block) to build the list of outputs for the final merges.
ECHO %PRODUCTHOME%>>"%WORKINGDIRNAME%\OutputFolders.txt"

rem ###########################################################
rem           Create directory structure for outputs
rem ###########################################################
CD "%WORKINGDIRNAME%"
MKDIR "%PRODUCTHOME%"
MKDIR "%PRODUCTHOME%\TileMetrics_%FILEIDENTIFIER%"
IF /I "%DOGROUND%"=="true" MKDIR "%PRODUCTHOME%\BareGround_%GROUNDFILEIDENTIFIER%"
IF /I "%DOCANOPY%"=="true" MKDIR "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%"
IF /I "%DOSPECIALCANOPY%"=="true" MKDIR "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%"
IF /I "%DOSPECIALCANOPY%"=="true" MKDIR "%PRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%"
IF /I "%DOCANOPY%"=="true" MKDIR "%PRODUCTHOME%\CanopyMetrics_%CANOPYSTATSFILEIDENTIFIER%"
IF /I "%DOSEGMENTS%"=="true" MKDIR "%PRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%"
IF /I "%DOSEGMENTS%"=="true" MKDIR "%PRODUCTHOME%\CanopyHeight_%SEG_CANOPYFILEIDENTIFIER%"
IF /I "%DOMORTALITY%" == "true" MKDIR "%PRODUCTHOME%\SegmentClips"
IF /I "%DOMETRICS%"=="true" MKDIR "%PRODUCTHOME%\Metrics_%FILEIDENTIFIER%"
IF /I "%DOFIRSTMETRICS%"=="true" MKDIR "%PRODUCTHOME%\Metrics_%FILEIDENTIFIER%"
IF /I "%DOINTENSITY%"=="true" MKDIR "%PRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%"
IF /I "%DOMULTITOPO%"=="true" MKDIR "%PRODUCTHOME%\TopoMetrics_%TOPOFILEIDENTIFIER%
IF /I "%DOFINEMULTITOPO%"=="true" MKDIR "%PRODUCTHOME%\FineTopoMetrics_%FINETOPOFILEIDENTIFIER%
IF /I "%DOSTRATA%"=="true" MKDIR "%PRODUCTHOME%\StrataMetrics_%FILEIDENTIFIER%

rem MKDIR "%PRODUCTHOME%\QAQC"

rem create directory structure for final outputs
rem we always need the home folder because we copy the batch files into a subfolder
MKDIR "%FINALPRODUCTHOME%"
IF NOT "%BLOCKNAME%"=="" (
   rem create directory structure for merged outputs
   IF /I "%DOGROUND%"=="true" MKDIR "%FINALPRODUCTHOME%\BareGround_%GROUNDFILEIDENTIFIER%"
   IF /I "%DOCANOPY%"=="true" MKDIR "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%"
   IF /I "%DOSPECIALCANOPY%"=="true" MKDIR "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%"
   IF /I "%DOSPECIALCANOPY%"=="true" MKDIR "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%"
   IF /I "%DOCANOPY%"=="true" MKDIR "%FINALPRODUCTHOME%\CanopyMetrics_%CANOPYSTATSFILEIDENTIFIER%"
   IF /I "%DOSEGMENTS%"=="true" MKDIR "%FINALPRODUCTHOME%\Segments_%SEG_CANOPYFILEIDENTIFIER%"
   IF /I "%DOSEGMENTS%"=="true" MKDIR "%FINALPRODUCTHOME%\CanopyHeight_%SEG_CANOPYFILEIDENTIFIER%"
   IF /I "%DOMETRICS%"=="true" MKDIR "%FINALPRODUCTHOME%\Metrics_%FILEIDENTIFIER%"
   IF /I "%DOFIRSTMETRICS%"=="true" MKDIR "%FINALPRODUCTHOME%\Metrics_%FILEIDENTIFIER%"
   IF /I "%DOINTENSITY%"=="true" MKDIR "%FINALPRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%"
   IF /I "%DOMULTITOPO%"=="true" MKDIR "%FINALPRODUCTHOME%\TopoMetrics_%TOPOFILEIDENTIFIER%
   IF /I "%DOFINEMULTITOPO%"=="true" MKDIR "%FINALPRODUCTHOME%\FineTopoMetrics_%FINETOPOFILEIDENTIFIER%
   IF /I "%DOSTRATA%"=="true" MKDIR "%FINALPRODUCTHOME%\StrataMetrics_%FILEIDENTIFIER%
)

rem ###########################################################
rem           Copy the batch files used for processing
rem ###########################################################
rem copy the setup batch file...%0 is the full path to the currently running file...this means that the setup batch file can be in a different folder
rem than all the other batch files
rem also copy the original projection file to the scripts folder
IF NOT EXIST "%FINALPRODUCTHOME%\Scripts" (
	MKDIR "%FINALPRODUCTHOME%\Scripts"
	ECHO %PROCESSINGHOME%>%FINALPRODUCTHOME%\Scripts\AccessoryScriptFolder.txt
	COPY "%PROCESSINGHOME%\*.*" "%FINALPRODUCTHOME%\Scripts"
	COPY %0 "%FINALPRODUCTHOME%\Scripts"
	COPY "%BASEPRJ%" "%FINALPRODUCTHOME%\Scripts"
	
	rem copy the index shapefiles for the processing layout
	MKDIR "%FINALPRODUCTHOME%\Layout_shapefiles"
	COPY "%WORKINGDIRNAME%\%RUNIDENTIFIER%_DeliveryTiles.*" "%FINALPRODUCTHOME%\Layout_shapefiles"
	COPY "%WORKINGDIRNAME%\%RUNIDENTIFIER%_ProcessingTiles.*" "%FINALPRODUCTHOME%\Layout_shapefiles"
	COPY "%WORKINGDIRNAME%\%RUNIDENTIFIER%_ProcessingBlocks.*" "%FINALPRODUCTHOME%\Layout_shapefiles"
	COPY "%WORKINGDIRNAME%\%RUNIDENTIFIER%_GroundModels.*" "%FINALPRODUCTHOME%\Layout_shapefiles"
	COPY "%WORKINGDIRNAME%\%RUNIDENTIFIER%_DensityLayers.*" "%FINALPRODUCTHOME%\Layout_shapefiles"
)

rem change back to processing home directory...important so all tasks know where they start in the directory structure
CD "%PROCESSINGHOME%"
