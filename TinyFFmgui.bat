@echo off

setlocal EnableDelayedExpansion
color 0F
title TinyFFmgui v1.0
set cdir=%~dp0
cls
if not exist "!cdir!ffmpeg.exe" (goto missing)
if not exist "!cdir!preferences.bat" (goto genpref)
call "!cdir!preferences.bat"
if not "%1"=="" (
    set folderInput=%1
    for %%i in ("!folderInput!") do (
        set folder=%%~dpi
    )
    for %%a in ("!folderInput!") do (
        set fileInput=%%~nxa
    )
    set folderOutput=!folder!FF!fileInput!
)
if not !folderOverlay! == False (
    for %%a in ("!folderOverlay!") do (
        set videoOverlay=%%~nxa
    )
) else (set videoOverlay=False)
for %%a in ("!folderInput!") do (
    set fileInput=%%~nxa
)
for %%a in ("!folderOutput!") do (
    set fileOutput=%%~nxa
)

:main
mode con: cols=40 lines=29
echo.
echo                TinyFFmgui
echo ________________________________________
echo.
echo  -- Video
echo [VR] Video resolution: !videoWidth! x !videoHeight!
echo [VF] Video framerate: !videoFramerate! FPS
echo [VB] Video bitrate: !videoBitrate! kbps
echo [VO] Video overlay: !videoOverlay!
echo [VC] Video codec: !videoCodec!
echo.
echo  -- Audio
echo [AP] Audio playback: !audioPlayback!
echo [AB] Audio bitrate: !audioBitrate! kbps
echo [AC] Audio codec: !audioCodec!
echo.
echo  -- General
if not !trimStart! == False (
    echo [T] Trim: !trimStart! to !trimEnd!
) else (
    echo [T] Trim: False
)
echo [S] Speed: x!speed!
echo [P] Preset: !preset!
echo.
echo  -- File
echo [I] Input: !fileInput!
echo [O] Output: !fileOutput!
echo.
echo [X] START
echo.
echo.
set /p option="> "

mode con: cols=40 lines=12
echo.
echo                TinyFFmgui
echo ________________________________________
echo.
goto !option!

:vr
echo Current resolution: !videoWidth! x !videoHeight!
echo.
set /p videoWidth="Set width: "
set /p videoHeight="Set height: "
goto main

:vf
echo Current framerate: !videoFramerate! FPS
echo.
set /p videoFramerate="Set framerate: "
goto main

:vb
echo Current bitrate: !videoBitrate! kbps
echo.
set /p videoBitrate="Set bitrate: "
goto main

:vo
echo Current overlay file: !videoOverlay!
echo.
echo [Set to False to disable]
echo.
echo Set full directory of overlay:
set /p folderOverlay="> "
if not !folderOverlay! == False (
    for %%a in ("!folderOverlay!") do (
        set videoOverlay=%%~nxa
    )
) else (set videoOverlay=False)
goto main

:vc
echo Current video codec: !videoCodec!
echo.
echo [You can check your supported
echo codecs by running ffmpeg -codecs]
echo.
set /p videoCodec="Set video codec: "
goto main

:ap
echo Audio playback: !audioPlayback!
echo.
echo [Enable/Disable with True/False]
echo.
set /p audioPlayback="Audio playback: "
goto main

:ab
echo Current audio bitrate: !audioBitrate! kbps
echo.
set /p audioBitrate="Set audio bitrate: "
goto main

:ac
echo Current audio codec: !audioCodec!
echo.
echo [You can check your supported
echo codecs by running ffmpeg -codecs]
echo.
set /p audioCodec="Set audio codec: "
goto main

:t
if not !trimStart! == False (
    echo Current trimming: !trimStart! to !trimEnd!
) else (
    echo Current trimming: False
)
echo.
echo [You can disable trimming by
echo setting it to False]
echo.
set /p trimStart="Set start of trim: "
if !trimStart! == False (goto main)
set /p trimEnd="Set end of trim: "
goto main

:s
echo Current speed: !speed!
echo.
set /p speed="Set speed: "
goto main

:p
echo Current preset: !preset!
echo.
set /p preset="Set preset: "
goto main

:i
echo Current file input: !fileInput!
echo.
echo Set full directory of input:
set /p folderInput="> "
for %%a in ("!folderInput!") do (
    set fileInput=%%~nxa
)
goto main

:o
echo Current file output: !fileOutput!
echo.
echo Set full directory of output:
set /p folderOutput="> "
for %%a in ("!folderOutput!") do (
    set fileOutput=%%~nxa
)
goto main

:x
cls
(
    echo @echo off
    echo set videoWidth=!videoWidth!
    echo set videoHeight=!videoHeight!
    echo set videoFramerate=!videoFramerate!
    echo set videoBitrate=!videoBitrate!
    echo set folderOverlay=!videoOverlay!
    echo set videoCodec=!videoCodec!
    echo set audioPlayback=!audioPlayback!
    echo set audioBitrate=!audioBitrate!
    echo set audioCodec=!audioCodec!
    echo set trimStart=!trimStart!
    echo set trimEnd=!trimEnd!
    echo set speed=!speed!
    echo set preset=!preset!
    echo set folderInput=!folderInput!
    echo set folderOutput=!folderOutput!
) > "!cdir!preferences.bat"

if not !folderOverlay! == False (
    set fVideoOverlay=-i "!folderOverlay!" -filter_complex "[1:v]scale2ref=w=iw:h=ih[ovrl][base];[base][ovrl]overlay=x=0:y=0,fps=!videoFramerate!,setpts=PTS/!speed!"
) else (set fVideoOverlay=-vf "fps=!videoFramerate!,setpts=PTS/!speed!")
if not !audioPlayback! == False (
    set fAudio=-c:a !audioCodec! -af "atempo=!speed!" -b:a !audioBitrate!k
) else (set fAudio=-an)
if not !trimStart! == False (
    set fTrim=-ss !trimStart! -to !trimEnd!
) else (set fTrim=)

start "FFmpeg" cmd /c ""!cdir!ffmpeg.exe" -i "!folderInput!" !fVideoOverlay! -s !videoWidth!:!videoHeight! !fTrim! -preset !preset! -b:v !videoBitrate!k !fAudio! -an !folderOutput!"

goto main



:missing
mode con: cols=40 lines=15
echo.
echo                TinyFFmgui
echo ________________________________________
echo.
echo    Seems like you're missing FFmpeg.
echo.
echo    You need to put ffmpeg.exe in the
echo    current folder.
echo.
echo    If you're missing FFmpeg entirely,
echo    you get a prebuilt binary from
echo    thier official site:
echo.
echo    https://ffmpeg.org/download.html
pause > nul
exit

:genpref
mode con: cols=15 lines=1
(
    echo @echo off
    echo set videoWidth=1280
    echo set videoHeight=720
    echo set videoFramerate=30
    echo set videoBitrate=4096
    echo set folderOverlay=False
    echo set videoCodec=h264
    echo set audioPlayback=True
    echo set audioBitrate=512
    echo set audioCodec=libopus
    echo set trimStart=False
    echo set speed=1
    echo set preset=fast
    echo set folderInput=!cdir!input.mp4
    echo set folderOutput=!cdir!output.mp4
) > "!cdir!preferences.bat"
call "!cdir!preferences.bat"
set videoOverlay=False
for %%a in ("!folderInput!") do (
    set fileInput=%%~nxa
)
for %%a in ("!folderOutput!") do (
    set fileOutput=%%~nxa
)
goto main