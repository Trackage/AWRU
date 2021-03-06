
;=============================================================================
PRO PATHEXT2b, FILENAME, ARRAY, LONS, LATS, ORIG = ORIG, FLAG = FLAG, PIX = PIX, $
	MASK = MASK, NOCONV = NOCONV, NOMASK = NOMASK, PAL = PAL,  QUIET = QUIET
;==============================================================================
; NAME:
;       PFEXT
;
; PURPOSE:
;			To extract one image of Pathfinder SST data from hdf files, with lons and lats
;
;PROCEDURES:  HDF_DFR8_GETIMAGE - reads the hdf file
;
; CATEGORY:
; CALLING SEQUENCE:
;					PFEXT, file, pfsst_arr, lons, lats, /type (orig/flag)
;
; INPUTS:
;				    file - Pathfinder SST hdf file
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
;					orig - returns Pathfinder SST valid values
;					flag - returns Pathfinder SST flag values
;					pix - returns the pixel quality values (if avail)
;					mask - returns a named variable with mask values (land and ice and no data)
;					noconv - returns MCSST values as byte-scaled, without conversion
;					nomask - don't assign -9999.0 to mask areas
;					pal 	- return the colour palette
;
; OUTPUTS:
;					array - named variable for Pathfinder SST data
;					lons - named v. of longitude values
;					lats - named v. of latitude values
;
; COMMON BLOCKS:
; NOTES:
;					Will access one of the Pathfinder SST images, use repeatedly if more than one
;					required.
;					If user specifies more than one of the keywords - /orig, /flag
;					it is safe, only one is returned and a message is given as to which.
;
; MODIFICATION HISTORY:
;
;					Written MDSumner 25Sep01, a combination of NASA's READ_MCSST_DATA
;					and KJM's SSTEXT.
;==============================================================================

;ON_ERROR, 2
IF n_params() LT 2 OR keyword_set(hlp) THEN BEGIN
	print, 'Need Pathfinder SST hdf file input and variable for image output '
	print, 'Usage:  PFEXT, file, pfsst_arr (, lons, lats, orig, flag, mask, noconv)'
	return
ENDIF
IF NOT keyword_set(orig) AND NOT keyword_set(flag) AND NOT keyword_set(pix) THEN $
	message, 'must set one and only one keyword, /orig or /flag or /pix '

 	   ;uncompress if required
