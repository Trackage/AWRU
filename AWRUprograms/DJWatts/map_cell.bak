;+
; NAME:
;    Map_Cell
;
;    maps cells with time spent in each
;    cell_data structure from cell_multi.pro
;
; Input: argos_data, cell, map_bins (deg)
;
;        /overlay  - overlays tracks
;	 /lego - additional surface lego plot
;	 /percent - fills cells with percent time of total
;
;
;-
pro map_cell, argos_data, cell_data, 	$
	overlay = overlay, 		$
	plot_device = plot_device,	$
	map_file = map_file,		$
	map_limits = map_limits,	$
	isotropic = isotropic, 		$
	title = title, 			$
	annotate = annotate, 		$
	default_title = default_title,	$
	percent_cell = percent_cell, 	$
	lego = lego, 			$
	gif_name = gif_name,		$
	to_file = to_file, 		$
	debug = debug

if n_elements(gif_name) eq 0 then gif_name = 'argos.gif'

percent_string = ""

if keyword_set(percent_cell) then percent_string = " (Percent time per cell)"

if n_elements(title) ne 0 then title = title + percent_string

; put the default title on the plot if required
if keyword_set(default_title) then begin
    start_time = argos_data.ut_times(0)
    end_time = argos_data.ut_times(argos_data.npts-1)
    title = "PTT " + string(argos_data.ptts(0),format='(i5)') + $
        " Profile " + string(argos_data.profile_nos(0),format='(i3)') + $
	"  From " + dt_tm_fromjs(start_time,format='d$/n$/y$ h$:m$') + $
	" to "    + dt_tm_fromjs(end_time,format='d$/n$/y$ h$:m$') + $
	"   Quality ge " + argos_data.min_classes(0) + percent_string
endif
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

if !version.os eq 'vms' then begin
@anare:[library.idl.plot]start_plot
end else begin
@Schwarzloch:Documents:IDL:ANARE lib:plot:start_plot
endelse

;col = define_colours()
set_map = 0

if cell_data.rb eq 0 then begin
   ;-- if a projection is decalred then set a map_projection
    if keyword_set(isotropic)  then begin
        set_map = 1	;-- map projection set - use oplot
        map_set, /merc,  /isotropic, $
	    limit = map_limits, $
	    title = title
    endif

      ;else begin
        ; center_lat = (yrange(0) + yrange(1))/2.0
        ; center_lon = (xrange(0) + xrange(1))/2.0
       ;  map_set, center_lat, center_lon, /ortho,  $
	   ; limit = map_limits, $
	   ; title = title
      ; endelse
   ;endif

endif

;-- Plot the raw pts
if keyword_set(overlay) then begin
    good = where(argos_data.ok eq 'Y')

    if cell_data.rb eq 1 then begin
        ll2rb, argos_data.ref_lon, argos_data.ref_lat, argos_data.lons(good), argos_data.lats(good), range, bearing
        range = range * !radeg * 60.0 * 1.852  ; km
        plot, bearing, range, $
            xrange=xrange, yrange=yrange, xstyle=1, ystyle=1, $
            xtitle = 'Bearing (' + string(cell_data.cell_size(0), format='(f6.3)') + ' deg)', $
            ytitle = 'Range ('   + string(cell_data.cell_size(1), format='(f6.3)') + ' km)', title = title
        oplot, bearing, range, psym=1,color=col.red
    end else begin

	if set_map eq 1 then begin
           oplot, argos_data.lons(good), argos_data.lats(good)

           oplotgrid, map_limits

           ; ---- do any annotation - ignore any bad fixes -----
           if keyword_set(annotate) then begin
           for k = 0, n_elements(argos_data.lats) - 1 do begin
               if argos_data.ok(k) eq 'Y' then begin
	              label_pts = string(k + 1, format='(i3)')
	              xyouts, argos_data.lons(k), argos_data.lats(k), label_pts, alignment=0, size=0.5
               endif
           endfor
           endif

     endif

	if set_map eq 0 then begin
           plot, argos_data.lons(good), argos_data.lats(good), $
            xrange=xrange, yrange=yrange, xstyle=1, ystyle=1, $
            xtitle = 'Longitude  cell=' + string(cell_data.cell_size(1), format='(f6.3)') + ' deg)', $
            ytitle = 'Latitude   cell=' + string(cell_data.cell_size(0), format='(f6.3)') + ' deg)', $
            title = title

        oplot, argos_data.lons(good), argos_data.lats(good), psym=1,color=col.red
           ; ---- do any annotation - ignore any bad fixes -----
           if keyword_set(annotate) then begin
           for k = 0, n_elements(argos_data.lats) - 1 do begin
               if argos_data.ok(k) eq 'Y' then begin
	              label_pts = string(k + 1, format='(i3)')
	              xyouts, argos_data.lons(k), argos_data.lats(k), label_pts, alignment=0, size=0.5
               endif
           endfor
           endif
       endif

    endelse
