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

;==============================================================================
FUNCTION SAT_DAY, FILES, JDAY0, JDAY1, YEARS = YEARS, WEIGHTS = WEIGHTS
;==============================================================================
; NAME:   SAT_DAY
;
; PURPOSE:	Select SeaWiFS and MCSST and TOPEX files for a particular period of year.
; CATEGORY:
; CALLING SEQUENCE:		SAT_DAY, FILES, JDAY0, JDAY1 [, YEARS = YEARS]
;
; INPUTS:				FILES - an array of file names
;						JDAY0 - start julian day (day of year)
;						JDAY1 - end day of year
;
; KEYWORD PARAMETERS:	YEARS - array of year values e.g. [1998, 2001]
;								BUT only the year that contains the start of a season
;							E.G.  If you want 1999, 2000 summer values, then only input
;								[1999], or you'll get 2000-01 files too.
;						WEIGHTS - will return as array of weights for each file,
;						 based on the number of days (out of 8) that are covered
;
; OUTPUTS:				Outputs a new array of file names according to specs.
;						Keyword WEIGHTS accepts value out of 1.0 for contribution
;						 of each file to specified time.
;
; COMMON BLOCKS:
; EXAMPLES:  Just an e.g. of finding files

	;;------------------------------------------------------------------
	;FUNCTION get_files, mcsst = mcsst, seawifs = seawifs

	;On_Error, 2
	;IF keyword_set(mcsst) AND keyword_set(seawifs) THEN message, $
	;	'Set keyword mcsst OR seawifs, not both '

	;IF keyword_set(seawifs) THEN files =  findfile(filepath('*CHLO*', $
	;	subdirectory = '/resource/datafile/satdata'), count = num)
	;IF keyword_set(mcsst) THEN files = findfile(filepath('sd*', $
	;	subdirectory = '/resource/datafile/satdata'), count = num)
	;IF num LT 1 THEN message, 'No files found'
	;return, files
	;END
	;--------------------------------------------------------------------

;			Stuff I'm relunctant to throw but don't think matters
;			 to account for leap years.
;	;--------------------------------------------------------------------
;		   ;;define leap year (divisible by 4.0)
	;		I don't think this matters?  MDS 9Oct01
	;	F1 = FIX(year/4.0)
 	;	F2 = year/4.0
 	;	IF F1 NE F2 THEN jul_day0 = jday0 +1 & jul_day1 = jday1 + 1 ;just add one to period for leap years
;	;--------------------------------------------------------------------------------

; NOTES:	Currently user must beware of inputting files of same name that are
;				compressed, these aren't filtered out
;
; MODIFICATION HISTORY:  Written October 2001 MDSumner.
;				Embedded the weights option, still beware of including copies
;				 of compressed and uncompressed files, MDS 9Oct01.
;				Added WOCE TOPEX sea surface anomaly files, MDSumner 11Oct01.
;					http://podaac.jpl.nasa.gov/cdrom/woce2_topex/
;
;==============================================================================


;On_Error, 2

file_check, files   ;jump out if any copies in files array


   ;;first check for type of file, either SeaWiFS or MCSST
	;if not SeaWiFS then must be MCSST or not valid



file_name = files(0)



refpos = strpos(file_name, 'CHLO')
dyplus = -11			;the number of characters from refpos for end day and end year
yrplus = -15
offs = 7		;the number of days in SeaWiFS and MCSST weeks minus one
nc = -1
mcsst = -1			;set the not topex and not mcsst flag

IF refpos LT 0 THEN BEGIN
	refpos = strpos(file_name, 'sd')	;different positions in file names for MCSST
	dyplus = 6
	yrplus = 2
	offs = 7
	mcsst = 1
ENDIF

IF refpos LT 0 THEN BEGIN
	refpos = strpos(file_name, 'nc')	;e.g 'ssh05d19990910.nc'
	dyplus = -5
	yrplus = -9
	nc = 1    ;flag to tell following stuff what type of file
	offs = 9
ENDIF
	;just quit if not one of these
IF refpos LT 0 THEN message, 'Not a valid MCSST, SeaWiFS or TOPEX file '


NYflag = 0		;set a flag for crossing New Years
yr_chk2 = -1	;and one for
IF jday1 LT jday0 THEN BEGIN
	jday1 = jday1 + 365
	;IF mcsst EQ 1 THEN
	NYflag = 1

