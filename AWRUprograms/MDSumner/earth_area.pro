;"equatorial diameter" is 12,755 kilometers (7,927 miles)."polar diameter" is 12,711 kilometers (7,900 miles).

;The difference 44 kilometers (27 miles),"oblateness"  44/12755, or 0.0034. This amounts to l/3 of 1 percent.
;This from Isaac Asimov, The Skeptical InquirerVol. 14 No. 1Fall 1989http://home.earthlink.net/~dayvdanls/relativity.htm



FUNCTION earth_area, radius, lims = limits

IF n_elements(radius) EQ 0 THEN radius = 6371.23


;restore, 'eachfn.xdr'

;lons = seal_cells.xgrid
;lats = seal_cells.ygrid
help, lims

IF keyword_set(limits) THEN BEGIN
	IF  n_elements(lims) EQ 0 THEN lims = [-40.9467,     -69.2945,      126.303 ,     219.657]
	help, lims
ENDIF ELSE BEGIN
	lims = [90.0, -90.0, 0.0, 360.0]

ENDELSE

th0 = lims(2)
th1 = lims(3)
ph0 = lims(0)
ph1 = lims(1)

;calculate cylindrical projection dimensions of area

x_len = !pi*2*radius*((th1 - th0)/360.0)

IF NOT keyword_set(limits) THEN y_len = radius*2 ELSE y_len = radius*tan((ph0 - ph1)/!radeg)
print, x_len
print, y_len
area = x_len * y_len

return, area


end
