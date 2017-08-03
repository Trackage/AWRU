;+
; NAME:
;       FSC_COLOR
;
; PURPOSE:
;
;       The purpose of this function is to obtain drawing colors
;       by name and in a device-decomposition independent way. The
;       color names and values may be read in as a file, or 88
;       color names and values are supplied from the program. These
;       were obtained from the file rgb.txt, found on most X-Window
;       distributions. Representative colors were chose from across
;       the color spectrum. To see a list of colors available, type:
;       Print, FSC_Color(/Names).
;
; AUTHOR:
;
;       FANNING SOFTWARE CONSULTING:
;       David Fanning, Ph.D.
;       1645 Sheely Drive
;       Fort Collins, CO 80526 USA
;       Phone: 970-221-0438
;       E-mail: davidf@dfanning.com
;       Coyote's Guide to IDL Programming: http://www.dfanning.com
;
; CATEGORY:
;
;       Graphics, Color Specification.
;
; CALLING SEQUENCE:
;
;       color = FSC_COLOR(theColor, theColorIndex)
;
; NORMAL CALLING SEQUENCE FOR DEVICE-INDEPENDENT COLOR:
;
;       axisColor = FSC_COLOR("Green", !D.Table_Size-2)
;       backColor = FSC_COLOR("Charcoal", !D.Table_Size-3)
;       dataColor = FSC_COLOR("Yellow", !D.Table_Size-4)
;       Plot, Findgen(11), Color=axisColor, Background=backColor, /NoData
;       OPlot, Findgen(11), Color=dataColor
;
; OPTIONAL INPUT PARAMETERS:
;
;       TheColor: A string with the "name" of the color. To see a list
;           of the color names available set the NAMES keyword.
;
;           Valid names depend on the colors loaded in the program, but
;           typically include such these colors as these:
;
;              Black       Pink
;              Magenta     Aqua
;              Cyan        SkyBlue
;              Yellow      Beige
;              Green       Charcoal
;              Red         Gray
;              Blue        Orchid
;              Navy        White
;
;           The color WHITE is used if this parameter is absent. To see a list
;           of the color names available in the program, type this:
;
;              Print, FSC_COLOR(/Names)
;
;       TheColorIndex: The color table index where the specified color is loaded.
;           The color table index parameter should always be used if you wish to
;           obtain a color value in a color-decomposition-independent way in your
;           code. See the NORMAL CALLING SEQUENCE for details.
;
; RETURN VALUE:
;
;       The value that is returned by FSC_COLOR depends upon the keywords
;       used to call it and on the version of IDL you are using. In general,
;       the return value will be either a color index number where the specified
;       color is loaded by the program, or a 24-bit color value that can be
;       decomposed into the specified color on true-color systems.
;
;       If you are running IDL 5.2 or higher, the program will determine which
;       return value to use, based on the color decomposition state at the time
;       the program is called. If you are running a version of IDL before IDL 5.2,
;       then the program will return the color index number. This behavior can
;       be overruled in all versions of IDL by setting the DECOMPOSED keyword.
;       If this keyword is 0, the program always returns a color index number. If
;       the keyword is 1, the program always returns a 24-bit color value.
;
;       If the TRIPLE keyword is set, the program always returns the color triple,
;       no matter what the current decomposition state or the value of the DECOMPOSED
;       keyword. Normally, the color triple is returned as a 1 by 3 column vector.
;       This is appropriate for loading into a color index with TVLCT:
;
;          IDL> TVLCT, FSC_Color('Yellow', /Triple), !P.Color
;
;       But sometimes (e.g, in object graphics applications) you want the color
;       returned as a row vector. In this case, you should set the ROW keyword
;       as well as the TRIPLE keyword:
;
;          viewobj= Obj_New('IDLgrView', Color=FSC_Color('charcoal', /Triple, /Row))
;
;       If the ALLCOLORS keyword is used, then instead of a single value, modified
;       as described above, then all the color values are returned in an array. In
;       other words, the return value will be either an NCOLORS-element vector of color
;       table index numbers, an NCOLORS-element vector of 24-bit color values, or
;       an NCOLORS-by-3 array of color triples.
;
;       If the NAMES keyword is set, the program returns a vector of
;       color names known to the program.
;
; INPUT KEYWORD PARAMETERS:
;
;       ALLCOLORS: Set this keyword to return indices, or 24-bit values, or color
;              triples, for all the known colors, instead of for a single color.
;
;       DECOMPOSED: Set this keyword to 0 or 1 to force the return value to be
;              a color table index or a 24-bit color value, respectively.
;
;       FILENAME: The string name of an ASCII file that can be opened to read in
;              color values and color names. There should be one color per row
;              in the file. Please be sure there are no blank lines in the file.
;              The format of each row should be:
;
;                  redValue  greenValue  blueValue  colorName
;
;              Color values should be between 0 and 255. Any kind of white-space
;              separation (blank characters, commas, or tabs) are allowed. The color
;              name should be a string, but it should NOT be in quotes. A typical
;              entry into the file would look like this:
;
;                  255   255   0   Yellow
;
;       NAMES: If this keyword is set, the return value of the function is
;              a ncolors-element string array containing the names of the colors.
;              These names would be appropriate, for example, in building
;              a list widget with the names of the colors. If the NAMES
;              keyword is set, the COLOR and INDEX parameters are ignored.
;
;                 listID = Widget_List(baseID, Value=GetColor(/Names), YSize=16)
;
;       ROW:   If this keyword is set, the return value of the function when the TRIPLE
;              keyword is set is returned as a row vector, rather than as the default
;              column vector. This is required, for example, when you are trying to
;              use the return value to set the color for object graphics objects. This
;              keyword is completely ignored, except when used in combination with the
;              TRIPLE keyword.
;
;       SELECTCOLOR: Set this keyword if you would like to select the color name with
;              the PICKCOLORNAME program. Selecting this keyword automaticallys sets
;              the INDEX positional parameter. If this keyword is used, any keywords
;              appropriate for PICKCOLORNAME can also be used. If this keyword is used,
;              the first positional parameter can be either a color name or the color
;              table index number. The program will figure out what you want.
;
;       TRIPLE: Setting this keyword will force the return value of the function to
;              *always* be a color triple, regardless of color decomposition state or
;              visual depth of the machine. The value will be a three-element column
;              vector unless the ROW keyword is also set.
;
;       In addition, any keyword parameter appropriate for PICKCOLORNAME can be used.
;       These include BOTTOM, COLUMNS, GROUP_LEADER, INDEX, and TITLE.
;
; OUTPUT KEYWORD PARAMETERS:
;
;       CANCEL: This keyword is always set to 0, unless that SELECTCOLOR keyword is used.
;              Then it will correspond to the value of the CANCEL output keyword in PICKCOLORNAME.
;
;       COLORSTRUCTURE: This output keyword (if set to a named variable) will return a
;              structure in which the fields will be the known color names (without spaces)
;              and the values of the fields will be either color table index numbers or
;              24-bit color values.
;
;       NCOLORS: The number of colors recognized by the program. It will be 88 by default.
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; ADDITIONAL PROGRAMS REQUIRED:
;
;   PICKCOLORNAME: This file can be found in the Coyote Library:
;
;             http://www.dfanning.com/programs/pickcolorname.pro
;
; EXAMPLE:
;
;       To get drawing colors in a device-decomposed independent way:
;
;           axisColor = FSC_COLOR("Green", !D.Table_Size-2)
;           backColor = FSC_COLOR("Charcoal", !D.Table_Size-3)
;           dataColor = FSC_COLOR("Yellow", !D.Table_Size-4)
;           Plot, Findgen(11), Color=axisColor, Background=backColor, /NoData
;           OPlot, Findgen(11), Color=dataColor
;
;       To set the viewport color in object graphics:
;
;           theView = Obj_New('IDLgrView', Color=FSC_Color('Charcoal', /Triple))
;
;       To change the viewport color later:
;
;           theView->SetProperty, Color=FSC_Color('Antique White', /Triple)
;
; MODIFICATION HISTORY:
;       Written by: David Fanning, 19 October 2000. Based on previous
;          GetColor program.
;       Fixed a problem with loading colors with TVLCT on a PRINTER device. 13 Mar 2001. DWF.
;       Added the ROW keyword. 30 March 2001. DWF.
;-
;
;###########################################################################
;
; LICENSE
;
; This software is OSI Certified Open Source Software.
; OSI Certified is a certification mark of the Open Source Initiative.
;
; Copyright � 2000 Fanning Software Consulting.
;
; This software is provided "as-is", without any express or
; implied warranty. In no event will the authors be held liable
; for any damages arising from the use of this software.
;
; Permission is granted to anyone to use this software for any
; purpose, including commercial applications, and to alter it and
; redistribute it freely, subject to the following restrictions:
;
; 1. The origin of this software must not be misrepresented; you must
;    not claim you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation
;    would be appreciated, but is not required.
;
; 2. Altered source versions must be plainly marked as such, and must
;    not be misrepresented as being the original software.
;
; 3. This notice may not be removed or altered from any source distribution.
;
; For more information on Open Source Software, visit the Open Source
; web site: http://www.opensource.org.
;
;###########################################################################


