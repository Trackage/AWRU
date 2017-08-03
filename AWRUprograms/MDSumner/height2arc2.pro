;==============================================================================
; NAME:
;		HEIGHT2ARC
;
; PURPOSE:		To extract and smooth WOCE topex 0.5 deg data for input into GIS.
;
; FUNCTIONS:	MONTHNAMES - JHU program that returns array of month names
;
; PROCEDURES:	SSA_EXT - the extraction program for 0.5 and 1.0 files
;				LIM_AREA - the subsetting program for satellite gridded arrays
;				SAT_FILE - the write-to-file program
;
; CATEGORY:
; CALLING SEQUENCE:	HEIGHT2ARC, FILES [, LIMITS = LIMITS, LABL = LABL, VAL = VAL]
;
; INPUTS:			FILES - array of file names of topex data
;
; KEYWORD PARAMETERS:	LIMITS - array of geog limits [nlat, slat, wlat, elat]
;						LABL - a file output start name
;							e.g. labl = G:\bin\stuff_'
;						VAL - a label for the data type e.g. val = 'height'
;
; OUTPUTS:			Produces file output as specified by LABL, files are labelled
;						according to this and by the WOCE_DATE variable returned by the
;						NCDF routines in SSA_EXT.
;
; COMMON BLOCKS:
; NOTES:		Removed Aleks' specific option, MDS2Nov01.
;
;			WOCE topex data http://podaac.jpl.nasa.gov/cdrom/woce2_topex/

; MODIFICATION HISTORY:  Written MDSumner 1Nov01.
;==============================================================================
PRO HEIGHT2ARC2, FILES, LIMITS = LIMITS, LABL = LABL, VAL = VAL, MEAN = MEAN
;================================================================================
;IF NOT keyword_set(labl) THEN labl = 'G:\aleks\arcview\height\ssh_05_'
;IF NOT keyword_set(limits) THEN limits = [-45, -65, 145, 195]   ;Aleks

months = monthnames()

months = months[1:12]
FOR n = 0, n_elements(files) -1 do begin

	file = files(n)
 	ssa_ext, file, arr, lons, lats, land = land, woce_date = woce_date
 	array = arr
	bad = where(array LE -9998)

	IF keyword_set(mean) THEN BEGIN
		IF n EQ 0 THEN start = woce_date
		IF n EQ n_elements(files) - 1 THEN finish = woce_date
		mask = array*0 + 1
		IF bad(0) NE - 1 THEN mask(bad) = 0
		IF n EQ 0 THEN BEGIN
			sum = array * mask
			nn = mask
		ENDIF ELSE BEGIN
			sum = sum + array * mask
			nn = nn + mask
			map_array, sum, lons, lats

		ENDELSE
	ENDIF
	IF NOT keyword_set(mean) THEN BEGIN


		array(bad) = !values.f_nan
		array = smooth(array, 5, /nan)

		array(land) = -9998

		lim_area, array, lons, lats, area, alons, alats, limits = limits

		yy = strmid(woce_date, 6, 2)
		mm = strmid(woce_date, 8, 2)*1
		dd = strmid(woce_date, 10, 2)
		mm = strmid(months(mm-1), 0, 3)

		outfile = strcompress(labl + dd + mm + yy + '.txt')
		sat_file, area, alons, alats, outfile, val = val
		IF n EQ n_elements(files) - 1 THEN return
	ENDIF


endfor

mean = sum * mask
good = where(mask GT 0)
mean(good) = mean(good) * mask(good)
bad = where(mask EQ 0)
mean(bad) = !values.f_nan
mean = smooth(mean, 5, /nan)

mean(land) = -9998

IF keyword_set(limits) THEN BEGIN
	lim_area, mean, lons, lats, area, alons, alats, limits = limits
ENDIF ELSE BEGIN
		area = mean
		alons = lons
		alats = lats
ENDELSE

syy = strmid(start, 6, 2)
smm = strmid(start, 8, 2)*1
sdd = strmid(start, 10, 2)
smm = strmid(months(smm-1), 0, 3)
eyy = strmid(start, 6, 2)
emm = strmid(start, 8, 2)*1
edd = strmid(start, 10, 2)
emm = strmid(months(emm-1), 0, 3)
outfile = strcompress(labl + sdd + smm + syy + edd + smm + syy + '.txt')
sat_file, area, alons, alats, outfile, val = 'mean' + val

stop
end