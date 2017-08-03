;==============================================================================
; NAME:	FIND_SAT_FILES
;
; PURPOSE:	To find files of satellite data from the default directory in UNIX or Win32.

; CATEGORY:
; CALLING SEQUENCE:  FILES = FIND_SAT_FILES(/TYPE)
;						TYPE - one of /mcsst, /seawifs, /topex
;
; FUNCTIONS:  GET_FILES - this finds the names of all available files
;			  DT_TM_TOJS -JHU program that converts string input of date to julian seconds
;			  JS2YMDS  - JHU converts julian second to year, month, day second
;			  YDNS2JS - JHU year, day number to js
;
; PROCEDURES: FILE_CHECK - this makes sure no copies of files are used
;
; INPUTS:	TIME0
;			TIME1 - start and end times for required period (in julian seconds from
;					FILTCELLARC or as a string which is passed to DT_TM_TOJS.PRO and converted)
;				-if format is string, date must be separated like '29 JAN 00' or '29,jan,00',
;					 not '29JAN00'  -see DT_TM_TOJS from John Hopkins University
;
; KEYWORD PARAMETERS:	MCSST - retrieve MCSST files
;						SEAWIFS - retrieve Level 3 (weekly) SMI SeaWiFS files
;						TOPEX
;						http://podaac.jpl.nasa.gov/cdrom/woce2_topex/topex/docs/data_doc.htm
;						ANNUAL - (in conjunction with SEAWIFS keyword) - retrieve L3
;								SMI annual SeaWiFS files
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;			With annual keyword set, the year previous to time0 is selected and that file used.
;
; MODIFICATION HISTORY:  Written October01 MDSumner, AWRU.
;			Added annual keyword to select yearly seawifs files from FILTCELLARC,
;			MDSumner 30Oct01.
;==============================================================================
;------------------------------------------------------------------------------------
FUNCTION GET_FILES, MCSSTDAY = MCSSTDAY, MCSSTNIGHT = MCSSTNIGHT,  SEAWIFS = SEAWIFS,$
	 TOPEX1 = TOPEX1, TOPEX05 = TOPEX05,  ANNUAL = ANNUAL
