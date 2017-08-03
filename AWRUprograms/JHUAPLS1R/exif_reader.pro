;-------------------------------------------------------------
;+
; NAME:
;       EXIF_READER
; PURPOSE:
;       Read values from an Exif file (digital camera file).
; CATEGORY:
; CALLING SEQUENCE:
;       exif_reader, file, values
; INPUTS:
;       file = Name of digital camera image file.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         /LIST means list values.
;         DESCRIPTION=desc Returned text array of descriptive text.
;         /TAGS means list in hex all tag values found.
; OUTPUTS:
;       values = Returned structure with values.    out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2000 Dec 19
;
; Copyright (C) 2000, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro exif_reader, file, values, list=list, description=desc, $
	  tags=tags, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Read values from an Exif file (digital camera file).'
	  print,' exif_reader, file, values'
	  print,'   file = Name of digital camera image file.   in'
	  print,'   values = Returned structure with values.    out'
	  print,' Keywords:'
	  print,'   /LIST means list values.'
	  print,'   DESCRIPTION=desc Returned text array of descriptive text.'
	  print,'   /TAGS means list in hex all tag values found.'
	  return
	endif
 
	;------------  Init  ---------------------
	hend = endian()			; Host endian (current computer).
	eflag = 1-hend			; JPEG file values are big endian.
	txtman = ''			; Camera Manufacturer.
	txtmod = ''			; Camera Model.
	txtver = ''			; Camera firmware version.
	txttim = ''			; Date/Time.
	shutter = 0.			; Shutter speed (1/sec).
	fnum = 0.			; F-number as rational.
	dt_tm = ''			; Date/Time of original.
	xprog_tab = ['<?','manual control','program normal',$
	  'aperture priority','shutter priority',$
	  'program creative (slow program)',$
	  'program action (high-speed program)',$
	  'portrait mode','landscape mode','>?']
	expprog = ''			; Exposure program (see table).
	isospeed = 0			; ISO Speed.
	dist = 0.			; Focus distance (m).
	subsec = ''			; Time subsecond.
	maxap = 0.			; Max Aperture.
	foclen = 0.			; Focal len (mm).
	flash = -1			; Flash?
	x_pixels = 0			; X size in pixels.
	y_pixels = 0			; Y size in pixels.
	bitsperpix = 0			; Est. Compression in bits/pixel,
	cmt = ''			; User comment.
 
	;--------  Open Image file  ------------
	openr,lun,file,/get_lun
 
	;--------  Check for and read Exif data  ----------
	soi = bytarr(2)			; Start of Image (JFIF).
	readu,lun,soi
	pntr = 2L			; Pointer into file.
	app = bytarr(2)			; App marker.
	readu,lun,app
	pntr = pntr + 2L
	len = bytarr(2)			; App length.
	readu,lun,len
	pntr = pntr + 2L
	len = fix(len,0)
	if eflag then len=swap_endian(len)
	buff = bytarr(len-2)		; App data buffer size.
	readu,lun,buff
	free_lun, lun
	id = string(buff)		; Better say 'Exif'
	if id ne 'Exif' then begin
	  print,' Not an Exif file.'
	  return
	endif
 
	;---------  This is an Exif file  ---------------
	buff = buff(6:*)		; All offsets are from this start.
	balign = string(buff(0:1))	; Find target endian.
	if balign eq 'II' then tend=0 else tend=1
