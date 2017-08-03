;+
;   NAME
;      Plot_Crossing
;
;      plot crossing beahviour of daily plots per cell of each animal
;      ie look for solar dependence etc on behaviour
;
;-

pro plot_crossing, cell_data, cross_data, solar=solar

nx = n_elements(cell_data.xgrid)-1
ny = n_elements(cell_data.ygrid)-1
x_cell_centers = (cell_data.xgrid(0:nx-1) + cell_data.xgrid(1:nx))/2.0
y_cell_centers = (cell_data.ygrid(0:ny-1) + cell_data.ygrid(1:ny))/2.0

;print, x_cell_centers
!p.multi=[0,5,5]



for ix = 0, n_elements(x_cell_centers)-1 do begin
    xpt = x_cell_centers(ix)
    for iy = 0, n_elements(y_cell_centers)-1 do begin
        ypt = y_cell_centers(iy)
        
        ii = where(abs(cross_data.cell_x_pos - xpt) lt 0.01  and abs(cross_data.cell_y_pos - ypt) lt 0.01, ic)
        if ic ne 0 then begin
           start_ut = cross_data.entry_times(ii)
		sun_time = start_ut
                      
           if keyword_set(solar) then start_ut = cross_data.entry_solar_times(ii)
           dur      = cross_data.duration(ii)
           time_bins = replicate(0.0d0, 240)      ;-- time array for day 240 bins ie 6min bins
           

           ; print, 'start UT ',xpt, ypt, n_elements(start_ut)
           
           for k=0,n_elements(start_ut)-1 do begin
              js2ymds, start_ut(k), yr, mth, day, sec
              start_bin = floor(sec /360.0)
              end_bin = start_bin + ceil(dur(k) * 10)
              
              ;print,start_bin, end_bin
              
              if end_bin lt 240 then begin
                  time_bins(start_bin:end_bin) = time_bins(start_bin:end_bin) + 1
              end else begin
                  time_bins(start_bin:239) = time_bins(start_bin:239) + 1

                  while end_bin gt 239 do begin
                    end_bin = end_bin - 240
                    end_bin_day = min([end_bin, 239])
                    time_bins(0:end_bin_day) = time_bins(0:end_bin_day) + 1
                  endwhile
              endelse 
           
           endfor
           
           sunaltazi, total(sun_time)/n_elements(sun_time), ypt, xpt, azi, alt, zone=
          
           
           
           tmax = max(time_bins) + 0.5
           plot, indgen(240)*0.1, time_bins, $
                yrange=[0,tmax], ystyle=1, $
                title = string(ypt, xpt,format='(f7.3,2x,f8.3)'), $
                xtitle='hrs'
        
        endif
        
        
    endfor
endfor

end