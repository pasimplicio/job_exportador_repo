@echo off
setlocal

REM === CONFIGURACOES ===
set "ROOT_DIR=D:\job_exportador"
set "ENGINE_JAR=%ROOT_DIR%\engine\target\exportador-csv-1.0.0-jar-with-dependencies.jar"
set "COMANDO_FILE=%ROOT_DIR%\comando\COMANDO_FATURAMENTO.csv"

REM === ACESSO BANCO ===
REM Credenciais: veja engine/credenciais.bat (nao versionado).
call "%ROOT_DIR%\engine\credenciais.bat"

REM === JAVA ===
set "JAVA_EXE=%JAVA_HOME%\bin\java.exe"

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
    echo ERRO na execucao do projeto TAXA MINIMA
) else (
    echo.
    echo Projeto TAXA MINIMA gerado com sucesso.
)
endlocal
