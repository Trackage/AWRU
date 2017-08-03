;+
; NAME:
;       XIMAGE
;
; PURPOSE:
;       The purpose of this program is to demonstrate how to
;       create a image plot with axes and a title in the
;       new IDL 5 object graphics.
;
; AUTHOR:
;       FANNING SOFTWARE CONSULTING
;       David Fanning, Ph.D.
;       2642 Bradbury Court
;       Fort Collins, CO 80521 USA
;       Phone: 970-221-0438
;       E-mail: davidf@dfanning.com
;       Coyote's Guide to IDL Programming: http://www.dfanning.com
;
; CATEGORY:
;       Widgets, IDL 5 Object Graphics.
;
; CALLING SEQUENCE:
;       XImage, image
;
; REQUIRED INPUTS:
;       None. The image "worldelv.dat" from the examples/data directory
;       is used if no data is supplied in call.
;
; OPTIONAL INPUTS
;
;       image: A 2D or 3D image array.
;
; OPTIONAL KEYWORD PARAMETERS:
;
;       COLORTABLE: The number of a color table to use as the image palette.
;       Color table 0 (grayscale) is used as a default.
;
;       GROUP_LEADER: The group leader for this program. When the group leader
;       is destroyed, this program will be destroyed.
;
;       KEEP_ASPECT_RATIO: Set this keyword if you wish the aspect ratio
;       of the image to be preserved as the graphics display window is resized.
;
;       SIZE: The initial window size. Default is 300 by 300 pixels.
;
;       TITLE: A string used as the title of the plot.
;
;       XRANGE: A two-element array specifying the X axis range.
;
;       XTITLE: A string used as the X title of the plot.
;
;       YRANGE: A two-element array specifying the Y axis range.
;
;       YTITLE: A string used as the Y title of the plot.
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; EXAMPLE:
;       To use this program with your 2D or 3D image data, type:
;
;        IDL> XImage, image
;
; MODIFICATION HISTORY:
;       Written by David Fanning, 13 June 97.
;       Added Keep_Apect_Ratio keyword and Zoom buttons. DWF 15 JUNE 97.
;       Improved font handling and color support. DWF 4 OCT 97.
;       Fixed memory leakage from improper object cleanup. 12 FEB 98. DWF
;       Changed IDLgrContainer to IDL_Container to fix 5.1 problems. 20 May 98. DWF.
;       Modified program to show how image values can be selected. 8 May 2000. DWF.
;       Made several modifications to resize event handler. Much improved. 2 June 2000. DWF.
;-
;
;###########################################################################
;
; LICENSE
;
; This software is OSI Certified Open Source Software.
; OSI Certified is a certification mark of the Open Source Initiative.
;
; Copyright © 2000 Fanning Software Consulting.
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


FUNCTION Normalize, range, Position=position

    ; This is a utility routine to calculate the scale factor
    ; required to position a vector of specified range at a
    ; specific position given in normalized coordinates.

IF (N_Elements(position) EQ 0) THEN position = [0.0, 1.0]

scale = [((position[0]*range[1])-(position[1]*range[0])) / $
    (range[1]-range[0]), (position[1]-position[0])/(range[1]-range[0])]

RETURN, scale
END
;-------------------------------------------------------------------------



FUNCTION XImage_Aspect, plotAspect, windowAspect

    ; This is a utility function to calculate the positions in a
    ; normalized window (0->1) of the plot axes, given that the
    ; plot has a specific aspect ratio (width/height) and the
    ; window has another specific aspect ratio. The plot aspect
    ; ratio is preserved in the window with these position
    ; coordinates.

IF N_PARAMS() NE 2 THEN $
   Message, 'Correct calling sequence is: ' + $
   'XImage_Aspect, plotAspect, windowAspect'

   ; Calculate normalized positions in window.

xstart = 0.0
ystart = 0.0
xend = 1.0
yend = 1.0

IF (plotAspect GE windowAspect) THEN BEGIN

   yend = 1.0 * (windowAspect / plotAspect)
   ystart = ystart + (1.0 - (yend - ystart)) / 2.0
   yend = yend + (1.0 - (yend - ystart)) / 2.0

ENDIF ELSE BEGIN

   xend = 1.0 * (plotAspect / windowAspect)
   xstart = xstart + (1.0 - (xend - xstart)) / 2.0
   xend = xend + (1.0 - (xend - xstart)) / 2.0