FUNCTION FSC_Color_Count_Rows, filename, MaxRows = maxrows

; This utility routine is used to count the number of
; rows in an ASCII data file.

IF N_Elements(maxrows) EQ 0 THEN maxrows = 500L
IF N_Elements(filename) EQ 0 THEN BEGIN
   filename = Dialog_Pickfile()
   IF filename EQ "" THEN RETURN, -1
ENDIF

OpenR, lun, filename, /Get_Lun

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   count = count-1
   Free_Lun, lun
   RETURN, count
ENDIF

RESTART:

count = 1L
line = ''
FOR j=count, maxrows DO BEGIN
   ReadF, lun, line
   count = count + 1

      ; Try again if you hit MAXROWS without encountering the
      ; end of the file. Double the MAXROWS parameter.

   IF j EQ maxrows THEN BEGIN
      maxrows = maxrows * 2
      Point_Lun, lun, 0
      GOTO, RESTART
   ENDIF

ENDFOR

RETURN, -1
END ;-------------------------------------------------------------------------------



FUNCTION FSC_Color_Error_Message, theMessage, Traceback=traceback, $
   NoName=noName, _Extra=extra

On_Error, 2

   ; Check for presence and type of message.

IF N_Elements(theMessage) EQ 0 THEN theMessage = !Error_State.Msg
s = Size(theMessage)
messageType = s[s[0]+1]
IF messageType NE 7 THEN BEGIN
   Message, "The message parameter must be a string.", _Extra=extra
