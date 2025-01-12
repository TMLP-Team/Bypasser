#!/system/bin/sh
# Welcome #
EXIT_SUCCESS=0
EXIT_FAILURE=1
EOF=255
exitCode=0
moduleName="Bypasser"
echo "Welcome to the \`\`action.sh\`\` of the ${moduleName} Magisk Module! "
echo ""

function cleanCache()
{
	sync
	echo 3 > /proc/sys/vm/drop_caches
	return 0
}

cleanCache

# HMA/HMAL (0b00000XX) #
blacklistName="Blacklist"
whitelistName="Whitelist"
configFolderPath="/sdcard/Download"
blacklistConfigFileName=".HMAL_Blacklist_Config.json"
blacklistConfigFilePath="${configFolderPath}/${blacklistConfigFileName}"
whitelistConfigFileName=".HMAL_Whitelist_Config.json"
whitelistConfigFilePath="${configFolderPath}/${whitelistConfigFileName}"

function getType()
{
	if [[ "B" == "$1" || "C" == "$1" || "D" == "$1" ]];
	then
		arr=$(curl -s "https://raw.githubusercontent.com/TMLP-Team/Bypasser/main/Classification/classification$1.txt" | sort | uniq)
		if [[ $? == ${EXIT_SUCCESS} ]];
		then
			for pkg in $arr
			do
				if echo "${pkg}" | grep -qE '^[A-Za-z][0-9A-Za-z_]*(\.[A-Za-z][0-9A-Za-z_]*)+$';
				then
					echo "${pkg}"
				fi
			done
			return ${EXIT_SUCCESS}
		else
			return $?
		fi
	else
		return ${EOF}
	fi
}

function getArray()
{
	content=""
	arr=$(echo "$@" | sort | uniq)
	for package in ${arr}
	do
		content="${content}\"${package}\","
	done
	if [[ "${content}" == *, ]];
	then
		content=${content%,}
		echo ${content}
		return ${EXIT_SUCCESS}
	else
		echo ${content}
		return ${EXIT_FAILURE}
	fi
}	

function getBlacklistScopeString()
{
	content=""
	for package in "$@"
	do
		content="${content}\"${package}\":{\"useWhitelist\":false,\"excludeSystemApps\":false,\"applyTemplates\":[\"${blacklistName}\"],\"extraAppList\":[]},"
	done
	if [[ "${content}" == *, ]]; then
		content=${content%,}
		echo ${content}
		return ${EXIT_SUCCESS}
	else
		echo ${content}
		return ${EXIT_FAILURE}
	fi
}

function getWhitelistScopeStringC()
{
	content=""
	for package in "$@"
	do
		content="${content}\"${package}\":{\"useWhitelist\":true,\"excludeSystemApps\":true,\"applyTemplates\":[\"${whitelistName}\"],\"extraAppList\":[\"${package}\"]},"
	done
	if [[ "${content}" == *, ]]; then
		content=${content%,}
		echo ${content}
		return ${EXIT_SUCCESS}
	else
		echo ${content}
		return ${EXIT_FAILURE}
	fi
}

function getWhitelistScopeStringD()
{
	content=""
	for package in "$@"
	do
		content="${content}\"${package}\":{\"useWhitelist\":true,\"excludeSystemApps\":true,\"applyTemplates\":[\"${whitelistName}\"],\"extraAppList\":[]},"
	done
	if [[ "${content}" == *, ]]; then
		content=${content%,}
		echo ${content}
		return ${EXIT_SUCCESS}
	else
		echo ${content}
		return ${EXIT_FAILURE}
	fi
}

classificationB=$(getType "B")
returnCodeB=$?
classificationC=$(getType "C")
returnCodeC=$?
classificationD=$(getType "D")
returnCodeD=$?
if [[ ${returnCodeB} == ${EXIT_SUCCESS} ]];
then
	echo "Successfully fetched $(echo "$classificationB" | wc -l) package name(s) of Type \$B\$. "
else
	echo "Failed to fetch package names of Type \$B\$. "
fi
if [[ ${returnCodeC} == ${EXIT_SUCCESS} ]];
then
	echo "Successfully fetched $(echo "$classificationC" | wc -l) package name(s) of Type \$C\$. "
else
	echo "Failed to fetch package names of Type \$C\$. "
