;---------------------------------------------------------------------------------
PRO SW_SUM, FILES, MEAN, NN, LIMITS = LIMITS, LABEL = LABEL, WEIGHTS = WEIGHTS, debug = debug
;==============================================================================
; NAME:
;		SUM_CHL
; PURPOSE:	To calculate mean SeaWiFS values from L-3 SMI data.
; FUNCTIONS:
; PROCEDURES:	LIM_AREA - subsets the global array
;				SWEXT - extracts the data from the SW file
;				SAT_FILE - writes the data to file for ARC info
;
; CATEGORY:
; CALLING SEQUENCE:  SW_SUM, files, limits = limits
;
; INPUTS:		FILES - array of files desired in mean
;
;		E.G. UNIX files = findfile('./satdata/*CHLO*')
;			Win32 files = findfile(filepath('*CHLO', subdirectory = '/resource/datafile/satdata'))
;
; KEYWORD PARAMETERS:  LIMITS - 4 element vector [Nlat, Slat, Wlon, Elon]
;						E.G. limits = [-53.0, -62.0, 158.0, 175.0]
;					   LABEL - a descriptive string to ID period averaged for file name
;						E.G. 'Creche94-00', 'PLEX98-01'
;					   WEIGHTS - accepts weights array from SAT_DAY
;
; OUTPUTS:		Mean values written to file
;				MEAN (optional) - Save mean array to variable
;				NN (optional)  - save nn array to variable
;
; COMMON BLOCKS:
; NOTES:	Just input an array of file names and they will all be included in the mean.
;
;
; MODIFICATION HISTORY:	Written October 2001, MDSumner, AWRU.
;		Originally sum_chl, for Verity's penguin work, this chose
;		the right files using chl_day or verchl_day.
;==============================================================================
for n = 0, n_elements(files) -1 do begin
	filename = files(n)

		;extract data from file, SWEXT returns unconverted by default
	swext, filename, array, lons, lats

		;subset the area
	IF keyword_set(limits) THEN BEGIN
		lim_area, array, lons, lats, area, alons, alats, limits = limits
	ENDIF ELSE BEGIN
		area = array
		alons = lons
		alats = lats
	ENDELSE
		;create masks
	bad = where(area EQ 255)  ;255 is SeaWiFS mask value
	mask = fix(area)*0 + 1
	;only mask if some are bad!
	IF bad(0) NE -1 THEN mask(bad) = 0


	IF keyword_set(weights) THEN BEGIN
		IF n_elements(weights) NE n_elements(files) THEN $
			message, 'Different number of files and weights values!!!'
		area = area*weights(n)
		mask = mask*weights(n)
		print, 'This weighting stuff hasn''t been tested!!'
		IF keyword_set(debug) THEN BEGIN
			;window, !d.window + 1
			map_array, area, alons, alats
		ENDIF
	ENDIF
	area = area*mask
		;now sum values from successive areas, keeping track of n for each pixel
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
	;undefine, array  ;Can't remember why this here, MDS
ENDFOR

   ;create masks for taking mean values
good = where(nn GT 0)
bad = where(nn LE 0)
mask1 = nn*0
mean = sum *0.0
mean(good) = sum(good)/nn(good)

	IF keyword_set(debug) THEN BEGIN

		map_array, mean, alons, alats
		return
	ENDIF



IF bad(0) NE -1 THEN mask(bad) =  -99  ;bad values get this absurd value

   ;write the result to file for ARC info input
IF n_elements(label) EQ 0 THEN label = 'sum_'
chlfile = label + 'chl.csv'
sat_file, mean, alons, alats, chlfile



END
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------
