;=============================================================================
PRO SWEXT, FILE, ARR, LONS, LATS, MASK = MASK,  CONV = CONV, PAL = PAL, $
	HLP = HLP, QUIET = QUIET
;==============================================================================
; NAME:
;       SWEXT
;
; PURPOSE:
;			To extract image of SeaWiFS data from Level 3 SMI hdf files, with
;			lons and lats, and color palette.
;
; CATEGORY:
; CALLING SEQUENCE:
;					SWEXT, file, SW_arr, lons, lats
;
; INPUTS:
;				    file - SeaWiFS Level 3 SMI hdf file
;
; E.G.s Win32	SWfiles = findfile(filepath('*CHLO*', root_dir = 'G:\', subdirectory = 'satdata\SW_chla'))
;		UNIX	SWfiles = findfile(./satdata/'*CHLO*')
;
;	Decompression:  Win32  command = 'gzip -d '  + file  [d is for decompress]
;					UNIX   command = 'gunzip ' + file
;
;	Compression:	Win32  command = 'gzip -f ' + file [f forces compression if zip file already exists]
;					UNIX   command = 'gzip ' + file
;
;	Then sends command to OS:	spawn, command
;
;
; PROCEDURES:
;			SET_DISPLAY - this loads the SeaWiFS color table
;			HDF_SD_READSLICE - reads the hdf file
;
; KEYWORD PARAMETERS:
;
;					pal - returns a named variable with SeaWiFS color table as
;					 palette values
;					conv - returns the converted values (mg/m^3) as a separate array
;
; OUTPUTS:
;					array - named variable for SMI data, accepts the byte data
							;use conv for the converted data
;					lons - named v. of longitude values
;					lats - named v. of latitude values
;
; COMMON BLOCKS:
; NOTES:
;
;			A select area may be extracted using LIM_AREA.
;			The current color table is saved, then reloaded after obtaining the
;				SeaWiFS colors.
;
; MODIFICATION HISTORY:
;
;					Written MDSumner 25Sep01, partly from C.Rathbone's RECT_GIF.
;			I can't get the mask and pal keywords to work properly, MDS 25Sep01.
;			Taken out the IF option, so pal and mask work MDS 26Sep01.
;		    Added option to un/compress in Windoze with gzip, required moving files
;			 to G:\satdata\SW_chla as OS won't recognize '\Program Files'.  GZIP
;			resides in the IDL home directory for this, MDS 17Oct01.
;			Embedded un/compression in the procedure ZIP.PRO, MDS 23Oct01.
;==============================================================================

   ;set simple error response
ON_ERROR, 2
IF n_params() LT 2 OR keyword_set(hlp) THEN BEGIN
	print, 'Need SeaWiFS SMI hdf file input and variable for image output '
	print, 'Usage:  SWEXT, file, array (, lons, lats, /pal, /mask, /noconv) '
	return
ENDIF

   ;uncompress the file if needed

zip, file, /unzip
help, file

    ;extract the chlorophyll data for the whole globe, and make Greenwich the xzero
hdf_sd_readslice, file, 'l3m_data', img, start = [0, 0], count = [4096, 2048]
arr = [img[2048:4095, *], img[0:2047, *]]

   ;recompress the file
zip, file

   ;create lons/lats
cell = 360.0/4096.0D  							;define cell size in degrees
lons = findgen(4096) * cell + (cell/2.0)  		;lons 0<->360
lats = findgen(2048)* cell + (cell/2.0) - 90.0  ;lats 90N<->-90S

   ;define masks for land/missing and chl values
good = where(arr LT 255)
bad = where(arr EQ 255)
;IF keyword_set(mask) THEN BEGIN
	mask = fix(arr)*0
	mask(good) = 1
;ENDIF

	;convert to chl values unless requested not to
;IF keyword_set(conv) THEN BEGIN
	conv = arr*1.0
	conv(good) = 10^(arr(good)*0.015 - 2.0)
	conv(bad) = -9999.0
	IF NOT keyword_set(quiet) THEN print, 'Use arr output to maintain colour for input to map_array '
	IF NOT keyword_set(quiet) THEN print, 'Bad values now -9999 in conv array '
;ENDIF

	;create 3-D palette from SeaWiFS color table
;IF keyword_set(pal) THEN BEGIN
   ;save current color table

  tvlct, curr, curg, curb, /get
	pal = bytarr(3, 256)
	set_display
	tvlct, r, g, b, /get
	pal(0, *) = r
	pal(1, *) = g
	pal(2, *) = b
	;reload previous colour table

  tvlct, curr, curg, curb
;ENDIF

END