ENDIF
;IF jday1 LT jday0 THEN jday1 = jday1 + 365
;help, jday0, jday1

   ;set counter, then for each file
ik = -1
for n = 0, n_elements(files) - 1 do begin

	file_name = files(n)

	IF nc EQ 1 THEN BEGIN
		dd = STRMID(file_name, refpos + dyplus +2, 2) * 1
		mm = STRMID(file_name, refpos + dyplus, 2) * 1
		year = STRMID(file_name, refpos + yrplus,4) * 1

			;day of year, this is centre of 10 day period (bloody confusing!!)
			;http://podaac.jpl.nasa.gov/cdrom/woce2_topex/topex/docs/data_doc.htm
		day =   ymd2jd(year, mm, dd) - ymd2jd(year, 1, 1)
		day = day + 4   ;I assume 'center day' means the 12:00 that day, i.e. 10 is the
						;'center' of 5  6  7  8  9  10  11  12  13  14

	ENDIF ELSE BEGIN
		day = STRMID(file_name, refpos + dyplus, 3)  ;file end day
		day = day*1

		year = STRMID(file_name, refpos + yrplus,4)	;file end year
		year = year*1
	ENDELSE
		;kick over New Years, include previous year for check
	IF NYflag EQ 1 THEN day = day + 365	& year2 = year - 1

		;redefine jdays for this loop
	jul_day0 = jday0
	jul_day1 = jday1


	start0 = day - jul_day0
	start1 = day - jul_day1
	;end0 = day - offs - jul_day0
	;end1 = day - offs - jul_day1
	end0 = day - offs - jul_day0
	end1 = day - offs - jul_day1

		;this old line is replaced by subtractions above, and shorter line below (to get weights)
	;IF day  GE jul_day0 AND day LE jul_day1 OR day - offs GE jul_day0 AND day - offs LE jul_day1 THEN BEGIN

		;
	IF start0  GE 0 AND start1 LE 0 OR end0 GE 0 AND end1 LE 0 THEN BEGIN

		   ;first check that this is within specified years, if this option specified
		yr_ok = 1
		IF keyword_set(years) THEN BEGIN
			yr_chk = where(years EQ year)			;was this file's year asked for?
			IF NYflag EQ 1 THEN yr_chk2 = where(years EQ year2)  ;how about NYear straddlers?
	;		help, yr_chk
	;		print, yr_chk
			IF yr_chk(0) NE -1 OR yr_chk2(0) NE - 1 THEN yr_ok = 1 ELSE yr_ok = -1   ;assign check flag
		ENDIF
	;	help, yr_ok

			;first time thru, and yr_ok and within period then save the file's subscript
		IF ik EQ -1 THEN BEGIN
			IF yr_ok EQ 1 THEN BEGIN	;if check flag OK
				good = n
				ik = 1					;assign counter flag
			ENDIF
			;then concatenate the rest of the ok ones
		ENDIF ELSE BEGIN
			IF yr_ok EQ 1 THEN good = [good, n]
		ENDELSE

	;IF keyword_set(weights) THEN BEGIN
	;help, start0, start1, end0, end1
	help, day,  jul_day0, jul_day1
		print, file_name
   	IF start0 LT offs and start0 GE 0 and end0 LT offs and end0 GE 0 THEN BEGIN
   		print, 'shit!'
   		stop
	ENDIF
	;stop
		;calculate proportion of this file that makes it in

	IF start0 LT offs AND start0 GE 0  THEN BEGIN

		cover = (start0+1)/(offs*1.0 + 1)

	ENDIF ELSE BEGIN

		IF  0 - end1 LT offs AND 0 - end1 GE 0 THEN BEGIN

			cover = (1 -end1)/(offs*1.0 + 1)

		ENDIF ELSE cover = 1.0

	ENDELSE
	help, cover

		IF n_elements(good) LE  1 THEN weights = cover ELSE weights = [weights, cover]

	;IF n_elements(weights) GT n_elements(good) THEN stop


	;print, 'in OK loop'
	;help, day, jul_day0, jul_day1
	;print, file_name
	;help, good
	;help, year
	;stop

	ENDIF

endfor

IF n_elements(good) GT 0 THEN files2 = files(good) ELSE message, 'No files in specified period'



return, files2
END

;---------------------------------------------------------------------------------------

