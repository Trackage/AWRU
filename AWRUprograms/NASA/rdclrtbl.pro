;-------------------------------------------------------------------
; IDL PROGRAM  :  rdclrtbl.pro
; PARAMETERS   :  color index arrays:  r,g,b
; AUTHOR       :  Jorge Vazquez
; MODIFICATIONS: 	Modified to use variable lun option for openr, and
;				to close this lun when finished, MDSumner 31Oct01.
;===================================================================
;   Copyright (c) 2001, California Institute of Technology
;===================================================================


pro rdclrtbl,r,g,b

r=fltarr(255)
g=fltarr(255)
b=fltarr(255)
openr,lun,'clrtbl.d', /get_lun

for i=0,254 do begin
  readf,lun,dum,rr,rg,rb
  r(i)=rr
  g(i)=rg
  b(i)=rb
  tvlct,r,g,b
endfor
free_lun, lun
end

