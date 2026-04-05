@echo off
set "JAVA_HOME=C:\Users\HIRUSHIE\AppData\Local\Programs\Eclipse Adoptium\jdk-21.0.10.7-hotspot"
set "PATH=%JAVA_HOME%\bin;%PATH%"
echo JAVA_HOME set to %JAVA_HOME%
java -version
echo Starting Firebase Emulators...
firebase emulators:start %*
pause
