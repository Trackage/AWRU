;---------------------------------------------------------------------------------
PRO SST_SUM, FILES, MEAN, LIMITS = LIMITS, LABEL = LABEL, $
	ORIG = ORIG, INTP = INTP, FLAG = FLAG, WEIGHTS = WEIGHTS, debug = debug
;==============================================================================
; NAME:
;		SUM_SST
; PURPOSE:	To calculate mean MCSST values (valid data).
; FUNCTIONS:
; PROCEDURES:	LIM_AREA - subsets the global array
;				SSTEXT - extracts the data from the SW file
;				SAT_FILE - writes the data to file for ARC info
;
; CATEGORY:
; CALLING SEQUENCE: SST_SUM, files
;
; INPUTS:		FILES - array of files desired in mean
;
;		E.G. UNIX files = findfile('./satdata/*hdf*')
;			Win32 files = findfile(filepath('*hdf', subdirectory = '/resource/datafile/satdata'))
;
; KEYWORD PARAMETERS:  LIMITS - 4 element vector [Nlat, Slat, Wlon, Elon]
;						E.G. limits = [-53.0, -62.0, 158.0, 175.0]
;					   LABEL - a descriptive string to ID period averaged for file name
;						E.G. 'Creche94-00', 'PLEX98-01'
;					   ORIG/INTP/FLAG - choose desired MCSST data
;						WEIGHTS - accepts array of weights from SAT_DAY
;						DEBUG - will show the arrays as it calculates them, and jump out
;							before writing to file
;
; OUTPUTS:		Mean values written to file
;				MEAN - contains mean values in array
;
; COMMON BLOCKS:
; NOTES:	Just input an array of file names and they will all be included in the mean.
;			No weighting is done, but see Kelvin Michael's OCCOMS and SSTCOMS, Ant. CRC.
;
; MODIFICATION HISTORY:	Written October 2001, MDSumner, AWRU.
;		Originally sum_sst, for Verity's penguin work, this chose
;		the right files using sst_day or versst_day.
;==============================================================================

;ON_ERROR, 2


for n = 0, n_elements(files) -1 do begin
	filename = files(n)

		;extract data from file

	sstext, filename, array, lons, lats, orig = orig, intp = intp, flag = flag, pal = pal

		;subset the area
	IF keyword_set(limits) THEN BEGIN
		lim_area, array, lons, lats, area, alons, alats, limits = limits
	ENDIF ELSE BEGIN
		area = array
		alons = lons
		alats = lats
	ENDELSE
		;create masks

	bad = where(area LT -2.0 OR area GE 36.0)
	mask = fix(area)*0 + 1

		;only mask if some are bad!
	IF bad(0) NE -1 THEN mask(bad) = 0


		;use the weights array to weight the values
	IF keyword_set(debug) THEN BEGIN
		;window, !d.window + 1
		map_array, area, alons, alats
	ENDIF
	;help, min(area), max(area)

	;stop
	IF keyword_set(weights) THEN BEGIN
		IF n_elements(weights) NE n_elements(files) THEN $
			message, 'Different number of files and weights values!!!'
		area = area*weights(n)
		mask = mask*weights(n)
		;help, min(area), max(area)
		;help, min(mask), max(mask)
		;stop
		;print, 'This weighting stuff hasn''t been tested!!'
		IF keyword_set(debug) THEN BEGIN
			;window, !d.window + 1
			map_array, area, alons, alats
		ENDIF
	ENDIF
	area = area*mask
	IF n EQ 0 THEN BEGIN

		sum = area
		nn = mask

	ENDIF ELSE BEGIN

		sum = sum + area
		nn = nn + mask

		IF keyword_set(debug) THEN BEGIN
			;window, !d.window + 1
			map_array, nn, alons, alats
		ENDIF
	ENDELSE

ENDFOR

good = where(nn GT 0)
bad = where(nn LE 0)
mask1 = nn*0
mean = sum *0.0
mean(good) = sum(good)/nn(good)

IF keyword_set(debug) THEN BEGIN
			;window, !d.window + 1
			map_array, mean, alons, alats

			return
ENDIF



IF bad(0) NE -1 THEN mask(bad) = -99




IF n_elements(label) EQ 0 THEN label = 'sum_'
sstfile = label + 'sst.txt'
sat_file, mean, alons, alats, sstfile

END
;-------------------------------------------------------------------------------