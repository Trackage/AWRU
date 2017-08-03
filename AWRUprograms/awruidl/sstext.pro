
;=============================================================================
PRO SSTEXT, FILENAME, ARRAY, LONS, LATS, ORIG = ORIG, INTP = INTP, FLAG = FLAG, $
	MASK = MASK, PAL = PAL, NOCONV = NOCONV, NOMASK = NOMASK, QUIET = QUIET
;==============================================================================
; NAME:
;       SSTEXT
;
; PURPOSE:
;			To extract one image of MCSST data from hdf files, with lons and lats,
;			and MCSST color palette.
;
;PROCEDURES:  HDF_DFR8_GETIMAGE - reads the hdf file
;
; CATEGORY:
; CALLING SEQUENCE:
;					SSTEXT, file, mcsst_arr, lons, lats, /type (orig/intp/flag)
;
; INPUTS:
;				    file - MCSST hdf file
;
;; E.G.s  Win32	sstfiles = findfile(filepath('*hdf*', root_dir = 'G:\', subdirectory = 'satdata\MCSST'))
;		UNIX	sstfiles = findfile(./satdata/'*hdf*')
;
;	Decompression:  Win32  command = 'gzip -d '  + file  [d is for decompress]
;					UNIX   command = 'gunzip ' + file
;
;	Compression:	Win32  command = 'gzip -f ' + file [f forces compression if zip file already exists]
;					UNIX   command = 'gzip ' + file
;
;	Then sends command to OS:	spawn, command
;
; KEYWORD PARAMETERS:
;					orig - returns MCSST valid values
;					intp - returns MCSST interpolated values
;					flag - returns MCSST flag values
;					pal - returns a named variable with MCSST palette values
;					mask - returns a named variable with mask values (land and ic and no data)
;					noconv - returns MCSST values as byte-scaled, without conversion
;					nomask - don't assign -9999.0 to mask areas
;
; OUTPUTS:
;					array - named variable for MCSST data
;					lons - named v. of longitude values
;					lats - named v. of latitude values
;
; COMMON BLOCKS:
; NOTES:
;					Will return one of the MCSST images, use repeatedly if more than one
;					required.
;					If user specifies more than one of the keywords - /orig, /intp, /flag
;					it is safe, only one is returned and a message is given as to which.
;
; MODIFICATION HISTORY:
;
;					Written MDSumner 25Sep01, a combination of NASA's READ_MCSST_DATA
;					and KJM's SSTEXT.
;==============================================================================

;ON_ERROR, 2
IF n_params() LT 2 OR keyword_set(hlp) THEN BEGIN
	print, 'Need MCSST hdf file input and variable for image output '
	print, 'Usage:  SSTEXT, file, mcsst_arr (, lons, lats, orig, intp, flag, '
	print, 'pal, mask, noconv'
	return
ENDIF
IF NOT keyword_set(orig) AND NOT keyword_set(intp) AND NOT keyword_set(flag) THEN $
	message, 'must set one and only one keyword, /orig, /intp, or /flag '

 	   ;uncompress if required
zip, filename, /unzip

		;open the file and read it with the HDF procedures, returns data array
		;and colour palette
file=HDF_OPEN(filename)
	hdf_dfr8_restart ;reset the hdf read environment
   	HDF_DFR8_GETIMAGE, filename, orig_mcsst, orig_pal			;valid
	HDF_DFR8_GETIMAGE, filename, interp_mcsst, interp_pal		;intp
	HDF_DFR8_GETIMAGE, filename,flag_data, flag_pal				;flag
HDF_CLOSE,file  ;close the hdf file

zip, filename

	; HARD CODE IN THE VALUE FOR ICE AT 90N.  PLEASE REFER TO
	; THE AVHRR MCSST GUIDE DOCUMENT IF FURTHER INFORMATION IS
	; REQUIRED http://podaac.jpl.nasa.gov/mcsst/mcsst_doc.html

orig_mcsst(*,0)=254
interp_mcsst(*,0)=254
flag_data(*,0)=254

IF NOT keyword_set(noconv) THEN BEGIN
		; MULTIPLY THE MCSST DIGITAL NUMBER BY THE CALIBRATION NUMBER (0.15)
		; AND THEN ADD THE OFFSET (-2.1) TO GET DEGREES CELSIUS

	orig_mcsst=0.15*orig_mcsst-2.1
	interp_mcsst=0.15*interp_mcsst-2.1
	flag_mask = where(flag_data GT 253)
	orig_mask = where(orig_mcsst LT -2.0 OR orig_mcsst GE 36.0)
	intp_mask = where(interp_mcsst LT -2.0 OR interp_mcsst GE 36.0)

ENDIF ELSE BEGIN

	flag_mask = where(flag_data GT 253)
	orig_mask = where(orig_mcsst EQ 0 OR orig_mcsst GE 254)
	intp_mask = where(interp_mcsst EQ 0 OR interp_mcsst GE 254)

ENDELSE

dx = 360.0/2048
lons = (findgen(2048))*dx + (dx/2.0)
lats = (findgen(1024))*dx + (dx/2.0) -90.0
mask = intarr(2048, 1024) + 1
IF keyword_set(orig) THEN BEGIN
	mask(orig_mask) = 0
	array = orig_mcsst
	IF NOT keyword_set(nomask) THEN array(orig_mask) = -9999.0
	pal = orig_pal
	IF NOT keyword_set(quiet) THEN print, 'returned array contains valid MCSST '
	return
ENDIF
IF keyword_set(intp) THEN BEGIN
	array = interp_mcsst
	mask(intp_mask) = 0
	IF NOT keyword_set(nomask) THEN array(intp_mask) = -9999.0
	pal = interp_pal
	IF NOT keyword_set(quiet) THEN print, 'returned array contains interpolated MCSST '
	return
ENDIF
IF keyword_set(flag) THEN BEGIN
	mask(flag_mask) = 0
	array = flag_data
	IF NOT keyword_set(nomask) THEN array(flag_mask) = -9999.0
	pal = flag_pal
	IF NOT keyword_set(quiet) THEN print, 'returned array contains MCSST flag '
	return
ENDIF



end
;---------------------------------------------------------------------------------------------

