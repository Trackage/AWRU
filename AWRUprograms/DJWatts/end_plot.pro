case strupcase(plot_device) of
    'GIF': begin
	if n_elements(plot_file) eq 0 then begin
	    if !version.os eq 'vms' then plot_file = 'sys$login:idl.gif'
	    if !version.os eq 'MacOS' then plot_file = 'idl.gif'
	endif
	write_gif, plot_file, tvrd()
	device,/close
	end
     'VT': if set_device then device,/close
     'PS': begin
	if set_device then begin
	    device,/close
	    if !version.os eq 'vms' then spawn,'print/form=ps_plain/delete ' + plot_file
	end
	end
     'EPS': begin
	if set_device then device,/close
	end
     else:
endcase

;-- reset back to original plot device
if set_device then set_plot,old_plotdevice 	
