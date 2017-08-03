;+
; NAME:
;	argos_map
;
; Calling Sequence
;
;	argos_map, argos_data
;
;
; 	Must pass one parameter (a data structure) containing
;	the lats/lons etc of the PTT(s) we wish to plot. All other
; 	parameters are passed via switches
;
; 	If there are multiple PTT's to plot then invoke 'multi_plot' mode
;
; Keywords
;	/noconnect      - do not connect pts
;	/error_circles  - add error circles
;	/day_marks      - add marks at each local midnight
;	/days_only      - only plot day to day movements
;	/autoscale      - instead of set map limits, use the data to define the map limits
;	/plot_gebco     - plot bathymetry if a suitable file can be found.
;	/default_title  - use a default title
;
;	map_file        = map_file - passin a file containing a map
;	map_limits      = vector of map limits [slat, wlon, nlat, elon] in degress
;	plot_device     - PS GIF VT 
;	title           - pass in a title
;
;
;-

pro argos_map, argos_data, $
	noconnect = noconnect,		$
	error_circles = error_circles,	$
	day_marks = day_marks, $
	days_only = days_only, $
	autoscale = autoscale, 		$
	annotate = annotate, 		$
	default_title = default_title,	$
	title = title, 			$
	profile_name = profile_name, 	$
	plot_device = plot_device, 	$
	map_file = map_file,		$
	map_limits = map_limits,	$
	projection = projection, 	$
	gif_parameters = gif_parameters, $
;	gif_name = gif_name,		$
	plot_gebco = plot_gebco, 	$
	v4=v4, $
	debug=debug


on_error, 2
if n_params() lt 1 then message, 'Argos_system:ARGOS_MAP: - No data to plot'

;-----------------  Set default parameters ---------------
; set plot device
if not keyword_set(plot_device) then begin
    if !version.os eq 'MacOS' then plot_device = 'MAC'
    if !version.os eq 'vms' then plot_device = 'X'
endif
plot_device = strupcase(plot_device)

if n_elements(gif_parameters) eq 0 then $
	gif_parameters = {gif_name:'argos.gif', xsize:600, ysize:500}

connect = 1	; set connect is true unless othwerwise
annotate_pts = 0
if keyword_set(noconnect) then connect = 0
if keyword_set(annotate) then annotate_pts = 1
if keyword_set(day_marks) then begin		; day marks always conectted
;	annotate_pts = 0			; with special annotaion
endif

if n_elements(projection) eq 0 then projection = "O"
if n_elements(profile_name) eq 0 then profile_name = ""

; put the default title on the plot if required
if keyword_set(default_title) then begin
    start_time = argos_data.ut_times(0)
    end_time = argos_data.ut_times(argos_data.npts-1)
    title = "!3PTT " + string(argos_data.ptts(0),format='(i5)') + $
        "    Profile " + string(argos_data.profile_nos(0),format='(i3)') + '!c' + $
	"From " + dt_tm_fromjs(start_time,format='d$/n$/y$ h$:m$') + $
	" to "    + dt_tm_fromjs(end_time,format='d$/n$/y$ h$:m$') + '!c' + $
	"Quality ge " + argos_data.min_classes(0) + $
	"   " + profile_name + '!x'
endif


; try a filled diamond
usersym, [-0.5,0.0,0.5,0.0,-0.5],[0.0,0.5,0.0,-0.5,0.0], /fill



;---------- Set map limits etc -----------

if not keyword_set(map_limits) or keyword_set(autoscale) then begin
    ; record that maximum PTT lat/long pts we see
    good_index = where(argos_data.ok eq 'Y')
    map_limits = [min(argos_data.lats(good_index)), min(argos_data.lons(good_index)), $
		  max(argos_data.lats(good_index)), max(argos_data.lons(good_index))]

    delta_lat = map_limits(2) - map_limits(0)
    delta_lon = map_limits(3) - map_limits(1)
    ; tweak map_limits to be about 3% larger side
    map_limits(0) = map_limits(0) - delta_lat * 0.03
    map_limits(1) = map_limits(1) - delta_lon * 0.03
    map_limits(2) = map_limits(2) + delta_lat * 0.03
    map_limits(3) = map_limits(3) + delta_lon * 0.03