ENDELSE

RETURN, [xstart, ystart, xend, yend]
END
;-------------------------------------------------------------------------



PRO XImage_Zoom_Button_Event, event

     ; Event handler to perform window zooming.

Widget_Control, event.top, Get_UValue=info, /No_Copy

    ; What kind of zooming is wanted?

Widget_Control, event.id, Get_UValue=zoomIt
CASE zoomIt OF

    'ZOOM_IN': BEGIN
        info.plotView->GetProperty, Viewplane_Rect=thisRect
        thisRect(0) = (thisRect(0) + 0.05) < thisRect(2)
        thisRect(1) = (thisRect(1) + 0.05) < thisRect(3)
        thisRect(2) = (thisRect(2) - 0.1) > thisRect(0)
        thisRect(3) = (thisRect(3) - 0.1) > thisRect(1)
        info.plotView->SetProperty, Viewplane_Rect=thisRect
        END

    'ZOOM_OUT': BEGIN
        info.plotView->GetProperty, Viewplane_Rect=thisRect
        thisRect(0) = thisRect(0) - 0.05
        thisRect(1) = thisRect(1) - 0.05
        thisRect(2) = thisRect(2) + 0.1
        thisRect(3) = thisRect(3) + 0.1
        info.plotView->SetProperty, Viewplane_Rect=thisRect
        END

ENDCASE

    ; Redisplay the view.

info.thisWindow->Draw, info.plotView

Widget_Control, event.top, Set_UValue=info, /No_Copy
END
;-------------------------------------------------------------------



PRO XImage_Processing, event

     ; Event handler to perform image processing options.

Widget_Control, event.top, Get_UValue=info, /No_Copy

    ; What processing is wanted?

Widget_Control, event.id, Get_UValue=thisOperation
CASE thisOperation OF

    'SOBEL': data=Sobel(*info.processPtr)
    'ROBERTS': data=Roberts(*info.processPtr)
    'BOXCAR': data=Smooth(*info.processPtr,5)
    'MEDIAN': data=Median(*info.processPtr,5)
    'ORIGINAL': data=*info.imagePtr

ENDCASE

   ; Update image and processed image data.

info.thisImage->SetProperty, Data=BytScl(data, Top=info.ncolors-1)
*info.processPtr = data

    ; Redisplay the view.

info.thisWindow->Draw, info.plotView

Widget_Control, event.top, Set_UValue=info, /No_Copy
END
;-------------------------------------------------------------------



PRO XImage_Properties, event

     ; Event handler to set graphic properties.

Widget_Control, event.top, Get_UValue=info, /No_Copy

    ; What property is wanted?

Widget_Control, event.id, Get_UValue=newProperty
CASE newProperty OF

       ; Background color.

   'BBLACK': info.plotView->SetProperty, Color=info.black
   'BWHITE': info.plotView->SetProperty, Color=info.white
   'BCHARCOAL': info.plotView->SetProperty, Color=info.gray

       ; Axes colors.

   'ABLACK': BEGIN
      info.xAxis1->SetProperty, Color=info.black
      info.xAxis2->SetProperty, Color=info.black
      info.yAxis1->SetProperty,Color=info.black
      info.yAxis2->SetProperty, Color=info.black
      END
   'AWHITE': BEGIN
      info.xAxis1->SetProperty,Color=info.white
      info.yAxis1->SetProperty,Color=info.white
      info.xAxis2->SetProperty,Color=info.white
      info.yAxis2->SetProperty,Color=info.white
      END
   'AGREEN': BEGIN
      info.xAxis1->SetProperty,Color=info.green
      info.yAxis1->SetProperty,Color=info.green
      info.xAxis2->SetProperty,Color=info.green
      info.yAxis2->SetProperty,Color=info.green
      END
   'AYELLOW': BEGIN
      info.xAxis1->SetProperty,Color=info.yellow
      info.yAxis1->SetProperty,Color=info.yellow
      info.xAxis2->SetProperty,Color=info.yellow
      info.yAxis2->SetProperty,Color=info.yellow
      END

       ; Title colors.

   'TBLACK': info.plotTitle->SetProperty, Color=info.black
   'TWHITE': info.plotTitle->SetProperty, Color=info.white
   'TGREEN': info.plotTitle->SetProperty, Color=info.green
   'TYELLOW': info.plotTitle->SetProperty, Color=info.yellow

