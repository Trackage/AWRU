;-------------------------------------------------------------
;+
; NAME:
;       GETFILE
; PURPOSE:
;       Read a text file into a string array.
; CATEGORY:
; CALLING SEQUENCE:
;       s = getfile(f)
; INPUTS:
;       f = text file name.      in
; KEYWORD PARAMETERS:
;       Keywords:
;         ERROR=err  error flag: 0=ok, 1=file not opened,
;           2=no lines in file.
;         /QUIET means give no error message.
;         LINES=n  Number of lines to read (def=all).
;           Much faster if number of lines is known.
; OUTPUTS:
;       s = string array.        out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 20 Mar, 1990
;       R. Sterner, 1999 Apr 14 --- Added LINES=n keyword.
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function getfile, file, error=err, help=hlp, quiet=quiet, lines=lines
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Read a text file into a string array.'
	  print,' s = getfile(f)'
	  print,'   f = text file name.      in'
	  print,'   s = string array.        out'
	  print,' Keywords:'
	  print,'   ERROR=err  error flag: 0=ok, 1=file not opened,'
	  print,'     2=no lines in file.'
	  print,'   /QUIET means give no error message.'
	  print,'   LINES=n  Number of lines to read (def=all).'
	  print,'     Much faster if number of lines is known.'
	  return, -1
	endif
 
	get_lun, lun
	on_ioerror, err
	openr, lun, file
 
	if n_elements(lines) ne 0 then begin
	  s = strarr(lines)
	  readf,lun,s
	endif else begin
	  s = [' ']
	  t = ''
	  while not eof(lun) do begin
	    readf, lun, t
	    s = [s,t]
	  endwhile
	endelse
 
	close, lun
	free_lun, lun
	if n_elements(s) eq 1 then begin
	  if not keyword_set(quiet) then print,' No lines in file.'
	  err = 2
	  return,-1
	endif
	if n_elements(lines) eq 0 then s=s(1:*)
 
	err = 0
	return, s
 
err:	if !err eq -168 then begin
	  if not keyword_set(quiet) then print,' Non-standard text file format.'
	  free_lun, lun
	  return, s
	endif
	if not keyword_set(quiet) then print,$
	  ' Error in getfile: File '+file+' not opened.'
	free_lun, lun
	err = 1
	return, -1
 
	end
