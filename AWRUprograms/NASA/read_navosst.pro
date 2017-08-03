;===================================================================
; IDL PROGRAM:  read_navosst.pro
;
; DESCRIPTION:  To read DEF formatted NAVOCEANO SST DATA
;               Bins the sst and climatology data to .5 degree maps.
;
; PARAMETERS :  filename
;               sst
;
; USAGE      :  IDL> read_navosst
;
; AUTHOR     :  Jorge Vazquez and Rosanna Sumagaysay-Aouda
; DATE       :  August 3, 2001
; VERSION    :  1.0
;
; MODIFICATIONS Modified to use variable lun option for openr, and
;				to close this lun when finished, MDSumner 31Oct01.
;---------------
; 22 Aug 2001: Include subroutine to convert year,julian day,
;              time to strings. (rsa)
; 27 Aug 2001: Unpack function to split a byte data type to 2
;              8 bit data. (rsa)
;===================================================================
;   Copyright (c) 2001, California Institute of Technology
;===================================================================


;===================================================================
; FUNCTION   : catonate_jday, jdate_b1, jdate_b2
; DESCRIPTION: Catonates bytes to generate Julian Day value
; RETURNS    : Julian Day (jdate)
;-------------------------------------------------------------------
function catonate_jday, jdate_b1, jdate_b2

   jdate1 = fix(jdate_b1)
   jdate1 = ishft(jdate1,8)
   jdate2 = fix(jdate_b2)
   jdate  = jdate1 OR jdate2
   return,jdate

end
;-------------------------------------------------------------------

;===================================================================
; FUNCTION   : catonate_time, time_b1, time_b2, time_b3, time_b4
; DESCRIPTION: Catonates bytes to generate Time value
; RETURNS    : Time in seconds (time_in_sec)
;-------------------------------------------------------------------
function catonate_time, time_b1, time_b2, time_b3, time_b4

   time1 = long(time_b1)
   time1 = ishft(time1,24)
   time2 = long(time_b2)
   time2 = ishft(time2,16)
   time3 = long(time_b3)
   time3 = ishft(time3,8)
   time4 = long(time_b4)
   time_in_sec = 0l
   time_in_sec = time1 OR time2 OR time3 OR time4
   return,time_in_sec
end
;-------------------------------------------------------------------


;===================================================================
; FUNCTION   : date_time, year,jday,tmillisec
; DESCRIPTION: Converts date and time-in-secs to string format
;              yyyy dd MONTH_ASCII hh:mm.ss
; RETURNS    : String date (str_datetime)
;-------------------------------------------------------------------
function date_time, year, jday, tmillisec

   months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep', $
             'Oct','Nov','Dec']
   month_days = intarr(2,12)
   month_days[0,*]  = [31,59,90,120,151,181,212,243,273,304,334,365]
   month_days[1,*]  = [31,60,91,121,152,182,213,244,274,305,335,366]
   leap           = 0

;----------------------------------------------------
; convert 'year' value to 4-digit year
;----------------------------------------------------
   if (year < 50) then begin
      year = year + 2000
   endif else begin
      year = year + 1999
   endelse
   if ((((year MOD 4) EQ 0) AND ((year MOD 100) NE 0)) OR $
      ((year MOD 400) EQ 0)) then begin
      leap = 1
   endif
   str_year = string(year)
   new_year = strcompress(str_year,/REMOVE_ALL)

;----------------------------------------------------
; convert 'jday' value to month and day
;----------------------------------------------------
   ip = 0
   while (jday GT month_days(leap,ip)) DO ip = ip + 1
   month_num = months(ip)
   daynum = jday -month_days(leap,ip-1)
   str_daynum = string(daynum)
   new_day = strcompress(str_daynum,/REMOVE_ALL)

   if (daynum lt 10) then begin
      new_day = '0' + new_day
   endif

;----------------------------------------------------
; convert 'tmillisec' value to hour:min.sec
;----------------------------------------------------
   xhour  = (tmillisec * .001) / 3600
   thour  = fix(xhour)
   tmin   = (xhour - thour) * 60
   str_hour = string(thour)
   str_min  = string(tmin)
   new_hour = strcompress(str_hour,/REMOVE_ALL)
   new_min  = strcompress(str_min,/REMOVE_ALL)

   if (thour lt 10) then begin
      new_hour = '0' + new_hour
   endif

   if (tmin lt 10) then begin
      new_min = '0' + new_min
   endif

   str_datetime = new_year + ' ' + month_num + ' ' + $
                  new_day + ' ' + new_hour + ':' + new_min + ' GMT'
   return,str_datetime
end
;-------------------------------------------------------------------


