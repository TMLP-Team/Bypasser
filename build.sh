#!/bin/bash
# Module #
moduleName="Bypasser"
moduleId="bypasser"
moduleVersion=`date +%Y%m%d%H`
moduleFolderPath="${PWD}"

if [[ `basename "${moduleFolderPath}"` == "${moduleName}" ]]; then
	echo "Welcome to the builder for the ``${moduleName}`` Magisk Module! "
else
	echo "The shell script is working in a wrong working directory. "
	exit 1
fi

# Pack #
srcFolderPath="src"
propFileName="module.prop"
propFilePath="${srcFolderPath}/${propFileName}"
propContent="id=${moduleId}\n\
name=${moduleName}\n\
version=v${moduleVersion}\n\
versionCode=${moduleVersion}\n\
author=TMLP Team\n\
description=This is a developing Magisk module for bypassing Android environment detection related to TMLP. The abbreviation \"TMLP\" stands for anything related to TWRP, Magisk, LSPosed, and Plugins. \n\
updateJson=https://raw.githubusercontent.com/TMLP-Team/Bypasser/main/Update.json"
zipFolderPath="Release"
zipFileName="${moduleName}_v${moduleVersion}.zip"
zipFilePath="${zipFolderPath}/${zipFileName}"

if [[ -d "${srcFolderPath}" && -d "${srcFolderPath}/META-INF" && -d "${srcFolderPath}/system" ]]; then
	echo "Sources were found to be packed. "
	echo -e "${propContent}" > "${propFilePath}"
	if [[ 0 == $? && -e "${propFilePath}" ]]; then
		echo "Successfully generated the property file \"${propFilePath}\". "
		find "${srcFolderPath}" -type f | while read file;
		do
			echo "$(sha512sum "${file}" | cut -d " " -f1)" > "${file}.sha512"
			if [[ 0 == $? && -e "${file}.sha512" ]];
			then
				echo "Successfully generated the SHA-512 value of \"${file}\". "
			else
				echo "Failed to generate the SHA-512 value of \"${file}\". "
			fi
		done
		if [ ! -d "${zipFolderPath}" ]; then
			mkdir -p "${zipFolderPath}"
		fi
		if [ -d "${zipFolderPath}" ]; then
			echo "Successfully created the ZIP folder path \"${zipFolderPath}\". "
			(cd "${srcFolderPath}" && zip -J -ll -r -v - *) > "${zipFilePath}"
			if [[ 0 == $? && -f "${zipFilePath}" ]]; then
				echo "Successfully packed the ${moduleName} Magisk module to \"${zipFilePath}\" via the ``zip`` command! "
			else
				echo "Failed to pack the ${moduleName} Magisk module to \"${zipFilePath}\" via the ``zip`` command. "
				exit 2
			fi
		else
			echo "Failed to create the ZIP folder path \"${zipFolderPath}\". "
			exit 3
		fi
	else
		echo "Failed to generate the property file \"${propFilePath}\". "
		exit 4
	fi
else
	echo "No sources were found to be packed. "
	exit 5
fi

# Log #
changelogFolderPath="Changelog"
changelogFileName="${moduleName}_v${moduleVersion}.md"
changelogFilePath="${changelogFolderPath}/${changelogFileName}"

if [[ ! -d "${changelogFolderPath}" ]]; then
	mkdir -p "${changelogFolderPath}"
fi
if [[ -d "${changelogFolderPath}" ]]; then
	echo "Successfully created the log folder path \"${changelogFolderPath}\". "
	echo -e "## ${moduleName}_v${moduleVersion}\n" > "${changelogFilePath}"
	if [[ 0 == $? && -f "${changelogFilePath}" ]]; then
		echo "Successfully created the log \"${changelogFilePath}\". "
		if [[ $# -ge 1 ]]; then
			for arg in "$@"
			do
				echo "${arg}" >> "${changelogFilePath}"
			done
		else
			echo "Please write down your changelog: "
			read changelog
			echo "${changelog}" >> "${changelogFilePath}"
		fi
		if [[ 0 == $? && -f "${changelogFilePath}" ]]; then
			echo "Successfully wrote the change log to \"${changelogFilePath}\". "
		else
			echo "Failed to write the change log to \"${changelogFilePath}\". "
			exit 6
		fi
	else
		echo "Failed to create the log \"${changelogFilePath}\". "
		exit 7
	fi
else
	echo "Failed to create the log folder path \"${changelogFolderPath}\". "
	exit 8
fi

# Update #
updateFolderPath="."
updateFileName="Update.json"
updateFilePath="${updateFolderPath}/${updateFileName}"
updateContent="{\n\
	\"version\":\"v${moduleVersion}\", \n\
	\"versionCode\":${moduleVersion}, \n\
	\"zipUrl\":\"https://raw.githubusercontent.com/TMLP-Team/Bypasser/main/${zipFilePath}\", \n\
	\"changelog\":\"https://raw.githubusercontent.com/TMLP-Team/Bypasser/main/${changelogFilePath}\"\n\
}"
if [[ ! -d "${updateFolderPath}" ]]; then
	mkdir -p "${updateFolderPath}"
fi
if [[ -d "${updateFolderPath}" ]]; then
	echo "Successfully created the update folder path \"${updateFolderPath}\". "
	echo -e "$updateContent" > "${updateFilePath}"
	if [[ 0 == $? && -f "${updateFilePath}" ]]; then
		echo "Successfully created the update JSON file \"${updateFilePath}\". "
	else
		echo "Failed to create the update JSON file \"${updateFilePath}\". "
		exit 9
	fi
else
	echo "Failed to create the update folder path \"${updateFolderPath}\". "
	exit 10
fi

# Git #
git add . && git commit -m "Update (${moduleVersion})" && git push
if [[ 0 == $? ]]; then
	echo "Successfully pushed to GitHub. "
else
	echo "Failed to push to GitHub. "
	exit 11
fi

# Exit #
exit 0