ENDCASE

    ; Redraw the graphic.

info.thisWindow->Draw, info.plotView

    ;Put the info structure back.

Widget_Control, event.top, Set_UValue=info, /No_Copy
END
;-------------------------------------------------------------------



PRO XImage_Output, event

   ; This event handler creates GIF and JPEG files.

Widget_Control, event.top, Get_UValue=info, /No_Copy

   ; Get a snapshop of window contents. (TVRD equivalent.)

info.thisWindow->GetProperty, Image_Data=snapshot

   ; JPEG or GIF file wanted?

Widget_Control, event.id, Get_UValue=whichFileType
CASE whichFileType OF

   'GIF': BEGIN

         ; Because we are using a window set up for RGB color,
         ; snapshot contains a 3xMxN array. Use Color_Quan to
         ; create a 2D image and appropriate color tables for
         ; the GIF file.

      image2D = Color_Quan(snapshot, 1, r, g, b)
      filename = Dialog_Pickfile(/Write, File='idl.gif')
      IF filename NE '' THEN Write_GIF, filename, image2d, r, g, b
      END

   'JPEG': BEGIN

      filename = Dialog_Pickfile(/Write, File='idl.jpg')
      IF filename NE '' THEN Write_JPEG, filename, snapshot, True=1
      END

ENDCASE

    ;Put the info structure back.

Widget_Control, event.top, Set_UValue=info, /No_Copy
END
;-------------------------------------------------------------------



PRO XImage_Exit, event

   ; Exit the program via the EXIT button.
   ; The XIMAGE_CLEANUP procedure will be called automatically.

Widget_Control, event.top, /Destroy
END
;-------------------------------------------------------------------



PRO XImage_Printing, event

   ; PostScript printing and printer setup handled here.

Widget_Control, event.top, Get_UValue=info, /No_Copy

   ; Which button?

Widget_Control, event.id, Get_UValue=ButtonValue
CASE buttonValue OF

   'PRINT': BEGIN
      result = Dialog_PrintJob(info.thisPrinter)
      IF result EQ 1 THEN BEGIN
         info.thisPrinter->Draw, info.plotView
         info.thisPrinter->NewDocument
      ENDIF
      END

   'SETUP': BEGIN
      result = Dialog_PrinterSetup(info.thisPrinter)
      IF result EQ 1 THEN BEGIN
         info.thisPrinter->Draw, info.plotView
         info.thisPrinter->NewDocument
      ENDIF
      END

ENDCASE

   ; Put the info structure back.

Widget_Control, event.top, Set_UValue=info, /No_Copy
END
;-------------------------------------------------------------------



PRO XImage_Image_Colors, event
; This event handler changes color tables for elevation shading.

Widget_Control, event.top, Get_UValue=info, /No_Copy

   ; What kind of event is this?

thisEvent = Tag_Names(event, /Structure_Name)
CASE thisEvent OF

   "WIDGET_BUTTON": BEGIN
      TVLCT, info.r, info.g, info.b
      XColors, Group_Leader=event.top, NotifyID=[event.id, event.top], $
         NColors=info.ncolors
      ENDCASE

   "XCOLORS_LOAD": BEGIN
      info.r[0:info.ncolors-1] = Congrid(event.r, info.ncolors)
      info.g[0:info.ncolors-1] = Congrid(event.g, info.ncolors)
      info.b[0:info.ncolors-1] = Congrid(event.b, info.ncolors)
      IF Obj_Valid(info.thisPalette) THEN info.thisPalette->SetProperty, $
         Red=event.r, Green=event.g, Blue=event.b
      ENDCASE

ENDCASE

   ; Draw the graphic display.

info.thisWindow->Draw, info.plotView
Widget_Control, event.top, Set_UValue=info, /No_Copy
END ;------------------------------------------------------------------------------



PRO XIMAGE_CLEANUP, id

    ; Come here when the widget dies. Free all the program
    ; objects, pointers, pixmaps, etc. and release memory.

Widget_Control, id, Get_UValue=info
IF N_Elements(info) NE 0 THEN BEGIN
   Obj_Destroy, info.thisContainer
   Ptr_Free, info.imagePtr
   Ptr_Free, info.processPtr
