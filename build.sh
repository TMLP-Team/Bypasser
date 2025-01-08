moduleName=Bypasser
moduleVersion=`date +%Y%m%d%H`
folderPath=src
fileName="$moduleName_v$moduleVersion.zip"
zip -r "$fileName" "$folderPath"
exit 0
