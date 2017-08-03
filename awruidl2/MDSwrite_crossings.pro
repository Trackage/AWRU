;+
;   Write_Crossings
;
;   Output cell_data structure that contains the cell crossing data from
;   cell_multi.pro
;-;Added file name for output MDSumner, 29May03
;Call:
;mdswrite_crossings, filt, cell, 'file.txt', crossing_data = crossing_data

pro mdswrite_crossings, argos_data, cell_data, filename, $
	crossing_data = crossing_data

last = n_elements(cell_data.cross_times)-1
delta_time       = (cell_data.cross_times(1:last) - cell_data.cross_times(0:last-1)) / 3600.0
cross_solar_times = cell_data.cross_times - cell_data.cross_x * 3600.0 /15.0

start_time = min(argos_data.ut_times)
end_time   = max(argos_data.ut_times)

ref_string = 'Start point is initial fix'
if (argos_data.include_refs(0) ne 'N') then begin
    ref_string = 'Start point is ' + argos_data.ref_name(0) + '  at  ' + $
	dm_string(argos_data.ref_lat(0)) + '    ' + $
	dm_string(argos_data.ref_lon(0))
end
speed_restriction = 'No speed restrictions'
if argos_data.max_speed(0) ne 0.0 then $
    speed_restriction = 'Max RMS speed is ' + $
	string(argos_data.max_speed(0), format='(f6.2," km/hr")')



openw, wlun,filename,width=150,/get_lun

printf, wlun, "  From " + dt_tm_fromjs(start_time,format='d$/n$/Y$ h$:m$:s$') + $
	" to "    + dt_tm_fromjs(end_time,format='d$/n$/Y$ h$:m$:s$') + $
	"   Quality ge " + argos_data.min_classes(0)

printf, wlun, ' '
printf, wlun, 'Profile number : ',string(argos_data.profile_nos(0), format='(i4)')
printf, wlun, speed_restriction,'           ',ref_string
printf, wlun, ' '
printf, wlun, 'Cell size = ', cell_data.cell_size
printf, wlun, ' '
printf, wlun, 'PTT    Entry time        Exit time       Duration (hrs)  Cell entry lat/lon    exit lat/lon       Mid cell lat/lon   Solar entry/exit time'
printf, wlun, ' '

old_ptt =  cell_data.cross_ptt(0)

for k=1,n_elements(cell_data.cross_times)-1 do begin

    if cell_data.start_cell_x(k) eq cell_data.end_cell_x(k-1) and $
       cell_data.start_cell_y(k) eq cell_data.end_cell_y(k-1) and $
       old_ptt eq  cell_data.cross_ptt(k) then begin ;and $
       ;delta_time(k-1) ge 0.0 then begin

       x_cell_center = (cell_data.start_cell_x(k) + 0.5) * (cell_data.xgrid(1) - cell_data.xgrid(0))   + cell_data.xgrid(0)
       y_cell_center = (cell_data.start_cell_y(k) + 0.5) * (cell_data.ygrid(1) - cell_data.ygrid(0))   + cell_data.ygrid(0)


    printf, wlun, cell_data.cross_ptt(k), ' ', $
        dt_tm_fromjs(cell_data.cross_times(k-1), format='d$/n$/Y$ h$:m$:s$'), ' ', $   ;-- entry time
        dt_tm_fromjs(cell_data.cross_times(k), format='d$/n$/Y$ h$:m$:s$'), '    ', $  ;-- exit time
        string(delta_time(k-1), format='(f7.3)'), '    ', $                         ;-- time spent (hrs)
        string(cell_data.cross_y(k-1), format='(f7.3)'),  ' ', $                    ;-- enter pt
        string(cell_data.cross_x(k-1), format='(f8.3)'),  '    ', $
        string(cell_data.cross_y(k), format='(f7.3)'),  ' ', $                      ;-- exit pt
        string(cell_data.cross_x(k), format='(f8.3)'),  '     ', $

        string(y_cell_center, format='(f7.3)'),  ' ', $                          ;-- cell mid pt
        string(x_cell_center, format='(f8.3)'),  '     ', $
        dt_tm_fromjs(cross_solar_times(k-1), format='h$:m$'), ' ', $             ;-- solar times z
        dt_tm_fromjs(cross_solar_times(k), format='h$:m$')



        if n_elements(entry_times) eq 0 then begin
            entry_times = cell_data.cross_times(k-1)
            entry_solar_times = cell_data.cross_times(k-1) - cell_data.cross_x(k-1) * 3600.0 /15.0
            duration = delta_time(k-1)
            cell_x_pos = x_cell_center
            cell_y_pos =  y_cell_center
        end else begin
            entry_times = [entry_times, cell_data.cross_times(k-1)]
            entry_solar_times = [entry_solar_times, cell_data.cross_times(k-1) - cell_data.cross_x(k-1) * 3600.0 /15.0]
            duration = [duration, delta_time(k-1)]
            cell_x_pos = [cell_x_pos, x_cell_center]
            cell_y_pos = [cell_y_pos, y_cell_center]
        endelse
     endif

     old_ptt =  cell_data.cross_ptt(k)

endfor
free_lun, wlun

crossing_data = $
    {entry_times:entry_times, $
     entry_solar_times:entry_solar_times, $
     duration:duration, $
     cell_x_pos:cell_x_pos, $
     cell_y_pos:cell_y_pos }

end
