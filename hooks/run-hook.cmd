: << 'CMDBLOCK'
@echo off
REM Cross-platform polyglot wrapper for hook scripts.
REM On Windows: cmd.exe runs the batch portion, which finds and calls bash.
REM On Unix: the shell interprets this as a script (: is a no-op in bash).
REM
REM Hook scripts use extensionless filenames (e.g. "session-start" not
REM "session-start.sh") so Claude Code's Windows auto-detection -- which
REM prepends "bash" to any command containing .sh -- doesn't interfere.
REM
REM Adapted from obra/superpowers (MIT).
REM
REM Usage: run-hook.cmd <script-name>

if "%~1"=="" (
    echo run-hook.cmd: missing script name >&2
    exit /b 1
)
if not "%~1"=="session-start" if not "%~1"=="pre-tool-guard" (
    echo run-hook.cmd: invalid script name >&2
    exit /b 1
)
if not "%~2"=="" (
    echo run-hook.cmd: extra arguments are not allowed >&2
    exit /b 1
)

set "HOOK_DIR=%~dp0"
set "BASH_EXE="

REM Only these fixed Git for Windows locations are trusted.
if exist "C:\Program Files\Git\bin\bash.exe" (
    set "BASH_EXE=C:\Program Files\Git\bin\bash.exe"
)
if not defined BASH_EXE if exist "C:\Program Files (x86)\Git\bin\bash.exe" (
    set "BASH_EXE=C:\Program Files (x86)\Git\bin\bash.exe"
)

if not defined BASH_EXE (
    echo run-hook.cmd: trusted Git Bash was not found >&2
    exit /b 1
)

"%BASH_EXE%" "%HOOK_DIR%%~1"
set "CHILD_EXIT=%ERRORLEVEL%"
exit /b %CHILD_EXIT%
CMDBLOCK

# Unix: validate the same allowlist and run through a fixed Bash path.
if [ "$#" -ne 1 ]; then
    printf '%s\n' 'run-hook.cmd: usage is run-hook.cmd <session-start|pre-tool-guard>' >&2
    exit 1
fi
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_NAME="$1"
case "$SCRIPT_NAME" in
    session-start|pre-tool-guard) ;;
    *) printf '%s\n' 'run-hook.cmd: invalid script name' >&2; exit 1 ;;
esac
if [ -x /usr/bin/bash ]; then
    BASH_EXE=/usr/bin/bash
elif [ -x /bin/bash ]; then
    BASH_EXE=/bin/bash
else
    printf '%s\n' 'run-hook.cmd: trusted Bash was not found' >&2
    exit 1
fi
exec "$BASH_EXE" "${SCRIPT_DIR}/${SCRIPT_NAME}"