ENDIF

   ; Get the call stack and the calling routine's name.

Help, Calls=callStack
callingRoutine = (Str_Sep(StrCompress(callStack[1])," "))[0]

   ; Are widgets supported? Doesn't matter in IDL 5.3 and higher.

widgetsSupported = ((!D.Flags AND 65536L) NE 0) OR Float(!Version.Release) GE 5.3
IF widgetsSupported THEN BEGIN
   IF Keyword_Set(noName) THEN answer = Dialog_Message(theMessage, _Extra=extra) ELSE BEGIN
      IF StrUpCase(callingRoutine) EQ "$MAIN$" THEN answer = Dialog_Message(theMessage, _Extra=extra) ELSE $
         answer = Dialog_Message(StrUpCase(callingRoutine) + ": " + theMessage, _Extra=extra)
   ENDELSE
ENDIF ELSE BEGIN
      Message, theMessage, /Continue, /NoPrint, /NoName, /NoPrefix, _Extra=extra
      Print, '%' + callingRoutine + ': ' + theMessage
      answer = 'OK'
ENDELSE

   ; Provide traceback information if requested.

IF Keyword_Set(traceback) THEN BEGIN
   Help, /Last_Message, Output=traceback
   Print,''
   Print, 'Traceback Report from ' + StrUpCase(callingRoutine) + ':'
   Print, ''
   FOR j=0,N_Elements(traceback)-1 DO Print, "     " + traceback[j]
