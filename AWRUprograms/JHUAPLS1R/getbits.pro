;-------------------------------------------------------------
;+
; NAME:
;       GETBITS
; PURPOSE:
;       Pick out specified bits from a value.
; CATEGORY:
; CALLING SEQUENCE:
;       out = getbits(in, s, n)
; INPUTS:
;       in = integer value (scalar or array) to pick from. in
;       s = bit number to start at (LSB is 0).             in
;       n = number of bits to pick out (def=1).            in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       out = returned value.                              out
; COMMON BLOCKS:
; NOTES:
;       Notes: Input value must be an integer data type:
;         byte, int, u_int, long, u_long, long_64, u_long_64
;         Returned value is same data type.
; MODIFICATION HISTORY:
;       R. Sterner, 1999 Jun 3
;
; Copyright (C) 1999, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function getbits, in, start, num, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Pick out specified bits from a value.'
	  print,' out = getbits(in, s, n)'
	  print,'   in = integer value (scalar or array) to pick from. in'
	  print,'   s = bit number to start at (LSB is 0).             in'
	  print,'   n = number of bits to pick out (def=1).            in'
	  print,'   out = returned value.                              out'
	  print,' Notes: Input value must be an integer data type:'
	  print,'   byte, int, u_int, long, u_long, long_64, u_long_64'
	  print,'   Returned value is same data type.'
	  return,''
	endif
 
	;-----  Input error checks  ------------
	t = datatype(in,integer_bits=bits)
	if bits le 0 then begin
	  print,' Error in getbits: must be an integer value.'
	  return,-1
	endif
        if (start+num) ge bits then begin
          print,' Error in getbits: '+$
            'Source ('+strtrim(bits,2)+' bits) is too small to'
          print,'   extract '+strtrim(num,2)+' bits starting at bit '+$
            strtrim(start,2)+'.'
          return,-1
        endif
 
	;-----  Shift requested start bit to LSB  -----------
	out = ishft(in,-start)
 
	;-----  Needed bit mask  -------------
        case bits of
8:      mask = 2B ^num - 1B	; Byte mask.
16:     mask = 2  ^num - 1	; Int mask.
32:     mask = 2L ^num - 1L	; Long mask.
64:     mask = 2LL^num - 1LL	; Long_24 mask.
else:   stop,' Stopped in getbits: internal error.'
        endcase
 
	;-----  Mask off unrequested bits  --------- 
	return, out AND mask
 
	end