endif else begin
    delta_lat = map_limits(2) - map_limits(0)
    delta_lon = map_limits(3) - map_limits(1)
endelse

center_lat = (map_limits(0) + map_limits(2))/2.0
center_lon = (map_limits(1) + map_limits(3))/2.0

;---------- Start the plotting -----------

grid_colour = 0
coast_colour = 0
label_colour = 0
symbol_colour = 0
track_colour = 0

if (plot_device eq 'PS') then begin
	set_plot,'ps'
	device, filename='report_tmx', /landscape
end else if (plot_device eq 'EPS') then begin
	set_plot,'ps'
	device, filename='report_tmx', /encapsulated, xsize=15, ysize=15
end else if (plot_device eq 'GIF') then begin
	set_plot,'z', /copy
	device, set_resolution=[gif_parameters.xsize,gif_parameters.ysize]
	tek_color
	!p.background = 1
	!p.color = 0
	grid_colour = 0
	coast_colour = 11
	label_colour = 0
	symbol_colour = 8
	;track_colour = 2
	;-- make an array of possible track colours/styles for gifs
	track_colour = [2, 8, 7, 19, 23, 29, 0]
	track_style  = [0, 2, 0, 2, 0, 2, 0]
end else if (plot_device eq 'REGIS') then begin
	set_plot,'regis'
end else begin
    col = define_colours()
    !p.background = col.black
	!p.color = col.white
	grid_colour = col.white
	coast_colour = col.green
	label_colour = col.yellow
	symbol_colour = col.red

endelse

;--------  Create the map ---------------
!p.charsize=0.7

if projection eq 'M' then begin
    map_set, /merc,  /isotropic, $
	limit = map_limits, $
	position=[0.05,0.15,0.95,0.9], /noborder
end else begin
    map_set, center_lat, center_lon, /ortho,  /isotropic, $
	limit = map_limits, $
	position=[0.05,0.15,0.95,0.9], /noborder
endelse

xyouts, 0.01, 0.96, title, /normal, charsize=1.2
oplotgrid, map_limits, /label

; map an optional mapfile and Gebco bathymetry
if keyword_set(map_file) then oplotmap, map_file
;if keyword_set(plot_gebco) then oplotmap, 'map_dir:gebco.geo', linestyle=3
if keyword_set(plot_gebco) then oplotmap, 'map_dir:gebco.geo'


if keyword_set(v4) then v4, colour=track_colour

;---------- plot the data -------------


;------ Error circles -------

if keyword_set(error_circles) then begin
;
; compute radius of error circles in device units to preserve shape
; error circles on class 3 2 or 1 only (metres)
; get required radius in device units centered in middle of map
    radius = [150.0, 300.0, 1000.0] / 1852.0 /60.0 ;convert to degrees
    radius_device = [0, 0, 0]
    for j = 0,2 do begin

	vector = convert_coord(/to_device, 	$
		[center_lon, center_lon], $
		[center_lat, (center_lat - radius(j) * 10.0)])
	radius_device(j) = abs(vector(1,0) - vector(1,1)) /10.0

	; note we have scaled up by 10 the radius and then scaled back by
	; 10 in device units so that the convert_coord calculation
	; will work .
   endfor


    for k = 0, argos_data.npts-1 do begin
	case argos_data.classes(k) of 
	    '3': j = 0
	    '2': j = 1
	    '1': j = 2
	    else: j = -1
	endcase

