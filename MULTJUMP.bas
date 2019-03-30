DECLARE SUB EXITLEVEL ALIAS "_EXIT" (BYVAL ERRORLEVEL%)
DECLARE FUNCTION serialmsg$ (cmd$)

serialport$ = "COM1:9600,N,8,1,BIN,CS0,DS0"
cmdinput$ = COMMAND$
'cmdinput$ = "/nr 2,11,0;2,12,2;2,10,2"
IF UCASE$(LEFT$(cmdinput$, 3)) = "/NR" THEN
    cmdinput$ = RIGHT$(cmdinput$, LEN(cmdinput$) - 4)
    askreboot% = 0
ELSE
    askreboot% = 1
END IF

OPEN serialport$ FOR RANDOM AS #1
cursor% = 1
failed% = 0
change% = 0
DO
    loopexit% = 0
    nextcursor% = INSTR(cursor% + 1, cmdinput$, ";")
    IF cursor% <> 1 AND nextcursor% <> 0 THEN
        cmd$ = MID$(cmdinput$, cursor% + 1, nextcursor% - cursor% - 1)
    ELSEIF cursor% = 1 AND nextcursor% <> 0 THEN
        cmd$ = LEFT$(cmdinput$, nextcursor% - 1)
    ELSEIF cursor% = 1 AND nextcursor% = 0 THEN
        cmd$ = cmdinput$
        loopexit% = 1
    ELSE
        cmd$ = RIGHT$(cmdinput$, LEN(cmdinput$) - cursor%)
        loopexit% = 1
    END IF
    IF LEFT$(cmd$, 1) = "2" THEN
        comma% = INSTR(cmd$, ",")
        msg$ = serialmsg$("1," + MID$(cmd$, comma% + 1, INSTR(comma% + 1, cmd$, ",") - comma% - 1))
        IF RIGHT$(msg$, 1) = "0" THEN
            IF LEFT$(msg$, LEN(msg$) - 2) = RIGHT$(cmd$, LEN(cmd$) - 2) THEN
                PRINT "Command: ";
                PRINT cmd$;
                PRINT " ...already set! (";
                PRINT msg$;
                PRINT ")"
                GOTO continueloop
            END IF
        END IF
    END IF
    msg$ = serialmsg$(cmd$)
    IF RIGHT$(msg$, 1) = "0" THEN
        IF LEFT$(cmd$, 1) = "2" THEN
            comma% = INSTR(cmd$, ",")
            msg$ = serialmsg$("1," + MID$(cmd$, comma% + 1, INSTR(comma% + 1, cmd$, ",") - comma% - 1))
            IF RIGHT$(msg$, 1) = "0" THEN
                IF LEFT$(msg$, LEN(msg$) - 2) = RIGHT$(cmd$, LEN(cmd$) - 2) THEN
                    PRINT "Command: ";
                    PRINT cmd$;
                    PRINT " ...succeeded! (";
                    PRINT msg$;
                    PRINT ")"
                    change% = 1
                END IF
            END IF
        ELSE
            PRINT "Command: ";
            PRINT cmd$;
            PRINT " ...succeeded! (";
            PRINT msg$;
            PRINT ")"
        END IF
    ELSE
        PRINT "Command: ";
        PRINT cmd$;
        PRINT " ...failed!"
        failed% = failed% + 1
    END IF
continueloop:
    IF loopexit% = 1 THEN
        EXIT DO
    END IF
    cursor% = nextcursor%
LOOP
CLOSE #1
IF failed% = 0 AND change% = 1 THEN
    IF askreboot% = 1 THEN
        INPUT "Reboot? (y/n) ", reboot$
        IF UCASE$(reboot$) = "Y" THEN
            OUT &H64, &HFE
        END IF
    END IF
    EXITLEVEL 0
ELSE
    EXITLEVEL 10
END IF
END

FUNCTION serialmsg$ (cmd$)
    DIM bytestr AS STRING * 1
    serialcmd$ = cmd$
    serialcmd$ = serialcmd$ + CHR$(13)
    serialout$ = ""
    DO
        IF serialcmd$ <> "" THEN
            FOR i = 1 TO LEN(serialcmd$)
                bytestr = MID$(serialcmd$, i, 1)
                PUT #1, , bytestr
            NEXT i
            bytestr = ""
            serialcmd$ = ""
        END IF
        IF LOC(1) THEN
            GET #1, , bytestr
            serialout$ = serialout$ + bytestr
        END IF
        IF bytestr = CHR$(10) THEN
            serialdone = 1
        END IF
    LOOP UNTIL serialdone
    serialmsg$ = LEFT$(serialout$, LEN(serialout$) - 2)
END FUNCTION

