@IsDefined
;-------------------------------------------------------------------------------
; Close movie down.
;-------------------------------------------------------------------------------

    Pro showmovie_event, event
	widget_control, /destroy, event.top
    end


;-------------------------------------------------------------------------------
; Imprint a label on an image frame.
; (Modified version of /v/scat/idl/lib/movie/addlabel.pro)
;
; Loads an image into movie storage.  If movie not yet initiated, a movie widget
; is realized, and id's of its base and draw area returned.
; Dates are annotated to each frame if supplied.  If only a "from" or a "to"
; date is supplied, a single date is annotated.  If both are supplied, the
; annotation has the form "ddmmyyyy - ddmmyyyy".  Dates are only annotated if all
; thre parts (day, month, year) are provided.
; A check is maintained on the capacity permitted, but if images of different
; sizes are loaded, a running total of loaded bytes should be maintained outside
; this routine.
;
; The routine is designed such that calls (including initial call) can be
; repeated with the keywords set to the same variables, which act as buffers
; passing updated information back and forth.
;
; Argument :-	image = the (byte) image to be loaded
;
; Keywords :-
;	movie_base_id	= on initiation, returns the id of the base widget for
;			  the movie.  Subsequently used to input the id of the
;			  base.  In input value less than 0 initiates a new
;			  movie.
;	movie_id	= on initiation, returns the id of the draw widget for
;			  the movie.  Subsequently used to input the id of the
;			  movie draw area (screen).
;	movie_window	= on initiation, returns the window number for the
;			  movie.  Subsequently used to input the window number.
;	from_day	= input a day number (integer), which will appear in
;			  the (first) date annotated to the frame.
;	from_month	= input a month number (integer), which will appear in
;			  the (first) date annotated to the frame.
;	from_year	= input a year number (integer), which will appear in
;			  the (first) date annotated to the frame.
;	to_day		= input a day number (integer), which will appear in
;			  the (second) date annotated to the frame.
;	to_month	= input a month number (integer), which will appear in
;			  the (second) date annotated to the frame.
;	to_year		= input a year number (integer), which will appear in
;			  the (second) date annotated to the frame.
;	colour		= input the colour index to use for annotations
;	num_frames	= used on initiation to input the number of frames that
;			  will be loaded.  The routine estimates the required
;			  capacity (bytes), based on the size of the first
;			  image, and if it exceeds the total capacity, as
;			  indicated by keyword storage, estimates and returns
;			  the number of frames permissable.
;	next_frame	= on input, the frame number for the supplied image;
;			  on output, the frame number for the subsequent image.
;			  If, on input, the requested frame number would exceed
;			  the storage capacity (base on the size of the current
;			  image, the image is not loaded.
;	top_down	= if set, top down raster scanning is used, otherwise
;			  bottom up (x,y) scanning is assumed.
;	title		= text to be used in the title bar.  During loading, may
;			  be set for each image, but the last title applied will
;			  appear during movie play-back.  The title may be
;			  altered externally via WIDGET_CONTROL call, using
;			  "movie_base_id" and TLB_SET_TITLE keyword.
;	storage		= input maximum capacity (bytes) to allow for storage.
;			  This may be used as a system dependent value.  This
;			  keyword is used on initialization and subsequently.
;			  If ONLY supplied at initialization, the DEFAULT size
;			  will be assumed in subsequent checks.
;			  The default value is 10,000,000 bytes.
;	full		= returned with value 1 if there is no room left in
;			  "storage" for subsequent frames, otherwise retrurned
;			  as 0.
;	indicator	= longword initially returned with widget id for the
;			  "% completed" indicator.  This value must be re-
;			  supplied as input on subsequent calls.
;	
;-------------------------------------------------------------------------------

pro AddFrame,	image,				 $; [i] image to load
		movie_base_id	= movie_base_id, $; [io] wdgt id of movie base
		movie_id	= movie_id,	 $; [io] wdgt id of movie area
		movie_window	= movie_window,	 $; [io] window no. for movie
		from_day	= fday,		 $; [i] 1st day (integer)
		from_month	= fmonth,	 $; [i] 1st month (integer)
		from_year	= fyear,	 $; [i] 1st year (integer)
		to_day		= lday,		 $; [i] 2nd day (integer)
		to_month	= lmonth,	 $; [i] 2nd month (integer)
		to_year		= lyear,	 $; [i] 2nd year (integer)
		colour		= colour,	 $; [i] colour for annotations
		num_frames	= num_frames,	 $; [io] anticipated no. frames
		next_frame	= next_frame,	 $; [io] no. of next frame
		top_down	= top_down,	 $; [i] raster type (set)
		title		= title,	 $; [i] text for title bar
		storage		= storage,	 $; [i] maximum bytes to load
		full		= full,		 $; [o] indicate overload
		indicator	= indicator	  ; [io] widget id for indicator

    if not IsDefined(var = colour) then colour = 0B

    if not IsDefined(var = storage) then storage = 1e7
    s = size(image)
    store = s[1] * s[2]

    ; New movie
    if movie_base_id lt 0 or not IsDefined(var = movie_base_id) then begin

	bytes = string(fix(storage/1000000), format='(I4,"Mb")')
	report_init, [	'Loading movie frames......',			    $
			'(Total storage allowed = ' + bytes + ')' ],	    $
		     base = indicator, title = 'Movie Load',		    $
		     /remaining;, /interupt ; can't use cancel button!!
	image = byte(image)
	movie_base_id	= widget_base (title = title)
	if store * num_frames gt storage then num_frames = fix(storage / store)
	report_inc, indicator, num_frames
	movie_id	= cw_movie (movie_base_id, s[1], s[2], num_frames,  $
			  zoom_colour = colour)
	widget_control, movie_base_id, /realize
	movie_window	= !D.WINDOW
	next_frame	= 0

	print, 'Loading frames ....'

    endif

    ; check capacity
    capacity = next_frame * store
    report_stat, indicator, next_frame, num_frames;, cancel=full
    if capacity + store gt storage then full = 1
    if full gt 0 then begin
	report_init, base=indicator, /finish
	goto, theend
    endif
    capacity = capacity + store
    if IsDefined(var = num_frames) then total_capacity = store * num_frames    $
			     else total_capacity = storage

    cwid = !d.window
    wset, movie_window
    tv, image, order = top_down	;	 put image in window

    if IsDefined(var = fday)   and					   $
       IsDefined(var = fmonth) and					   $
       IsDefined(var = fyear)  then					   $
	   fdate = string(format='(2(i2.2,"/"),i4)', fday, fmonth, fyear)  $
    else fdate = ''

    if IsDefined(var = lday)   and					   $
       IsDefined(var = lmonth) and					   $
       IsDefined(var = lyear)  then					   $
	   ldate = string(format='(2(i2.2,"/"),i4)', lday, lmonth, lyear)  $
    else ldate = ''

    if not (fdate eq '' or ldate eq '') then middle = " - "		   $
					else middle = ""

    xyouts, 	2, 2,				$
		/device,			$
		fdate + middle + ldate,		$
		charsize=0.8,			$
		color = colour

    cw_movie_load,	movie_id,		$
			frame	= next_frame,	$
			window	= movie_window

    next_frame = next_frame + 1
    report_stat, indicator, next_frame, num_frames;, cancel=full
    if (next_frame + 1) * store gt storage then full = 1
    if (next_frame + 1) gt num_frames then full = 1
    if full gt 0 then report_init, base=indicator, /finish

    if IsDefined(var = title) then					$
	widget_control, movie_base_id, tlb_set_title = title

    wset, cwid

theend:
print,'capacity = ', capacity / storage * 100, '%'
end