;===================================================================
; FUNCTION   : unpack_byte, data_array, numbits
; DESCRIPTION: Unpacks byte value
; RETURNS    : 8-bit value
;-------------------------------------------------------------------
function unpack_byte, data_array, numbits
   newval = ishft(data_array,numbits)
   return, newval AND 255
end
;-------------------------------------------------------------------


;___________________________________________________________________
;
; MAIN PROGRAM
;___________________________________________________________________

pro read_navosst, filename, sst, csst, s_str_datetime, $
                  e_str_datetime, spcr_id


; Declare Common Variables
; Check for updates from NAVO Document
;-----------------------------------------------------------

      ; SPACECAFT ID
      ;-----------------------------------------------------
  sid = ['SPARE','NOAA-11 NH','NOAA-16','NOAA-14 NJ',  $
         'NOAA-15 K', 'NOAA-12 ND', 'N/A', 'NOAA-9 NF',   $
         'NOAA-10 NG']

      ; DATA TYPES
      ;-----------------------------------------------------
  dtype = ['LAC','GAC','HRPT','TIP','HIRS/2','MSU','SSU', $
           'DCS','SEM','SPARE']


      ; Tip Source if data type = TIP
      ;-----------------------------------------------------
  tsource = ['N/A','EMBEDDED TIP','STORED TIP',           $
             'THIRD CDA TIP','SPARE']


; Declare Variables for DEF descriptors
;-----------------------------------------------------------
pidb_size = 28             ; Product ID Block
hddb_size = 172            ; Header Data Description Block
hdb_size  = 30             ; Header Data Block
mddb_size = 540            ; MCCST Data Description Block
endb_size = 6              ; End of Product Block
xh1  = bytarr(pidb_size)
xh2  = bytarr(hddb_size)
xh3  = bytarr(hdb_size)
xh4  = bytarr(mddb_size)
descriptor_size = 770      ; Total Descriptors Size

; Declare Variables and data structure for MCSST Data Block
;----------------------------------------------------------
nblocksize = 1406              ; MCSST Data Block Size
num_points = 25                ; Number of Location Points
num_param  = 28                ; To read Integer Values
data_block = {header: 0l, data_cell:  $
              intarr(num_param,num_points), checksum: 0}

; Declare Latitude, Longitude and Binning values
;---------------------------------------------------------
;xlatmn = -90.
;xlonmn = -180.
xlatmn = -89.75
xlonmn = -179.75
xibin  = 2.
yibin  = 2.
sst    = fltarr(721,360)   ; .5 Degree L3 SST Maps.
csst   = fltarr(721,360)   ; .5 Degree L3 Climatology Maps.

openr,lun,filename, /get_lun

; Calculate number of Data Blocks with constant values
;---------------------------------------------------------
def_stat =fstat(lun)
nblocks  = float(def_stat.size - descriptor_size - endb_size)/nblocksize
ndatablocks=fix(nblocks)
data_read=replicate(data_block,ndatablocks)

forrd,lun,xh1,xh2,xh3,xh4,data_read
free_lun, lun
;--------------------------------------------------------
; Get data for each block separately. There are 25 point
; locations in each data block
;--------------------------------------------------------

; Unpack Header Data Block
;-------------------------------------------------------
spacecraft_id = xh3(4)
data_tip      = xh3(5)
syear         = xh3(6)
sjdate_b1     = xh3(7)
sjdate_b2     = xh3(8)
stime_b1      = xh3(9)
stime_b2      = xh3(10)
stime_b3      = xh3(11)
stime_b4      = xh3(12)

eyear         = xh3(13)
ejdate_b1     = xh3(14)
ejdate_b2     = xh3(15)
etime_b1      = xh3(16)
etime_b2      = xh3(17)
etime_b3      = xh3(18)
etime_b4      = xh3(19)


; Retrieve least significant 4 bits for TIP Source
;--------------------------------------------------
tip_source    = fix(data_tip) AND 15
if (tip_source GE 4) then begin
   tip_source = 4
endif


; Retrieve most significant 4 bits for  DATA Type
;--------------------------------------------------
data_type     = (ishft(data_tip,-4)) AND 15
if (data_type GE 10) then begin
   data_type = 10
endif


; Process Data Start date and Time
;----------------------------------
sjdate = catonate_jday(sjdate_b1, sjdate_b2)
stime  = catonate_time(stime_b1, stime_b2, stime_b3, stime_b4)
s_str_datetime = date_time(syear, sjdate, stime)


; Process Data End date and Time
;--------------------------------
ejdate = catonate_jday(ejdate_b1, ejdate_b2)
etime  = catonate_time(etime_b1, etime_b2, etime_b3, etime_b4)
e_str_datetime = date_time(eyear, ejdate, etime)

