;+
;  NAME:
;     Argos_Movie
;
; Must pass one parameter (a data structure) containing the ARGOS data structure
;
;  map_limits = [southlat, westlon, northlat, eastlon]
;  map_file = map to be used (default is low resolution IDL map)
;
;  mpeg_file  output MPEG file name
;
;  time_limits = 2 element vector of JHU time 
;
;  delta_time (hours) - time step size in the movie (default is 24 hrs)
;
;  trails = make a trail of each ptt from current pt to last 'trails' pt, 
;           Default is no trails. if trails = 1 then plot current to previous pt.
;
;  /eez - oplot macca island EEZ
;-

pro argos_movie, argos_data, $
	title = title, 			$
	delta_time = delta_time, $
	time_limits = time_limits, $
	map_limits = map_limits, $
	map_file = map_file, $
	mpeg_file = mpeg_file, $
	trails = trails, $
	eez = eez

on_error, 2
if n_params() lt 1 then message, 'Argos_system:Movie: - No data to plot'

;-----------------  Set default parameters ---------------
gif_name = 'argos.gif'
if not keyword_set(mpeg_file) then mpeg_file = 'argos.mpg'
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

time_limits = [min(start_time), max(end_time)]
np = n_elements(argos_data.npts)
ptt = fltarr(np)	;-- store PTT number


;GHA F 443,444.432,494,430,434,438,439,495,496
;       M  425,445.433,435,436,437,440,441,442,497, 432, 429
;BBA F 427,491,418,493,481,485,410,455,490,422,461,487,415,460,484,416
;       ? 458,411,413,420,423,414
;      M 409,489,417,456,457,480,483,412,479,421,486,482,424.459.488,492

gha_f = [443,444,432,494,430,434,438,439,495,496]
gha_m = [425,445,433,435,436,437,440,441,442,497,432, 429]
bba_f = [427,491,418,493,481,485,410,455,490,422,461,487,415,460,484,416]
bba_m = [409,489,417,456,457,480,483,412,479,421,486,482,424,459,488,492]
bba_u = [458,411,413,420,423,414]

start_pt = 0l
for j = 0, np - 1 do begin
    ptt(j) = argos_data.ptts(start_pt)
    profile = argos_data.profile_nos(j)
    end_pt = start_pt + argos_data.npts(j) - 1
    sym = 7
    
    ;-- set symbol for Diego Ramirez profiles
    is_gha_f = where(gha_f eq profile, ic)
    if ic ne 0 then sym = 1
    is_gha_m = where(gha_m eq profile, ic)
    if ic ne 0 then sym = 2
    is_bba_f = where(bba_f eq profile, ic)
    if ic ne 0 then sym = 4
    is_bba_m = where(bba_m eq profile, ic)
    if ic ne 0 then sym = 5
    is_bba_u = where(bba_u eq profile, ic)
    if ic ne 0 then sym = 6
    
    print,'profile ',profile,ic,sym

    ;-- extract lats/lons so we can remove 'bad' pts using WHERE
    temp_lats  = argos_data.lats(start_pt:end_pt)
    temp_lons  = argos_data.lons(start_pt:end_pt)
    temp_times = argos_data.ut_times(start_pt:end_pt)
    temp_ok    = argos_data.ok(start_pt:end_pt)

    good = where(temp_ok eq 'Y', count)

    if count gt 0 then begin
	good_lats  = temp_lats(good)
	good_lons = temp_lons(good)
	good_times = temp_times(good)

	;-- find new positions for all the data
	create_day_positions, good_lats, good_lons, good_times,$
		delta_time = delta_time, $
		time_limits = time_limits

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
	    sym_array = make_array(n_elements(good_lats), np,/int)
	    time_elements = n_elements(good_lats)
	endif
	lat_array(*,j) = good_lats
	lon_array(*,j) = good_lons
	sym_array(*,j) = sym
    endif
    start_pt = end_pt + 1
endfor

col = define_colours(/tek)
;tek_color
window,0,xsize=600,ysize=500
;set_plot,'z', /copy
;device, set_resolution=[600,500]

