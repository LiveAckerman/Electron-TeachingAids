@echo off
setlocal enabledelayedexpansion

rem 教具系统更新程序

echo ==================begin========================

cls 
::-----------------------------WEB配置-----------------------------
:: WEB项目所在路径
set WEB_PROJECT_PATH=D:\ta\teachingAids_web\html\tamm-practical-operation
:: WEB项目服务名称
set WEB_SERVER_NAME=nginx
:: WEB线上打包地址
set WEB_BUILD_PATH=http://120.78.201.189:12877/update/teachingAids_web/build.7z
:: WEB线上配置地址
set WEB_CONFIG_PATH=http://120.78.201.189:12877/update/teachingAids_web/config.json
:: 7z exe 安装包路径
set WEB_7zExE_PATH=C:\Program Files\7-Zip\7z.exe
::-----------------------------WEB配置-----------------------------
color 0a 
TITLE 教具系统更新程序

CLS 

echo. 
echo. *** 教具系统更新程序  -  Levi *** 
echo. 

:MENU 

::*************************************************************************************************************
echo. 
    echo.  [1] 更新WEB程序  
	echo.  [2] 重启WEB服务
	echo.  [3] 更新WEB配置
    echo.  [0] 退 出 
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
::更新WEB程序
:updateWeb 
    call :updateWebProject
    PAUSE 
    EXIT

	
::更新WEB配置
:updateConfig 
    call :updateConfigFn
    PAUSE 
    EXIT


::重启WEB服务
:reloadNginx 
    call :reloadNginxServer
    PAUSE 
    EXIT

	
::*************************************************************************************
::底层
::*************************************************************************************
::更新WEB程序
:updateWebProject
    echo. 
	echo. ----------------------------------------------
	:: 切换路径
	cd /d %WEB_PROJECT_PATH%
	:: 复制配置文件
	xcopy .\static\config.json .\  /Y /C
	:: 备份
	echo. ------------------正在备份--------------------
	set copy_path=%date:~0,10%
	set NOW_TIME=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%
	xcopy .\* ..\..\web_copy\%copy_path%\%NOW_TIME%\ /E /I /C /Y /F
	echo. --------------备份完成-%NOW_TIME%--------------
	:: 删除文件夹
	rmdir /s /q  .\js .\static
	:: 拉取远程更新包
	echo. -------------正在拉取远程更新包---------------
	curl -o "%WEB_PROJECT_PATH%\build.7z" %WEB_BUILD_PATH%
	echo. ------------------拉取完成--------------------
	echo. ------------------正在解压--------------------
	:: 使用7z进行解压
	"%WEB_7zExE_PATH%" x "%WEB_PROJECT_PATH%\build.7z" -o"%WEB_PROJECT_PATH%" -y
	echo. ------------------解压完成--------------------
	:: 删除解压包
	echo. -----------------删除解压包-------------------
	del /F /Q .\build.7z 
	:: 替换配置文件
	xcopy .\config.json .\static\  /C /Y
	echo. --------------配置文件替换已完成--------------
	echo. --------------更新WEB程序已完成---------------
    goto :eof

::更新WEB配置
:updateConfigFn
	echo. 
	echo. ----------------------------------------------
	:: 切换路径
	cd /d %WEB_PROJECT_PATH%
	:: 备份
	echo. ------------------正在备份--------------------
	set copy_path=%date:~0,10%
	set NOW_TIME=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%
	xcopy .\config.json ..\..\web_copy\%copy_path%\%NOW_TIME%\ /C /Y
	echo. --------------备份完成-%NOW_TIME%--------------
	echo. -------------正在拉取远程配置文件--------------
	curl -o "%WEB_PROJECT_PATH%\config.json" %WEB_CONFIG_PATH%
	echo. ------------------拉取完成--------------------
	:: 替换配置文件
	xcopy .\config.json .\static\  /C /Y
	echo. --------------配置文件替换已完成--------------
	echo. ----------------------------------------------
    goto :eof

::重启WEB服务
:reloadNginxServer
	echo. 
	echo. ----------------------------------------------
	net session >nul 2>&1
	if %errorLevel% == 0 (
		:: 停止服务
		net stop %WEB_SERVER_NAME%
		net start %WEB_SERVER_NAME%
	) else (
		echo. 当前用户没有以管理员身份运行。
		echo. 请右键点击批处理文件并选择 "以管理员身份运行"。
	)
	echo. ----------------------------------------------
    goto :eof