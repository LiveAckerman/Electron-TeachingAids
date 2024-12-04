@echo off
setlocal enabledelayedexpansion

rem �̾�ϵͳ���³���

echo ==================begin========================

cls 
::-----------------------------WEB����-----------------------------
:: WEB��Ŀ����·��
set WEB_PROJECT_PATH=D:\ta\teachingAids_web\html\tamm-practical-operation
:: WEB��Ŀ��������
set WEB_SERVER_NAME=nginx
:: WEB���ϴ����ַ
set WEB_BUILD_PATH=http://120.78.201.189:12877/update/teachingAids_web/build.7z
:: WEB�������õ�ַ
set WEB_CONFIG_PATH=http://120.78.201.189:12877/update/teachingAids_web/config.json
:: 7z exe ��װ��·��
set WEB_7zExE_PATH=C:\Program Files\7-Zip\7z.exe
::-----------------------------WEB����-----------------------------
color 0a 
TITLE �̾�ϵͳ���³���

CLS 

echo. 
echo. *** �̾�ϵͳ���³���  -  Levi *** 
echo. 

:MENU 

::*************************************************************************************************************
echo. 
    echo.  [1] ����WEB����  
	echo.  [2] ����WEB����
	echo.  [3] ����WEB����
    echo.  [0] �� �� 
echo. 

set "batch_file=%~f0"

for %%F in ("%batch_file%") do (
    set "filename=%%~nF"
)

set "id="
for /f "tokens=1,2 delims=_" %%a in ("!filename!") do (
    set "id=%%b"
)

IF "%id%"=="1" (GOTO updateWeb)
IF "%id%"=="2" (GOTO reloadNginx)
IF "%id%"=="3" (GOTO updateConfig)
IF "%id%"=="0" EXIT
::*************************************************************************************************************
::����WEB����
:updateWeb 
    call :updateWebProject
    PAUSE 
    EXIT

	
::����WEB����
:updateConfig 
    call :updateConfigFn
    PAUSE 
    EXIT


::����WEB����
:reloadNginx 
    call :reloadNginxServer
    PAUSE 
    EXIT

	
::*************************************************************************************
::�ײ�
::*************************************************************************************
::����WEB����
:updateWebProject
    echo. 
	echo. ----------------------------------------------
	:: �л�·��
	cd /d %WEB_PROJECT_PATH%
	:: ���������ļ�
	xcopy .\static\config.json .\  /Y /C
	:: ����
	echo. ------------------���ڱ���--------------------
	set copy_path=%date:~0,10%
	set NOW_TIME=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%
	xcopy .\* ..\..\web_copy\%copy_path%\%NOW_TIME%\ /E /I /C /Y /F
	echo. --------------�������-%NOW_TIME%--------------
	:: ɾ���ļ���
	rmdir /s /q  .\js .\static
	:: ��ȡԶ�̸��°�
	echo. -------------������ȡԶ�̸��°�---------------
	curl -o "%WEB_PROJECT_PATH%\build.7z" %WEB_BUILD_PATH%
	echo. ------------------��ȡ���--------------------
	echo. ------------------���ڽ�ѹ--------------------
	:: ʹ��7z���н�ѹ
	"%WEB_7zExE_PATH%" x "%WEB_PROJECT_PATH%\build.7z" -o"%WEB_PROJECT_PATH%" -y
	echo. ------------------��ѹ���--------------------
	:: ɾ����ѹ��
	echo. -----------------ɾ����ѹ��-------------------
	del /F /Q .\build.7z 
	:: �滻�����ļ�
	xcopy .\config.json .\static\  /C /Y
	echo. --------------�����ļ��滻�����--------------
	echo. --------------����WEB���������---------------
    goto :eof

::����WEB����
:updateConfigFn
	echo. 
	echo. ----------------------------------------------
	:: �л�·��
	cd /d %WEB_PROJECT_PATH%
	:: ����
	echo. ------------------���ڱ���--------------------
	set copy_path=%date:~0,10%
	set NOW_TIME=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%
	xcopy .\config.json ..\..\web_copy\%copy_path%\%NOW_TIME%\ /C /Y
	echo. --------------�������-%NOW_TIME%--------------
	echo. -------------������ȡԶ�������ļ�--------------
	curl -o "%WEB_PROJECT_PATH%\config.json" %WEB_CONFIG_PATH%
	echo. ------------------��ȡ���--------------------
	:: �滻�����ļ�
	xcopy .\config.json .\static\  /C /Y
	echo. --------------�����ļ��滻�����--------------
	echo. ----------------------------------------------
    goto :eof

::����WEB����
:reloadNginxServer
	echo. 
	echo. ----------------------------------------------
	net session >nul 2>&1
	if %errorLevel% == 0 (
		:: ֹͣ����
		net stop %WEB_SERVER_NAME%
		net start %WEB_SERVER_NAME%
	) else (
		echo. ��ǰ�û�û���Թ���Ա������С�
		echo. ���Ҽ�����������ļ���ѡ�� "�Թ���Ա�������"��
	)
	echo. ----------------------------------------------
    goto :eof