;--- make a movie of the positions
good_lats = where(lat_array le 900.0,iok)
good_lons = where(lon_array le 900.0,iok)
max_lat = max(lat_array(good_lats), min=min_lat)
max_lon = max(lon_array(good_lons), min=min_lon)
if n_elements(map_limits) eq 0 then $
    map_limits = [min(argos_data.lats), min(argos_data.lons), $
		  max(argos_data.lats), max(argos_data.lons)]
;print, map_limits

delta_lat = map_limits(2) - map_limits(0)
delta_lon = map_limits(3) - map_limits(1)

;-- tweak map_limits to be about 3% larger side
map_limits(0) = map_limits(0) - delta_lat * 0.03
map_limits(1) = map_limits(1) - delta_lon * 0.03
map_limits(2) = map_limits(2) + delta_lat * 0.03
map_limits(3) = map_limits(3) + delta_lon * 0.03
center_lat = (map_limits(0) + map_limits(2))/2.0
center_lon = (map_limits(1) + map_limits(3))/2.0

;-- map an optional mapfile
;if keyword_set(map_file) then oplotmap, map_file

!p.background = col.white
!p.color = col.black
!p.background = col.black
!p.color = col.white

TVLCT, R, G, B, /GET

if keyword_set(mpeg) then mpeg_id = mpeg_open([600,500])

for itime = 0, time_elements-1 do begin

    print,dt_tm_fromjs(good_times(itime),format=' d$/n$/y$ h$:m$')

    map_set, center_lat, center_lon, /ortho, /isotropic,  /continents, /noborder, $
	    limit = map_limits, title = title
    oplotgrid, map_limits, /label
    if keyword_set(eez) then macca_eez
    
    ;-- loop over PTT's
    for ippt = 0, np-1 do begin
    
       psymbol = 4
       pcol = col.brown
       if sym_array(itime,ippt) eq 1 then psymbol = 6 ;gha f (sqaure)
       if sym_array(itime,ippt) eq 2 then psymbol = 1 ;gha m (plus)
       if sym_array(itime,ippt) eq 4 then psymbol = 6 ;bba f
       if sym_array(itime,ippt) eq 5 then psymbol = 1 ;bba m
       if sym_array(itime,ippt) eq 6 then psymbol = 5 ;bba unknown sex
       
       if sym_array(itime,ippt) eq 1 then pcol = col.red
       if sym_array(itime,ippt) eq 2 then pcol = col.red
       if sym_array(itime,ippt) eq 4 then pcol = col.green
       if sym_array(itime,ippt) eq 5 then pcol = col.green
       if sym_array(itime,ippt) eq 6 then pcol = col.green
       
       if lon_array(itime,ippt) lt 900.0 and lat_array(itime, ippt) le 900.0 then $
           oplot, [lon_array(itime,ippt)], [lat_array(itime, ippt)], psym=psymbol, color=col.red
       
       ;-- plot a trailing for each ppt
       if n_elements(trails) ne 0 then begin
          iprev = itime - trails > 0
          lons = lon_array(iprev:itime, ippt)
          lats = lat_array(iprev:itime, ippt)
          lon_ok = where(lons lt 900.0, ilon_ok)
          lat_ok = where(lats lt 900.0, ilat_ok)
          if ilon_ok ge 1 and ilat_ok ge 1 then plots, lons(lon_ok), lats(lat_ok), color=col.yellow
       endif
    
    endfor
    
    xyouts, 0.1, 0.95, dt_tm_fromjs(good_times(itime),format=' d$/n$/y$ h$:m$'), $
	    alignment=0, size=1.5,/normal, color=col.white
	    
    if keyword_set(mpeg) then begin
         mpeg_put, mpeg_id, window=0, frame=itime, /order
    end else begin
        write_gif, gif_name, tvrd(), r,g,b, /multiple
    endelse

endfor

if keyword_set(mpeg) then begin
    mpeg_save, mpeg_id, filename = mpeg_file
    mpeg_close, mpeg_id
    print,'Saved MPEG file ' + mpeg_file
endif else begin
    write_gif, gif_name, tvrd(), /close
endelse

end