fi
if [[ ${returnCodeD} == ${EXIT_SUCCESS} ]];
then
	echo "Successfully fetched $(echo "$classificationD" | wc -l) package name(s) of Type \$D\$. "
else
	echo "Failed to fetch package names of Type \$D\$. "
fi

if [[ ${returnCodeB} == ${EXIT_SUCCESS} ]];
then
	blacklistAppList=$(getArray ${classificationB})
	if [[ ${returnCodeC} == ${EXIT_SUCCESS} ]];
	then
		whitelistScopeList="$(getWhitelistScopeStringC ${classificationC}),$(getWhitelistScopeStringD ${classificationD})"
	else
		whitelistScopeList=""
	fi
else
	blacklistAppList=""
	whitelistScopeList=""
fi
if [[ ${returnCodeD} == ${EXIT_SUCCESS} ]];
then
	whitelistAppList=$(getArray ${classificationD})
	if [[ ${returnCodeC} == ${EXIT_SUCCESS} ]];
	then
		blacklistScopeList=$(getBlacklistScopeString ${classificationC} ${classificationD})
	else
		blacklistScopeList=""
	fi
else
	whitelistAppList=""
	blacklistScopeList=""
fi
commonConfigContent="{\"configVersion\":90,\"forceMountData\":true,\"templates\":{\"${blacklistName}\":{\"isWhitelist\":false,\"appList\":[${blacklistAppList}]},\"${whitelistName}\":{\"isWhitelist\":true,\"appList\":[${whitelistAppList}]}},"
blacklistConfigContent="${commonConfigContent}\"scope\":{${blacklistScopeList}}}"
whitelistConfigContent="${commonConfigContent}\"scope\":{${whitelistScopeList}}}"

if [[ ! -d "${configFolderPath}" ]];
then
	mkdir -p "${configFolderPath}"
fi
if [[ -d "${configFolderPath}" ]];
then
	echo "Successfully created the folder \"${configFolderPath}\". "
	echo "${blacklistConfigContent}" > "${blacklistConfigFilePath}"
	if [[ ${EXIT_SUCCESS} == ${?} && -e "${blacklistConfigFilePath}" ]];
	then
		echo "Successfully generated the config file \"${blacklistConfigFilePath}\". "
	else
		exitCode=$(expr $exitCode + 1)
		echo "Failed to generate the config file \"${blacklistConfigFilePath}\". "
	fi
	echo "${whitelistConfigContent}" > "${whitelistConfigFilePath}"
	if [[ ${EXIT_SUCCESS} == ${?} && -e "${whitelistConfigFilePath}" ]];
	then
		echo "Successfully generated the config file \"${whitelistConfigFilePath}\". "
	else
		exitCode=$(expr $exitCode + 2)
		echo "Failed to generate the config file \"${whitelistConfigFilePath}\". "
	fi
else
	exitCode=$(expr $exitCode + 3)
	echo "Failed to create the folder \"${configFolderPath}\". "
fi
if [[ -z "${blacklistAppList}" || -z "${blacklistScopeList}" || -z "${whitelistAppList}" || -z "${whitelistScopeList}" ]];
then
	echo "At least one list was empty. Please check the configurations generated before importing. "
fi
echo ""