;	if hend ne tend then print,' Must endian swap TIFF values.'
	ifd_off = long(buff(4:7),0)	; Offset to first Image File Directory.
	if hend ne tend then ifd_off=swap_endian(ifd_off)
 
	;-----------------------------------------------------------------
	;  First Image File Directory (IFD0 = Main Image)
	;  Thumbnail image has IFD1 but we don't care about that.
	;  IFD0 has a link at end to IFD1, we want link to SubIFD
	;  which is given by the value of IFD0 tag 8769 (hex).
	;  IFD0 only has a few interesting items, like Camera
	;  manufacturer and model number.  All the other good stuff
	;  is in SubIFD.
	;-----------------------------------------------------------------
	subifd_off = 0
	num = fix(buff(ifd_off:ifd_off+1),0)	; # entries in IFD0.
	if hend ne tend then num=swap_endian(num)
	if keyword_set(tags) then print,' IFD0 Tags:'
	for i=0,num-1 do begin			; Loop through entries.
	  lo = 12*i+ifd_off+2			; Each entry is 12 bytes.
	  hi = lo+11
	  t = buff(lo:hi)			; Grab bytes for entry.
	  tag = uint(t(0:1),0)			; Get tag number.
	  if hend ne tend then tag=swap_endian(tag)
	  form = fix(t(2:3),0)			; Get format.
	  if hend ne tend then form=swap_endian(form)
	  nn = long(t(4:7),0)			; Get # items.
	  if hend ne tend then nn=swap_endian(nn)
	  dd = long(t(8:11),0)			; Get data or pointer to data.
	  if hend ne tend then dd=swap_endian(dd)
	  xtag = basecon(to=16,tag)		; Want tag in hex.
	  if keyword_set(tags) then print,' Tag = '+xtag
	  ;---------  Process selected tags  -------------
	  if xtag eq '10F' then txtman = string(buff(dd:dd+nn-1))
	  if xtag eq '110' then txtmod = string(buff(dd:dd+nn-1))
	  if xtag eq '131' then txtver = string(buff(dd:dd+nn-1))
	  if xtag eq '132' then txttim = string(buff(dd:dd+nn-1))
	  if xtag eq '8769' then subifd_off = dd
	endfor
 
	;-----------------------------------------------------------------
	;  SubIFD
	;-----------------------------------------------------------------
	ifd_off = subifd_off			; Offset to SubIFD.
	num = fix(buff(ifd_off:ifd_off+1),0)	; # entries in SubIFD.
	if hend ne tend then num=swap_endian(num)
	if keyword_set(tags) then print,' '
	if keyword_set(tags) then print,' SubIFD Tags:'
	for i=0,num-1 do begin			; Loop through entries.
	  lo = 12*i+ifd_off+2			; Each entry is 12 bytes.
	  hi = lo+11
	  t = buff(lo:hi)
	  tag = uint(t(0:1),0)
	  if hend ne tend then tag=swap_endian(tag)
	  form = fix(t(2:3),0)
	  if hend ne tend then form=swap_endian(form)
	  nn = long(t(4:7),0)
	  if hend ne tend then nn=swap_endian(nn)
	  dd = long(t(8:11),0)
	  dds = fix(t(8:11),0)
	  if hend ne tend then dd=swap_endian(dd)
	  if hend ne tend then dds=swap_endian(dds)