; ignore bad points
        if argos_data.ok(k) eq 'N' then j = -1

	if j ge 0 then begin
	    pos = convert_coord(argos_data.lons(k), argos_data.lats(k), $
		/to_device)
	    xpos = radius_device(j) * sin(findgen(37) * 10.0 * !dtor) + pos(0)
	    ypos = radius_device(j) * cos(findgen(37) * 10.0 * !dtor) + pos(1)
	    plots, xpos, ypos,/device
	endif
    endfor
endif

; ----- parse out data per profile and plot it -------
start_pt = 0l
for j = 0, n_elements(argos_data.npts)-1 do begin
	end_pt = start_pt + argos_data.npts(j) - 1

; extract lats/lons so we can remove 'bad' pts using WHERE
     temp_lats    = argos_data.lats(start_pt:end_pt)
     temp_lons    = argos_data.lons(start_pt:end_pt)
     temp_times   = argos_data.ut_times(start_pt:end_pt)
     temp_classes = argos_data.classes(start_pt:end_pt)
     temp_ok      = argos_data.ok(start_pt:end_pt)

	good = where(temp_ok eq 'Y', count)
	if count gt 0 then begin
	
	    ;-- get a  color for the plot
	    if plot_device eq 'GIF' then begin
	    	icol = j mod n_elements(track_colour) 
	    	plot_colour = track_colour(icol)
	    endif else begin
	    	plot_colour = symbol_colour
	    endelse

	    good_lats  = temp_lats(good)
	    good_lons  = temp_lons(good)
	    good_times = temp_times(good)
	    good_classes = temp_classes(good)
	    
	    ;-- Find day pts and plot
	    if keyword_set(day_marks) then begin
	        good_day_lats = good_lats
	        good_day_lons = good_lons
	        good_day_times = good_times
	    	   create_day_positions, good_day_lats, good_day_lons, good_day_times, /solar
		   for day_index = 0, n_elements(good_day_times)-1 do begin
	    	      xyouts, good_day_lons(day_index), good_day_lats(day_index), $
	    		   dt_tm_fromjs(good_day_times(day_index),format=' d$/n$'), $
	    		   alignment=0, size=0.5, color=plot_colour	
		   endfor

		   scale = 1
		   symbols, 2, scale
		   plots, good_day_lons, good_day_lats, psym=8
		
		   ;-- connect day to day pts if /days_only is set
		   if keyword_set(days_only) and connect eq 1 then plots, good_day_lons, good_day_lats
	    endif
	    
	    ;-- connect msg to msg pts if /noconnect or /days_only are NOT set
    	    if not keyword_set(days_only) then begin
    	        if connect eq 1 then begin
    	             plots, good_lons, good_lats, color = plot_colour
    	        endif else begin
                  plots, good_lons, good_lats, psym=2, color = symbol_colour, symsize=0.5
             endelse
             
             ;-- mark any ref points with a special symbol
             ref_pts_index = where(good_classes eq ' ', iref)
             if iref ne 0 then begin
 		     symbols, 30, 2
; 		     for k=0,n_elements(ref_pts_index) do plots, good_lons(k), good_lats(k), psym=8
             endif
              
     	    endif
    	    
	endif
	start_pt = end_pt + 1
endfor



; ---- do any annotation - ignore any bad fixes -----
if (annotate_pts) then begin
    for k = 0, n_elements(argos_data.lats) - 1 do begin
      if argos_data.ok(k) eq 'Y' then begin
	label_pts = string(k + 1, format='(i3)')
	xyouts, argos_data.lons(k), argos_data.lats(k), label_pts, alignment=0, size=0.5
      endif
    endfor
endif



;-------- Plot any map attributes -------------

if (plot_device eq 'GIF') then write_gif, gif_parameters.gif_name, tvrd()

if (plot_device eq "GIF") then begin
	!p.background = 1
	!p.color = 0
endif

if  plot_device eq 'EPS' then device,encapsulated=0
if (plot_device ne 'X' and plot_device ne 'MAC') then device,/close

end
