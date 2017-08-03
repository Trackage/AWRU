
restore, 'eachfn.xdr'

lons = seal_cells.xgrid
lats = seal_cells.ygrid

limits = [max(lats), min(lats), min(lons), max(lons)]
; -40.9467     -69.2945      126.303      219.657
;diag
;ll2rb, 124.734, -70.1944, 221.226, -40.4968, drange, dazi
ll2rb, limits(2), limits(1), limits(3), limits(0), drange, dazi
;horiz
;ll2rb,  124.734, 70.1944, 221.226, 70.1944, hrange, hazi
ll2rb,  limits(2), limits(1), limits(3), limits(1), hrange, hazi
;vert
ll2rb,  limits(3), limits(1), limits(3), limits(0), vrange, vazi

help, dazi, hazi, vazi
;r = (abs(dazi) - abs(hazi))*!radeg
;g = (abs(vazi) - abs(hazi))*!radeg
;b = (abs(vazi) - abs(dazi))*!radeg
r = (hazi - dazi)/!radeg
g = (hazi - vazi)/!radeg
b = (dazi - vazi)/!radeg

area = 2*((6371.23^2)*(r + b + g - !PI))

stop

end
