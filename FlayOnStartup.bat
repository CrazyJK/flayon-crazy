@echo off
chcp 65001
setlocal

set "JAVA_OPTS=%JAVA_OPTS% -Dcom.sun.management.jmxremote"
set "JAVA_OPTS=%JAVA_OPTS% -Dcom.sun.management.jmxremote.port=58869"
set "JAVA_OPTS=%JAVA_OPTS% -Dcom.sun.management.jmxremote.ssl=false"
set "JAVA_OPTS=%JAVA_OPTS% -Dcom.sun.management.jmxremote.authenticate=false"
set "JAVA_OPTS=%JAVA_OPTS% -Dcom.sun.management.jmxremote.access.file=jmxremote.access"
set "JAVA_OPTS=%JAVA_OPTS% -Dcom.sun.management.jmxremote.password.file=jmxremote.password"
set "JAVA_OPTS=%JAVA_OPTS% -Dfile.encoding=UTF-8"
set "JAVA_OPTS=%JAVA_OPTS% -Dspring.liveBeansView.mbeanDomain"
set "JAVA_OPTS=%JAVA_OPTS% -Dspring.application.admin.enabled=true"
set "JAVA_OPTS=%JAVA_OPTS% -Dspring.profiles.active=crazy-home"
set "JAVA_OPTS=%JAVA_OPTS% -Dsun.stderr.encoding=UTF-8"
set "JAVA_OPTS=%JAVA_OPTS% -Dsun.stdout.encoding=UTF-8"
set "JAVA_OPTS=%JAVA_OPTS% -Dsun.jnu.encoding=UTF-8"

set "CURRENT_DIR=%cd%"
set "FLAYON_HOME=%CURRENT_DIR%"

echo Using FLAYON_HOME:  %FLAYON_HOME%
echo Using   JAVA_HOME:  %JAVA_HOME%
echo Using   JAVA_OPTS:  %JAVA_OPTS%

"%JAVA_HOME%"\bin\java.exe %JAVA_OPTS% -jar "%FLAYON_HOME%\target\flayon-crazy.jar"
