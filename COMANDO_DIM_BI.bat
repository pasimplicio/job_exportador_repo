@echo off
setlocal

REM === CONFIGURACOES ===
REM Raiz do projeto: a pasta onde este .bat esta, sem a barra final.
set "ROOT_DIR=%~dp0"
if "%ROOT_DIR:~-1%"=="\" set "ROOT_DIR=%ROOT_DIR:~0,-1%"
set "ENGINE_JAR=%ROOT_DIR%\engine\target\exportador-csv-1.0.0-jar-with-dependencies.jar"

set "COMANDO_FILE=%ROOT_DIR%\comando\COMANDO_DIM_BI.csv"

REM === ACESSO BANCO ===
REM Credenciais: veja engine/credenciais.bat (nao versionado).
call "%ROOT_DIR%\engine\credenciais.bat"

REM === JAVA ===
REM Usa o JAVA_HOME quando existir; senao cai no java do PATH.
if defined JAVA_HOME (
    set "JAVA_EXE=%JAVA_HOME%\bin\java.exe"
) else (
    set "JAVA_EXE=java.exe"
)

echo ROOT_DIR.....: %ROOT_DIR%
echo ENGINE_JAR...: %ENGINE_JAR%
echo COMANDO_FILE.: %COMANDO_FILE%
echo JDBC_URL.....: %JDBC_URL%
echo JAVA_EXE.....: %JAVA_EXE%
echo.

REM === EXECUCAO ===
"%JAVA_EXE%" -jar "%ENGINE_JAR%" ^
 "%JDBC_URL%" ^
 "%DB_USER%" ^
 "%DB_PASS%" ^
 "%ROOT_DIR%" ^
 "%COMANDO_FILE%"

if errorlevel 1 (
    echo.
    echo ERRO na execucao do projeto COMANDO_DIM_BI
) else (
    echo.
    echo Projeto COMANDO_DIM_BI gerado com sucesso.
)
endlocal
