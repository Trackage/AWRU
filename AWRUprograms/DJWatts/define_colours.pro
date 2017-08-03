;+
; NAME:
;       DEFINE_COLOURS
;	Sets up the colour table for plots.
;
; Usage:
;	col = define_colours()
;
; Output:
;	returns a data structure with named colours
;	ie
;		col.white
;		col.black
;		col.yellow
;
;	Use help, col,/struct to find current colour names
;
; Keywords:
;	/tek - load Tek_Table IDL module 
;     		this routine produces a good range of colours suitable for 
;     		GIF images for a Web
;
;       /x11 - load X11 standard colours - about 116 of them
;
;	/display - display on current device the colours
;
;	/gif - creates a GIF file called Colours.GIF 
;		of the colours loaded
;
;
; Side Effects:
;	The colour table is updated if it is an X display device
;       If the current device is Postscript or Regis then returns
;       a table of 'black' colours
;
; History:
;	Original: 2/8/95; SJT
;		  29-jul-96 DJW
;-

function define_colours, $
	tek=tek, 	$
	x11=x11,	$

	gif=gif,	$
	display=display


; Postscript and regis load a structure with all the same colour
; aslo we dont plot anything even if /gif or /dispay are on

if !d.name eq 'PS' or !d.name eq 'REGIS' then begin
    return, {black: !p.color,   white: !p.background,  red: !p.color,  $
		green: !p.color, blue:  !p.color,   light_blue:  !p.color,  $
		magenta: !p.color, yellow: !p.color, $ 
		brown: !p.color,  lime_green: !p.color, light_grey:170}
endif


if keyword_set(tek) then begin
    tek_color
    colours = {black: 0,   white: 1,  red: 2,  green: 3, $
	     blue:  4,   light_blue:  5,  magenta: 6, yellow: 7, $ 
 	     brown: 8,  lime_green: 9, $
	c10:10, c11:11, purple:12, c13:13, dark_grey:14, light_grey:15, $
	c16:16, c17:17, c18:18, c19:19, c20:20, c21:21, $
	c22:22, c23:23, c24:24, c25:25, c26:26, c27:27 , $
	c28:28, c29:29, c30:30, c31:31 }
endif


