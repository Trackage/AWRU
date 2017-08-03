;==============================================================================
; NAME:	SET_DISPLAY
;
; PURPOSE:	Set display environment for beastly map data.
;
; CATEGORY:
; CALLING SEQUENCE:
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;		This is really specific for identifying the display as one of
;		the Ant CRC's linux boxes, which have b, r, g, rather than r, g, b
;		and it just loads the seawifs color table 'pc28.pse'.
;
;
; MODIFICATION HISTORY:
;		Written 27Aug01, MDSumner.
;		Windows won't take the true colour keyword to device, MDS4Sep01
;==============================================================================


  ;set display environment

device,retain=2,decomposed=0;, true = 24
linux_displays = ['field.antcrc.utas.edu.au', 'frazil.antcrc.utas.edu.au', $
	'floe.antcrc.utas.edu.au']
linux = where(linux_displays EQ getenv('REMOTEHOST'))


IF !version.os EQ 'Win32' THEN $
	coltbl_load, filepath('pc28.pse', subdirectory = '/resource/datafile') ELSE $
	coltbl_load, 'pc28.pse'

IF   linux[0] GE 0  THEN coltbl_load, 'pc28.pse' /linux
print, 'Display properties set by set_display.pro, the Seawifs color table is loaded, MDS4Sep01'



END