;-------------------------------------------------------------------------------------
OS = STRUPCASE(!version.os)
IF OS EQ 'WIN32' THEN BEGIN

	IF keyword_set(seawifs) AND NOT keyword_set(annual) THEN $
		files = findfile(filepath('*CHLO*', root_dir = 'G:\', subdirectory = 'satdata\SW_chla\weekly'))
	IF keyword_set(seawifs) AND keyword_set(annual) THEN $
		files = findfile(filepath('*YR_CHLO*', root_dir = 'G:\', subdirectory = 'satdata\SW_chla\annual'))
	IF keyword_set(mcsstday) THEN $
		files = findfile(filepath('*hdf*', root_dir = 'G:\', subdirectory = 'satdata\MCSST\day'))
	IF keyword_set(mcsstnight) THEN $
		files = findfile(filepath('*hdf*', root_dir = 'G:\', subdirectory = 'satdata\MCSST\night'))
	IF keyword_set(topex1) THEN $
		files = findfile(filepath('*nc*', root_dir = 'G:\', subdirectory = 'satdata\topex\onedegree'))
	IF keyword_set(topex05) THEN $
		files = findfile(filepath('*nc*', root_dir = 'G:\', subdirectory = 'satdata\topex\halfdegree'))
ENDIF
IF OS EQ 'SUNOS' THEN BEGIN

	IF keyword_set(seawifs) THEN files = findfile('./satdata/seawifs/*CHLO*')
	IF keyword_set(mcsst) THEN files = findfile('./satdata/mcsst/*hdf*')
	IF keyword_set(topex) THEN files = findfile('./satdata/topex/*nc*')
ENDIF


return, files

END
;-------------------------------------------------------------------------------
;--------------------------------------------------------------------------------
PRO file_check, files


;this is to check if there are copies of sat files, some compressed some not or
;some with the .Z as well as .gz extension
checkfiles = files
;filechk = where(strpos(strupcase(files), '.GZ') GT 0 OR strpos(strupcase(files), '.Z') GT 0)

   ;for every compressed .GZ or .Z file

for n = 0, n_elements(files) - 1 do begin
	;bad = -1
	filenm = strupcase(files(n))
	comp1 = strpos(filenm, '.Z')
	comp2 = strpos(filenm, '.GZ')
	IF comp1 GT 0 THEN filenm = strmid(filenm, 0, strlen(filenm) - 2)
	IF comp2 GT 0 THEN filenm = strmid(filenm, 0, strlen(filenm) - 3)
	checkfiles(n) = filenm

ENDFOR

files = files(uniq(checkfiles, sort(checkfiles)))

END
;----------------------------------------------------------------------------------

;----------------------------------------------------------------------------------
FUNCTION FIND_SAT_FILES, TIME0, TIME1,  $
	MCSSTDAY = MCSSTDAY, MCSSTNIGHT = MCSSTNIGHT,  SEAWIFS = SEAWIFS, TOPEX1 = TOPEX1, $
		TOPEX05 = TOPEX05,ANNUAL = ANNUAL

IF size(time0, /type) EQ 7 THEN BEGIN
	time0 = dt_tm_tojs(time0)
	time1 = dt_tm_tojs(time1)
ENDIF

;On_Error, 3

  ;first get all the files available

IF n_elements(files) EQ 0 THEN files = GET_FILES(MCSSTDAY = MCSSTDAY, SEAWIFS = SEAWIFS, $
	TOPEX1 = TOPEX1, TOPEX05 = TOPEX05, ANNUAL = ANNUAL)

  ;for annual case, determine year of start time
IF keyword_set(annual) THEN BEGIN
	js2ymds, time0, an_y, am, ad, as
ENDIF

;check there aren't redundant copies of files
file_check, files

  ;select those that are in the right time period
good = -1   ;set the good flag

FOR n = 0, n_elements(files) - 1 do begin
	file_name = files(n)
	refpos = strpos(file_name, 'CHLO')   ;get a ref point in file name string
	dyplus = -11			;the number of characters from refpos for end day and end year
	yrplus = -15
	offs = 7		;the number of days in SeaWiFS and MCSST weeks minus one for offset
	nc = -1
	mcsst = -1			;set the not topex and not mcsst flag
	mess = 'seawifs'    ;this is message to user later if no files found
	IF refpos LT 0 THEN BEGIN
		refpos = strpos(file_name, 'sd')	;different positions in file names for MCSST
		dyplus = 6
		yrplus = 2
		offs = 7
		mcsst = 1
		mess = 'mcsst'
	ENDIF

	IF refpos LT 0 THEN BEGIN
		refpos = strpos(file_name, 'nc')	;e.g 'ssh05d19990910.nc'
		dyplus = -5
		yrplus = -9
		nc = 1    ;flag to tell following stuff what type of file
		offs = 9
		mess = 'topex'
	ENDIF

	;just quit if not one of these

	IF refpos LT 0 THEN BEGIN
		print,  file_name + 'Not a valid MCSST, SeaWiFS or TOPEX file '
		return, -1
	ENDIF

	IF nc EQ 1 THEN BEGIN  ;for topex case
				;file time
		file_dd = STRMID(file_name, refpos + dyplus +2, 2) * 1
		file_mm = STRMID(file_name, refpos + dyplus, 2) * 1
		file_year = STRMID(file_name, refpos + yrplus,4) * 1

			;day of year, this is centre of 10 day period (bloody confusing!!)
			;http://podaac.jpl.nasa.gov/cdrom/woce2_topex/topex/docs/data_doc.htm
		;day =   ymd2jd(file_year, mm, dd)
		file_dd = file_dd + 4   ;I assume 'center day' means the 12:00 that day, i.e. 10 is the
						;'center' of 5  6  7  8  9  10  11  12  13  14
		js = ymds2js(file_year, file_mm, file_dd, 0)  ;convert file time to js
	ENDIF ELSE BEGIN
		file_doy = STRMID(file_name, refpos + dyplus, 3)*1  ;file end day
		file_year = STRMID(file_name, refpos + yrplus,4)*1	;file end year


			;do for annual case, and return with one file or none without continuing other stuff
		IF keyword_set(annual) THEN BEGIN
			IF file_year  EQ an_y -1 THEN BEGIN
				files2 = files(n)
				return, files2  ;just hop out with one file when right year found
			ENDIF
			IF n EQ n_elements(files) - 1 THEN message, 'No files found ' ;jump out if no annual files
		ENDIF


		   ;convert file time to js
		js = ydns2js(file_year, file_doy)
	ENDELSE

	   ;now check that the file js is within the input time0, time1
	 IF js LT time1 AND js - (offs*24*3600) GT time0 THEN BEGIN
	 	IF good(0) EQ - 1 THEN good = n ELSE good = [good, n]
	ENDIF

ENDFOR
IF good(0) GT 0 THEN BEGIN
	files2 = files(good)
ENDIF ELSE BEGIN
	print, 'No ', mess, ' files in specified period'
	files2 = -1
ENDELSE
return, files2

END

;---------------------------------------------------------------------------------------



