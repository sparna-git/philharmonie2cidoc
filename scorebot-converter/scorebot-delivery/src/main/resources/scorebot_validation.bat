@echo off

set DIR_HOME=%CD%

echo inputs

:: Source
set SHACL_DIR=%DIR_HOME%\shacl
set RDF_DIR=%DIR_HOME%\output
set DIR_OUTPUT=%DIR_HOME%\output-validation

:: créer les dossiers s'ils n'existent pas.
mkdir %DIR_OUTPUT%

:: Nettoyer les dosiers des fichiers à valider
del %DIR_OUTPUT%\*.ttl
del %DIR_OUTPUT%\*.html
del %DIR_OUTPUT%\*.log

echo ###
echo ### Validation des data et Generation du rapport
echo ###

java -Xmx4048M -jar %DIR_HOME%\shacl-play-app-0.6.2-onejar.jar validate -i %RDF_DIR% -s %SHACL_DIR%\scorebot-shacl.ttl -o %DIR_OUTPUT%\scorebot_validation-report.ttl -o %DIR_OUTPUT%\scorebot_validation-report.html > %DIR_OUTPUT%\scorebot_validation-log.log

echo ###
echo ### Fin
echo ###