;help,dd,dds
	  xtag = basecon(to=16,tag)
	  if keyword_set(tags) then print,' Tag = '+xtag
	  ;---------  Process selected tags  -------------
	  if xtag eq '9003' then dt_tm = string(buff(dd:dd+nn-1))
	  if xtag eq '8822' then expprog = xprog_tab[[dds]]
	  if xtag eq '8827' then isospeed = dd
	  if xtag eq '9291' then subsec = string(buff(dd:dd+nn-1))
	  if xtag eq '9209' then flash = dd
	  if xtag eq 'A002' then x_pixels = dd
	  if xtag eq 'A003' then y_pixels = dd
	  if xtag eq '9102' then begin
	    tmp = ulong(buff,dd,2)
	    bitsperpix = (float(tmp[0])/tmp[1])
	  endif
	  if xtag eq '9206' then begin
	    tmp = long(buff,dd,2)
	    if tmp[1] ne 0 then dist=(float(tmp[0])/tmp[1])
	  endif
	  if xtag eq '829A' then begin
	    tmp = ulong(buff,dd,2)
	    shutter = (float(tmp[1])/tmp[0])
	  endif
	  if xtag eq '829D' then begin
	    tmp = ulong(buff,dd,2)
	    fnum = (float(tmp[0])/tmp[1])
	  endif
	  if xtag eq '9205' then begin
	    tmp = ulong(buff,dd,2)
	    maxap = sqrt(2)^(float(tmp[0])/tmp[1])
	  endif
	  if xtag eq '920A' then begin
	    tmp = ulong(buff,dd,2)
	    foclen = (float(tmp[0])/tmp[1])
	  endif
	  if xtag eq '9286' then begin		; User comment.
	    cmt = buff(dd:dd+nn-1)
	    w = where(cmt eq 0, cnt)		; Replace leading 0s with spc.
	    if cnt gt 0 then cmt(w) = 32B
	    cmt = strtrim(string(cmt),2)
	  endif
	endfor
 
	;------  Finish up some values  ------------
	if subsec ne '' then subsec='.'+subsec
	dt_tm = dt_tm + subsec
	flash = (['NO','YES'])(flash)
	yy = getwrd(dt_tm,0,del=':')+0
	nn = getwrd(dt_tm,1,del=':')+0
	dd = getwrd(dt_tm,2,del=':')+0
	ss = secstr(getwrd(dt_tm,1))
	js = ymds2js(yy,nn,dd,ss)
	if subsec eq '' then begin
	  date = dt_tm_fromjs(js,form='Y$ n$ 0d$ h$:m$:s$ w$')
	endif else begin
	  date = dt_tm_fromjs(js,form='Y$ n$ 0d$ h$:m$:s$f$ w$')
	endelse
 
	;---------  List  -------------------
	if keyword_set(list) then begin
	  print,' '
	  print,' File: '+file
	  print,' Image shot at ',date
	  print,' Comment: '+cmt
	  print,' Picture size: '+strtrim(x_pixels,2)+' x '+strtrim(y_pixels,2)
	  print,' Shutter speed (1/sec): '+strtrim(shutter,2)
	  print,' F-number: '+strtrim(fnum,2)+' (max aperture: '+ $
	    strtrim(maxap,2)+')'
	  print,' Focal length used (mm): '+strtrim(foclen,2)
	  print,' ISO Speed: '+strtrim(isospeed,2)
	  if dist gt 0. then txt=strtrim(dist,2) else txt='unavailable'
	  print,' Focus distance (m): '+txt
	  print,' Flash: ',flash
	  print,' Exposure program: ',expprog
	  print,' Estimated average Bits/pixel: '+strtrim(bitsperpix,2)
	  print,' Camera manufacturer: '+txtman
	  print,' Camera model: '+txtmod
	  print,' Camera firmware version: '+txtver
	endif
 
	;------------  Pack into a returned structure  ---------
	values = {file:file, manufacturer:txtman, model:txtmod, $
		firmware_vers:txtver, image_time:dt_tm, date:date, $
	        date_js:js, shutter:shutter, $
		fnum:fnum, exp_prog:expprog, ISO_speed:isospeed, $
		focus_dist:dist, max_aper:maxap, focal_len:foclen, $
		flash:flash, x_pixels:x_pixels, y_pixels:y_pixels, $
		ave_bits:bitsperpix, comment:cmt}
 
	;---------  Description  ----------------------------
	if not arg_present(desc) then return
	desc = ['Image_time is when image was shot: YYYY:MM:DD HH:MM:SS.FFFFF',$
		'Shutter is shuuter speed in 1/seconds',$
		'fnum is F/number', 'ISO_speed is the film speed equivalent',$
		'focus_dist is focus distance in meters (if available)',$	
		'max_aper is the camera maximum aperture as an F/number',$
		'focal_len is lens focal length in mm (for the shot?)',$
		'flash is flash used? NO/YES',$
		'ave_bits is the estimated average bits/pixel (compression)']
 
	end
