
;+
; NAME:
;       OPLOTGRID
;
; PURPOSE:
;       Given map_limits then compute sensible grid
;	Produce an overlay of latitude and longitude lines over a plot or image
;	on the current graphics device. AITOFF_GRID assumes that the ouput plot
;	coordinates span the x-range of -180 to 180 and the y-range goes from
;	-90 to 90.
;
; CALLING SEQUENCE:
;
;	OPLOTGRID, map_limits, [LINESTYLE=LINESTYLE, /LABELS]
;
; INPUTS:
;	vector of map_limits
;
; KEYWORDS:
;
;	LINESTYLE	= Optional input integer specifying the linestyle to
;			  use for drawing the grid lines.
;	LABELS		= Optional keyword specifying that the lattitude and
;			  longitude lines on the prime meridian and the
;			  equator should be labeled in degrees. If LABELS is
;			  given a value of 2, i.e. LABELS=2, then the longitude
;			  labels will be in hours and minutes instead of
;			  degrees.
;
; OUTPUTS:
;	Draws grid lines on current graphics device.
;
;-

pro oplotgrid, map_limits, $
	linestyle=linestyle, $
	colour = colour, $
	min_ticks = min_ticks, $
	label=label

; default linestyle is dotted
if not keyword_set(linestyle) then linestyle=1
if not keyword_set(colour) then colour=!p.color
if not keyword_set(min_ticks) then min_ticks = 3

delta_lat = map_limits(2) - map_limits(0)
delta_lon = map_limits(3) - map_limits(1)
left_side = map_limits(1) - 0.04 * delta_lon
bottom    = map_limits(0) - 0.04 * delta_lat

; Do lines of constant latitude
dmstickle, map_limits(0), map_limits(2), tikvals, tiklabs, min_ticks = min_ticks
; create 100 element array of pts from west to east long
longs = map_limits(1) + findgen(100) * delta_lon / 99.0
for k = 0, n_elements(tikvals) -1 do begin
	lats = replicate(tikvals(k), 100)
	plots, longs, lats, linestyle=linestyle, color=colour
	if keyword_set(label) then xyouts, left_side, tikvals(k), $
		tiklabs(k), alignment=1.0, charsize=0.7
endfor

;
; Do lines of constant longitude

dmstickle, map_limits(1), map_limits(3), tikvals, tiklabs, min_ticks = min_ticks
; create 100 element array of pts from west to east long
lats = map_limits(0) + findgen(100) * delta_lat / 99.0
for k = 0, n_elements(tikvals) -1 do begin
	longs = replicate(tikvals(k), 100)
	plots, longs, lats, linestyle=linestyle, color=colour
	if keyword_set(label) then xyouts, tikvals(k), bottom, $
		tiklabs(k), alignment=0.5, charsize =0.7
endfor

return
end
