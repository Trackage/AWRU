;+
; NAME:
;    cell_file
;
;    ripped off map_cell, thrown away display stuff , just to output data to file
;
; Input: argos_data, cell, map_bins (deg)
;
;        /overlay  - overlays tracks
;	 /lego - additional surface lego plot
;	 /percent - fills cells with percent time of total

;	MODHIST:  added cellzero keyword so filtcellarc returns zero values for ARCinfo, MDS7Nov01
;
;
;-
pro cell_file, argos_data, cell_data, 	$
	to_file = to_file, title = title, cellzero = cellzero


if n_elements(gif_name) eq 0 then gif_name = 'argos.gif'

percent_string = ""

if keyword_set(percent_cell) then percent_string = " (Percent time per cell)"

if n_elements(title) ne 0 then title = title + percent_string

; put the default title on the plot if required
;if keyword_set(default_title) then begin
;    start_time = argos_data.ut_times(0)
;    end_time = argos_data.ut_times(argos_data.npts-1)
;    title = "PTT " + string(argos_data.ptts(0),format='(i5)') + $
;        " Profile " + string(argos_data.profile_nos(0),format='(i3)') + $
;	"  From " + dt_tm_fromjs(start_time,format='d$/n$/y$ h$:m$') + $
;	" to "    + dt_tm_fromjs(end_time,format='d$/n$/y$ h$:m$') + $
;	"   Quality ge " + argos_data.min_classes(0) + percent_string
;endif
if n_elements(title) eq 0 then title = 'Argos Cell map  - Profile ' + $
        string(argos_data.profile_nos(0),format='(i3)') + percent_string


nx = n_elements(cell_data.xgrid)-1
ny = n_elements(cell_data.ygrid)-1
deltax = (cell_data.xgrid(nx) - cell_data.xgrid(0)) * 0.02
deltay = (cell_data.ygrid(ny) - cell_data.ygrid(0)) * 0.02
xrange = [cell_data.xgrid(0) - deltax, cell_data.xgrid(nx) + deltax]
yrange = [cell_data.ygrid(0) - deltay, cell_data.ygrid(ny) + deltay]

map_limits = [yrange(0), xrange(0), yrange(1), xrange(1)]

x_cell_centers = (cell_data.xgrid(0:nx-1) + cell_data.xgrid(1:nx))/2.0
y_cell_centers = (cell_data.ygrid(0:ny-1) + cell_data.ygrid(1:ny))/2.0

; start the plot
;@start_plot - now extracted from start_plot.pro and included directly


;-- overlay the hours on the grid
map_bins = cell_data.map_bins
cell_totals = total(map_bins)

    ;map_bins = map_bins * 100.0 / cell_totals



;-- Output data to file if required
if keyword_set(to_file) then begin
    openw,wlun, to_file,/get_lun
    ;printf, wlun, 'Cell data -- cell centres ' + title
    ;printf, wlun, 'Total time is ',cell_totals
    printf, wlun, 'Long', ',',  'Lat', ',',  'Celltime', ',', 'time_PC'     ;Percent time in cell'
endif

for ix = 0, n_elements(x_cell_centers)-1 do begin
    xpt = x_cell_centers(ix)
    for iy = 0, n_elements(y_cell_centers)-1 do begin
        ypt = y_cell_centers(iy)
       IF NOT keyword_set(cellzero) THEN BEGIN  ;don't print zeroes

       	 	if map_bins(ix,iy) ne 0.0 then begin

	    		printf,wlun,xpt, ', ', ypt, ', ', map_bins(ix,iy) , ', ', map_bins(ix,iy) * 100.0 /cell_totals
			endif
			;print zeroes
		ENDIF ELSE printf,wlun,xpt, ', ', ypt, ', ', map_bins(ix,iy) , ', ', map_bins(ix,iy) * 100.0 /cell_totals
    endfor
endfor

if keyword_set(to_file) then free_lun, wlun


end



