PRO PLACE_NAMES, macq = macq, anta = anta, tas = tas, nz = nz, ross = ross, ball = ball, auck = auck, $
	camp = camp, chath = chath, antip = antip, bount = bount, all = all

IF keyword_set(macq) THEN BEGIN

	a = bytarr(5,5) + !d.n_colors -1
	tv, a, 158.55, -54.27, /data
	xyouts, 158, -55.5, 'MACQUARIE IS.', color = !d.n_colors - 1, charsize = 1.0, charthick = 0.7, /data
ENDIF
IF keyword_set(anta) THEN xyouts, 135, -72, 'ANTARCTICA', color = 256l*256*256-1, charsize = 1.5, charthick = 0.7, /data
IF keyword_set(tas) THEN xyouts, 145, -42.5, 'TAS', color = 256l*256*256-1, charsize = 1.5, charthick = 0.7, /data
IF keyword_set(nz) THEN xyouts, 169, -45, 'NZ', color = 256l*256*256-1, charsize = 1.5, charthick = 0.7, /data
IF keyword_set(ross) THEN xyouts, 185, -76, 'ROSS SEA', color = 256l*256*256-1, charsize = 1.5, charthick = 0.7, /data
IF keyword_set(ball) THEN xyouts, 164, -66, 'BALLENY IS.', color = 256l*256*256-1, charsize = 01.0, charthick = 0.7, /data
IF keyword_set(auck) THEN xyouts, 166, -50, 'AUCKLAND IS.', color = 256l*256*256-1, charsize = 1.0, charthick = 0.7, /data
IF keyword_set(camp) THEN xyouts, 170, -53, 'CAMPBELL IS.', color = 256l*256*256-1, charsize = 1.0, charthick = 0.7, /data
IF keyword_set(chath) THEN xyouts, 185, -44, 'CHATHAM IS.', color = 256l*256*256-1, charsize = 1.0, charthick = 0.7, /data
IF keyword_set(antip) THEN xyouts, 180, -51,  'ANTIPODES IS.', color = 256l*256*256-1, charsize = 1.0, charthick = 0.7, /data
IF keyword_set(bount) THEN xyouts, 180, -48,  'BOUNTY IS.', color = 256l*256*256-1, charsize = 1.0, charthick = 0.7, /data

IF keyword_set(all) THEN BEGIN


	a = bytarr(5,5) + !d.n_colors -1
	tv, a, 158.55, -54.27, /data
	xyouts, 158, -55.5, 'MACQUARIE IS.', color = !d.n_colors - 1, charsize = 1.0, charthick = 0.7, /data

	xyouts, 135, -72, 'ANTARCTICA', color = 256l*256*256-1, charsize = 1.5, charthick = 0.7, /data
	xyouts, 145, -42.5, 'TAS', color = 256l*256*256-1, charsize = 1.5, charthick = 0.7, /data
	xyouts, 169, -45, 'NZ', color = 256l*256*256-1, charsize = 1.5, charthick = 0.7, /data
	xyouts, 185, -76, 'ROSS SEA', color = 256l*256*256-1, charsize = 1.5, charthick = 0.7, /data
	xyouts, 164, -66, 'BALLENY IS.', color = 256l*256*256-1, charsize = 1.0, charthick = 0.7, /data
	xyouts, 166, -50, 'AUCKLAND IS.', color = 256l*256*256-1, charsize = 1.0, charthick = 0.7, /data
	xyouts, 170, -53, 'CAMPBELL IS.', color = 256l*256*256-1, charsize = 1.0, charthick = 0.7, /data
	xyouts, 185, -44, 'CHATHAM IS.', color = 256l*256*256-1, charsize = 1.0, charthick = 0.7, /data
	xyouts, 180, -51,  'ANTIPODES IS.', color = 256l*256*256-1, charsize = 1.0, charthick = 0.7, /data
	xyouts, 180, -48,  'BOUNTY IS.', color = 256l*256*256-1, charsize = 1.0, charthick = 0.7, /data
ENDIF
END