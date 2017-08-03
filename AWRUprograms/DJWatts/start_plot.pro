
; set plot device
old_plotdevice = !d.name

if n_elements(plot_device) then begin
	set_device = 1			; if we declare the device then set it
end else begin
	plot_device = !d.name		; otherwise it was externally to this
	set_device = 0
endelse
plot_device = strupcase(plot_device)
;print,'PD ',plot_device

case plot_device of
    'MAC': begin
	if set_device then set_plot,'mac'
	col = define_colours()
	!p.color = col.white
	!p.background = col.black
	end
    'WIN': begin
	if set_device then set_plot,'win'
	col = define_colours()
	!p.color = col.white
	!p.background = col.black
	end
    'X': begin
	if set_device then set_plot,'x'
	col = define_colours()
	!p.color = col.white
	!p.background = col.black
	end
    'PS': begin
	if set_device then begin
	    set_plot,'ps'
	    if n_elements(plot_file) eq 0 then begin
	        if !version.os eq 'vms' then plot_file = 'sys$login:idl.ps'
	        if !version.os eq 'MacOS' then plot_file = 'idl.ps'
	        if !version.os eq 'Win32' then plot_file = 'idl.ps'
	    endif
	    device, filename=plot_file, /landscape
 	endif
	col = define_colours()
	end
    'EPS': begin
	if set_device then begin
	    set_plot,'ps'
	    device,/encapsulated, xsize=15,ysize=10
	    if n_elements(plot_file) eq 0 then begin
	        if !version.os eq 'vms' then plot_file = 'sys$login:idl.eps'
	        if !version.os eq 'MacOS' then plot_file = 'idl.eps'
	        if !version.os eq 'Win32' then plot_file = 'idl.eps'
	    endif
	    device, filename=plot_file, /landscape
 	endif
	col = define_colours()
	end
    'GIF': begin
        if n_elements(gif_size) eq 0 then gif_size=[500,300]
	set_plot,'z', /copy
	device, set_resolution=gif_size
	col = define_colours(/tek)
	!p.color = col.black
	!p.background = col.white
	end
    'Z': begin
	col = define_colours(/tek)
	!p.color = col.black
	!p.background = col.white
	end
    'VT': begin
	if set_device then set_plot,'regis'
	col = define_colours()
	end
    'REGIS': begin
	if set_device then set_plot,'regis'
	col = define_colours()
	end
	else:
endcase
