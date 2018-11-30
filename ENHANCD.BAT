@ECHO OFF

IF NOT DEFINED ENHANCD_DIR SET ENHANCD_DIR=%APPDATA%\enhancd
SET ENHANCD_LOG=%ENHANCD_DIR%\enhancd.log

IF NOT EXIST "%ENHANCD_DIR%" MKDIR "%ENHANCD_DIR%"
IF NOT EXIST "%ENHANCD_LOG%" TYPE NUL > "%ENHANCD_LOG%"

IF "%~1" == "" (
	CD /D %USERPROFILE%
	GOTO :AFTER_CD
)

IF NOT "%~1" == "." IF NOT "%~1" == "..." (
	CD %* >NUL 2>&1
	IF NOT ERRORLEVEL 1 GOTO :AFTER_CD
)

IF "%~1" == "." (
	FOR /F "delims=" %%I IN ('DIR /AD /B ^| fzy.exe') DO (
		CD /D %%I
	)
	GOTO :AFTER_CD
)

IF "%~1" == "..." (
	CALL :LIST_PARENTS > "%ENHANCD_DIR%.parents"
	FOR /F "delims=" %%I IN ('fzy.exe ^< "%ENHANCD_DIR%.parents"') DO (
		CD /D %%I
	)
	GOTO :AFTER_CD
)

REM Other methods require reversed log.
CALL :GENERATE_REVERSE_LOG

IF "%~1" == "-" (
	FOR /F "delims=" %%I IN ('fzy.exe ^< "%ENHANCD_LOG%.reversed"') DO (
		CD /D %%I
	)
	GOTO :AFTER_CD
)

REM Filter logs with given argument.
(
	FOR /F "delims=" %%I IN ('fzy.exe -e "%*" ^< "%ENHANCD_LOG%.reversed" ^| fzy.exe') DO (
		CD /D %%I
	)
	GOTO :AFTER_CD
)

:AFTER_CD
FOR /F "delims=" %%I IN ('CD') DO SET ENHANCD_CD=%%I
CALL :ADD_LINE_TO_LOG %ENHANCD_CD%
SET ENHANCD_CD=
EXIT /B


:ADD_LINE_TO_LOG
	CALL :ADD_LINE %* > "%ENHANCD_LOG%.tmp"
	MOVE /Y "%ENHANCD_LOG%.tmp" "%ENHANCD_LOG%">NUL
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
	TYPE NUL > "%ENHANCD_LOG%.reversed"

	SET I=0
	FOR /F "usebackq delims=" %%J IN ("%ENHANCD_LOG%") DO (
		SET /A I=!I! + 1
		SET LINE!I!=%%J
	)

	FOR /F "delims=" %%K IN ('CD') DO (
		FOR /L %%C IN (!I!,-1,1) DO (
				IF NOT "%%~K" == "!LINE%%C!" ECHO !LINE%%C!>> "%ENHANCD_LOG%.reversed"
		)
	)

	ENDLOCAL
	EXIT /B


:LIST_PARENTS
	SETLOCAL
	:LIST_PARENTS_LOOP
	CD ..>NUL 2>&1
	CD
	FOR /F "tokens=1,2 delims=\" %%I IN ("%__CD__%") DO (
		IF NOT "%%~J" == "" GOTO :LIST_PARENTS_LOOP
	)
	ENDLOCAL
	EXIT /B

