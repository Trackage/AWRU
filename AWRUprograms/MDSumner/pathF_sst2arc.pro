;==============================================================================
; NAME:
;		WOCE_SST2ARC
;
; PURPOSE:		To extract WOCE avhrr data for input into GIS.
;
; FUNCTIONS:	MONTHNAMES - JHU program that returns array of month names
;
; PROCEDURES:	SSA_EXT - the extraction program for 0.5 and 1.0 files
;				LIM_AREA - the subsetting program for satellite gridded arrays
;				SAT_FILE - the write-to-file program
;
; CATEGORY:
; CALLING SEQUENCE:	WOCE_SST2ARC, FILES [, LIMITS = LIMITS, LABL = LABL, VAL = VAL]
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
;						NCDF routines in WOCE_SSTEXT.
;
; COMMON BLOCKS:
; NOTES:		I removed the Aleks' specific options for labl and limits, MDS2Nov01.
;
;			WOCE avhrr data http://podaac.jpl.nasa.gov/cdrom/woce2_avhrr/
;
; MODIFICATION HISTORY:  Written MDSumner 2Nov01.
;==============================================================================
PRO pathF_SST2ARC, FILES, LIMITS = LIMITS, LABL = LABL, VAL = VAL;, SMTH = SMTH
;================================================================================

;IF NOT keyword_set(labl) THEN labl = 'G:\aleks\arcview\avhrr\sst_05_'
;IF NOT keyword_set(limits) THEN limits = [-45, -65, 145, 195]   ;Aleks


FOR n = 0, n_elements(files) -1 do begin

	file = files(n)
 	mdspfext, file, arr, lons, lats, /orig
	array = arr
	bad = where(array LE -9998)
	;IF keyword_set(smth) THEN BEGIN
	;	array(bad) = !values.f_nan
	;	array = smooth(array, smth, /nan)
	;	array(land) = -9999
	;ENDIF
	lim_area, array, lons, lats, area, alons, alats, limits = limits

	;yy = strmid(woce_date, 6, 2)
	;mm = strmid(woce_date, 8, 2)*1
	;dd = strmid(woce_date, 10, 2)
	;mm = strmid(months(mm-1), 0, 3)
	filestring = strmid(file, 0, strlen(file) -2)
	;outfile = strcompress(labl + dd + mm + yy + '.txt')
	outfile = strcompress(filestring + '.txt')
	sat_file, area, alons, alats, outfile, val = val

endfor

end