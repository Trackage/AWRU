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
;==============================================================================

FUNCTION SNAKE2PTT, filename, dbllons = dbllons

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

	maxlines = 5000

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

lines = n_elements(a) 

ut_times = dblarr(lines)
lats   = fltarr(lines)
lons   = fltarr(lines)
seals  = strarr(lines)
temps = fltarr(lines)

   ;define anchor value

ik=-1
;print, lines
FOR i=0, lines -1 DO BEGIN

	   ;separate lines of data into variables, comma delimited

	bits = str_sep(a[i],',')

	;IF i LT 20 THEN print, bits
	  ;if the correct number of columns from file are present



;if i le 4 then print, bits

		   ;str_sep was replaced in IDL 5.3 by STRSPLIT

		date = str_sep(bits[2],'/')
		day = date[1] * 1
      	mth = date[0] * 1
      	year = date[2] * 1

		if (year lt 50) then year = ('20'+date[2]) * 1

		if (year lt 100) then year = ('19'+date[2]) * 1

;f i le 4 then print, date, day, mth, year

		time = str_sep(bits[1],':')
		sec = time[0]*3600.0 + time[1]*60.0 + time[2]

;if i le 4 then print, time, sec

        	ut_time = ymds2js(year,mth,day,sec)

;if i le 4 then print, ut_time

	      ik = ik + 1
        	seals(ik) = bits[0]
        	ut_times(ik) = ut_time
        		;Snake gave me files with two lons columns, so added this keyword, MDS 23Aug01

        	lons(ik)    = bits[3]*1.0
        	IF keyword_set(dbllons) THEN lats(ik) = bits[5]*1.0 ELSE lats(ik)  = bits[4]*1.0
		temps(ik) = bits[5]*1.0



ENDFOR

   ;find the number of different seals in the data file

unique_ids = seals(uniq(seals))

   ;ix is array of subscripts for unique seals in 'seals' array

for k=0, n_elements(unique_ids)-1 do begin

    ix = where(seals eq unique_ids(k),ixc)

   	;npts is array with # of mentions of kth seal in 'seals' array,
	;this next line concatenates successive ix arrays of these numbers

    if k eq 0 then npts = [ixc] else npts = [npts, ixc]

endfor



   ;prepare the padding data for the ARGOS data format

ok           = replicate('Y',lines)
classes      = replicate('3',lines)
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
         ok:ok, $
	   dawn_temps:temps}



end
