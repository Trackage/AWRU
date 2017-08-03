;---------------------------------------------------------------------------
 ; Author: Mike Schienle
 ; $Workfile$
 ; $Revision: 1.1 $
 ; Orig Date:  96-08-11
 ; $Modtime$
 ;---------------------------------------------------------------------------
 ; Purpose: Pad a scalar or array with leading zeroes.
 ; History:
 ;---------------------------------------------------------------------------

 Function StrZero, asData, iZero, Help=iHelp
     ;   asData is the input string array (or scalar)
     ;   iZero is the number of zeroes

     ;   check if asData was specified
     IF ((N_Elements(asData) EQ 0) OR (KeyWord_Set(iHelp))) THEN BEGIN
         ;   input array not specified - clue user
         Print, 'usage: StrZero, asData [, iZero] [, /Help]'
         Print, '    asData is an array (scalar is acceptable) of strings, '
         Print, '    or any type of data that may be converted to strings.'
         Print, '    iZero is the number of zeroes to place in front of '
         Print, '    each element of the array. If iZero is not specified, '
         Print, '    each string in the array will be padded to the length '
         Print, '    of the longest element in the array.'
         Print, ''
         Return, ''
     ENDIF ELSE BEGIN
         ;   trim leading and trailing blanks
         asOutputData = StrTrim(asData, 2)
     ENDELSE

     ;   check if number of zeroes was set
     IF (N_Elements(iZero) EQ 0) THEN $
         ;   default to max length of string array
         iZero = Max(Strlen(asOutputData))

     ;   assign a byte value for use in padding the string
     bZero = 48b

     ;   loop through number of elements in array
     FOR i = 0, (N_Elements(asOutputData) - 1) DO BEGIN
         ;   get the length of the string
         iLength = StrLen(asOutputData(i))

         ;   check string length against specified number of zeroes
         IF (iLength LT iZero) THEN $
             asOutputData(i) = String(BytArr(iZero - iLength) + bZero) + $
                 asOutputData(i)
     ENDFOR
     ;   return array
     Return, asOutputData
 END
