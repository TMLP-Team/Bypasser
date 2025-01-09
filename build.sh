#!/bin/bash

# Module #
moduleName="Bypasser"
moduleVersion=`date +%Y%m%d%H`
moduleFolderPath="$PWD"
if [[ `basename $moduleFolderPath` == $moduleName ]]; then
	echo "Welcome to the builder for the ``$moduleName`` Magisk Module! "
else
	echo "The shell script is working in a wrong working directory. "
	exit 1
fi

# Pack #
srcFolderPath="src"
zipFolderPath="./Release"
zipFileName="${moduleName}_v${moduleVersion}.zip"
zipFilePath="$zipFolderPath/$zipFileName"
if [ -d "$srcFolderPath" ]; then
	if [ ! -d "$zipFolderPath" ]; then
		mkdir -p "$zipFolderPath"
	fi
	if [ -d "$zipFolderPath" ]; then
		echo "zip -9 -T -j -ll -r -v \"$zipFilePath\" \"$srcFolderPath\""
		zip -9 -T -j -ll -r -v "$zipFilePath" "$srcFolderPath"
		if [[ 0 == $? && -e "$zipFilePath" ]]; then
			echo "Successfully packed the ${moduleName} Magisk module to \"$zipFilePath\"! "
		else
			echo "Failed to pack the ${moduleName} Magisk module to \"$zipFilePath\". "
			exit 2
		fi
	else
		echo "Failed to create the zip folder path \"$zipFolderPath\". "
		exit 3
	fi
else
	echo "No source files are found to be packed. "
	exit 4
fi

# Log #
changelogFolderPath="Changelog"
changelogFileName="Changelog_v${moduleVersion}.log"
changelogFilePath="$changelogFolderPath/$changelogFileName"
if [ ! -d "$changelogFolderPath" ]; then
	mkdir -p "$changelogFolderPath"
fi
if [ -d "$changelogFolderPath" ]; then
	echo -e "# Changelog_v${moduleVersion}\n" > "$changelogFilePath"
	if [[ 0 == $? && -e "$changelogFilePath" ]]; then
		if [[ $# -ge 1 ]]; then
			for arg in "$@"
			do
				echo "$arg" >> "$changelogFilePath"
			done
		else
			echo "Please write down your changelog: "
			read changelog
			echo "$changelog" >> "$changelogFilePath"
		fi
		if [[ 0 == $? && -e "$changelogFilePath" ]]; then
			echo "Successfully wrote the change log to \"$changelogFilePath\". "
			exit 0
		else
			echo "Failed to write the change log to \"$changelogFilePath\". "
			exit 5
		fi
	else
		echo "Failed to create the log \"$changelogFilePath\". "
		exit 6
	fi
else
	echo "Failed to create the log folder path \"$changelogFolderPath\". "
	exit 7
fi