end else begin
    if cell_data.rb eq 1 then begin
            xtitle = 'Bearing   (cell = ' + string(cell_data.cell_size(0), format='(f6.3)') + ' deg)'
            ytitle = 'Range     (cell = ' + string(cell_data.cell_size(1), format='(f6.3)') + ' km)'
    end else begin
            xtitle = 'Longitude  (cell = ' + string(cell_data.cell_size(1), format='(f7.3)') + ' deg)'
            ytitle = 'Latitude   (cell = ' + string(cell_data.cell_size(0), format='(f7.3)') + ' deg)'
            if cell_data.km eq 1 then begin
            xtitle = 'Longitude  (cell = ' + string(cell_data.cell_size(1), format='(f7.3)') + ' km)'
            ytitle = 'Latitude   (cell = ' + string(cell_data.cell_size(0), format='(f7.3)') + ' km)'
            endif
    endelse
    if set_map eq 0 then $
 	plot, xrange, yrange, /nodata, xrange=xrange, yrange=yrange, xstyle=1, ystyle=1, $
    	xtitle = xtitle, ytitle = ytitle, title = title
endelse

;-- Overlay the grid
for ix = 0, n_elements(cell_data.xgrid)-1 do begin
    oplot, [cell_data.xgrid(ix), cell_data.xgrid(ix)], $
           [cell_data.ygrid(0),  cell_data.ygrid(ny)], color=col.yellow
endfor
for iy = 0, n_elements(cell_data.ygrid)-1 do begin
    oplot, [cell_data.xgrid(0),  cell_data.xgrid(nx)], $
	   [cell_data.ygrid(iy), cell_data.ygrid(iy)], color=col.yellow
endfor


;-- overlay the hours on the grid
map_bins = cell_data.map_bins
cell_totals = total(map_bins)
if keyword_set(percent_cell) then begin
    map_bins = map_bins * 100.0 / cell_totals
end

;-- Output data to file if required
if keyword_set(to_file) then begin
    openw,wlun,'cell_data.txt',/get_lun
    printf, wlun, 'Cell data -- ' + title
    printf, wlun, 'Total time is ',cell_totals
    printf, wlun, '  Lat     Long     Cell time (hrs)     Percent time in cell'
endif

for ix = 0, n_elements(x_cell_centers)-1 do begin
    xpt = x_cell_centers(ix)
    for iy = 0, n_elements(y_cell_centers)-1 do begin
        ypt = y_cell_centers(iy)
        if map_bins(ix,iy) ne 0.0 then begin
            xyouts, xpt, ypt, $
	    strtrim(string(map_bins(ix,iy), format='(f10.1)'),2), $
	    charsize=0.6, alignment=0.5, orientation=90
	    if keyword_set(to_file) then printf,wlun,ypt,xpt, map_bins(ix,iy), map_bins(ix,iy) * 100.0 /cell_totals
	endif
    endfor
endfor
if keyword_set(to_file) then free_lun, wlun


if cell_data.rb eq 0 then begin
    if keyword_set(map_file) then begin
	if map_file eq 'idl_world.dat' and set_map eq 1 then oplotmap, map_file
	if map_file ne 'idl_world.dat' then oplotmap, map_file
    endif
endif

if keyword_set(lego) then begin
   nx = n_elements(cell_data.xgrid)
   ny = n_elements(cell_data.ygrid)
   new_cells = make_array(nx,ny, /float, value=0.0)
   new_cells(0:nx-2, 0:ny-2) = map_bins

   surface, new_cells, cell_data.xgrid, cell_data.ygrid, $
       /lego, az=30, ax=40, charsize=2, min_value=0.1
endif

if !version.os eq 'vms' then begin
@anare:[library.idl.plot]end_plot
end else begin
@Schwarzloch:Documents:IDL:ANARE lib:plot:end_plot
endelse

end