ENDIF

RETURN, answer
END ;-------------------------------------------------------------------------------



FUNCTION FSC_Color_Color24, color

   ; This FUNCTION accepts a [red, green, blue] triple that
   ; describes a particular color and returns a 24-bit long
   ; integer that is equivalent to (can be decomposed into)
   ; that color. The triple can be either a row or column
   ; vector of 3 elements or it can be an N-by-3 array of
   ; color triples.

ON_ERROR, 2

s = Size(color)

IF s[0] EQ 1 THEN BEGIN
   IF s[1] NE 3 THEN Message, 'Input color parameter must be a 3-element vector.'
   RETURN, color[0] + (color[1] * 2L^8) + (color[2] * 2L^16)
ENDIF ELSE BEGIN
   IF s[2] GT 3 THEN Message, 'Input color parameter must be an N-by-3 array.'
   RETURN, color[*,0] + (color[*,1] * 2L^8) + (color[*,2] * 2L^16)
ENDELSE

END ;--------------------------------------------------------------------------------------------



FUNCTION FSC_Color, theColor, colorIndex, $
   AllColors=allcolors, $
   ColorStructure=colorStructure, $
   Cancel=cancelled, $
   Decomposed=decomposedState, $
   _Extra=extra, $
   Filename=filename, $
   Names=names, $
   NColors=ncolors, $
   Row=row, $
   SelectColor=selectcolor, $
   Triple=triple

   ; Error handling.

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = FSC_Color_Error_Message(/Traceback)
   cancelled = 1
   RETURN, !P.Color
ENDIF

   ; Did the user want to select a color name? If so, we set
   ; the color name and color index, unless the user provided
   ; them. In the case of a single positional parameter, we treat
   ; this as the color index number as long as it is not a string.

cancelled = 0.0
IF Keyword_Set(selectcolor) THEN BEGIN

   CASE N_Params() OF
      0: BEGIN
         colorIndex = !P.Color < 255
         theColor = PickColorName(Filename=filename, _Extra=extra, Cancel=cancelled)
         IF cancelled THEN RETURN, !P.Color
         END
      1: BEGIN
         IF Size(theColor, /TName) NE 'STRING' THEN BEGIN
            colorIndex = theColor
            theColor='White'
         ENDIF ELSE colorIndex = !P.Color < 255
         theColor = PickColorName(theColor, Filename=filename, _Extra=extra, Cancel=cancelled)
         IF cancelled THEN RETURN, !P.Color
         END
      2: BEGIN
         theColor = PickColorName(theColor, Filename=filename, _Extra=extra, Cancel=cancelled)
         IF cancelled THEN RETURN, !P.Color
         END
   ENDCASE
ENDIF

   ; Make sure you have a color name and color index.

IF N_Elements(theColor) EQ 0 THEN theColor = 'White'
IF N_Elements(colorIndex) EQ 0 THEN colorIndex = !P.Color < (!D.Table_Size - 1) $
   ELSE colorIndex = 0 > colorIndex < (!D.Table_Size - 1)

   ; Make sure the color parameter is an uppercase string.

varInfo = Size(theColor)
IF varInfo(varInfo(0) + 1) NE 7 THEN $
   Message, 'The color name parameter must be a string.', /NoName
theColor = StrUpCase(StrCompress(StrTrim(theColor,2), /Remove_All))

   ; Check synonyms of color names.

