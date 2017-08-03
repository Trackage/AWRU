;-------------------------------------------------------------
;+
; NAME:
;       MONTHNUM
; PURPOSE:
;       Return month number given name.
; CATEGORY:
; CALLING SEQUENCE:
;       num = monthnum(name)
; INPUTS:
;       name = month name (at least 3 characters).  in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       num = month number (Jan=1, Feb=2, ...).     out
;         -1 means invalid input month name.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1999 Aug 2
;
; Copyright (C) 1999, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function monthnum, name, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Return month number given name.'
	  print,' num = monthnum(name)'
	  print,'   name = month name (at least 3 characters).  in'
	  print,'   num = month number (Jan=1, Feb=2, ...).     out'
	  print,'     -1 means invalid input month name.'
	  return,''
	endif
 
	a = strlowcase(strmid(monthnames(),0,3))	; List of 3 char names.
	n = strlowcase(strmid(name,0,3))		; Edited input name.
	w = where(n eq a, cnt)				; Find match.
	return,w(0)					; Return result.
 
	end