# Tricky Store (0b000XX00) #
trickyStoreFolderPath="../../tricky_store"
trickyStoreTargetFileName="target.txt"
trickyStoreTargetFilePath="${trickyStoreFolderPath}/${trickyStoreTargetFileName}"
if [[ -e "${trickyStoreFolderPath}" ]];
then
	echo "The tricky store folder was found at \"${trickyStoreFolderPath}\". "
	abortFlag=0
	if [[ -e "${trickyStoreTargetFilePath}" ]];
	then
		echo "The tricky store target file was found at \"${trickyStoreTargetFilePath}\". "
		mv "${trickyStoreTargetFilePath}" "${trickyStoreTargetFilePath}.bak"
		if [[ ${EXIT_SUCCESS} == $? ]];
		then
			echo "Successfully packed the backup. "
		else
			abortFlag=1
			echo "Failed to pack the backup. "
		fi
	else
		echo "No tricky store target files were detected. "
	fi
	if [[ ${EXIT_SUCCESS} == ${abortFlag} ]];
	then
		echo "com.google.android.gms" > "${trickyStoreTargetFilePath}"
		if [[ ${EXIT_SUCCESS} == ${?} && -e "${trickyStoreTargetFilePath}" ]];
		then
			echo "Successfully created the new tricky store target file at \"${trickyStoreTargetFilePath}\". "
			echo  ${classificationB}  ${classificationC}  ${classificationD} | sort | uniq | tr " " "\n" >> "${trickyStoreTargetFilePath}"
			if [[ ${EXIT_SUCCESS} == ${?} && -e "${trickyStoreTargetFilePath}" ]];
			then
				cnt=$(wc -l "${trickyStoreTargetFilePath}")
				echo "Successfully wrote $cnt target(s) to \"${trickyStoreTargetFilePath}\". "
			else
				exitCode=$(expr $exitCode + 4)
				echo "Failed to write to \"${trickyStoreTargetFilePath}\". "
			fi
		else
			exitCode=$(expr $exitCode + 8)
			echo "Failed to create the new tricky store target file at \"${trickyStoreTargetFilePath}\". "
			if [[ -e "${trickyStoreTargetFilePath}.bak" ]];
			then
				mv "${trickyStoreTargetFilePath}.bak" "${trickyStoreTargetFilePath}"
				if [[ ${EXIT_SUCCESS} == ${?} && -e "${trickyStoreTargetFilePath}" ]];
				then
					echo "Successfully restore the file. "
				else
					echo "Failed to restore the file. "
				fi
			fi
		fi
	fi
else
	exitCode=$(expr $exitCode + 12)
	echo "No tricky store folders were detected. "
fi
echo ""

# Shamiko (0b00X0000) #
shamikoInstallationFolderPath="../shamiko"
shamikoConfigFolderPath="/data/adb/shamiko"
shamikoWhitelistConfigFileName="whitelist"
shamikoWhitelistConfigFilePath="${shamikoConfigFolderPath}/${shamikoWhitelistConfigFileName}"
if [[ -d "${shamikoInstallationFolderPath}" ]];
then
	echo "The shamiko installation folder was found at \"${shamikoInstallationFolderPath}\". "
	if [[ ! -d "${shamikoConfigFolderPath}" || -z "$(ls -1A "${shamikoConfigFolderPath}")" ]]; then
	then
		echo "The shamiko configuration folder at \"${shamikoConfigFolderPath}\" did not exist or was detected to be empty. "
		touch "${shamikoWhitelistConfigFilePath}"
		if [[ ${EXIT_SUCCESS} == ${?} && -e "${shamikoWhitelistConfigFilePath}" ]];
		then
			echo "Successfully created the whitelist config file \"${shamikoWhitelistConfigFilePath}\". "
		else
			echo "Failed to create the whitelist config file \"${shamikoWhitelistConfigFilePath}\". "
			exitCode=$(expr $exitCode + 16)
		fi
	else
		echo "The shamiko configuration folder at \"${shamikoConfigFolderPath}\" was detected not to be empty. "
	fi
else
	echo "No shamiko installation folders were found. "
fi

# Update (0bXX00000) #
shellContent=$(curl -s "https://raw.githubusercontent.com/TMLP-Team/Bypasser/main/src/action.sh")
if [[ ${EXIT_SUCCESS} == ${?} && ! -z "${shellContent}" ]];
then
	echo "Successfully fetched the latest \`\`action.sh\`\` from GitHub. "
	cp -fp "${0}" "${0}.bak"
	if [[ ${EXIT_SUCCESS} == ${?} && -e "${0}.bak" ]];
	then
		echo "Successfully copied \`\`action.sh\`\` to \`\`action.sh.bak\`\`. "
		echo "${shellContent}" > "${0}"
		if [[ ${EXIT_SUCCESS} == ${?} ]];
		then
			echo "Successfully updated \`\`action.sh\`\`. "
		else
			exitCode=$(expr $exitCode + 32)
			echo "Failed to update \`\`action.sh\`\`. "
		fi
	else
		exitCode=$(expr $exitCode + 64)
		echo "Failed to copy \`\`action.sh\`\` to \`\`action.sh.bak\`\`. "
	fi
else
	exitCode=$(expr $exitCode + 96)
	echo "Failed to fetch the latest \`\`action.sh\`\` from GitHub. "
fi

# Exit #
cleanCache
echo "Finished executing the \`\`action.sh\`\` (${exitCode}). "
exit ${exitCode}