IF StrUpCase(theColor) EQ 'GREY' THEN theColor = 'GRAY'
IF StrUpCase(theColor) EQ 'LIGHTGREY' THEN theColor = 'LIGHTGRAY'
IF StrUpCase(theColor) EQ 'MEDIUMGREY' THEN theColor = 'MEDIUMGRAY'
IF StrUpCase(theColor) EQ 'SLATEGREY' THEN theColor = 'SLATEGRAY'
IF StrUpCase(theColor) EQ 'DARKGREY' THEN theColor = 'DARKGRAY'
IF StrUpCase(theColor) EQ 'AQUA' THEN theColor = 'AQUAMARINE'
IF StrUpCase(theColor) EQ 'SKY' THEN theColor = 'SKYBLUE'
IF StrUpCase(theColor) EQ 'NAVY BLUE' THEN theColor = 'NAVY'
IF StrUpCase(theColor) EQ 'NAVYBLUE' THEN theColor = 'NAVY'

IF N_Elements(filename) NE 0 THEN BEGIN

      ; Count the number of rows in the file.

   ncolors = FSC_Color_Count_Rows(filename)

      ; Read the data.

   OpenR, lun, filename, /Get_Lun
   rvalue = BytArr(NCOLORS)
   gvalue = BytArr(NCOLORS)
   bvalue = BytArr(NCOLORS)
   colors = StrArr(NCOLORS)
   redvalue = 0B
   greenvalue = 0B
   bluevalue = 0B
   colorvalue = ""
   FOR j=0L, NCOLORS-1 DO BEGIN
      ReadF, lun, redvalue, greenvalue, bluevalue, colorvalue
      rvalue[j] = redvalue
      gvalue[j] = greenvalue
      bvalue[j] = bluevalue
      colors[j] = colorvalue
   ENDFOR
   Free_Lun, lun

      ; Trim the colors array of blank characters.

   colors = StrTrim(colors, 2)

