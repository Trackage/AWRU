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
PRO HEIGHT2ARC, FILES, area, alons, alats, LIMITS = LIMITS, LABL = LABL, VAL = VAL, $
	grad = grad
;================================================================================
;IF NOT keyword_set(labl) THEN labl = 'G:\aleks\arcview\height\ssh_05_'
;IF NOT keyword_set(limits) THEN limits = [-45, -65, 145, 195]   ;Aleks

	;get the names of months for naming files
months = monthnames()
months = months[1:12]


FOR n = 0, n_elements(files) -1 do begin
		;for each file extract the data, and write to file
	file = files(n)

		;extract data from height file
 	ssa_ext, file, arr, lons, lats, land = land, woce_date = woce_date

		;make another array to mess around with
	array = arr

		;find the nondata values, assign Not-A-Number to them

	bad = where(array LE -9998)
	array(bad) = !values.f_nan

		;smooth the array, interpolates the data and avoids NaN
	array = smooth(array, 5, /nan)

		;find the gradient values if keyword set
	IF keyword_set(grad) THEN array = sobel(array)

		;reassign the flag value to the land areas output by ssa_ext
	array(land) = -9999

		;cut out the section we want
	lim_area, array, lons, lats, area, alons, alats, limits = limits

		;find the date from the woce_date to name the file
	yy = strmid(woce_date, 6, 2)
	mm = strmid(woce_date, 8, 2)*1
	dd = strmid(woce_date, 10, 2)
	mm = strmid(months(mm-1), 0, 3)
	outfile = strcompress(labl + dd + mm + yy + '.txt')

		;write the data to an ARC text file
	sat_file, area, alons, alats, outfile, val = val

endfor

end