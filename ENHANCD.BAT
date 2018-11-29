@ECHO OFF

IF NOT DEFINED ENHANCD_DIR SET ENHANCD_DIR=%APPDATA%\enhancd
SET ENHANCD_LOG=%ENHANCD_DIR%\enhancd.log

IF NOT EXIST %ENHANCD_DIR% MKDIR %ENHANCD_DIR%
IF NOT EXIST %ENHANCD_LOG% TYPE NUL > %ENHANCD_LOG%

IF NOT "%~1" == "" IF NOT "%~1" == "." IF EXIST %~s1\NUL (
	CD /D %*
	GOTO :AFTER_CD
)

CALL :GENERATE_REVERSE_LOG

IF "%~1" == "" (
	FOR /F "delims=" %%I IN ('fzy.exe ^< %ENHANCD_LOG%.reversed') DO (
		CD /D %%I
	)
) ELSE IF "%~1" == "." (
	FOR /F "delims=" %%I IN ('DIR /AD /B ^| fzy.exe') DO (
		CD /D %%I
	)
) ELSE (
	FOR /F "delims=" %%I IN ('fzy.exe -e "%*" ^< %ENHANCD_LOG%.reversed ^| fzy.exe') DO (
		CD /D %%I
	)
)

GOTO :AFTER_CD


:AFTER_CD
REM FOR /F "delims=" %%I IN ('DIR /AD /B') DO (
REM 	CALL :ADD_LINE_TO_LOG %__CD__%%%I
REM )

FOR /F "delims=" %%I IN ('CD') DO SET ENHANCD_CD=%%I
CALL :ADD_LINE_TO_LOG %ENHANCD_CD%
SET ENHANCD_CD=
EXIT /B


:ADD_LINE_TO_LOG
	CALL :ADD_LINE %* > %ENHANCD_LOG%.tmp
	MOVE /Y %ENHANCD_LOG%.tmp %ENHANCD_LOG%>NUL
	EXIT /B


:ADD_LINE
	FOR /F "usebackq delims=" %%I IN ("%ENHANCD_LOG%") DO (
		IF NOT "%%I" == "%*" ECHO %%I
	)
	ECHO %*
	EXIT /B


:GENERATE_REVERSE_LOG
	REM Algorithm from https://superuser.com/questions/583262/how-to-reverse-text-file-in-windows

	SETLOCAL ENABLEDELAYEDEXPANSION
	TYPE NUL > %ENHANCD_LOG%.reversed

	SET I=0
	FOR /F "delims=" %%J IN (%ENHANCD_LOG%) DO (
		SET /A I=!I! + 1
		SET LINE!I!=%%J
	)

	FOR /L %%C IN (!I!,-1,1) DO (
		ECHO !LINE%%C!>> %ENHANCD_LOG%.reversed
	)

	ENDLOCAL
	EXIT /B


REM :RELATIVE_PATH
REM 	SETLOCAL
REM 	FOR /F "usebackq delims=" %%I IN ("%ENHANCD_LOG%") DO (
REM 		SET ENHANCD_LINE=%%I
REM 		ECHO %ENHANCD_LINE:%__CD__%=%
REM 	)
REM 	ENDLOCAL
REM 	EXIT /B
