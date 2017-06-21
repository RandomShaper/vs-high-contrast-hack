@echo off

rem
rem ------------------------------------------------------------
rem
rem Copyright 2017 Pedro J. Estébanez
rem
rem Permission is hereby granted, free of charge, to any person obtaining a copy of this software
rem and associated documentation files (the "Software"), to deal in the Software without restriction,
rem including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
rem and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
rem subject to the following conditions:
rem 
rem The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
rem 
rem THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
rem INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
rem PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
rem FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
rem ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
rem
rem ------------------------------------------------------------
rem

rem
rem Visual Studio 2017, as happens with earlier versions, forces their high contrast theme in Windows is under a high contrast theme as well.
rem Microsoft seems not to be interested in fixing it so people have to use certain registry hacks to use Visual Studio's dark theme.
rem Before the 2017 release, Visual Studio settings were right in the registry and you could do the hack by hand more or less easily.
rem
rem A first problem with that is under some circumstances (for instance, after updates) the theme setting switches back to the high contrast theme
rem and you have to re-apply the hack by hand. Another problem is that from the 2017 release the registry settings have been moved to a hive file
rem so you have first to load it into the global registry, rem do the hack and unload it again.
rem
rem The purpose of this program is to apply the hack for Visual Studio 2017 automatically. It makes a backup of the key containing
rem the high contrast theme to a new key with '.backup' appended and copies the dark theme key recursively over that of the high contrast one.
rem It first checks if the backup is already present to avoid overwriting it with the already-tampered data.
rem

rem
rem Credits to Chris Shrigley for his post on this: http://shrigley.com/visual-studio-2017-high-contrast-theme-registry-hack/
rem
rem In case this program evolves, you can find the latest version at https://github.com/RandomShaper/vs-high-contrast-hack
rem
rem THIS SCRIPT MUST BE RUN WITH ADMINISTRATIVE PRIVILEGES.
rem

setlocal

if not "%1"=="" goto hack

for /F "delims=" %%i in ('dir %LOCALAPPDATA%\Microsoft\VisualStudio\15.0_* /s/b') do call "%~f0" "%%i"

goto end

:hack

set vs_instance=%~nx1
set tmp_key=HKLM\_tmp_%vs_instance%
set themes_key=%tmp_key%\Software\Microsoft\VisualStudio\%vs_instance%_Config\Themes
set ok=1

echo Working with Visual Studio instance %vs_instance%

echo Loading private registry
reg load %tmp_key% "%~1\privateregistry.bin" > nul
if errorlevel 1 (
	echo Unable to load private registry. Possible cauese:
	echo - Visual Studio is running or has exited a short time ago.
	echo - You are not running this with administrator privileges.
	echo - This program was aborted during a former run; in that case you'll have to use `regedit` to unload the following key manually: %tmp_key%
	goto end
)

reg query %themes_key%\{a5c004b4-2d4b-494e-bf01-45fc492522c7}.backup > nul
if errorlevel 1 (
	echo Backing up high contrast theme
	reg copy %themes_key%\{a5c004b4-2d4b-494e-bf01-45fc492522c7} %themes_key%\{a5c004b4-2d4b-494e-bf01-45fc492522c7}.backup /s > nul
	if errorlevel 1 (
		echo Unable to do the backup.
		set ok=0
		goto unload
	)
) else (
	echo High contrast theme already backed up
)

echo Copying the dark theme over the high contrast theme
reg copy %themes_key%\{1ded0138-47ce-435e-84ef-9ec1f439b749} %themes_key%\{a5c004b4-2d4b-494e-bf01-45fc492522c7} /s /f > nul
if errorlevel 1 (
	echo Unable to make the copy.
	set ok=0
	goto unload
)

:unload
echo Unloading private registry
reg unload %tmp_key% > nul
if errorlevel 1 (
	echo Unable to unload private registry. Probably you'll have to use `regedit` to unload the %tmp_key% key manually.
)

:end

if "%ok%"=="1" echo DONE!
