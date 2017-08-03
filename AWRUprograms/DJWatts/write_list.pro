;+
; NAME:
;	Write_List
;
; Must pass one parameter (a data structure) containing
; the lats/lons etc of the PTT(s) we wish to list. All other
; parameters are passed via switches
;
; /gis  - output as GIS arcview import file
; /excel - output as EXcel import file
;
; html_name =    -- output as HTML file with this name
; gif_name =    -- output HTML with embeeded link to a GIF file with this name
;
;-

pro write_list, argos_data, profile_name, $
	day_marks = day_marks, $
	html_name = html_name, gif_name=gif_name, $
	gis = gis, $
	excel = excel

;on_error, 2
if n_params() lt 1 then message, 'Argos_System:WRITE_LIST - No data to print'
if n_params() eq 1 then profile_name = 'Unknown profile name'

;-- check if any data
no_ptt_data = 0
if argos_data.npts(0) eq 0 then begin
    start_time = argos_data.ut_times(0)
    end_time = argos_data.ut_times(1)
    no_ptt_data = 1
end else begin
    start_time = argos_data.ut_times(0)
    end_time = argos_data.ut_times(argos_data.npts-1)
endelse

;-----------------  Set default parameters ---------------
total_range = 0.0
sum_range = fltarr(6)        ; store range sums for each class 3 to A
last_ut = 0.0d0
last_lat = 0.0
last_lon = 0.0
last_class_lat = fltarr(6)
last_class_lon = fltarr(6)
start_class_time = dblarr(6)
end_class_time = dblarr(6)
class_code = ['3','2','1','0','A','B']

list_file = 'report_tmx'

;-- Check if output is an HTML ----------------------
file_type = 'TEXT'
if n_elements(html_name) ne 0 then begin
    file_type = 'HTML' 
    list_file = html_name
    if n_elements(gif_name) eq 0 then gif_name = 'argos.gif'
endif

;-- Check if GIS
if keyword_set(gis) then begin
	file_type = 'GIS'
	list_file = 'report_tmx'
endif

;-- Check if Excel
if keyword_set(excel) then begin
	file_type = 'EXCEL'
	list_file = 'report_tmx'
	tab = "	"
endif

; ---------- set up ref position -----
; if none specified we use the first position on our list

ref_string = 'Start point is initial fix'
if (argos_data.include_refs(0) ne 'N') then begin 
    ref_string = 'Start point is ' + argos_data.ref_name(0) + '  at  ' + $
	dm_string(argos_data.ref_lat(0)) + '    ' + $
	dm_string(argos_data.ref_lon(0)) 
    ref_position = [argos_data.ref_lat(0), argos_data.ref_lon(0)]
end else begin
    ref_position = [argos_data.lats(0), argos_data.lons(0)]
endelse

;-----------  Note any speed restrictions ------------

speed_restriction = 'No speed restrictions'
if argos_data.max_speed(0) ne 0.0 then $
    speed_restriction = 'Max RMS speed is ' + $ 
	string(argos_data.max_speed(0), format='(f6.2," km/hr")') 

;-----------------------------


openw, lun, list_file, width=180, /get_lun


