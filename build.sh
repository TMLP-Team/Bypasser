#!/system/bin/sh
moduleName=Bypasser
moduleVersion=`date +%Y%m%d%H`
folderName=src
fileName="../Release/${moduleName}_v${moduleVersion}.zip"
cd "$folderName"
zip -r "$fileName" *
exit 0
