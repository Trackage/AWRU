;-------------------------------------------------------------------------------
; Check that a file exists, and return its status / format.
; Returned values:-
;			'HDF'		= HDF format file found
;			'binary'	= binary format file found
;			'none'		= no file found
;			'unknown'	= file found but "faulty"
; Required inputs:-
;			filename	Full path/filename
;
;
;-------------------------------------------------------------------------------

Function passive_check_file,	filename

	file = filename[0]
	openr, unit, file, /get_lun, error = ok
	ok = ok eq 0
	if ok then begin
	    close, unit
	    free_lun, unit
	    ok = HDF_ISHDF(file)
	    if ok then begin
		L = HDF_OPEN(file)
		if L eq -1 then ok = 0 else HDF_CLOSE, L
	    endif
	    if ok eq 0 then status = 'binary' else status = 'HDF'
	endif else begin
	    if !error_state.name eq 'IDL_M_CNTOPNFIL' then status = 'none' $
						      else status = 'unknown'
	endelse

	return, status

end


;-------------------------------------------------------------------------------

