;---------------------------------------------------------------------------------
PRO SAT_SUM, FILES, MEAN, ALONS, ALATS, LIMITS = LIMITS, LABL = LABL, $
	ORIG = ORIG, INTP = INTP, FLAG = FLAG, WEIGHTS = WEIGHTS, BYT = BYT, $
	SMTH = SMTH, EXPERT = EXPERT, debug = debug
;==============================================================================
; NAME:
;		SUM_SST
; PURPOSE:	To calculate mean MCSST values (valid data).
; FUNCTIONS:
; PROCEDURES:	LIM_AREA - subsets the global array
;				SWEXT - extracts the data from the SeaWiFS file
;				SSTEXT - extracts data from the MCSST file
;				SAT_FILE - writes the data to file for ARC info
;
; CATEGORY:
; CALLING SEQUENCE: SST_SUM, files
;
; INPUTS:		FILES - array of files desired in mean
;
;		E.G. MCSST
;			UNIX files = findfile('./satdata/*hdf*')
;			Win32 files = findfile(filepath('*hdf', subdirectory = '/resource/datafile/satdata'))
;		E.G. SeaWiFS
;			UNIX files = findfile('./satdata/*CHLO*')
;			Win32 files = findfile(filepath('*CHLO', subdirectory = '/resource/datafile/satdata'))
;
;
; KEYWORD PARAMETERS:  LIMITS - 4 element vector [Nlat, Slat, Wlon, Elon]
;						E.G. limits = [-53.0, -62.0, 158.0, 175.0]
;					   LABEL - a descriptive string to ID period averaged for file name
;						E.G. 'Creche94-00', 'PLEX98-01'
;					   ORIG/INTP/FLAG - choose desired MCSST data
;						WEIGHTS - accepts array of weights from SAT_DAY
;						BYT - do not convert values from byte-scaled
;						DEBUG - will show the arrays as it calculates them, and jump out
;							before writing to file
;						SMTH - run SMOOTH boxcar average over averaged array, this now
;						EXPERT - override the no average rule topex data
;
;
; OUTPUTS:		Mean values written to file
;				MEAN - contains mean values in array
;
; COMMON BLOCKS:
; NOTES:	Just input an array of file names and they will all be included in the mean.
;			No weighting is done, but see Kelvin Michael's OCCOMS and SSTCOMS, Ant. CRC.
;			FIND_SAT_FILE replaced SAT_DAY, no weighting is in operation 30Oct01, MDS.
;
; MODIFICATION HISTORY:	Written October 2001, MDSumner, AWRU.
;		Added spatial gradient output, MDSumner 30Oct01.
;		Added byte-scaled option (BYT) MDSumner 30Oct01.
;		Added smooth option, MDSumner 31Oct01.
;==============================================================================

;ON_ERROR, 2

   ;determine what type of data
IF NOT keyword_set(orig) AND NOT keyword_set(intp) AND NOT keyword_set(flag) THEN BEGIN
	   ;find if 'chlo' is in the file name and set flags appropriately
	refpos = strpos(files(0), 'CHLO')
	IF refpos GT 0 THEN SW_flag = 1
	refpos2 = strpos(files(0), 'nc')
	IF refpos2 GT 0 THEN BEGIN
		SSH_flag = 1
		deg_type = strmid(files(0), 3, 2)
		IF n_elements(files) GT 1 AND NOT keyword_set(expert) THEN message, 'Averaging of topex data not recommended ' + $
																	' either input one file only or use /expert keyword' $
		ELSE message, 'Either not SeaWiFS CHLO or TOPEX ' + $
		'files or MCSST keyword not set: see the documentation for SSTEXT and SWEXT and SSA_EXT'
		SST_flag = 0
	ENDIF
ENDIF ELSE BEGIN
		;there are two types of MCSST, day (sd) and night (sn)
	refpos = strpos(files(0), 'sd')
	refpos2 = strpos(files(0), 'sn')
	IF refpos GT 0 OR refpos2 GT 0 THEN SST_flag = 1  ELSE message, files(0) + 'Not an expected MCSST file '
	SW_flag = 0

ENDELSE
	;cycle thru the files
