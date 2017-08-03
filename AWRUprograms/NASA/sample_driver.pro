;===================================================================
; IDL PROGRAM:  sample_driver.pro
;
; DESCRIPTION:  Calls IDL programs to read NAVOCEANO SST data set
;               which dumps results on the screen as well as
;               view binned image maps on an IDL Windows.
;               Will display SST and Climatology SST Images.
;
; PARAMETERS :  none
;
; USAGE      :  IDL> .run sample_driver.pro
;
; AUTHOR     :  Rosanna Sumagaysay-Aouda
; DATE       :  August 28, 2001
; VERSION    :  1.0
;
; MODIFICATIONS 
;---------------
;===================================================================
;   Copyright (c) 2001, California Institute of Technology
;===================================================================


rdclrtbl,r,g,b

; NOTE:  Files in FTP site are GNU ZIPPED.  Before running this 
;        program please uncompress the data file.
;-------------------------------------------------------------------

;filename = '../../data/L2/sample/mcsst_n14_d20010829_s065700_e085200_b3434546_cnavo.def'
;filename = '../../data/L2/noaa14/2001/271/mcsst_n14_d20010928_s021600_e040400_b3476667_cnavo.def'

read_navosst,filename,sst,csst,stime,etime,spcr_id


; Read Land Mask Data
;--------------------------------------
a_land = bytarr(720,360)
openr, 4, 'lmask.dat'
readu,4,a_land
land   = congrid(a_land,721,360)
index_land = where(land eq 0)

; Process SST Map
;--------------------------------------
sst_bytscl = bytscl(sst,0,30)
nodata = where(sst_bytscl EQ 0)
sst_bytscl(nodata) = 1
sst_bytscl(index_land) = 0
window,1,xsize=740, ysize=440
tv,sst_bytscl,10,55
title = 'NAVOCEANO MCSST (SST)   ' + spcr_id
strdate = 'Coverage:  ' + stime + ' - ' + etime + $
           '    (deg. Celsius)'

xyouts,140,420, title, /device
xyouts, 10,5, strdate, /device, charsize=.75
xyouts,10,40,'0', /device, charsize=.75
xyouts,360,40,'15',/device, charsize=.75
xyouts,720, 40,'30', /device, charsize= .75

cbar,1,1,740,440

; Save as GIF image
;-----------------------------

image1=tvrd()
write_gif,'sst_tst.gif',image1,r,g,b



; Process Climatology  Map
;--------------------------------------
csst_bytscl = bytscl(csst,0,30)
csst_bytscl(nodata) = 1 
csst_bytscl(index_land) = 0
window,2,xsize=740, ysize=440
tv,csst_bytscl,10,55
title = 'NAVOCEANO MCSST (CLIMATOLOGY)   ' + spcr_id
footer = strdate + '    (File: ' + filename + ')'

xyouts,100,420, title, /device
xyouts, 10,5, strdate, /device, charsize=.75
xyouts,10,40,'0', /device, charsize=.75
xyouts,360,40,'15',/device, charsize=.75
xyouts,720, 40,'30', /device, charsize= .75

cbar,1,1,740,440

; Save as GIF image
;-----------------------------

image2=tvrd()
write_gif,'csst_tst.gif',image2,r,g,b

end
