pro cbar,xpos,ypos,xsize,ysize
;
;xposbar= position from edge of object
;yposbar= position from edge of object
;csize  = length size of colorbar.
;CUSTOMIZED for NAVOCEANO MCSST IMAGES
;Date:  July 18, 2001
;--------------------------------------------
;

icbx=findgen(225)+30
csize=720.
cbar=fltarr(225,2)
cbar(0:224,0)=icbx
cbar(0:224,1)=icbx
cbarexp=fltarr(csize,20)
cbarexp=congrid(cbar,csize,5)
cbarbyte=byte(cbarexp)

;yposbar=(ysize - (180+30+5))
yposbar=(ysize - (360+25)) 
xposbar = 10 


tv,cbarbyte,xposbar,yposbar
end
