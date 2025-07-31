@echo off
setlocal enabledelayedexpansion

REM SonarQube Docker镜像构建脚本 (Windows版本)

REM 默认值
set IMAGE_NAME=zgsonarqube
set TAG=latest
set PUSH=false

REM 显示帮助信息
if "%1"=="-h" goto show_help
if "%1"=="--help" goto show_help

REM 解析命令行参数
:parse_args
if "%1"=="" goto build_image
if "%1"=="-n" (
    set IMAGE_NAME=%2
    shift
    shift
    goto parse_args
)
if "%1"=="--name" (
    set IMAGE_NAME=%2
    shift
    shift
    goto parse_args
)
if "%1"=="-t" (
    set TAG=%2
    shift
    shift
    goto parse_args
)
if "%1"=="--tag" (
    set TAG=%2
    shift
    shift
    goto parse_args
)
if "%1"=="-p" (
    set PUSH=true
    shift
    goto parse_args
)
if "%1"=="--push" (
    set PUSH=true
    shift
    goto parse_args
)
shift
goto parse_args

:show_help
echo 用法: %0 [选项]
echo.
echo 选项:
echo   -n, --name NAME     镜像名称 (默认: zgsonarqube)
echo   -t, --tag TAG       镜像标签 (默认: latest)
echo   -p, --push          构建后推送到仓库
echo   -h, --help          显示此帮助信息
echo.
echo 示例:
echo   %0                    # 构建默认镜像
echo   %0 -n my-zgsonar -t v1.0  # 构建自定义名称和标签的镜像
echo   %0 -p                 # 构建并推送镜像
goto end

:build_image
set FULL_IMAGE_NAME=%IMAGE_NAME%:%TAG%

echo 开始构建SonarQube Docker镜像...
echo 镜像名称: %FULL_IMAGE_NAME%

REM 检查Docker是否安装
docker --version >nul 2>&1
if errorlevel 1 (
    echo 错误: Docker未安装或不在PATH中
    exit /b 1
)

REM 检查Docker是否运行
docker info >nul 2>&1
if errorlevel 1 (
    echo 错误: Docker守护进程未运行
    exit /b 1
)

REM 构建镜像
echo 构建Docker镜像...
docker build -t "%FULL_IMAGE_NAME%" .

if errorlevel 1 (
    echo 镜像构建失败!
    exit /b 1
)

echo 镜像构建成功!

REM 显示镜像信息
echo 镜像信息:
docker images "%FULL_IMAGE_NAME%"

if "%PUSH%"=="true" (
    echo 推送镜像到仓库...
    docker push "%FULL_IMAGE_NAME%"
    if errorlevel 1 (
        echo 镜像推送失败!
        exit /b 1
    )
    echo 镜像推送成功!
)

echo 构建完成!
echo 运行命令:
echo   docker run -p 9000:9000 %FULL_IMAGE_NAME%
echo   或使用docker-compose:
echo   docker-compose up -d

:end 