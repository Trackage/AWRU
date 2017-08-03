;==============================================================================
; NAME:
;       GL2PTT
; PURPOSE:
;       Read Geo-Location TDR data (GLTDR) as ouputted
;       from a PC that analyses the light levels and computes
;       day (and sometimes night) positions.

; CATEGORY:
; CALLING SEQUENCE:
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;	  modified from a program written by DJW Mar 2000, KJM April 2000.
;	  Comments added May 2001, M.Sumner, AWRU.
;		Added option for classes to be read from .csv file, when they've been
;		converted from .dat files, MDS 30Oct01.
;		I modified the test for number of columns in a line to give the user
;		a message about which lines are buggered in their file, MDS 17Apr02
;==============================================================================

FUNCTION READCSV, filename

; print, 'GL2PTT - filename: ', filename

   ;if filename not entered then use default

if n_elements(filename) eq 0 then filename = 'sealgeo.csv'

   ;open the file, returning nonzero error value to i if it occurs

openr, unit, filename, /get_lun, ERROR=i

   ;if error occurs

if i lt 0 then begin
	return, [ !err_string, ' Can not display ' + filename]

endif else begin

	   ;Maximum # of lines in file

	maxlines = 500000

	   ;a will contain strings of each line from the file

	a = strarr(maxlines)

	   ;read the file into a, goto label if i/o error

	on_ioerror, done_reading
	readf, unit, a

done_reading: s = fstat(unit)		;Get # of lines actually read, null the error

	  a = a[0: (s.transfer_count-1) > 0]
	  on_ioerror, null
	  FREE_LUN, unit
endelse


  ;define arrays to accept data from file

lines = n_elements(a) -1

ut_times = dblarr(lines)
lats   = fltarr(lines)
lons   = fltarr(lines)
seals  = strarr(lines)
classes = strarr(lines)

   ;let's check for classes field, i.e. these are ARGOS data
check = str_sep(a(0), ',')
check_for_CLASS = strpos(strupcase(check(6)), 'CLA')
class_flg = -1
IF check_for_CLASS GE 0 THEN class_flg = 1


   ;define anchor value

ik=-1

FOR i=1, lines    DO BEGIN

	   ;separate lines of data into variables, comma delimited

	bits = str_sep(a[i],',')

	  ;if the correct number of columns from file are present

	if n_elements(bits) ne 11 THEN message, 'check the line ' +  string(i + 1) + ' in ' + filename


;if i le 4 then print, bits

		   ;str_sep was replaced in IDL 5.3 by STRSPLIT

		sep = strpos(bits[8],'/')
		IF sep LT 0 THEN sep = '-' ELSE sep = '/'
		date = str_sep(bits[8],sep)

		day = date[0] * 1
      	mth = date[1] * 1
      	year = date[2] * 1

		if (year lt 50) then year = ('20'+date[2]) * 1


		if (year lt 100) then year = ('19'+date[2]) * 1

;if i le 4 then print, date, day, mth, year

		time = str_sep(bits[7],':')
		sec = time[0]*3600.0 + time[1]*60.0 + time[2]

;if i le 4 then print, time, sec

        	ut_time = ymds2js(year,mth,day,sec)

;if i le 4 then print, ut_time

	      ik = ik + 1
        	seals(ik) = bits[0]

        	ut_times(ik) = ut_time

			IF bits[9] LT 0 THEN lons(ik) = bits[9]*1.0 + 360. ELSE lons(ik)    = bits[9]*1.0
        	lats(ik)    = bits[10]*1.0
        	IF class_flg THEN classes(ik) = bits(6)



ENDFOR

   ;find the number of different seals in the data file

unique_ids = seals(uniq(seals, sort(seals)))

   ;this stuff is only here to get rid of empty string 4066!
;bad = where(unique_ids EQ '')
;good = where(unique_ids NE '')
;IF n_elements(bad) GT 0 THEN BEGIN
;	unique_ids = unique_ids(good)
;ENDIF
   ;ix is array of subscripts for unique seals in 'seals' array

for k=0, n_elements(unique_ids)-1 do begin

    ix = where(seals eq unique_ids(k),ixc)

   	;npts is array with # of mentions of kth seal in 'seals' array,
	;this next line concatenates successive ix arrays of these numbers

    if k eq 0 then npts = [ixc] else npts = [npts, ixc]

endfor


   ;prepare the padding data for the ARGOS data format

ok           = replicate('Y',lines)
IF NOT class_flg THEN classes      = replicate('3',lines)
min_classes  = replicate('3',lines)
include_refs = replicate('N',lines)
ref_name     =  replicate('',lines)
ref_lat      =  replicate(0.0,lines)
ref_lon      =  replicate(0.0,lines)
max_speeds   =  replicate(0.0,lines)

;print, 'npts ', npts

return, {npts:npts, $
         profile_nos:intarr(n_elements(npts)), $
	   include_refs:include_refs,	$
 	   min_classes:min_classes,	$
 	   ref_name:ref_name, 	$
 	   ref_lat:ref_lat, 	$
 	   ref_lon:ref_lon,	$
 	   max_speed:	max_speeds,	$
         ptts:seals, $
         ut_times:ut_times, $
         lats:lats, $
         lons:lons, $
         classes:classes, $
         ok:ok}



end