ENDIF
END
;---------------------------------------------------------------------



PRO XImage_DrawWidget_Event, event

    ; This event handler handles draw widget events, including
    ; image value selection events.

Widget_Control, event.top, Get_UValue=info, /No_Copy

    ; Is this an XCOLORS event?

thisEvent = Tag_Names(event, /Structure_Name)
IF thisEvent EQ 'XCOLORS_LOAD' THEN BEGIN

        ; Make sure the color vectors have correct drawing colors.

    event.r(info.ncolors:info.ncolors+4) = info.drawColors(*,0)
    event.g(info.ncolors:info.ncolors+4) = info.drawColors(*,1)
    event.b(info.ncolors:info.ncolors+4) = info.drawColors(*,2)

        ; Set the color palette with the new colors.

    info.thisPalette->SetProperty, Red_Values=event.r
    info.thisPalette->SetProperty, Blue_Values=event.b
    info.thisPalette->SetProperty, Green_Values=event.g
    Widget_Control, event.top, Set_UValue=info, /No_Copy
    RETURN
ENDIF

possibleEvents = ['DOWN', 'UP', 'MOTION', 'SCROLL', 'EXPOSE']
thisEvent = possibleEvents[event.type]
CASE thisEvent OF
   'DOWN': Widget_Control, event.id, Draw_Motion_Events=1
   'UP': Widget_Control, event.id, Draw_Motion_Events=0
   'EXPOSE': info.thisWindow->Draw, info.plotView
   ELSE:
ENDCASE

IF thisEvent NE 'EXPOSE' THEN BEGIN

   ; Calculate the image value at the current location.

   hit = info.thisWindow->Pickdata(info.plotView, info.thisImage, [event.x, event.y], xyz)
   xpt = Floor(xyz[0])
   ypt = Floor(xyz[1])
   IF xpt LT 0 OR xpt GT (info.xsize-1) OR ypt LT 0 OR ypt GT (info.ysize-1) THEN BEGIN
      Widget_Control, info.xvalueID, Set_Value=-999
      Widget_Control, info.yvalueID, Set_Value=-999
      Widget_Control, info.valueID, Set_Value='-9999.0'
   ENDIF ELSE BEGIN
      Widget_Control, info.xvalueID, Set_Value=xpt
      Widget_Control, info.yvalueID, Set_Value=ypt
      Widget_Control, info.valueID, Set_Value=Float((*info.processPtr)[xpt, ypt])
   ENDELSE

ENDIF

    ;Put the info structure back.

Widget_Control, event.top, Set_UValue=info, /No_Copy
END
;-------------------------------------------------------------------



PRO XImage_Resize, event

    ; This is main event handler for the TLB. It handles resize events.

Widget_Control, event.top, Get_UValue=info, /No_Copy

    ; Resize the draw widget.

info.thisWindow->SetProperty, Dimension=[event.x > 400, event.y-info.basesize]

    ; Keep the aspect ratio of the graphic?

IF info.keepAspect THEN BEGIN

        ; Get the new viewplane rectangle.

    waspect = (event.y-info.basesize) / Float(event.x > 400)
    IF waspect GE 1.0 THEN BEGIN
       ylen = 1.0 * waspect
       xlen = 1.0
       ystart = (-ylen/2.0) + 0.5 ; Center it.
       xstart = 0.0
    ENDIF ELSE BEGIN
       xlen = 1.0 / waspect
       ylen = 1.0
       xstart = (-xlen/2.0) + 0.5 ; Center it.
       ystart = 0.0
    ENDELSE

        ; Reset the viewplane rectangle.

    info.plotView->SetProperty,Viewplane_Rect=[xstart, ystart, xlen, ylen]

ENDIF

   ; Redisplay the graphic.

info.thisWindow->Draw, info.plotView

    ;Put the info structure back.

Widget_Control, event.top, Set_UValue=info, /No_Copy
END
;---------------------------------------------------------------------



PRO XIMAGE, image, XRange=xrange, YRange=yrange, $
    Keep_Aspect=keepAspect, Size=wsize, $
    Colortable=colortable, XTitle=xtitle, YTitle=ytitle, $
    Group_Leader=group, Title=plottitle, TrueColor=trueColor

    ; Check for parameters.