zip, filename, /unzip

	; code segment below from read_pfsst_data.pro
	; 1991 and 1994 are in binary format

	slaspos = rstrpos(filename,'\')
	;year = strmid(filename,slaspos+ 1,4) * 1
	;print, year

	hdfno = strpos(filename, 'hdf', slaspos + 1)
	IF  (hdfno EQ  - 1) THEN BEGIN
	;if (year EQ 1991) OR (year EQ 1994) OR (year GE 1999) THEN BEGIN
		;1991005m8av40fsst05
		;199302h18ea-gdm.hdf
		orig_sst = read_idl(filename,xlat = lats, xlon = lons)
		print, 'Array was read from ' + filename + ' with read_idl.pro, binary format'

		orig_sst = (orig_sst / 100.0)
		bad = where(orig_sst EQ 40.0)
		orig_mask = orig_sst*0.0 + 1
		orig_mask[bad] = 0
		info = size(orig_sst)
		xlen = info[1]
		xmid = xlen /2
		orig_pal = -1

	ENDIF ELSE BEGIN

			;open the file and read it with the HDF procedures, returns data array
			;and colour palette

	file=HDF_OPEN(filename)

	; FIND THE NUMBER OF IMAGES AVAILABLE IN THE HDF FILE
	IF file[0] EQ - 1 THEN MESSAGE, 'Cannot open HDF file ' + filename

	nimg=hdf_dfr8_nimages(filename)

	; READ THE DATA IN EACH IMAGE
	; (PLEASE NOTE:  There are three images for "All" SST and two images for "Best" SST)
	hdf_dfr8_restart
	hdf_dfr8_getimage,filename,orig_sst,orig_pal
	info = size(orig_sst)
	xlen = info[1]
	xmid = xlen /2
	orig_sst = FIX(orig_sst)  ;to change byte to integer in case noconv is set



	if (nimg eq 3) then begin

		hdf_dfr8_getimage,filename,pix_qual,pix_pal
		pix_qual = [pix_qual[xmid:xlen - 1, *], pix_qual[0:xmid - 1, *]]
		pix_mask = where(pix_qual EQ 0)
	ENDIF

	hdf_dfr8_getimage,filename,flag_data,flag_pal
	flag_data = [flag_data[xmid:xlen - 1, *], flag_data[0:xmid - 1, *]]


	HDF_CLOSE,file
	flag_mask = where(flag_data GT 0)

	bad = where((orig_sst EQ 0) OR (orig_sst GE 254))
	orig_mask = orig_sst*0.0 + 1
	orig_mask[bad] = 0
	IF NOT keyword_set(noconv) THEN BEGIN
	; MULTIPLY THE SST DIGITAL NUMBER BY THE CALIBRATION NUMBER (0.15)
	; AND THEN ADD THE OFFSET (-3.0) TO GET DEGREES CELSIUS

	 orig_sst=0.15*orig_sst-3.0

	ENDIF

ENDELSE
orig_sst = [orig_sst[xmid:xlen - 1, *], orig_sst[0:xmid - 1, *]]
orig_mask = [orig_mask[xmid:xlen - 1, *], orig_mask[0:xmid - 1, *]]



	; swap the halves of the arrays to make sure the Pathfinder data arrays run from 0 to 360 longitude


;zip, filename





; define size of cells and the global lon and lat values
dx = 360.0/xlen
lons = (findgen(xlen))*dx + (dx/2.0)
lats = (findgen(xlen / 2.0))*dx + (dx/2.0) -90.0

; create a mask for the globe
mask = intarr(xlen, xlen / 2.0) + 1

IF keyword_set(orig) THEN BEGIN
	mask(orig_mask) = 0
	array = orig_sst

	IF NOT keyword_set(nomask) THEN BEGIN
		bad = where(orig_mask EQ 0)
		array[bad] = -9999.0
	ENDIF
	pal = orig_pal

	IF NOT keyword_set(quiet) THEN print, 'returned array contains valid Pathfinder SST '
	return
ENDIF

IF keyword_set(flag) THEN BEGIN
	mask(flag_mask) = 0
	array = flag_data

	IF NOT keyword_set(nomask) THEN array(flag_mask) = -9999.0
	pal = flag_pal
	IF NOT keyword_set(quiet) THEN print, 'returned array contains Pathfinder SST flags '
	return
ENDIF

IF keyword_set(pix) THEN BEGIN
	mask(pix_mask) = 0
	array = pix_qual
	IF NOT keyword_set(nomask) THEN array(pix_mask) = -9999.0
	pal = pix_pal
	IF NOT keyword_set(quiet) THEN print, 'returned array contains Pathfinder SST pixel quality '
	return
ENDIF

end
;---------------------------------------------------------------------------------------------

;---------------------------------------------------------------------------------------------
FUNCTION read_idl,file,xlat = xlat,xlon = xlon
;
; 05/06/99 Written by Jorge Vazquez
; Copyright California Institute of Technology
;
;filename='/sst/disk11/jorge/8day/data/1985/1985140m8av40fsst05'
openr,lun,file, /swap_if_little_endian, /get_lun  ; THIS MEANS THE DATA
;WERE CREATED IN SUN,SGI
sst=intarr(4096,2048)
forrd,lun,sst
;
;setup  latitude and longitude arrays
;
xlatmx=89.956055
xlonmn=-179.956055
delta=360./4096.
xlat=fltarr(2048)
xlon=fltarr(4096)
xlat=xlatmx-findgen(2048)*delta
xlon=xlonmn+findgen(4096)*delta
free_lun, lun
return, sst
end
