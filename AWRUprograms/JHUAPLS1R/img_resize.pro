;-------------------------------------------------------------
;+
; NAME:
;       IMG_RESIZE
; PURPOSE:
;       Resize a 2-D or 3-D image array.
; CATEGORY:
; CALLING SEQUENCE:
;       out = img_resize(in,mag)
; INPUTS:
;       in = Input image.           in
;       mag = Mag factor            in
;          mag may be [magx,magy].
; KEYWORD PARAMETERS:
;       Keywords:
;         ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,
;           2=wrong number of color channels for 3-D array.
;         May also use the keywords allowed by CONGRID.
; OUTPUTS:
;       out = Resized image.        out
; COMMON BLOCKS:
; NOTES:
;       Note: deals with 2-D or 3-D image arrays and resizes
;         correct image planes.
; MODIFICATION HISTORY:
;       R. Sterner, 2000 Sep 21
;       R. Sterner, 2001 Jan 29 --- Allowed x and y mag.
;
; Copyright (C) 2000, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_resize, img, mag, _extra=extra, error=err, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Resize a 2-D or 3-D image array.'
	  print,' out = img_resize(in,mag)'
	  print,'   in = Input image.           in'
	  print,'   mag = Mag factor            in'
	  print,'      mag may be [magx,magy].'
	  print,'   out = Resized image.        out'
	  print,' Keywords:'
	  print,'   ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,'
	  print,'     2=wrong number of color channels for 3-D array.'
	  print,'   May also use the keywords allowed by CONGRID.'
	  print,' Note: deals with 2-D or 3-D image arrays and resizes'
	  print,'   correct image planes.'
	  return, ''
	endif
 
	err = 0
 
	;-------  For for no op  -----------------------
	nmag = n_elements(mag)
	case nmag of
1:	begin
	  if mag(0) eq 1 then return, img
	end
2:	begin
	  if (mag(0) eq 1) and (mag(1) eq 1) then return, img
	end
else:	begin
	  print,' Error in img_resize: invalid mag factor.'
	  err = 3
	  return, img
	end
	endcase
 
;	if (n_elements(mag) eq 1) and (mag eq 1) then return, img  ; No op.
 
	;--------  Find image dimensions  --------------
	sz = size(img)
	ndim = sz(0)
	if (ndim lt 2) or (ndim gt 3) then begin
	  err = 1
	  print,' Error in img_resize: given array must 2-D or 3-D.'
	  return, img
	endif
 
	;--------  2-D image  --------------------------
	if ndim eq 2 then begin
	  nx = round(sz(1)*mag)
	  ny = round(sz(2)*mag)
	  return, congrid(img,nx,ny,_extra=extra)
	endif
 
	;--------  3-D image  --------------------------
	typ = 0
	if sz(1) eq 3 then typ=1
	if sz(2) eq 3 then typ=2
	if sz(3) eq 3 then typ=3
	if typ eq 0 then begin
	  err = 2
	  print,' Error in img_resize: given array must have a dimension of 3.'
	  return, img
	endif
 
	case typ of
1:	begin
	  nx = round(sz(2)*(mag([0]))(0))
	  ny = round(sz(3)*(mag([1]))(0))
	  r = congrid(reform(img(0,*,*)),nx,ny,_extra=extra)
	  g = congrid(reform(img(1,*,*)),nx,ny,_extra=extra)
	  b = congrid(reform(img(2,*,*)),nx,ny,_extra=extra)
	  sz=size(r) & nx=sz(1) & ny=sz(2) & dtyp=sz(sz(0)+1)
	  out = make_array(3,nx,ny,type=dtyp)
	  out(0,*,*) = r
	  out(1,*,*) = g
	  out(2,*,*) = b
	end
2:	begin
	  nx = round(sz(1)*(mag([0]))(0))
	  ny = round(sz(3)*(mag([1]))(0))
	  r = congrid(reform(img(*,0,*)),nx,ny,_extra=extra)
	  g = congrid(reform(img(*,1,*)),nx,ny,_extra=extra)
	  b = congrid(reform(img(*,2,*)),nx,ny,_extra=extra)
	  sz=size(r) & nx=sz(1) & ny=sz(2) & dtyp=sz(sz(0)+1)
	  out = make_array(nx,3,ny,type=dtyp)
	  out(*,0,*) = r
	  out(*,1,*) = g
	  out(*,2,*) = b
	end
3:	begin
	  nx = round(sz(1)*(mag([0]))(0))
	  ny = round(sz(2)*(mag([1]))(0))
	  r = congrid(reform(img(*,*,0)),nx,ny,_extra=extra)
	  g = congrid(reform(img(*,*,1)),nx,ny,_extra=extra)
	  b = congrid(reform(img(*,*,2)),nx,ny,_extra=extra)
	  sz=size(r) & nx=sz(1) & ny=sz(2) & dtyp=sz(sz(0)+1)
	  out = make_array(nx,ny,3,type=dtyp)
	  out(*,*,0) = r
	  out(*,*,1) = g
	  out(*,*,2) = b
	end
	endcase
 
	return, out
 
	end