IF N_Params() EQ 0 THEN BEGIN
   filename = Filepath(SubDir=['examples', 'data'], 'worldelv.dat')
   OpenR, lun, filename, /Get_LUN
   image = BytArr(360,360)
   ReadU, lun, image
   Free_Lun, lun
ENDIF

   ; Get dimensions of image data. Set up INTERLEAVE variable.

s = SIZE(image)
IF s(0) LT 2 THEN Message, 'Must pass a 2D or 3D image data set.'
IF s(0) EQ 2 THEN BEGIN
   xsize = s(1)
   ysize = s(2)
   interleave = 0
   IF N_Elements(trueColor) EQ 0 THEN trueColor = 0
ENDIF
IF s(0) EQ 3 THEN BEGIN
   sizes = [s(1), s(2), s(3)]
   interleave = WHERE(sizes EQ 3)
   interleave = interleave(0)
   IF N_Elements(trueColor) EQ 0 THEN trueColor = 1
   IF interleave LT 0 THEN $
      Message, 'Image does not appear to be a 24-bit image. Returning...'
   CASE interleave OF
      0: BEGIN
         xsize = s(2)
         ysize = s(3)
         END
      1: BEGIN
         xsize = s(1)
         ysize = s(3)
         END
      2: BEGIN
         xsize = s(1)
         ysize = s(2)
         END
   ENDCASE
ENDIF

   ; Check for keyword parameters. Define default values if necessary.

IF N_Elements(xrange) EQ 0 THEN xrange = [0,xsize]
IF N_Elements(yrange) EQ 0 THEN yrange = [0,ysize]
IF N_Elements(wsize) EQ 0 THEN BEGIN
    wxsize = 400
    wysize = 400
ENDIF ELSE BEGIN
    wxsize = wsize
    wysize = wsize
ENDELSE
IF N_Elements(xtitle) EQ 0 THEN xtitle = 'X Axis'
IF N_Elements(ytitle) EQ 0 THEN ytitle = 'Y Axis'
IF N_Elements(plotTitle) EQ 0 THEN plotTitle='Example Object Graphics Image Plot'
IF N_Elements(colortable) EQ 0 THEN colortable = 0
keepAspect = Keyword_Set(keepAspect)

    ; Calculate the aspect ratios (width/height) for the image
    ; and for the display window.

imageAspect = Float(xsize) / ysize
windowAspect = Float(wxsize) / wysize

   ; How many colors in this IDL session?

ncolors = !D.Table_Size - 5

   ; Get the color vectors for the palette object. I
   ; do this in a pixmap window so the user doesn't
   ; see a bunch of color flashing, etc. Drawing colors
   ; are loaded above the image colors.

LoadCT, colortable, NColors=ncolors
drawColors = [[80, 255, 0, 255, 0], [80, 255, 255, 255, 0], $
   [80, 0, 0, 255, 0]]
TVLCT, drawColors, ncolors
gray = ncolors
yellow = ncolors + 1
green = ncolors + 2
white = ncolors + 3
black = ncolors + 4
TVLCT, r, g, b, /Get

    ; Create the palette and image objects. Use a pointer to
    ; the image data.

thisPalette = Obj_New('IDLgrPalette', r, g, b)

imagePtr = Ptr_New(image)
processPtr = Ptr_New(image)
thisImage = Obj_New('IDLgrImage', BytScl(*imagePtr, Top=ncolors-1), $
   Dimensions=[xsize,ysize], Interleave=interleave, $
   Palette=thisPalette)

    ; Create scaling parameters for the image. I get
    ; position coordinates for a normalized window from
    ; my XImage_Aspect function. Then use my Normalize
    ; function to create scaling factors for the image.

pos = XImage_Aspect(imageAspect, windowAspect)
xs = Normalize([0,xsize], Position=[pos(0)+0.15, pos(2)-0.15])
ys = Normalize([0,ysize], Position=[pos(1)+0.15, pos(3)-0.15])

thisImage->SetProperty, XCoord_Conv=xs, YCoord_Conv=ys

    ; Note that XCoord_Conv and YCoord_Conv are broken in IDL 5.0
    ; for the image object, I must put the image in its own model
    ; and scale the model appropriately if I am running there.
    ; The code looks like this:

