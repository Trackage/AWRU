;============================================================================
; NAME:
;       GET_DIVE_DATA
;
; PURPOSE:  Extract data from dive file.
;
; CATEGORY:
; CALLING SEQUENCE:
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:

;	Adapted from section of DJW's cell_dive.pro, MDS July01
;=============================================================================

FUNCTION  GET_DIVE_DATA, filename,  drift = drift

if n_elements(filename) eq 0 then filename = 'sealdive.csv'

openr, unit, filename, /get_lun, ERROR=i	; open the seal dive file

if i lt 0l then begin		;OK?
	  return, [ !err_string, ' Cannot access sealdive.csv']
endif else begin
	  maxlines = 1000000		;Maximum # of lines in file
	  a = strarr(maxlines)
	  on_ioerror, done_reading
	  readf, unit, a
done_reading: s = fstat(unit)		;Get # of lines actually read
	  a = a[0: (s.transfer_count-1) > 0]
	  on_ioerror, null
	  FREE_LUN, unit				;free the file unit.
endelse

lines = n_elements(a) - 1
ut_times = dblarr(lines)
dates  = strarr(lines)	; column 2
times  = strarr(lines)	; column 3
seals  = strarr(lines)	; column 0

IF keyword_set(drift) THEN BEGIN
	drift = fltarr(lines)
	dslope = fltarr(lines)
ENDIF ELSE BEGIN

	depth = fltarr(lines)
	durat = fltarr(lines)
	sfint = fltarr(lines)
	btime = fltarr(lines)
	devel = fltarr(lines)
	asvel = fltarr(lines)
	wiggs = fltarr(lines)
	dvert = fltarr(lines)
	dvtdv = fltarr(lines)
ENDELSE
ik=-1
;print,'array ', n_elements(a)

for i=1l,lines do begin

	bits = str_sep(a[i],',')
	;print, 'bits[0]: ', bits[0]

	;if (n_elements(bits) eq 13) then begin

		date = str_sep(bits[2],'/')
		day = date[0] * 1
        mth = date[1] * 1
        year = date[2] * 1
        if (year lt 50) then year = ('20'+date[2]) * 1
		if (year lt 100) then year = ('19'+date[2]) * 1

		time = str_sep(bits[3],':')
		sec = time[0]*3600.0 + time[1]*60.0 + time[2]

        ut_time = ymds2js(year,mth,day,sec)

        ik = ik + 1l
        seals(ik) 	 = bits[0]
        ut_times(ik) = ut_time
        dates(ik) = bits[2]
        times(ik) = bits[3]

		IF keyword_set(drift) THEN BEGIN
			drift(ik) = bits[4]*1.0
			dslope(ik) = bits[5]*1.0

		ENDIF ELSE BEGIN

        	depth(ik)    = bits[4]*1.0
        	durat(ik)    = bits[5]*1.0
        	sfint(ik)    = bits[6]*1.0
        	btime(ik)    = bits[7]*1.0
        	devel(ik)    = bits[8]*1.0
        	asvel(ik)    = bits[9]*1.0
        	wiggs(ik)    = bits[10]*1.0
        	dvert(ik)    = bits[11]*1.0
        	dvtdv(ik)    = bits[12]*1.0
		ENDELSE
    ;endif

endfor

IF keyword_set(drift) THEN return, {ut_times:ut_times, dates:dates, times:times, seals:seals, $
		drift:drift, dslope:dslope}


return, {ut_times:ut_times, dates:dates, times:times, seals:seals, $
	depth:depth, durat:durat, sfint:sfint, btime:btime, devel:devel, $
	asvel:asvel, wiggs:wiggs, dvert:dvert, dvtdv:dvtdv}

END
