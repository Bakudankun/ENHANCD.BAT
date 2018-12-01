@ECHO OFF

IF NOT EXIST "%~dp0ENHANCD.BAT" (
	ECHO ENHANCD.BAT does not exist.1>&2
	EXIT /B 1
)

IF NOT DEFINED ENHANCD_DIR (
	SET ENHANCD_DIR=%APPDATA%\enhancd
	SET ENHANCD_LOG=%APPDATA%\enhancd\enhancd.log
)

IF NOT EXIST "%ENHANCD_DIR%" MKDIR "%ENHANCD_DIR%"
IF NOT EXIST "%ENHANCD_LOG%" TYPE NUL > "%ENHANCD_LOG%"

DOSKEY CD="%~dp0ENHANCD.BAT" $*