;imageModel = Obj_New('IDLgrModel')
;imageModel->Scale, (pos(2)-pos(0))/xsize, (pos(3)-pos(1))/ysize, 1
;imageModel->Translate, pos(0), pos(1), 1
;imageModel->Add, thisImage

    ; Set up font objects for the axes titles.

helvetica10pt = Obj_New('IDLgrFont', 'Helvetica', Size=10)
helvetica12pt = Obj_New('IDLgrFont', 'Helvetica', Size=12)

    ; Create title objects for the axes. Color them yellow.

xTitle = Obj_New('IDLgrText', xtitle, Color=yellow, Recompute_Dimensions=1)
yTitle = Obj_New('IDLgrText', ytitle, Color=yellow, Recompute_Dimensions=1)

    ; Create a plot title object. I want the title centered just
    ; above the upper X Axis.

plotTitle = Obj_New('IDLgrText', plotTitle, Color=yellow, $
   Location=[0.5, pos(3)-0.10, 0.0], Alignment=0.5, Font=helvetica12pt, Recompute_Dimensions=1)

    ; Set up scaling for the axes. These are the same
    ; scaling parameters I set up for the image, so I
    ; don't really have to do them again, but I wanted
    ; to remind you what I was doing.

pos = XImage_Aspect(imageAspect, windowAspect)
xs = Normalize(xrange, Position=[pos(0)+0.15, pos(2)-0.15])
ys = Normalize(yrange, Position=[pos(1)+0.15, pos(3)-0.15])

    ; Create the four axis objects (box axes). Make the titles
    ; with helvetica 10 point fonts.

xAxis1 = Obj_New("IDLgrAxis", 0, Color=yellow, Ticklen=0.025, $
    Minor=4, Range=xrange, Title=xtitle, /Exact, XCoord_Conv=xs,  $
    Location=[1000, pos(1)+0.15 ,0.15])
xAxis1->GetProperty, Ticktext=xAxisText
xAxisText->SetProperty, Font=helvetica10pt, Recompute_Dimensions=2

xAxis2 = Obj_New("IDLgrAxis", 0, Color=yellow, Ticklen=0.025, $
    Minor=4, /NoText, Range=xrange, TickDir=1, /Exact, XCoord_Conv=xs, $
    Location=[1000, pos(3)-0.15 ,0.15])

yAxis1 = Obj_New("IDLgrAxis", 1, Color=yellow, Ticklen=0.025, $
    Minor=4, Title=ytitle, Range=yrange, /Exact, YCoord_conv=ys, $
    Location=[pos(0)+0.15 ,1000, 0.15])
yAxis1->GetProperty, Ticktext=yAxisText
yAxisText->SetProperty, Font=helvetica10pt, Recompute_Dimensions=2

yAxis2 = Obj_New("IDLgrAxis", 1, Color=yellow, Ticklen=0.025, $
    Minor=4, /NoText, Range=yrange, TickDir=1, /Exact, YCoord_conv=ys, $
    Location=[pos(2)-0.15, 1000, 0.15])

    ; Create a plot model and add axes, image, title to it.

plotModel = Obj_New('IDLgrModel', Select=1)
plotModel->Add, thisImage
plotModel->Add, xAxis1
plotModel->Add, xAxis2
plotModel->Add, yAxis1
plotModel->Add, yAxis2
plotModel->Add, plotTitle

    ; Create a plot view. Add the model to the view. Notice
    ; the view is created to give space around the region
    ; where the "action" in the plot takes place. The extra
    ; space has to be large enough to accomodate axis annotation.

viewRect = [0.0, 0.0, 1.0, 1.0]
plotView = Obj_New('IDLgrView', Viewplane_Rect=viewRect, $
   Location=[0,0], Color=gray)
plotView->Add, plotModel

    ; Create the widgets for this program.

tlb = Widget_Base(Title='Resizeable Image Example', $
   MBar=menubase, TLB_Size_Events=1, Column=1, Base_Align_Center=1)

   ; Create the draw widget. Use either INDEXED or DIRECT color model
   ; depending upon status of TrueColor keyword. If INDEXED, the
   ; color palatte is always used. RETAIN=0 is necessary to generate
   ; EXPOSE events.