ENDIF ELSE BEGIN

   ; Set up the color vectors.

   colors = ['White']
   rvalue = [ 255]
   gvalue = [ 255]
   bvalue = [ 255]
   colors = [ colors,       'Snow',     'Ivory','Light Yellow',   'Cornsilk',      'Beige',   'Seashell' ]
   rvalue = [ rvalue,          255,          255,          255,          255,          245,          255 ]
   gvalue = [ gvalue,          250,          255,          255,          248,          245,          245 ]
   bvalue = [ bvalue,          250,          240,          224,          220,          220,          238 ]
   colors = [ colors,      'Linen','Antique White',    'Papaya',     'Almond',     'Bisque',  'Moccasin' ]
   rvalue = [ rvalue,          250,          250,          255,          255,          255,          255 ]
   gvalue = [ gvalue,          240,          235,          239,          235,          228,          228 ]
   bvalue = [ bvalue,          230,          215,          213,          205,          196,          181 ]
   colors = [ colors,      'Wheat',  'Burlywood',        'Tan', 'Light Gray',   'Lavender','Medium Gray' ]
   rvalue = [ rvalue,          245,          222,          210,          230,          230,          210 ]
   gvalue = [ gvalue,          222,          184,          180,          230,          230,          210 ]
   bvalue = [ bvalue,          179,          135,          140,          230,          250,          210 ]
   colors = [ colors,       'Gray', 'Slate Gray',  'Dark Gray',   'Charcoal',      'Black', 'Light Cyan' ]
   rvalue = [ rvalue,          190,          112,          110,           70,            0,          224 ]
   gvalue = [ gvalue,          190,          128,          110,           70,            0,          255 ]
   bvalue = [ bvalue,          190,          144,          110,           70,            0,          255 ]
   colors = [ colors,'Powder Blue',   'Sky Blue', 'Steel Blue','Dodger Blue', 'Royal Blue',       'Blue' ]
   rvalue = [ rvalue,          176,          135,           70,           30,           65,            0 ]
   gvalue = [ gvalue,          224,          206,          130,          144,          105,            0 ]
   bvalue = [ bvalue,          230,          235,          180,          255,          225,          255 ]
   colors = [ colors,       'Navy',   'Honeydew', 'Pale Green','Aquamarine','Spring Green',       'Cyan' ]
   rvalue = [ rvalue,            0,          240,          152,          127,            0,            0 ]
   gvalue = [ gvalue,            0,          255,          251,          255,          250,          255 ]
   bvalue = [ bvalue,          128,          240,          152,          212,          154,          255 ]
   colors = [ colors,  'Turquoise', 'Sea Green','Forest Green','Green Yellow','Chartreuse', 'Lawn Green' ]
   rvalue = [ rvalue,           64,           46,           34,          173,          127,          124 ]
   gvalue = [ gvalue,          224,          139,          139,          255,          255,          252 ]
   bvalue = [ bvalue,          208,           87,           34,           47,            0,            0 ]
   colors = [ colors,      'Green', 'Lime Green', 'Olive Drab',     'Olive','Dark Green','Pale Goldenrod']
   rvalue = [ rvalue,            0,           50,          107,           85,            0,          238 ]
   gvalue = [ gvalue,          255,          205,          142,          107,          100,          232 ]
   bvalue = [ bvalue,            0,           50,           35,           47,            0,          170 ]
   colors = [ colors,      'Khaki', 'Dark Khaki',     'Yellow',       'Gold','Goldenrod','Dark Goldenrod']
   rvalue = [ rvalue,          240,          189,          255,          255,          218,          184 ]
   gvalue = [ gvalue,          230,          183,          255,          215,          165,          134 ]
   bvalue = [ bvalue,          140,          107,            0,            0,           32,           11 ]
   colors = [ colors,'Saddle Brown',       'Rose',       'Pink', 'Rosy Brown','Sandy Brown',       'Peru' ]
   rvalue = [ rvalue,          139,          255,          255,          188,          244,          205 ]
   gvalue = [ gvalue,           69,          228,          192,          143,          164,          133 ]
   bvalue = [ bvalue,           19,          225,          203,          143,           96,           63 ]
   colors = [ colors,  'Indian Red',  'Chocolate',     'Sienna','Dark Salmon',    'Salmon','Light Salmon' ]
   rvalue = [ rvalue,          205,          210,          160,          233,          250,          255 ]
   gvalue = [ gvalue,           92,          105,           82,          150,          128,          160 ]
   bvalue = [ bvalue,           92,           30,           45,          122,          114,          122 ]
   colors = [ colors,     'Orange',      'Coral', 'Light Coral',  'Firebrick',      'Brown',  'Hot Pink' ]
   rvalue = [ rvalue,          255,          255,          240,          178,          165,          255 ]
   gvalue = [ gvalue,          165,          127,          128,           34,           42,          105 ]
   bvalue = [ bvalue,            0,           80,          128,           34,           42,          180 ]
   colors = [ colors,  'Deep Pink',    'Magenta',     'Tomato', 'Orange Red',        'Red', 'Violet Red' ]
   rvalue = [ rvalue,          255,          255,          255,          255,          255,          208 ]
   gvalue = [ gvalue,           20,            0,           99,           69,            0,           32 ]
   bvalue = [ bvalue,          147,          255,           71,            0,            0,          144 ]
   colors = [ colors,     'Maroon',    'Thistle',       'Plum',     'Violet',    'Orchid','Medium Orchid']
   rvalue = [ rvalue,          176,          216,          221,          238,          218,          186 ]
   gvalue = [ gvalue,           48,          191,          160,          130,          112,           85 ]
   bvalue = [ bvalue,           96,          216,          221,          238,          214,          211 ]
   colors = [ colors,'Dark Orchid','Blue Violet',     'Purple' ]
   rvalue = [ rvalue,          153,          138,          160 ]
   gvalue = [ gvalue,           50,           43,           32 ]
   bvalue = [ bvalue,          204,          226,          240 ]

ENDELSE

   ; How many colors do we have?

ncolors = N_Elements(colors)

   ; Did the user ask for the color names? If so, return them now.

IF Keyword_Set(names) THEN RETURN, Reform(colors, 1, ncolors)

   ; Process the color names.

theNames = StrUpCase( StrCompress( StrTrim( colors, 2 ), /Remove_All ) )

   ; Find the asked-for color in the color names array.