; ------------ write header in file ---------
case file_type of

  'HTML': begin
    printf, lun, "<h3>PTT " + string(argos_data.ptts(0),format='(i5)') + "</h3>"
    printf, lun, "From " + dt_tm_fromjs(start_time,format='d$/n$/y$ h$:m$') + $
	" to "    + dt_tm_fromjs(end_time,format='d$/n$/y$ h$:m$') + "<br>"
    printf, lun, "Quality ge " + argos_data.min_classes(0) + "<br>" 
    printf, lun, 'Profile number/name : ',string(argos_data.profile_nos(0), format='(i4)'), ' - ', profile_name, '<p>'
    printf, lun, speed_restriction,'<br>'
    printf, lun, ref_string, '<hr>

    if no_ptt_data then begin
	printf, lun, '<h3>No data to match criteria</h3>'
	Goto, end_listing
    end else begin
        printf, lun, '<img src="' + strtrim(gif_name) + '" alt="Map">'
        printf, lun, '<hr><pre>'
    endelse
    end

  'GIS': begin
    printf, lun, 'Profile number/name : ',string(argos_data.profile_nos(0), format='(i4)'), ' - ', profile_name, '<p>'
    end
 
  'EXCEL': begin
    printf, lun, 'Profile', tab, string(argos_data.profile_nos(0), format='(i4)')
    printf, lun, 'Name : ', tab, profile_name
    printf, lun, 'From', tab, dt_tm_fromjs(start_time,format='d$/n$/y$ h$:m$'), $ 
	tab, " to ", tab, dt_tm_fromjs(end_time,format='d$/n$/y$ h$:m$') 
    printf, lun, "Quality ge ", tab,  argos_data.min_classes(0) 
    printf, lun, speed_restriction
    printf, lun, ref_string
    printf, lun, " "
    printf, lun, 'Hit No', tab, 'Ok', tab, 'Date', tab, 'Time', tab, $
                 'Solar Time', tab, 'Sun alt', tab, 'Sun az', tab, $
		 'Light', tab, 'Quality', tab, 'Lat', tab, 'Long', tab, $ 
		 'km from last', tab, 'deg from last', tab, 'hrs from last', tab, $ 
		 'speed', tab, 'km from start', tab, 'deg from start', tab, $
  	         'sum range (km)'
    end

   else: begin

    printf, lun, "PTT " + string(argos_data.ptts(0),format='(i5)') + $
	"  From " + dt_tm_fromjs(start_time,format='d$/n$/y$ h$:m$') + $
	" to "    + dt_tm_fromjs(end_time,format='d$/n$/y$ h$:m$') + $
	"   Quality ge " + argos_data.min_classes(0)
    printf, lun, ' '
    printf, lun, 'Profile number/name : ',string(argos_data.profile_nos(0), format='(i4)'), '  ',profile_name
    printf, lun, speed_restriction,'           ',ref_string
    printf, lun, ' '

    if no_ptt_data then begin
	printf, lun, 'No data to match criteria'
	Goto, end_listing
    end 

    printf, lun, 'Hit  Ok   Date      Time    Time         Sun        Q  ', $
	'       Position          from last fix       Speed    from start  Sum range'
    printf, lun, 'No        (UT)      (UT)    Solar      Alt   Az  L     ', $
	'   Lat       Long      km    deg    (hrs)    km/hr    km    deg     km'
    printf, lun, ' '
    end
endcase


;---------- loop over the data points ---------- 
for j = 0, n_elements(argos_data.lats)-1 do begin

    ut = argos_data.ut_times(j)
    lat = argos_data.lats(j)
    lon = argos_data.lons(j)

    case argos_data.classes(j) of
    	' ':  class_index = 0
    	'3':  class_index = 0
    	'2':  class_index = 1
    	'1':  class_index = 2
    	'0':  class_index = 3
    	'A':  class_index = 4
    	else: class_index = 5
    endcase
    
    ; find start/end times of the class hits
    for ic = class_index,5 do begin
	if start_class_time(ic) eq 0.0d0 then start_class_time(ic) = ut
 	if end_class_time(ic) eq 0.0d0 or end_class_time(ic) lt ut then $
		end_class_time(ic) = ut
    endfor
       
    solar_time = ut + argos_data.lons(j) * 240 ; convert deg to sec

;-- get sun position
    jd = ut/86400.0d0 + ymd2jd(2000,1,1) - 0.5d0
    sun_data = sun_data(jd, lat, lon)

;-- compute current light levels
    light = ' '
    if sun_data.alt lt 0.0   then light = 'C'
    if sun_data.alt lt -6.0  then light = 'N'
    if sun_data.alt lt -12.0 then light = 'A'
    if sun_data.alt lt -18.0 then light = 'D'

    speed_string = string(replicate(32b,6))
    last_fix     = string(replicate(32b,20))
    ref_fix      = string(replicate(32b,15))
    if file_type eq 'EXCEL' then begin
    	last_fix = tab + tab
    	ref_fix = tab
    endif
    