spcr_id = sid(spacecraft_id)

print, '-------------------------------------------------------------------'
print, 'FILENAME     : ', filename
print, 'SPACECRAFT ID: ', sid(spacecraft_id)
print, 'DATA TYPE    : ', dtype(data_type-1)
print, 'TIP SOURCE   : ', tsource(tip_source)
print, 'Start Time   : ', s_str_datetime
print, 'End Time     : ', e_str_datetime
print, 'Number of Data Blocks: ',fix(nblocks)
print, '-------------------------------------------------------------------'

;  Unpack 'obs' variable
;-----------------------------------------------
temp_obs       = data_read.data_cell(0,*)
temp_obs_type  = unpack_byte(temp_obs,-8)
temp_obs_source = unpack_byte(temp_obs,0)

;  Unpack 'yearmonth' variable
;-----------------------------------------------
temp_yearmonth = data_read.data_cell(1,*)
temp_year = unpack_byte(temp_yearmonth,-8)
temp_month = unpack_byte(temp_yearmonth,0)


temp_lat       = data_read.data_cell(2,*)
temp_lon       = data_read.data_cell(3,*)

;  Unpack 'dayhour' variable
;-----------------------------------------------
temp_dayhour   = data_read.data_cell(4,*)
temp_day  = unpack_byte(temp_dayhour,-8)
temp_hour = unpack_byte(temp_dayhour,0)

;  Unpack 'minsecs' variable
;-----------------------------------------------
temp_minsecs   = data_read.data_cell(5,*)
temp_min  = unpack_byte(temp_minsecs,-8)
temp_secs = unpack_byte(temp_minsecs,0)

temp_sst       = data_read.data_cell(6,*)
temp_flag      = data_read.data_cell(7,*)
temp_sol       = data_read.data_cell(8,*)
temp_sat       = data_read.data_cell(9,*)
temp_fsst      = data_read.data_cell(10,*)
temp_err       = data_read.data_cell(11,*)
temp_azi       = data_read.data_cell(12,*)
temp_csst      = data_read.data_cell(13,*)
temp_pixel     = data_read.data_cell(14,*)
temp_ch1       = data_read.data_cell(15,*)
temp_ch2       = data_read.data_cell(16,*)
temp_ch3       = data_read.data_cell(17,*)
temp_ch4       = data_read.data_cell(18,*)
temp_ch5       = data_read.data_cell(19,*)
temp_rms1      = data_read.data_cell(20,*)
temp_rms2      = data_read.data_cell(21,*)
temp_rms3      = data_read.data_cell(22,*)
temp_rms4      = data_read.data_cell(23,*)
temp_rms5      = data_read.data_cell(24,*)
temp_aln       = data_read.data_cell(25,*)
temp_aot       = data_read.data_cell(26,*)
temp_dum       = data_read.data_cell(27,*)

;---------------------------------------------------------------
; Print out Data values to Screen
; EXAMPLE BELOW DUMPS BLOCK (1) ONLY.
; Uncomment other `for' loop to dump all data blocks on screen.
;---------------------------------------------------------------

print,'    LONGITUDE     LATITUDE        SST     CLIMATOLOGY   RELIABILITY'
print,'    (degree)      (degree)     (celsius)   (celsius)
print, '-------------------------------------------------------------------'
;for j=0,nblocks-1 do begin
for j=0,2 - 1 do begin             ; Data Block 1 only
   print, 'DATA BLOCK:',j+1
   format = '(i4)'
   for i=0, num_points-1 do begin
;if((float(temp_lon(0,i,j))/100 EQ 180.)) then begin
      print, float(temp_lon(0,i,j))/100., float(temp_lat(0,i,j))/100., $
            float(temp_sst(0,i,j))/10., float(temp_csst(0,i,j))/10 , $
            temp_err(0,i,j)
      format='(f6.2,f6.2,f4.2,f4.2)'
;endif
   endfor
endfor

;------------------------------------------------------------
; Return sst binned and gridded globally on 0.5 degrees bins
;------------------------------------------------------------
;

for ix=0,num_points - 1  do begin
   for iy=0,ndatablocks - 1  do begin
      ixbin=(float(temp_lon(0,ix,iy))/100.-xlonmn)*xibin
      iybin=(float(temp_lat(0,ix,iy))/100.-xlatmn)*yibin
      ;-----------------------------------------------------
      ; RETURN ARRAY VALUES
      ;-----------------------------------------------------
;print, ix, iy, fix(ixbin), fix(iybin)
      sst(ixbin,iybin)=(temp_sst(0,ix,iy))/10.
      csst(ixbin,iybin)=(temp_csst(0,ix,iy))/10.
   endfor
endfor




end
