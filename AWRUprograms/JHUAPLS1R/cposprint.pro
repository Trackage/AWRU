;-------------------------------------------------------------
;+
; NAME:
;       CPOSPRINT
; PURPOSE:
;       Print a string showing character positions.
; CATEGORY:
; CALLING SEQUENCE:
;       cposprint, s
; INPUTS:
;       s = input string to print.  in
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: prints character positions above string.
; MODIFICATION HISTORY:
;       R. Sterner, 2000 May 31
;
; Copyright (C) 2000, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro cposprint, s, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Print a string showing character positions.'
	  print,' cposprint, s'
	  print,'   s = input string to print.  in'
	  print,' Note: prints character positions above string.'
	  return
	endif
 
	;-------  Set up position ruler  ------------
	len = max(strlen(s))
	t0 = '' & t1 = '' & t2 = ''
	for i=0,len-1 do begin
	  a = string(i,form='(I3)')
	  t2 = t2 + strmid(a,0,1)
	  t1 = t1 + strmid(a,1,1)
	  t0 = t0 + strmid(a,2,1)
	endfor
 
	;--------  Display given text string(s)  -------------
	print,t2	
	print,t1
	print,t0
	for i=0,n_elements(s)-1 do print,s(i)
 
	return
 
	end
