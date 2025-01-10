#!/system/bin/sh
# Welcome #
EXIT_SUCCESS=0
EXIT_FAILURE=1
EOF=127
moduleName="Bypasser"
echo "Welcome to the \`\`action.sh\`\` of the ${moduleName} Magisk Module! "

# HMA/HMAL #
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

exitCode=0
if [[ ! -d "${configFolderPath}" ]];
then
	mkdir -p "${configFolderPath}"
fi
if [[ -d "${configFolderPath}" ]];
then
	echo "Successfully created the folder \"${configFolderPath}\". "
	echo "${blacklistConfigContent}" > "${blacklistConfigFilePath}"
	if [[ 0 == ${?} && -e "${blacklistConfigFilePath}" ]];
	then
		echo "Successfully generated the config file \"${blacklistConfigFilePath}\". "
	else
		exitCode=$[exitCode+1]
		echo "Failed to generate the config file \"${blacklistConfigFilePath}\". "
	fi
	echo "${whitelistConfigContent}" > "${whitelistConfigFilePath}"
	if [[ 0 == ${?} && -e "${whitelistConfigFilePath}" ]];
	then
		echo "Successfully generated the config file \"${whitelistConfigFilePath}\". "
	else
		exitCode=$[exitCode+2]
		echo "Failed to generate the config file \"${whitelistConfigFilePath}\". "
	fi
else
	exitCode=$[exitCode+3]
	echo "Failed to create the folder \"${configFolderPath}\". "
fi
echo ""

# Tricky Store #
trickyStoreFolderPath="../../tricky_store"
trickyStoreTargetFileName="target.txt"
trickyStoreTargetFilePath="${trickyStoreFolderPath}/${trickyStoreTargetFileName}"
allAppList=$(getArray ${classificationB} ${classificationC} ${classificationD})
if [[ -e "${trickyStoreFolderPath}" ]];
then
	echo "The tricky store folder was found at \"${trickyStoreFolderPath}\". "
	abortFlag=0
	if [[ -e "${trickyStoreTargetFilePath}" ]];
	then
		echo "The tricky store target file was found at \"${trickyStoreTargetFilePath}\". "
		mv "${trickyStoreTargetFilePath}" "${trickyStoreTargetFilePath}.bak"
		if [[ 0 == $? ]];
		then
			echo "Successfully packed the backup. "
		else
			abortFlag=1
			echo "Failed to pack the backup. "
		fi
	else
		echo "No tricky store target files were detected. "
	fi
	if [[ 0 == ${abortFlag} ]];
	then
		echo "com.google.android.gms" > "${trickyStoreTargetFilePath}"
		if [[ 0 == $? && -e "${trickyStoreTargetFilePath}" ]];
		then
			echo "Successfully created the new tricky store target file at \"${trickyStoreTargetFilePath}\". "
			cnt=1
			for package in ${allAppList}
			do
				echo "$package" >> "${trickyStoreTargetFilePath}"
				cnt=$[cnt+1]
			done
			if [[ 0 == $? && -e "${trickyStoreTargetFilePath}" ]];
			then
				echo "Successfully wrote $cnt target(s) to \"${trickyStoreTargetFilePath}\". "
			else
				exitCode=$[exitCode+4]
				echo "Failed to write to \"${trickyStoreTargetFilePath}\". "
			fi
		else
			exitCode=$[exitCode+8]
			echo "Failed to create the new tricky store target file at \"${trickyStoreTargetFilePath}\". "
			if [[ -e "${trickyStoreTargetFilePath}.bak" ]];
			then
				mv "${trickyStoreTargetFilePath}.bak" "${trickyStoreTargetFilePath}"
				if [[ 0 == $? && -e "${trickyStoreTargetFilePath}" ]];
				then
					echo "Successfully restore the file. "
				else
					echo "Failed to restore the file. "
				fi
			fi
		fi
	fi
else
	exitCode=$[exitCode+12]
	echo "No tricky store folders were detected. "
fi

# Exit #
echo "Finished executing the \`\`action.sh\`\` (${exitCode}). "
exit ${exitCode}