;-- compute bearing, speed from last fix
    if (j ne 0 and argos_data.ok(j) eq 'Y') then begin
	delta_time = float((ut - last_ut) / 3600.0) ; hrs
	ll2rb, last_lon, last_lat, lon, lat, range, bearing
	range = range * !radeg * 60.0 * 1.852  ; km
	last_fix = string(range,bearing,delta_time,format='(f7.2,2x,f5.1,x,f6.2)')
	if file_type eq 'EXCEL' then last_fix = $
	    string(range,tab, bearing,tab, delta_time,format='(f7.2,a1,f5.1,a1,f6.2)')
	
	if delta_time gt 0.0 then $
	    speed_string = string(float(range / delta_time), format='(f6.2)')
	total_range = total_range + range

	for ic = class_index,5 do begin
	    if last_class_lon(ic) ne 0.0 and last_class_lat(ic) ne 0.0 then begin
	      ll2rb, last_class_lon(ic), last_class_lat(ic), lon, lat, range, bearing
	      range = range * !radeg * 60.0 * 1.852  ; km
	      sum_range(ic) = sum_range(ic) + range
	    endif
	endfor
    endif 

;-- compute bearing, speed from ref pt
    if (argos_data.ok(j) eq 'Y') then begin
	ll2rb, ref_position(1), ref_position(0), lon, lat, range, bearing
	range = range * !radeg * 60.0 * 1.852  ; km
	ref_fix = string(range, bearing,format='(f7.2,2x,f5.1)') 
	if file_type eq 'EXCEL' then ref_fix = string(range, tab, bearing,format='(f7.2,a1,f5.1)')
    endif 

    case file_type of

     'GIS': begin
      printf, lun, $
	string(argos_data.lats(j), argos_data.lons(j), format='(f8.4,",",f8.4)')
      end

      'EXCEL': begin

      printf, lun, $
	string(j+1,format='(i3)'), tab, $
	argos_data.ok(j), tab, $
    	dt_tm_fromjs(ut,format='d$/n$/y$'), tab, $ ; ut date
    	dt_tm_fromjs(ut,format='h$:m$:s$'), tab, $ ; ut time
	dt_tm_fromjs(solar_time,format='h$:m$:s$'), tab ,  $ ; solar
	string(sun_data.alt, format='(f5.1)'), tab , $
	string(sun_data.az, format='(f5.1)'),tab, $
	light, tab , $

	argos_data.classes(j), tab, $
	string(argos_data.lats(j), format='(f8.4)'), tab, $ 
	string(argos_data.lons(j), format='(f8.4)'), tab, $
	
	last_fix, tab, speed_string, tab, ref_fix, tab, $
	string(total_range, format='(f7.1)')

      end

      else: begin

      printf, lun, $
	string(j+1,format='(i3)'), '  ', $
	argos_data.ok(j), '  ', $
    	dt_tm_fromjs(ut,format='d$/n$/y$ h$:m$:s$'), ' ', $ ; ut time
	dt_tm_fromjs(solar_time,format='h$:m$:s$'),'  ',  $ ; solar
	string(sun_data.alt, sun_data.az,format='(f5.1,x,f5.1)'),' ',light, '  ', $

	argos_data.classes(j), '   ', 		$ ; class
	dm_string(argos_data.lats(j)), '  ', 	$ ; lat
	dm_string(argos_data.lons(j)),' ',	$ ; long

	last_fix,'  ',speed_string, '  ', ref_fix, $
	'   ',string(total_range, format='(f7.1)')	; cumlative range
        end

    endcase

    if argos_data.ok(j) eq 'Y' then begin
	last_lat = lat
	last_lon = lon
	last_ut = ut
	last_class_lat(class_index:5) = lat
 	last_class_lon(class_index:5) = lon
    endif

endfor


if file_type ne 'GIS' then begin

printf, lun,'     '
printf, lun,'     '
printf, lun,'Total distance and average velocity over profile'
printf, lun,'for each minimum class which includes data from better classes '
printf, lun,'     '
case file_type of
    'EXCEL': begin
	printf, lun,'Class',tab,'Distance',tab,'Speed',tab,'Time'
	printf, lun,tab,'(km)',tab,'km/hr',tab,'hr'
     end

     else: begin
	printf, lun,'Class               Distance      Speed     Time'
	printf, lun,'                      (km)        km/hr      hr'
     end
endcase
printf, lun,'     '

;-- find worst class to report on -- ignore any worse ones --
case argos_data.min_classes(0) of
    	' ':  class_index = 0
    	'3':  class_index = 0
    	'2':  class_index = 1
    	'1':  class_index = 2
    	'0':  class_index = 3
    	'A':  class_index = 4
    	else: class_index = 5
