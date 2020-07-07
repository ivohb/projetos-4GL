REM #####Criado por Alessandro Munerato### 29/06/2012
@echo off
title Menu eficiente
color 0A
:Inicio
cls
echo ROTINA DE ATUALIZACAO DO REPOSITORIO
echo Escolha uma opcao!
echo.
echo 1 - Atualizar Logix PRODUCAO
echo 2 - Atualizar Logix TESTE
echo 99 - Volta RPO 
echo 00 - Sair 
echo.
set /p Comando=Digite sua opcão..::
if "%Comando%" equ "1" (goto:logixprd)
if "%Comando%" equ "2" (goto:logixtst)
if "%Comando%" equ "99" (goto:voltarpo)
if "%Comando%" equ "00" (goto:exit)
msg * OPCAO INVALIDA!
goto:Inicio

:LOGIXPRD
P:
cd \totvs\logix\bin\appserver_01
echo.
echo  Sua Pasta para o ambiente PRODUCAO atual:
echo.
type totvsappserver.ini | find "apo\prd"
echo.
echo Faca as Atualizacoes pelo LogixUpdate ou TotvsDevStudio depois tecle ENTER.
pause>nul
echo.
echo Foram feitas as atualizacoes no Repositorio? Tecle ENTER para continuar.
pause>nul
title Criando pasta para o PRODUCAO 
for /F "tokens=1-3 delims=/" %%A in ('echo %date%') do set VAR_TIME=%%C-%%B-%%A
for /F "tokens=1-3 delims=:" %%A in ('echo %time%') do set FOLDER_NAME=%VAR_TIME%-%%A%%B
mkdir D:\totvs\logix\apo\prd\%FOLDER_NAME%

for /F "tokens=1-3 delims=:" %%A in ('echo %time%') do xcopy D:\totvs\logix\apo\atu_prd\lgxp102.rpo D:\totvs\logix\apo\prd\%FOLDER_NAME%
echo.
echo  Sua Nova Pasta para o ambiente PRODUCAO:
echo.
echo D:\totvs\logix\apo\prd\%FOLDER_NAME%
echo.
echo Digite ENTER para selecionar a nova pasta do Repositorio.
pause>nul
start D:\totvs\logix\bin\updatetotvsini.exe
echo.
echo Digite ENTER Para Sair.
pause>nul
EXIT

:LOGIXTST
P:
cd \totvs\logix\bin\appserver_01
echo.
echo  Sua Pasta para o ambiente TESTE atual:
echo.
type totvsappserver.ini | find "apo\tst"
echo.
echo Faca as Atualizacoes pelo LogixUpdate ou TotvsDevStudio depois tecle ENTER.
pause>nul
echo.
echo Foram feitas as atualizacoes no Repositorio? Tecle ENTER para continuar.
pause>nul
title Criando pasta para o TESTE
for /F "tokens=1-3 delims=/" %%A in ('echo %date%') do set VAR_TIME=%%C-%%B-%%A
for /F "tokens=1-3 delims=:" %%A in ('echo %time%') do set FOLDER_NAME=%VAR_TIME%-%%A%%B
mkdir D:\totvs\logix\apo\tst\%FOLDER_NAME%

for /F "tokens=1-3 delims=:" %%A in ('echo %time%') do xcopy D:\totvs\logix\apo\atu_tst\lgxp102.rpo D:\totvs\logix\apo\tst\%FOLDER_NAME%
echo.
echo  Sua Nova Pasta para o ambiente TESTE:
echo.
echo D:\totvs\logix\apo\tst\%FOLDER_NAME%
echo.
echo Digite ENTER para selecionar a nova pasta do Repositorio.
pause>nul
start D:\totvs\logix\bin\updatetotvsini.exe
echo.
echo Digite ENTER Para Sair.
pause>nul
EXIT

:VOLTARPO
title Abrindo... Bloco de Notas
cls
start D:\totvs\logix\bin\updatetotvsini.exe
echo.
echo Digite ENTER Para Sair.
pause>nul
exit

:EXIT
title Saindo
echo.
echo Digite ENTER Para Sair.
pause>nul
echo Saindo....
cls
exit