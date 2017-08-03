;###########################################################################
 ; File Name:  osinfo.pro
 ; Version:    1.2
 ; Author:     Mike Schienle
 ; Orig Date:  96-11-29
 ; Delta Date: 4/1/97 @ 12:28:01
 ;###########################################################################
 ; Purpose: Gather/store OS information in a structure.
 ; History:
 ;   97-04-01 MGS
 ;       Modified Wm Adjust field to be a 2x2 array.
 ;       Intended to hold offsets for windows with full decorations,
 ;       and windows with minimal decorations.
 ;###########################################################################
 ; @(#)osinfo.pro    1.2
 ;###########################################################################

 FUNCTION OsInfo
     ;   information keys off OS Family (MacOS, UNIX, Windows, VMS)
     sOsType = strlowcase(!Version.OS_Family)

     ;   create the empty structure of information
     mOsInfo = {$
         sDiskChar: '', $        ;   disk separator character
         sDirChar: '', $         ;   directory separator character
         sPathChar: '', $        ;   path separator character
         sWinName: '', $         ;   Window manager name
         mBuffer: {$             ;   buffer offsets
             scroll: 0, $        ;   scroll bar
             frame: 0, $         ;   frame boundary
             exclusive: 0, $     ;   radio button (exclusive)
             nonexclusive: 0, $  ;   checkbox button (nonexclusive)
             button: 0}, $       ;   button (regular)
         mWmOff: {$              ;   Window manager offsets
             title: 0, $
             left: 0, $
             right: 0, $
             top: 0, $
             bottom: 0, $
             menubar: 0}}

     ;   fill in the structure based on OS Type
     CASE sOsType OF
         'macos': BEGIN
             mOsInfo.sDiskChar = ':'
             mOsInfo.sDirChar = ':'
             mOsInfo.sPathChar = ','
             mOsInfo.sWinName = 'MAC'
             mOsInfo.mBuffer.scroll = 14
             mOsInfo.mBuffer.frame = 12
             mOsInfo.mBuffer.exclusive = 12
             mOsInfo.mBuffer.nonexclusive = 16
             mOsInfo.mBuffer.button = 6
             mOsInfo.mWmOff.title = 10
             mOsInfo.mWmOff.left = 6
             mOsInfo.mWmOff.right = 6
             mOsInfo.mWmOff.top = 6
             mOsInfo.mWmOff.bottom = 6
             mOsInfo.mWmOff.menubar = 18
             END
         'unix': BEGIN
             mOsInfo.sDiskChar = '/'
             mOsInfo.sDirChar = '/'
             mOsInfo.sPathChar = ':'
             mOsInfo.sWinName = 'X'
             mOsInfo.mBuffer.scroll = 14
             mOsInfo.mBuffer.frame = 12
             mOsInfo.mBuffer.exclusive = 12
             mOsInfo.mBuffer.nonexclusive = 16
             mOsInfo.mBuffer.button = 6
             mOsInfo.mWmOff.title = 10
             mOsInfo.mWmOff.left = 8
             mOsInfo.mWmOff.right = 8
             mOsInfo.mWmOff.top = 8
             mOsInfo.mWmOff.bottom = 8
             END
         'vms': BEGIN
             mOsInfo.sDiskChar = ':'
             mOsInfo.sDirChar = ']'
             mOsInfo.sWinName = 'X'
             mOsInfo.mWmOff.left = 5
             mOsInfo.mWmOff.right = 16
             mOsInfo.mWmOff.top = 5
             mOsInfo.mWmOff.bottom = 5
             END
         'windows': BEGIN
             mOsInfo.sDiskChar = ':'
             mOsInfo.sDirChar = '\'
             mOsInfo.sPathChar = ','
             mOsInfo.sWinName = 'WIN'
             mOsInfo.mWmOff.left = 1
             mOsInfo.mWmOff.right = 16
             mOsInfo.mWmOff.top = 16
             mOsInfo.mWmOff.bottom = 16
             END
         ELSE:
     ENDCASE
     Return, mOsInfo
 END