endcase
    	
for ic = 0, class_index do begin
    dwell = (end_class_time(ic) - start_class_time(ic)) / 3600.0
;;    print, end_class_time(ic), start_class_time(ic)

    speed = 0.0
    if dwell ne 0.0d0 then speed = sum_range(ic) / dwell
    if file_type ne 'EXCEL' then printf, lun, $
    	class_code(ic), ' or better  ',sum_range(ic), speed, dwell, $
    	format='(2x,a1,a12,5x,f8.1,5x,f7.2,2x,f7.2)'
    if file_type eq 'EXCEL' then printf, lun, $
    	class_code(ic), ' or better  ',tab, sum_range(ic), tab, speed, tab, dwell, $
    	format='(a1,a12,a1,f8.1,a1,f7.2,a1,f7.2)'
endfor


;if keyword_set(day_marks) then begin
    printf, lun,' '
    printf, lun,'     '
    printf, lun,'     '
    printf, lun,' Travel per day starting from local midnight'
    printf, lun,'     '
    if file_type ne 'EXCEL' then printf, lun,' Day          Distance travelled (km)   Speed (km/hr)'
    if file_type eq 'EXCEL' then printf, lun,' Day', tab,'Distance travelled (km)',tab,'Speed (km/hr)'
    printf, lun,'     '


    good_pts = where(argos_data.ok eq 'Y',igood)
    if igood gt 0 then begin
        temp_times = argos_data.ut_times(good_pts)
        temp_lats  = argos_data.lats(good_pts)
        temp_lons  = argos_data.lons(good_pts)

        day_lats   = temp_lats
        day_lons   = temp_lons
        day_times  = temp_times
        create_day_positions, day_lats, day_lons, day_times,/exclude_ends
        temp_flag  = replicate(0l, n_elements(temp_times))
        day_flag   = replicate(1l, n_elements(day_times))
        temp_lats  = [temp_lats, day_lats]
        temp_lons  = [temp_lons, day_lons]
        temp_times = [temp_times, day_times]
        temp_flag  = [temp_flag, day_flag]
    
        sort_order = sort(temp_times)		; sort via time
        temp_lats  = temp_lats(sort_order)
        temp_lons  = temp_lons(sort_order)
        temp_times = temp_times(sort_order)
        temp_flag  = temp_flag(sort_order)

        daily_total = 0.0
        for k = 1, n_elements(temp_times)-1 do begin
	    ll2rb, temp_lons(k-1), temp_lats(k-1), temp_lons(k), temp_lats(k), range, bearing
	    range = range * !radeg * 60.0 * 1.852  ; km
	    daily_total = daily_total + range
     	    if temp_flag(k) eq 1 then begin

	 	if file_type ne 'EXCEL' then $
		   printf, lun, dt_tm_fromjs(temp_times(k)-86400.0,format=' d$/n$'), $
		   daily_total, daily_total/24.0, format='(a10,2x,f6.1,2x,f6.2)'
		if file_type eq 'EXCEL' then $
		    printf, lun, dt_tm_fromjs(temp_times(k)-86400.0,format=' d$/n$'), $
		    tab, daily_total, tab, daily_total/24.0, format='(a10,a1,f6.1,a1,f6.2)'

	  	daily_total = 0.0
	    	last_time = temp_times(k)
	    endif
        endfor
    end else begin
        printf, lun, ' No Good pts found for doing daily summaries'
    endelse
    
;    k = n_elements(temp_times)-1
;    delta_time = temp_times(k) - last_time
;    printf, lun, dt_tm_fromjs(temp_times(k),format=' d$/n$'), $
;		daily_total, daily_total/(temp_times(k)-last_time), $
;		format='(a10,2x,f6.1,2x,f6.2)'
  
;endif

end_listing:

case file_type of
   'HTML': begin
    printf, lun, '</pre><hr>'
    printf, lun, 'Back to <a href="ptt_menu.html">PTT menu</a>'
    printf, lun, '<hr><img align=middle src="/graphics/small_logo.gif">'   
    printf, lun, '<a href="/default.html">Australian Antarctic Division Home Page</a>'
    printf, lun, '</body>'
    end
   else:
endcase

end

free_lun, lun

end