drawID = Widget_Draw(tlb, XSize=wxsize, YSize=wysize, Color_Model=trueColor, $
   Graphics_Level=2, Expose_Events=1, Retain=0, $
   Event_Pro='XImage_DrawWidget_Event', Button_Events=1)

   ; Create image value and location widgets.

bottomBase = Widget_Base(tlb, Colum=1, /Base_Align_Center)
labelBase = Widget_Base(bottomBase, Row=1)
dummy = Widget_Label(labelBase, Value='Click (and drag) inside image for Image Value')
valueBase = Widget_Base(bottomBase, Row=1)
xvalueID = CW_Field(valueBase, Title='X Location:', Value=-999, /Integer, XSize=6)
yvalueID = CW_Field(valueBase, Title='  Y Location:', Value=-999, /Integer, XSize=6)
valueID =  CW_Field(valueBase, Title='  Image Value:', Value='-9999.0', XSize=10, /Float)

    ; Create FILE menu buttons for printing and exiting.

filer = Widget_Button(menubase, Value='File', /Menu)

   ; Create OUTPUT menu buttons for formatted output files.

saveasID = Widget_Button(filer, Value='Save As...', /Menu)
dummy = Widget_Button(saveasID, Value='GIF File', $
   UValue='GIF', Event_Pro='XImage_Output')
dummy = Widget_Button(saveasID, Value='JPEG File', $
   UValue='JPEG', Event_Pro='XImage_Output')

dummy = Widget_Button(filer, Value='Print', $
   Event_Pro='XImage_Printing', UValue='PRINT')
dummy = Widget_Button(filer, Value='Print Setup', $
   Event_Pro='XImage_Printing', UValue='SETUP')
dummy = Widget_Button(filer, /Separator, Value='Quit', $
   Event_Pro='XImage_Exit')

   ; Create COLORS menu buttons for changing colors.

properties = Widget_Button(menubase, Value='Colors', /Menu)

   ; Image Colors

imagecolors = Widget_Button(properties, Value='Image Colors...', $
   Event_Pro='XImage_Image_Colors')

   ; Background Color

bcolor = Widget_Button(properties, Value='Background Color', /Menu)
dummy = Widget_Button(bcolor, Value='Black', $
   Event_Pro='XImage_Properties', UValue='BBLACK')
dummy = Widget_Button(bcolor, Value='White', $
   Event_Pro='XImage_Properties', UValue='BWHITE')
dummy = Widget_Button(bcolor, Value='Charcoal', $
   Event_Pro='XImage_Properties', UValue='BCHARCOAL')

   ; Axes Color

acolor = Widget_Button(properties, Value='Axes Color', /Menu)
dummy = Widget_Button(acolor, Value='Black', $
   Event_Pro='XImage_Properties', UValue='ABLACK')
dummy = Widget_Button(acolor, Value='White', $
   Event_Pro='XImage_Properties', UValue='AWHITE')
dummy = Widget_Button(acolor, Value='Yellow', $
   Event_Pro='XImage_Properties', UValue='AYELLOW')
dummy = Widget_Button(acolor, Value='Green', $
   Event_Pro='XImage_Properties', UValue='AGREEN')

   ; Title Color

tcolor = Widget_Button(properties, Value='Title Color', /Menu)
dummy = Widget_Button(tcolor, Value='Black', $
   Event_Pro='XImage_Properties', UValue='TBLACK')
dummy = Widget_Button(tcolor, Value='White', $
   Event_Pro='XImage_Properties', UValue='TWHITE')
dummy = Widget_Button(tcolor, Value='Yellow', $
   Event_Pro='XImage_Properties', UValue='TYELLOW')
dummy = Widget_Button(tcolor, Value='Green', $
   Event_Pro='XImage_Properties', UValue='TGREEN')

   ; Create IMAGE PROCESSING menu buttons.

processing = Widget_Button(menubase, Menu=1, $
   Value='Processing')
edge = Widget_Button(processing, Menu=1, $
   Value='Edge Enhancement')
dummy = Widget_Button(edge, Value='Sobel', UValue='SOBEL', $
   Event_Pro='XImage_Processing')
dummy = Widget_Button(edge, Value='Roberts', UValue='ROBERTS', $
   Event_Pro='XImage_Processing')
smoother = Widget_Button(processing, Menu=1, $
   Value='Image Smoothing')
