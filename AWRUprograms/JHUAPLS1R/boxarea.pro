;=================================================================
;	boxarea.pro = Select an area with a box
;	R. Sterner, 1995 Oct 31
;=================================================================

	pro boxarea, x1, y1, x2, y2, flag=flag, help=hlp

	if keyword_set(hlp) then begin
	  print,' Select an area with a box.'
	  print,' boxarea, x1, y1, x2, y2'
	  print,'   x1,y1 = first box point.   out'
	  print,'   x2,y2 = second box point.  out'
	  print,' Keywords:'
	  print,'   FLAG=flg  Exit flag: 0=ok, 1=abort.'
	  print,' Notes: Open a box by dragging with left mouse button.'
	  print,'   Repeat to get desired box.'
	  print,'   Accept box with middle button.'
	  print,'   Reject box with right button.'
	  print,'   All coordinates are device coordinates.'
	  return
	endif

	!mouse.button = 0		; Clear button flag.
	device, set_graphics = 6	; Set XOR mode.
	x1=100  &  y1=100		; Initial old box.
	x2=100  &  y2=100

	;------  Loop until button 2 or 3 pressed  ----------
	repeat begin

	  ;-----  Loop until any button pressed  ----------
	  while !mouse.button eq 0 do cursor,/dev,xa,ya

	  ;-----  Process button 1 hold  ---------
	  if !mouse.button eq 1 then begin
	    plots,/dev,[x1,x2,x2,x1,x1],[y1,y1,y2,y2,y1]      	; Erase old box.
	    x1=xa  &  y1=ya					; New pt 1.
	    x2=x1  &  y2=y1					; Initial pt 2.

	    ;------  Loop until button 1 released (drag) -------
	    repeat begin
	      cursor,/dev,/change,xb,yb				; Get new pt 2.
	      plots,/dev,[x1,x2,x2,x1,x1],[y1,y1,y2,y2,y1]	; Erase old box.
	      plots,/dev,[x1,xb,xb,x1,x1],[y1,y1,yb,yb,y1]	; Draw new box.
	      x2=xb  &  y2=yb					; Save new pt 2.
	    endrep until !mouse.button eq 0	; End button 1 drag.

	  endif					; End process button 1.

	endrep until !mouse.button ge 2		; End wait for button 2.

	device, set_graphics = 3		; Restore plot mode.
	flag = !mouse.button ne 2		; Exit flag.

	end