theIndex = Where(theNames EQ theColor, foundIt)
theIndex = theIndex[0]

   ; If the color can't be found, report it and continue with
   ; the first color in the color names array.

IF foundIt EQ 0 THEN BEGIN
   Message, "Can't find color " + theColor + ". Substituting " + StrUpCase(colors[0]) + ".", /Informational
   theColor = theNames[0]
   theIndex = 0
ENDIF

   ; Get the color triple for this color.

r = rvalue[theIndex]
g = gvalue[theIndex]
b = bvalue[theIndex]

   ; Did the user want a color triple? If so, return it now.

IF Keyword_Set(triple) THEN BEGIN
   IF Keyword_Set(allcolors) THEN BEGIN
      IF Keyword_Set(row) THEN RETURN, Transpose([[rvalue], [gvalue], [bvalue]]) ELSE RETURN, [[rvalue], [gvalue], [bvalue]]
   ENDIF ELSE BEGIN
      IF Keyword_Set(row) THEN RETURN, [r, g, b] ELSE RETURN, [[r], [g], [b]]
   ENDELSE
ENDIF

   ; Otherwise, we are going to return either an index
   ; number where the color has been loaded, or a 24-bit
   ; value that can be decomposed into the proper color.

IF N_Elements(decomposedState) EQ 0 THEN BEGIN
   IF Float(!Version.Release) GE 5.2 THEN BEGIN
      IF (!D.Name EQ 'X' OR !D.Name EQ 'WIN' OR !D.Name EQ 'MAC') THEN BEGIN
         Device, Get_Decomposed=decomposedState
      ENDIF ELSE decomposedState = 0
   ENDIF ELSE decomposedState = 0
ENDIF ELSE decomposedState = Keyword_Set(decomposedState)

   ; Return the color value or values.

IF decomposedState THEN BEGIN

      ; Need a color structure?

   IF Arg_Present(colorStructure) THEN BEGIN
      theColors = FSC_Color_Color24([[rvalue], [gvalue], [bvalue]])
      colorStructure = Create_Struct(theNames[0], theColors[0])
      FOR j=1, ncolors-1 DO colorStructure = Create_Struct(colorStructure, theNames[j], theColors[j])
   ENDIF

   IF Keyword_Set(allcolors) THEN BEGIN
      RETURN, FSC_Color_Color24([[rvalue], [gvalue], [bvalue]])
   ENDIF ELSE BEGIN
      RETURN, FSC_Color_Color24([r, g, b])
   ENDELSE

ENDIF ELSE BEGIN

   IF Keyword_Set(allcolors) THEN BEGIN

            ; Need a color structure?

      IF Arg_Present(colorStructure) THEN BEGIN
         startIndex = !D.Table_Size - ncolors
         IF startIndex GT 0 THEN startIndex = startIndex - 1
         theColors = IndGen(ncolors) + startIndex
         colorStructure = Create_Struct(theNames[0],  theColors[0])
         FOR j=1, ncolors-1 DO colorStructure = Create_Struct(colorStructure, theNames[j], theColors[j])
      ENDIF

      startIndex = !D.Table_Size - ncolors
      IF startIndex LT 0 THEN $
         Message, 'Number of colors exceeds available color table values. Returning.', /NoName
      IF startIndex GT 0 THEN startIndex = startIndex - 1
      IF !D.Name NE 'PRINTER' THEN TVLCT, rvalue, gvalue, bvalue, startIndex
      RETURN, IndGen(ncolors) + startIndex
   ENDIF ELSE BEGIN

            ; Need a color structure?

      IF Arg_Present(colorStructure) THEN BEGIN
         colorStructure = Create_Struct(theColor,  colorIndex)
      ENDIF

      IF !D.Name NE 'PRINTER' THEN TVLCT, rvalue[theIndex], gvalue[theIndex], bvalue[theIndex], colorIndex
      RETURN, colorIndex
   ENDELSE


ENDELSE

END ;-------------------------------------------------------------------------------------------------------