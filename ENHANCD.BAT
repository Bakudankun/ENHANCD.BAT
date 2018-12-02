@ECHO OFF

IF NOT "%~1" == "" IF NOT "%~1" == "." IF NOT "%~1" == "..." (
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
	CALL :LIST_PARENTS > "%ENHANCD_DIR%.tmp"
	FOR /F "delims=" %%I IN ('fzy.exe ^< "%ENHANCD_DIR%.tmp"') DO (
		CD /D %%I
	)
	GOTO :AFTER_CD
)

IF "%~1" == "-" (
	CALL :LIST_LOG_EXCEPT_CD %ENHANCD_HYPHEN_NUM% > "%ENHANCD_LOG%.tmp"
	FOR /F "delims=" %%I IN ('fzy.exe ^< "%ENHANCD_LOG%.tmp"') DO (
		CD /D %%I
	)
	GOTO :AFTER_CD
)

IF "%~1" == "" (
	CALL :LIST_LOG_EXCEPT_CD > "%ENHANCD_LOG%.tmp"
	FOR /F "delims=" %%I IN ('fzy.exe ^< "%ENHANCD_LOG%.tmp"') DO (
		CD /D %%I
	)
	GOTO :AFTER_CD
)

REM Filter logs with given argument.
(
	FOR /F "delims=" %%I IN ('fzy.exe -e "%*" ^< "%ENHANCD_LOG%.tmp" ^| fzy.exe') DO (
		CD /D %%I
	)
	GOTO :AFTER_CD
)

:AFTER_CD
(
	CD
	ECHO %USERPROFILE%
	TYPE "%ENHANCD_LOG%"
	FOR /D %%I IN (*) DO ECHO %%~fI
	CALL :LIST_PARENTS
) > "%ENHANCD_LOG%.tmp"
CALL :UNIQUE "%ENHANCD_LOG%.tmp" > "%ENHANCD_LOG%"

EXIT /B


:LIST_LOG_EXCEPT_CD
	SETLOCAL ENABLEDELAYEDEXPANSION

	IF "%__CD__:~3%" == "" (
		SET STRING=!__CD__!
	) ELSE (
		SET STRING=!__CD__:~0,-1!
	)
	SET STRING=%STRING:\=\\%

	IF "%1" == "" (
		FINDSTR /X /V /C:"%STRING%" "%ENHANCD_LOG%"
	) ELSE (
		SET LIMIT=%1
		FOR /F "delims=" %%I IN ('FINDSTR /X /V /C:"%STRING%" /C:"%USERPROFILE%" "%ENHANCD_LOG%"') DO (
			IF "!LIMIT!" == "0" GOTO :EOF
			ECHO %%I
			SET /A LIMIT=!LIMIT! - 1
		)
	)

	ENDLOCAL
	EXIT /B


:LIST_PARENTS
	SETLOCAL

	:LIST_PARENTS_LOOP
	CD ..>NUL 2>&1
	CD
	IF NOT "%__CD__:~3%" == "" GOTO :LIST_PARENTS_LOOP

	ENDLOCAL
	EXIT /B


:UNIQUE
	IF DEFINED ENHANCD_AWK (
		"%ENHANCD_AWK%" -v ORS="\r\n" "!x[$0]++" "%~1"
		EXIT /B
	)

	SETLOCAL ENABLEDELAYEDEXPANSION

	SET LINENUM=0
	FOR /F "usebackq delims=" %%I IN ("%~1") DO (
		FOR /L %%J IN (1,1,!LINENUM!) DO (
			IF NOT "!CONTINUE_UNIQUE!" == "1" IF "!LINE%%J!" == "%%I" SET CONTINUE_UNIQUE=1
		)
		IF NOT "!CONTINUE_UNIQUE!" == "1" (
			SET /A LINENUM=!LINENUM! + 1
			SET LINE!LINENUM!=%%I
			ECHO %%I
		)
		SET CONTINUE_UNIQUE=

		IF DEFINED ENHANCD_LOG_MAX IF !LINENUM! GEQ !ENHANCD_LOG_MAX! GOTO :EOF
	)

	ENDLOCAL
	EXIT /B