dummy = Widget_Button(smoother, Value='Boxcar', UValue='BOXCAR', $
   Event_Pro='XImage_Processing')
dummy = Widget_Button(smoother, Value='Median', UValue='MEDIAN', $
   Event_Pro='XImage_Processing')
dummy = Widget_Button(processing, Value='Original Image', $
   Event_Pro='XImage_Processing', UValue='ORIGINAL')

    ; Zoom in and out buttons.

zoomit = Widget_Button(menubase, Value='Zoom')

zInButton = Widget_Button(zoomit, Value='Zoom In', $
   Event_Pro='XImage_Zoom_Button_Event', UValue='ZOOM_IN')

zOutButton = Widget_Button(zoomit, Value='Zoom Out', $
   Event_Pro='XImage_Zoom_Button_Event', UValue='ZOOM_OUT')

    ; Realize the widgets and get the window object.

Widget_Control, tlb, /Realize
Widget_Control, drawID, Get_Value=thisWindow

   ; Find out the size of the base below the image
   ; so you can keep it in the face of window resizing.

geom = Widget_Info(bottomBase, /Geometry)
basesize = geom.scr_ysize

   ; Load the palette into the window. This will cause the
   ; image to be output through the palette always, even
   ; when displayed on 24-bit displays.

thisWindow->SetProperty, Palette=thisPalette

   ; Draw the graphic in the window.

thisWindow->Draw, plotView

   ; Get a printer object for this graphic.

thisPrinter = Obj_New('IDLgrPrinter')

   ; Create a container object to hold all the other
   ; objects. This will make it easy to free all the
   ; objects when we are finished with the program.
   ; Make a container to hold all the objects you created.

thisContainer = Obj_New('IDL_Container')
thisContainer->Add, thisWindow
thisContainer->Add, plotView
thisContainer->Add, thisPrinter
thisContainer->Add, xTitle
thisContainer->Add, yTitle
thisContainer->Add, thisPalette
thisContainer->Add, helvetica10pt
thisContainer->Add, helvetica12pt
thisContainer->Add, xaxis1
thisContainer->Add, xaxis2
thisContainer->Add, yaxis1
thisContainer->Add, yaxis2
thisContainer->Add, plotTitle

s = Size(*imagePtr, /Dimensions)

    ; Create an info structure to hold program information.

info = { thisContainer:thisContainer, $  ; The container object.
         thisPalette:thisPalette, $      ; The palette for INDEXED color.
         thisWindow:thisWindow, $        ; The window object.
         plotView:plotView, $            ; The view that will be rendered.
         thisPrinter:thisPrinter, $      ; The printer object.
         thisImage:thisImage, $          ; The image object.
         processPtr:processPtr, $        ; The pointer to the processed image.
         imagePtr:imagePtr, $            ; The pointer to the original image.
         xsize:s[0], $                   ; The X size of the image
         ysize:s[1], $                   ; The Y size of the image.
         plotTitle:plotTitle, $          ; The plot title.
         viewRect:viewRect, $            ; The original viewplane rectangle.
         xAxis1:xAxis1, $                ; Bottom X axis.
         xAxis2:xAxis2, $                ; Top X axis
         yAxis1:yAxis1, $                ; Left Y axis.
         yAxis2:yAxis2, $                ; Right Y axis.
         gray:gray, $                    ; The gray color index.
         xvalueID:xvalueID, $            ; X location widget ID.
         yvalueID:yvalueID, $            ; Y location widget ID.
         valueID:valueID, $              ; Image value widget ID.
         yellow:yellow, $                ; The yellow color index.
         green:green, $                  ; The green color index
         white:white, $                  ; The white color index.
         black:black, $                  ; The black color index.
         r:r, $                          ; The red color vector.
         g:g, $                          ; The green color vector.
         b:b, $                          ; The blue color vector.
         basesize:basesize, $            ; The height of the label base.
         keepAspect:keepAspect, $        ; The image keep aspect flag.
         drawID:drawID, $                ; The draw widget ID.
         drawColors:drawColors, $        ; The drawing color definitions.
         ncolors:ncolors }               ; The number of data colors.

Widget_Control, tlb, Set_UValue=info, /No_Copy

XManager, 'ximage', tlb, Cleanup='XImage_Cleanup', $
   Group_Leader=group, /No_Block, Event_Handler='XImage_Resize'
END