;-- X devices can use TVLCT
if (!d.name eq 'X' or !d.name eq 'MAC') and not keyword_set(tek) then begin

    ;-load a simple table
    if not keyword_set(x11) then begin

       red = [0b, 255b, 255b, 0b, 0b, 0b, 255b, 255b, 255b, 127b, 0b, 0b, $
             127b, 255b, 85b, 170b] 
       green = [0b, 255b, 0b, 255b, 0b, 255b, 0b, 255b, 127b, 255b, 255b, 127b, $
              0b, 0b, 85b, 170b]
       blue = [0b, 255b, 0b, 0b, 255b, 255b, 255b, 0b, 0b, 0b, 127b, 255b, $
           255b, 127b, 85b, 170b] 
	tvlct, red, green, blue

	colours = {black: 0,   white: 1,  red: 2,  green: 3, $
	    blue:  4,   light_blue:  5,  magenta: 6, yellow: 7, $
	    brown: 8,  lime_green: 9, $
	    c10:10, c11: 11, c12: 12, c13: 13, $
	    dark_grey: 14, light_grey: 15}
    endif


    if keyword_set(x11) then begin
    	red = bytarr(115)
    	green = bytarr(115)
    	blue = bytarr(115)

    	red(0:68) = [ $
	    0b,  0b,  0b,  0b,  0b,  0b,  0b,  0b,  0b,  0b,  0b, 25b, 30b, 32b, $
	   34b, 46b, 47b, 50b, 60b, 64b, 65b, 70b, 72b, 72b, 85b, 95b,  0b  ,0b, $
	  100b,102b,105b,106b,107b,112b,119b,123b,124b,127b,132b,135b,135b,139b, $
	  139b,139b,143b,144b,147b,152b,154b,160b,160b,165b,169b,173b,173b,175b, $
	  176b,176b,176b,188b,189b,190b,205b,205b,208b,210b,210b,211b,216b ]

	red(69:114) = [ $
            218b,221b,224b,230b,233b,238b,240b,240b,240b,240b,240b,244b,245b,245b, $
            245b,245b,248b,250b,250b,250b,253b,255b,255b,255b,255b,255b,255b,255b, $
            255b,255b,255b,255b,255b,255b,255b,255b,255b,255b,255b,255b,255b,255b, $
            255b,255b,255b,255b]

	green(0:68) = [ $
	     0b,  0b,  0b,  0b,100b,191b,206b,250b,255b,255b,255b, 25b,144b,178b, $
           139b,139b, 79b,205b,179b,224b,105b,130b, 61b,209b,107b,158b,  0b,139b, $
           149b,205b,105b, 90b,142b,128b,136b,104b,252b,255b,112b,206b,206b,  0b, $
             0b, 69b,188b,238b,112b,251b,205b, 32b, 82b, 42b,169b,216b,255b,238b, $
            48b,196b,224b,143b,183b,190b, 92b,133b, 32b,105b,180b,211b,191b ]

	green(69:114) = [ $
           112b,160b,255b,230b,150b,130b,128b,230b,248b,255b,255b,164b,222b,245b, $
           245b,255b,248b,128b,235b,240b,245b,  0b,  0b, 20b, 69b, 99b,105b,127b, $
           140b,160b,165b,182b,192b,215b,218b,228b,235b,245b,248b,250b,250b,250b, $
           255b,255b,255b,255b]

	blue(0:68) = [ $
             0b,128b,205b,255b,  0b,255b,209b,154b,  0b,127b,255b,112b,255b,170b, $
            34b, 87b, 79b, 50b,113b,208b,225b,180b,139b,204b, 47b,160b,139b,139b, $
           237b,170b,105b,205b, 35b,144b,153b,238b,  0b,212b,255b,235b,250b,  0b, $
           139b, 19b,143b,144b,219b,152b, 50b,240b, 45b, 42b,169b,230b, 47b,238b, $
            96b,222b,230b,143b,107b,190b, 92b, 63b,144b, 30b,140b,211b,216b ]
 
	blue(69:114) = [ $
           214b,221b,255b,250b,122b,238b,128b,140b,255b,240b,255b, 96b,179b,220b, $
           245b,250b,255b,114b,215b,230b,230b,  0b,255b,147b,  0b, 71b,180b, 80b, $
             0b,122b,  0b,193b,203b,  0b,185b,181b,205b,238b,220b,205b,240b,250b, $
             0b,224b,240b,255b ]

	tvlct, red, green, blue
 
	colours = { $
          black:             0, $
          NavyBlue:          1, $
          MediumBlue:        2, $
          blue:              3, $
          DarkGreen:         4, $
          DeepSkyBlue:       5, $
          DarkTurquoise:     6, $
          MediumSpringGreen: 7, $
          green:             8, $
          SpringGreen:       9, $
          cyan:              10, $
          MidnightBlue:      11, $
          DodgerBlue:        12, $
          LightSeaGreen:     13, $
          ForestGreen:       14, $
          SeaGreen:          15, $
          DarkSlateGrey:     16, $
          LimeGreen:         17, $
          MediumSeaGreen:    18, $
          turquoise:         19, $
          RoyalBlue:         20, $
          SteelBlue:         21, $
          DarkSlateBlue:     22, $
          MediumTurquoise:   23, $
          DarkOliveGreen:    24, $
          CadetBlue:         25, $
          DarkBlue:          26, $
          DarkCyan:          27, $
          CornflowerBlue:    28, $
          MediumAquamarine:  29, $
          DimGray:           30, $
          SlateBlue:         31, $
          OliveDrab:         32, $
          SlateGrey:         33, $
          LightSlateGrey:    34, $
          MediumSlateBlue:   35, $
          LawnGreen:         36, $
          aquamarine:        37, $
          LightSlateBlue:    38, $
          SkyBlue:           39, $
          LightSkyBlue:      40, $
          DarkRed:           41, $
          DarkMagenta:       42, $
          SaddleBrown:       43, $
          DarkSeaGreen:      44, $
          LightGreen:        45, $
          MediumPurple:      46, $
          PaleGreen:         47, $
          YellowGreen:       48, $
          purple:            49, $
          sienna:            50, $
          brown:             51, $
          DarkGray:          52, $
          LightBlue:         53, $
          GreenYellow:       54, $
          PaleTurquoise:     55, $
          maroon:            56, $
          LightSteelBlue:    57, $
          PowderBlue:        58, $
          RosyBrown:         59, $
          DarkKhaki:         60, $
          grey:              61, $
          IndianRed:         62, $
          peru:              63, $
          VioletRed:         64, $
          chocolate:         65, $
          tan:               66, $
          LightGray:         67, $
          thistle:           68, $
          orchid:            69, $
          plum:              70, $
          LightCyan:         71, $
          lavender:          72, $
          DarkSalmon:        73, $
          violet:            74, $
          LightCoral:        75, $
          khaki:             76, $
          AliceBlue:         77, $
          honeydew:          78, $
          azure:             79, $
          SandyBrown:        80, $
          wheat:             81, $
          beige:             82, $
          WhiteSmoke:        83, $
          MintCream:         84, $
          GhostWhite:        85, $
          salmon:            86, $
          AntiqueWhite:      87, $
          linen:             88, $
          OldLace:           89, $
          red:               90, $
          magenta:           91, $
          DeepPink:          92, $
          OrangeRed:         93, $
          tomato:            94, $
          HotPink:           95, $
          coral:             96, $
          DarkOrange:        97, $
          LightSalmon:       98, $
          orange:            99, $
          LightPink:         100, $
          pink:              101, $
          gold:              102, $
          PeachPuff:         103, $
          moccasin:          104, $
          BlanchedAlmond:    105, $
          seashell:          106, $
          cornsilk:          107, $
          LemonChiffon:      108, $
          FloralWhite:       109, $
          snow:              110, $
          yellow:            111, $
          LightYellow:       112, $
          ivory:             113, $
          white:             114   }

    endif
endif


if keyword_set(Display) or keyword_set(Gif) then begin
    colour_names = tag_names(colours)
    max_colours = n_elements(colour_names) 

    !p.background = colours.white
    if keyword_set(gif) then set_plot,'z'
    
    ; produce squares of colour for index 0 to max_colours-1
    array_size = ceil(sqrt(max_colours))
    for iy = 0,array_size-1 do begin
	for ix = 0,array_size-1 do begin
	    icol = ix + iy*array_size
	    if icol ge max_colours then goto, end_plot
	    ix_cen = (ix +0.5)/ array_size
	    iy_cen = (iy +0.5)/ array_size

	    icell = 0.4 / array_size

	    polyfill, [ix_cen - icell, ix_cen - icell, ix_cen + icell, ix_cen + icell], $
		      [iy_cen - icell, iy_cen + icell, iy_cen + icell, iy_cen - icell], $
		    color=icol, /normal
	
	    xyouts, ix_cen-icell, iy_cen-icell, colour_names(icol), $
			charsize=0.6, /normal, color=colours.black
	endfor
    endfor
    end_plot:

    if keyword_set(gif) then begin
	write_gif,'colours.gif',tvrd()
	device,/close
    endif
endif

Return, colours

end
