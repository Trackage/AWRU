pro read_mcsst_data, filename, orig_mcsst, interp_mcsst, flag_data

;==========================================================
;  PROGRAM: read_mcsst_data.pro
;
;           An IDL program to read the AVHRR MCSST
;	    data which is given in the form of 8-bit
;	    raster images.
;
;  IMPORTANT VARIABLES:
;
;           orig_mcsst  = Multi-Channel Sea Surface Temp
;	    interp_mcsst= Interpolated MCSST
;           flag_data   = Flag and Number of MCSST
;                         Observations
;
;  8/96 K.L. Perry
;
;  Modifications:  12/97 hard coded in value for ice
;                        at 90N - K.L. Perry
;
;==========================================================

;***>The name of the input file must be entered by the user

; filename='sd1997001.hdf'

; OPEN THE HDF FILE

	file=HDF_OPEN(filename)

; FIND THE NUMBER OF IMAGES AVAILABLE IN THE HDF FILE

	nimg=hdf_dfr8_nimages(filename)

; READ THE DATA IN EACH IMAGE
; (PLEASE NOTE THAT THERE SHOULD BE THREE IMAGES)

	if (nimg ne 3) then begin
	  print,"THERE SHOULD BE THREE IMAGES IN EACH MCSST HDF FILE!"
	  print,"THE NUMBER OF IMAGES CURRENTLY BEING READ IS ",nimg
	  stop
	endif else begin
	  hdf_dfr8_restart
          hdf_dfr8_getimage,filename,orig_mcsst,orig_pal
	  hdf_dfr8_getimage,filename,interp_mcsst,interp_pal
	  hdf_dfr8_getimage,filename,flag_data,flag_pal
	endelse

; HARD CODE IN THE VALUE FOR ICE AT 90N.  PLEASE REFER TO
; THE AVHRR MCSST GUIDE DOCUMENT IF FURTHER INFORMATION IS
; REQUIRED

	orig_mcsst(*,0)=254
	interp_mcsst(*,0)=254
	flag_data(*,0)=254

; MULTIPLY THE MCSST DIGITAL NUMBER BY THE CALIBRATION NUMBER (0.15)
; AND THEN ADD THE OFFSET (-2.1) TO GET DEGREES CELSIUS

	orig_mcsst=0.15*orig_mcsst-2.1
	interp_mcsst=0.15*interp_mcsst-2.1

	HDF_CLOSE,file
	end

