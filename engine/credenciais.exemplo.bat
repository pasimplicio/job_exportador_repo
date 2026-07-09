@echo off
REM ===================================================================
REM MODELO DE CREDENCIAIS
REM
REM Copie este arquivo para "credenciais.bat" no mesmo diretorio e
REM preencha com os valores reais. O credenciais.bat e ignorado pelo
REM Git e nunca deve ser versionado.
REM
REM     copy engine\credenciais.exemplo.bat engine\credenciais.bat
REM ===================================================================

set "JDBC_URL=jdbc:postgresql://SERVIDOR:5432/BANCO"
set "DB_USER=USUARIO"
set "DB_PASS=SENHA"
