;-------------------------------------------------------------
;+
; NAME:
;       ZWINDOW
; PURPOSE:
;       Z buffer window like normal x window.
; CATEGORY:
; CALLING SEQUENCE:
;       zwindow
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         XSIZE=xs  X size of window (def=!d.x_size).
;         YSIZE=ys  Y size of window (def=!d.y_size).
;         N_COLORS=n  Number of colors to use (def=!d.table_size).
;         /CLOSE  Terminate z window and restore previous window.
;         /COPY   Copy z window to visible window.
;         /LIST   List zwindow status.
;         /GET    Get image and color table:
;           IMAGE=img, RED=r, GRN=g, BLU=b.
; OUTPUTS:
; COMMON BLOCKS:
;       zwindow_com
; NOTES:
;       Notes: Easy 8 bit graphics on a 24 bit display.
;         Set up z window, then graphics commands use it.
;         Can read back image and color table with tvrd, tvlct,/get.
;         Use /copy to display results, /close when done.
; MODIFICATION HISTORY:
;       R. Sterner, 2000 Mar 28
;       R. Sterner, 2000 Apr 17 --- removed the close on /COPY.
;       R. Sterner, 2000 May 07 --- Fixed an entry device bug.
;       R. Sterner, 2000 May 22 --- Will resize X window on /copy if needed.
;       R. Sterner, 2001 Jan 29 --- Added /GET,IMAGE=img,R=r,G=g,B=b
;
; Copyright (C) 2000, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro zwindow, xsize=xsize0, ysize=ysize0, n_colors=n_colors0, $
	  copy=copy, close=close, list=list, help=hlp, $
	  get=get, image=a, red=rr, grn=gg, blu=bb
 
	common zwindow_com, zflag, pdev, win, decomp, xsize, ysize, n_colors
 
	if keyword_set(hlp) then begin
	  print,' Z buffer window like normal x window.'
	  print,' zwindow'
	  print,'   All args are keywords.'
	  print,' Keywords:'
	  print,'   XSIZE=xs  X size of window (def=!d.x_size).' 
	  print,'   YSIZE=ys  Y size of window (def=!d.y_size).' 
	  print,'   N_COLORS=n  Number of colors to use (def=!d.table_size).'
	  print,'   /CLOSE  Terminate z window and restore previous window.'
	  print,'   /COPY   Copy z window to visible window.'
	  print,'   /LIST   List zwindow status.'
	  print,'   /GET    Get image and color table:'
	  print,'     IMAGE=img, RED=r, GRN=g, BLU=b.'
	  print,' Notes: Easy 8 bit graphics on a 24 bit display.'
	  print,'   Set up z window, then graphics commands use it.'
	  print,'   Can read back image and color table with tvrd, tvlct,/get.'
	  print,'   Use /copy to display results, /close when done.'
	  return
	endif
 
	;-------  List zwindow status  -----------
	if keyword_set(list) then begin
	  print,' '
	  print,' ZWINDOW status:'
	  help,zflag, pdev, win, decomp, xsize, ysize, n_colors
	  return
	endif
 
	;-------  Copy z window  -----------------
	if (keyword_set(copy)) or (keyword_set(get)) then begin
	  if n_elements(zflag) eq 0 then begin
	    print,' Error in zwindow: cannot copy zwindow, never opened.'
	    return
	  endif
	  if zflag eq 0 then begin
	    print,' Error in zwindow: cannot copy zwindow, not open.'
	    return
	  endif
	  pdev0 = !d.name			; Current plot device.
	  if pdev0 ne 'Z' then set_plot,'Z'	; Force to Z.
	  a = tvrd()			; Read 8 bit image from z buffer.
	  tvlct,rr,gg,bb,/get
	  if keyword_set(get) then begin
	    if pdev0 ne 'Z' then set_plot,pdev0
	    return
	  endif
	  sz=size(a) & nx=sz(1) & ny=sz(2)
	  set_plot,pdev			; Back to entry plot device.
	  if win_open(win) then begin
	    wset, win			; Set to entry window.
	    dxs = !d.x_size		; Get size.
	    dys = !d.y_size
	  endif else begin		; Window not open.
	    dxs = 0			; Zero size.
	    dys = 0
	  endelse
	  if win lt 0 then begin	; No window, force size mismatch.
	    dxs = 0
	    dys = 0
	  endif
	  if win ge 32 then begin	; /free window.
	    if (nx ne dxs) or (ny ne dys) then begin  ; New window.
              if (nx gt 1200) or (ny gt 900) then begin
                swindow,xs=nx,ys=ny,x_scr=nx<1200,y_scr=ny<900
              endif else begin
                window,/free,xs=nx,ys=ny
              endelse
	      win = !d.window		; Remember created window.
	    endif
	  endif else begin
	    if (nx ne dxs) or (ny ne dys) then begin ; New window.
              if (nx gt 1200) or (ny gt 900) then begin
                swindow,xs=nx,ys=ny,x_scr=nx<1200,y_scr=ny<900
              endif else begin
                window,win>0,xs=nx,ys=ny
              endelse
	      win = !d.window		; Remember created window.
	    endif
	  endelse
	  device, decomp=0		; Set to 8 bit display mode.
	  tvlct,rr,gg,bb
	  tv, a				; Display image.
	  set_plot,'z'			; Back to z buffer.
	  return
	endif
 
	;-------  Close z window  -----------------
	if keyword_set(close) then begin
	  if n_elements(zflag) eq 0 then return	; Never opened.
	  if zflag eq 0 then return		; Not open now.
	  device, /close			; Close z buffer.
	  set_plot,pdev				; Back to entry plot device.
	  device, decomp=decomp			; Set to previous state.
	  zflag = 0				; Set flag to closed.
	  return
	endif
 
	;-------  Find entry state  ---------------
	pdev0 = !d.name				; Plot device.
	if pdev0 eq 'Z' then return		; Assume ok if Z.
	pdev = pdev0
	win = !d.window				; Get visible window.
	device, get_visual_name=vis             ; Get visual type.
	vflag = vis ne 'PseudoColor'            ; 0 if PseudoColor.
	device, get_decomp=decomp		; Decomp flag.
 
	;--------  Set values  --------------------
	if n_elements(xsize0) eq 0 then xsize0=!d.x_size
	if n_elements(ysize0) eq 0 then ysize0=!d.y_size
	if n_elements(n_colors0) eq 0 then n_colors0=!d.table_size
	xsize=xsize0 & ysize=ysize0 & n_colors=n_colors0
 
	;--------  Set up window  ------------------
	set_plot,'z'
	device, set_colors=n_colors, set_res=[xsize,ysize], z_buff=0
	zflag = 1				; Set flag to open.
 
	return
 
	end
