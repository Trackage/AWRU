;+
;  NAME:
;     Correlate_Tracks
;
; Must pass one parameter (a data structure) containing
; the lats/lons etc of the PTT(s) we wish to plot. All other
; parameters are passed via switches
;
; If there are multiple PTT's to plot then invoke multi_plot mode
;
;-
pro correlate_tracks, argos_data, $
	title = title, 			$
	delta_time = delta_time, $
	plot_device = plot_device

on_error, 2
if n_params() lt 1 then message, 'Argos_system:Correlate_Tracks: - No data to plot'

;-----------------  Set default parameters ---------------
; set plot device
if not keyword_set(plot_device) then plot_device = 'PS'
if n_elements(delta_time) eq 0 then delta_time = 24.0

;---------- Start the plotting -----------
if !version.os eq 'vms' then begin
@anare:[library.idl.plot]start_plot
end else begin
@Schwarzloch:Documents:IDL:ANARE lib:plot:start_plot
endelse

; ----- parse out data per profile and plot it -------

start_time = dblarr(n_elements(argos_data.npts))
end_time = start_time
start_pt = 0l
for j = 0, n_elements(argos_data.npts)-1 do begin
    end_pt = start_pt + argos_data.npts(j) - 1
    start_time(j) = argos_data.ut_times(start_pt)
    end_time(j) = argos_data.ut_times(end_pt)
    start_pt = end_pt + 1
endfor

time_limits = [max(start_time), min(end_time)]
np = n_elements(argos_data.npts)
ptt = fltarr(np)	;-- store PTT number

start_pt = 0l
for j = 0, np - 1 do begin
    ptt(j) = argos_data.ptts(start_pt)
    end_pt = start_pt + argos_data.npts(j) - 1

; extract lats/lons so we can remove 'bad' pts using WHERE
    temp_lats  = argos_data.lats(start_pt:end_pt)
    temp_lons = argos_data.lons(start_pt:end_pt)
    temp_times = argos_data.ut_times(start_pt:end_pt)
    temp_ok    = argos_data.ok(start_pt:end_pt)

    good = where(temp_ok eq 'Y', count)

    if count gt 0 then begin
	good_lats  = temp_lats(good)
	good_lons = temp_lons(good)
	good_times = temp_times(good)

	;-- find new positions for all the data
	create_day_positions, good_lats, good_lons, good_times,$
		delta_time = delta_time

	;-- now select only the allowed range 
	select_range = where(time_limits(0) le good_times $
    		and time_limits(1) ge good_times, select_count)

	good_times = good_times(select_range)
	good_lats  = good_lats(select_range)
	good_lons = good_lons(select_range)

	; -- put the data into arrays
	if (j eq 0) then begin
	    lat_array = make_array(n_elements(good_lats), np,/float)
	    lon_array = lat_array
	    time_elements = n_elements(good_lats)
	endif
	lat_array(*,j) = good_lats
	lon_array(*,j) = good_lons
    endif
    start_pt = end_pt + 1
endfor



; -- construct a metric of the dispersion of the animals from each other

metric = fltarr(n_elements(good_lats))
metric_i = fltarr(n_elements(good_lats),np)
for k=0, N_elements(good_lats)-1 do begin
    center_lat = replicate(total(lat_array(k,*))/np, np)
    center_lon = replicate(total(lon_array(k,*))/np, np)
    
    ll2rb, center_lon, center_lat, lon_array(k,*), lat_array(k,*), range, bearing
    
    range = range * !radeg * 60.0 * 1.852 ; km
    average_range = total(range) / np ; km
    metric(k) = average_range
    metric_i(k,*) = range 
endfor 

;jsplot, good_times, metric, ytitle='Average range from mean (km)'

;-- Metric of individual distances from mean
;jsplot, time_limits, [0.0, max(metric_i)], /nodata, off=off, $
;	ytitle='Individual range from mean (km)'
;for k = 0, np-1 do begin
;    jsplot, good_times, metric_i(*,k), linestyle=k, off=off, /over
;endfor


;-- Metric of individual distances between each other
metric_one2one = fltarr(n_elements(good_lats),(np*(np-1)/2) )
label_one2one  = replicate('            ',np*(np-1)/2 )
ip = -1
for peng1 = 0, np-2 do begin
    for peng2 = peng1+1, np-1 do begin
	ip = ip + 1
	label_one2one(ip) = string(ptt(peng1), ptt(peng2), format='(i5,"-",i5)')
	for j=0, N_elements(good_lats)-1 do begin
	    ll2rb, lon_array(j,peng1), lat_array(j,peng1), $
		lon_array(j,peng2), lat_array(j,peng2), range, bearing
	    metric_one2one(j,ip) = range * !radeg * 60.0 * 1.852 ; km
	endfor
    endfor
endfor 

jsplot, time_limits, [0.0, max(metric_one2one)], /nodata, off=off, $
	ytitle='Range from each other (km)', xtitle='UT', $
	position = [0.08,0.05,0.9,0.95]
for k = 0, ip do begin
    jsplot, good_times, metric_one2one(*,k), linestyle=k, off=off, /over

    ypos = (335 - 25 * k)/400.0
    xyouts, 0.92, ypos, label_one2one(k), charsize=0.5, /normal
    plots, [.92, .98], [ypos-0.02, ypos-0.02], /normal, linestyle = k
endfor



if !version.os eq 'vms' then begin
@anare:[library.idl.plot]end_plot
end else begin
@Schwarzloch:Documents:IDL:ANARE lib:plot:end_plot
endelse

end