FOR n = 0, n_elements(files) -1 do begin
	filename = files(n)

		;extract data from file, with appropriate conversion from byte-scaled or not

	IF SST_flag  THEN BEGIN
		IF NOT keyword_set(byt) THEN $   ;/noconv returns byte-scaled values
			sstext, filename, array, lons, lats, orig = orig, intp = intp, flag = flag, pal = pal, /quiet $
				ELSE sstext, filename, array, lons, lats, orig = orig, intp = intp, flag = flag, /noconv, pal = pal, /quiet
	ENDIF

	IF SW_flag THEN BEGIN
		swext, filename, arr, lons, lats, conv = array, /quiet  ;arr is byte-scaled, conv = array is converted
		IF keyword_set(byt) THEN array = arr
	ENDIF

	IF SSH_flag THEN BEGIN
		ssa_ext, filename, array, lons, lats
		IF keyword_set(byt) THEN print, 'No byte version of SSA data'
		IF keyword_set(smth) THEN BEGIN
			smtharr = array
			smbad = where(array GE 32766)
			smtharr(bad) = !values.f_nan
			width = 5
			smtharr = smooth(area, width, /nan)
		ENDIF
	ENDIF


		;subset the area
	IF keyword_set(limits) THEN BEGIN
		lim_area, array, lons, lats, area, alons, alats, limits = limits   ;cut down to area, or area is whole globe
		IF keyword_set(smth) AND SSH_flag THEN lim_area, smtharr, lons, lats, smtharea, alons, alats, limits = limits
	ENDIF ELSE BEGIN
		area = array
		alons = lons
		alats = lats
	ENDELSE

		;create 1-D masks, according to byte-scaling or not

	IF SST_flag THEN BEGIN
		IF keyword_set(byt) THEN bad = where(area EQ 0 OR area GE 254) ELSE bad = where(area LT -2.0 OR area GE 36.0)
	ENDIF
	IF SW_flag THEN BEGIN
			;255 is SeaWiFS mask value, 255 = 66.8344, 254 = 64.5654
		IF keyword_set(byt) THEN bad = where(area EQ 255) ELSE bad = where(area GE 66.0)
	ENDIF
	IF SSH_flag THEN BEGIN
		bad = where(area GE 32766)
		land = where(area EQ 32766)

	ENDIF
	   ;create 2-D version of mask
	mask = fix(area)*0 + 1
	IF bad(0) NE -1 THEN mask(bad) = 0  ;only mask if some are bad!


	IF keyword_set(debug) THEN map_array, area, alons, alats  ;let's check it out if we are worried


	   ;;use the weights array to weight the values  - only manual at the moment, MDS 30Oct01.
	IF keyword_set(weights) THEN BEGIN

		IF n_elements(weights) NE n_elements(files) THEN $
			message, 'Different number of files and weights values!!!'
		area = area*weights(n)
		mask = mask*weights(n)

		IF keyword_set(debug) THEN map_array, area, alons, alats


	ENDIF

	  ;fuck off the masked values, these zeros get summed,
	  ;but they don't contribute to the sample size, nn

	area = area*mask

	IF n EQ 0 THEN BEGIN

		sum = area	;add it up
		nn = mask   ;add one to the sample size
		;SSQ = sum*sum
	ENDIF ELSE BEGIN

		sum = sum + area  ;keep adding
		nn = nn + mask    ;one more each time
		;SSQ = SSQ + sum * sum
		IF keyword_set(debug) THEN map_array, nn, alons, alats

	ENDELSE

ENDFOR

	;now mask the mean values from the nn array, zero nn means no contribution to the mean
good = where(nn GT 0)
bad = where(nn LE 0)
mask1 = nn*0
mean = sum *0.0
mean(good) = sum(good)/nn(good)

IF keyword_set(debug) THEN BEGIN
		map_array, mean, alons, alats
		;return  ;let's skedaddle if we're just checkin'
ENDIF

	;only mask if there are some non data values, and keep the mean value for the gradient
	;smoothing
mean_to_file = mean
IF bad(0) NE -1 THEN mean_to_file(bad) = -99

	;name the output file and output it
IF n_elements(labl) EQ 0 THEN labl = 'sum_'
IF SST_flag THEN BEGIN
	outfile = labl + 'SST.txt'
	val = 'SST'
ENDIF
IF SW_flag THEN BEGIN
	outfile = labl + 'COL.txt'
	val = 'col'
ENDIF
IF SSH_flag THEN BEGIN
	outfile = labl + 'SSH.txt'
	val = 'SSH'
ENDIF

sat_file, mean_to_file, alons, alats, outfile, val = val

IF keyword_set(debug) THEN map_array, mean, alons, alats, title = 'mean'


	;now do the smoothing
smthmean = mean
   ;name file and value label
IF SST_flag THEN BEGIN

	smthfile = labl + 'SSTSMTH.txt'
	val = 'SM_SST'
	  ;smooth leaves missing (nan) values as zero, so add the offset to the temps so
	  ;we know which are missing and which are valid zero temperatures
	smthmean = smthmean + 2.0
ENDIF
IF SW_flag THEN BEGIN
	smthfile = labl + 'COLSMTH.txt'
	val = 'SM_COL'
ENDIF

IF SST_flag OR COL_flag THEN BEGIN
	IF SSH_flag AND NOT deg_type EQ '05' THEN return  ;just skip out before smoothing, 1.0 deg topex is interpolated

	IF keyword_set(smth) THEN width = smth ELSE width = 10

	IF bad(0) NE -1 THEN smthmean(bad) = !values.f_nan	;mask out the bad shit for smoothing
	   ;run the boxcar filter
	smthmean = smooth(smthmean, width, /nan)
	smthbad = where(smthmean EQ 0)
	smthmean = smthmean - 2.0   ;take the nonzero offset off again
	IF bad(0) NE - 1 THEN smthmean(bad) = -99

	sat_file, smthmean, alons, alats, smthfile, val = val
	IF keyword_set(debug) THEN map_array, smthmean, alons, alats, title = 'smoothed mean'
	   ;now do the spatial gradient values
	grad = smthmean
	bad = where(smthmean EQ -99)
	IF newbad(0) NE - 1 THEN grad(bad) = !values.f_nan
	grad = sobel(grad)
	IF bad(0) NE - 1 THEN grad(bad) = -99

	newmask = nn*0.0 + 0
	good = where(finite(grad))
	newmask(good) = 1
	newbad = where(newmask EQ 0)
	zeros = where(grad EQ 0)
	IF zeros(0) NE -1 THEN grad(zeros) = -99
	IF newbad(0) NE - 1 THEN grad(newbad) = -99

	IF SST_flag THEN BEGIN
		grdfile = labl + 'SST_grad.txt'
		val = 'SST_grad'
	ENDIF

	IF SW_flag THEN BEGIN
		grdfile = labl + 'COL_grad.txt'
		val = 'col_grad'
	ENDIF
	sat_file, grad, alons, alats, grdfile, val = val
	IF keyword_set(debug) THEN map_array, grad, alons, alats, title = 'gradient of smoothed mean'
ENDIF ELSE BEGIN

	sat_file, smtharea, alons, alats
ENDELSE
END
;-------------------------------------------------------------------------------