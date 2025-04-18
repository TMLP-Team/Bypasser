#!/system/bin/sh
# Welcome (0b00000X) #
readonly EXIT_SUCCESS=0
readonly EXIT_FAILURE=1
readonly EOF=255
readonly VK_POWER=13
readonly VK_SCREEN=20
readonly VK_UP=38
readonly VK_DOWN=40
readonly moduleName="Bypasser"
readonly moduleId="bypasser"
readonly defaultTimeout=5
readonly actionFolderPath="$(dirname "$0")"
readonly startTime=$(date +%s%N)
exitCode=${EXIT_SUCCESS}

function clearCaches
{
	sync && echo 3 > /proc/sys/vm/drop_caches
	return $?
}

function setPermissions
{
	returnCode=${EXIT_SUCCESS}
	find . -type d -exec chmod 755 {} \;
	if [[ $? != ${EXIT_SUCCESS} ]];
	then
		returnCode=${EXIT_FAILURE}
	fi
	find . ! -name "*.sh" -type f -exec chmod 444 {} \;
	if [[ $? != ${EXIT_SUCCESS} ]];
	then
		returnCode=${EXIT_FAILURE}
	fi
	find . -name "*.sh" -type f -exec chmod 544 {} \;
	if [[ $? != ${EXIT_SUCCESS} ]];
	then
		returnCode=${EXIT_FAILURE}
	fi
	return ${returnCode}
}

echo "Welcome to the \`\`action.sh\`\` of the ${moduleName} Magisk Module! "
echo "The absolute path to this script is \"$(cd "$(dirname "$0")" && pwd)/$(basename "$0")\". "
clearCaches
if [[ $? -eq ${EXIT_SUCCESS} ]];
then
	echo "Successfully cleared caches. "
else
	exitCode=$(expr ${exitCode} \| ${EXIT_FAILURE})
	echo "Failed to clear caches. "
fi
chmod 755 "${actionFolderPath}" && cd "${actionFolderPath}"
if [[ $? -eq ${EXIT_SUCCESS} && "$(basename "$(pwd)")" == "${moduleId}" ]];
then
	echo "The current working directory is \"$(pwd)\". "
	setPermissions
	if [[ $? -eq ${EXIT_SUCCESS} ]];
	then
		echo "Successfully set permissions. "
	else
		exitCode=$(expr ${exitCode} \| ${EXIT_FAILURE})
		echo "Failed to set permissions. "
	fi
else
	echo "The working directory \"$(pwd)\" is unexpected. "
	exitCode=$(expr ${exitCode} \| ${EXIT_FAILURE})
fi
if $BOOTMODE;
then
	if [[ "${APATCH}" == "true" ]];
	then
		echo "Apatch (${APATCH_VER_CODE}): Please deploy the latest \`\`action\`\` version of the Apatch with only applications requiring root privileges configured and granted in the Apatch Manager, \
embed the Cherish Peekaboo as a kernel module, install the NeoZygisk module as a system module, install the Play Integrity Fix (PIF) module as a system module, install the Tricky Store (TS) module as a system module with the correct configurations, \
install the latest Jing Matrix \`\`action\`\` version of the LSPosed module as a system module with the narrowest scope for each plugin, install the VBMetaFixer module as a system module if TEE is not broken, \
and activate the HMAL plugin with the correct configurations. "
	elif [[ "${KSU}" == "true" ]];
	then
		echo "KSU (${KSU_VER_CODE}): Please deploy the latest KSU or KSU Next with only applications requiring root privileges configured and granted in the manager, embed the SUSFS as a kernel module, \
install the NeoZygisk module as a system module, install the Shamiko module as a system module with the whitelist mode enabled if you wish to, install the Play Integrity Fix (PIF) module as a system module, \
install the Tricky Store (TS) module as a system module with the correct configurations, install the latest Jing Matrix \`\`action\`\` version of the LSPosed module as a system module with the narrowest scope for each plugin, \
install the VBMetaFixer module as a system module if TEE is not broken, and activate the HMAL plugin with the correct configurations. "
	elif [[ -n "${MAGISK_VER_CODE}" ]];
	then
		echo "Magisk (${MAGISK_VER_CODE}): Please deploy the latest Magisk Manager with the Zygisk enabled by built-in Zygisk or the NeoZygisk module, execute applications requiring root privileges with root privileges granted, \
install the Shamiko module with the whitelist mode enabled if not using Magisk Delta, install the Play Integrity Fix (PIF) module, install the Tricky Store (TS) module with the correct configurations, \
install the latest Jing Matrix \`\`action\`\` version of the LSPosed module with the narrowest scope for each plugin, install the VBMetaFixer module if TEE is not broken, install the bindhosts or the built-in Systemless hosts module, \
and activate the HMAL plugin with the correct configurations. "
	else
		echo "Unknown: The rooting solution used is unknown. "
	fi	
else
	echo "Unbooted: The device is not working in the boot mode. "
fi
echo ""

# HMA/HMAL (0b0000X0) #
echo "# HMA/HMAL (0b0000X0) #"
readonly dataAppFolder="/data/app"
readonly blacklistName="Blacklist"
readonly whitelistName="Whitelist"
readonly configFolderPath="/sdcard/Download"
readonly blacklistConfigurationFileName=".HMAL_Blacklist_Config.json"
readonly blacklistConfigurationFilePath="${configFolderPath}/${blacklistConfigurationFileName}"
readonly whitelistConfigurationFileName=".HMAL_Whitelist_Config.json"
readonly whitelistConfigurationFilePath="${configFolderPath}/${whitelistConfigurationFileName}"
readonly reportLink="https://github.com/TMLP-Team/Bypasser"
readonly sensitiveApplications="com.google.android.safetycore com.google.android.contactkeys"
gapTime=0

function getClassification
{
	if [[ $# == 1 ]];
	then
		if [[ "B" == "$1" || "C" == "$1" || "D" == "$1" ]];
		then
			arr="$(curl -s "https://raw.githubusercontent.com/TMLP-Team/Bypasser/main/Classification/classification$1.txt")"
			if [[ $? -eq ${EXIT_SUCCESS} ]];
			then
				arr="$(echo -n ${arr} | sort | uniq)"
				echoFlag=0
				for package in ${arr}
				do
					if echo -n "${package}" | grep -qE '^[A-Za-z][0-9A-Za-z_]*(\.[A-Za-z][0-9A-Za-z_]*)+$';
					then
						if [[ 1 == ${echoFlag} ]];
						then
							echo -e -n "\n${package}"
						else
							echo -n "${package}"
							echoFlag=1
						fi
					fi
				done
				return ${EXIT_SUCCESS}
			else
				return $?
			fi
		else
			return ${EOF}
		fi
	else
		return ${EOF}
	fi
}

function getTheKeyPressed
{
	if echo "$1" | grep -qE '^[1-9][0-9]*$';
	then
		timeout=$1
	else
		timeout=${defaultTimeout}
	fi
	read -r -t ${timeout} pressString < <(getevent -ql)
	pressCode=$?
	if [[ ${EXIT_SUCCESS} == ${pressCode} ]];
	then
		if echo "${pressString}" | grep -q "KEY_VOLUMEUP";
		then
			echo "The [+] was pressed. "
			return ${VK_UP}
		elif echo "${pressString}" | grep -q "KEY_VOLUMEDOWN";
		then
			echo "The [-] was pressed. "
			return ${VK_DOWN}
		elif echo "${pressString}" | grep -q "KEY_POWER";
		then
			echo "The power key was pressed. "
			return ${VK_POWER}
		elif echo "${pressString}" | grep -q "ABS_MT_TRACKING_ID";
		then
			echo "The screen was pressed. "
			return ${VK_SCREEN}
		else
			echo "The following unknown event occurred. "
			echo "${pressString}"
			return ${EXIT_FAILURE}
		fi
	else
		echo "Users did not respond within ${timeout} second(s). "
		return ${EOF}
	fi
}

function getArray
{
	if [[ $# == 1 ]];
	then
		content=""
		arr="$(echo -n "$1" | sort | uniq)"
		for package in ${arr}
		do
			content="${content}\"${package}\","
		done
		if [[ "${content}" == *, ]];
		then
			content="${content%,}"
			echo -n "${content}"
			return ${EXIT_SUCCESS}
		else
			echo -n "${content}"
			return ${EXIT_FAILURE}
		fi
	else
		echo -n ""
		return ${EOF}
	fi
}	

function getBlacklistScopeStringC
{
	if [[ $# == 1 ]];
	then
		content=""
		arr="$(echo -n "$1" | sort | uniq)"
		totalLength="$(echo "${arr}" | wc -l)"
		headIndex=0
		tailIndex=$(expr ${totalLength} - ${headIndex} - 1)
		for package in ${arr}
		do
			extraAppList="$(getArray "$(echo -e -n "$(echo -n "${arr}" | head -${headIndex})\n$(echo -n "${arr}" | tail -${tailIndex})")")"
			headIndex=$(expr ${headIndex} + 1)
			tailIndex=$(expr ${tailIndex} - 1)
			content="${content}\"${package}\":{\"useWhitelist\":false,\"excludeSystemApps\":false,\"applyTemplates\":[\"${blacklistName}\"],\"extraAppList\":[${extraAppList}]},"
		done
		if [[ "${content}" == *, ]]; then
			content="${content%,}"
			echo -n "${content}"
			return ${EXIT_SUCCESS}
		else
			echo -n "${content}"
			return ${EXIT_FAILURE}
		fi
	else
		echo -n ""
		return ${EOF}
	fi
}

function getBlacklistScopeStringD
{
	if [[ $# == 2 ]];
	then
		content=""
		arr="$(echo -n "$1" | sort | uniq)"
		extraAppList="$(getArray "$(echo -n "$2" | sort | uniq)")"
		for package in ${arr}
		do
			content="${content}\"${package}\":{\"useWhitelist\":false,\"excludeSystemApps\":false,\"applyTemplates\":[\"${blacklistName}\"],\"extraAppList\":[${extraAppList}]},"
		done
		if [[ "${content}" == *, ]]; then
			content="${content%,}"
			echo -n "${content}"
			return ${EXIT_SUCCESS}
		else
			echo -n "${content}"
			return ${EXIT_FAILURE}
		fi
	else
		echo -n ""
		return ${EOF}
	fi
}

function getWhitelistScopeString
{
	if [[ $# == 2 ]];
	then
		content=""
		arrC="$(echo "$1" | sort | uniq)"
		arrD="$(echo "$2" | sort | uniq)"
		for package in ${arrC}
		do
			content="${content}\"${package}\":{\"useWhitelist\":true,\"excludeSystemApps\":true,\"applyTemplates\":[\"${whitelistName}\"],\"extraAppList\":[\"${package}\"]},"
		done
		for package in ${arrD}
		do
			content="${content}\"${package}\":{\"useWhitelist\":true,\"excludeSystemApps\":true,\"applyTemplates\":[\"${whitelistName}\"],\"extraAppList\":[]},"
		done
		if [[ "${content}" == *, ]]; then
			content="${content%,}"
			echo -n "${content}"
			return ${EXIT_SUCCESS}
		else
			echo -n "${content}"
			return ${EXIT_FAILURE}
		fi
	else
		echo -n ""
		return ${EOF}
	fi
}

classificationB="$(getClassification "B")"
returnCodeB=$?
if [[ -n "${classificationB}" ]];
then
	lengthB=$(echo "${classificationB}" | wc -l)
else
	lengthB=0
fi
classificationC="$(getClassification "C")"
returnCodeC=$?
if [[ -n "${classificationC}" ]];
then
	lengthC=$(echo "${classificationC}" | wc -l)
else
	lengthC=0
fi
classificationD="$(getClassification "D")"
returnCodeD=$?
if [[ -n "${classificationD}" ]];
then
	lengthD=$(echo "${classificationD}" | wc -l)
else
	lengthD=0
fi
classificationL=""
lengthL=0
if [[ ${returnCodeB} == ${EXIT_SUCCESS} ]];
then
	echo "Successfully fetched ${lengthB} package name(s) of Classification \$B\$ from GitHub. "
	if [[ $# -ge 1 ]];
	then
		keyCode="$1"
	else
		echo "Please press the [+] or [-] key in ${defaultTimeout} seconds if you want to scan the local user application installation directory. Otherwise, you may touch the screen to skip the timing. "
		startGapTime=$(date +%s%N)
		getTheKeyPressed
		keyCode=$?
		endGapTime=$(date +%s%N)
		gapTime=$(expr ${endGapTime} - ${startGapTime})
	fi
	if [[ ${VK_UP} -eq ${keyCode} || ${VK_DOWN} -eq ${keyCode} ]];
	then
		localCount=0
		folderCount=0
		fileCount=0
		for item in "${dataAppFolder}/"*
		do
			if [[ -d "${item}" ]];
			then
				folderCount=$(expr ${folderCount} + 1)
				subItems="$(ls -1 "${item}")"
				if [[ $(echo "${subItems}" | wc -l) == 1 ]];
				then
					firstItem="$(echo "${subItems}" | awk "NR==1")"
					printableStrings="$(cat "${item}/${firstItem}/base.apk" | strings)"
					packageName="$(basename "${firstItem}" | cut -d "-" -f 1)"
					if echo -n "${packageName}" | grep -qE '^[A-Za-z][0-9A-Za-z_]*(\.[A-Za-z][0-9A-Za-z_]*)+$';
					then
						if [[ "${packageName}" != "com.google.android.gms" && ! "$(echo -e -n "${classificationB}\n${classificationC}\n${classificationD}")" =~ "${packageName}" ]];
						then
							if [[ -z "${classificationL}" ]];
							then
								classificationL="${packageName}"
							else
								classificationL="$(echo -e -n "${classificationL}\n${packageName}")"
							fi
						fi
						if echo "${printableStrings}" | grep -qE "/xposed/|xposed_init";
						then
							localCount=$(expr ${localCount} + 1)
							echo -n "[${localCount}] Found the string \"/xposed/\" or \"xposed_init\" in \`\`${packageName}\`\`, "
							if [[ "${classificationB}" =~ "${packageName}" ]];
							then
								echo "which is already in Classification \$B\$. "
							else
								echo "which was not in and has been added to Classification \$B\$. "
								classificationB="$(echo -e -n "${classificationB}\n${packageName}")"
							fi
						fi
					else
						echo "Failed to resolve the folder \"${item}\". "
					fi
				else
					echo "There is at least 1 additional item in \"${item}\", which should not exist. "
				fi
			elif [ -f "${item}" ];
			then
				if [[ "${item}" == *.apk ]];
				then
					fileCount=$(expr ${fileCount} + 1)
					printableStrings="$(cat "${item}" | strings)"
					packageName="$(basename "${item}")"
					packageName="${packageName%.apk}"
					if echo -n "${packageName}" | grep -qE '^[A-Za-z][0-9A-Za-z_]*(\.[A-Za-z][0-9A-Za-z_]*)+$';
					then
						if [[ "${packageName}" != "com.google.android.gms" && ! "$(echo -e -n "${classificationB}\n${classificationC}\n${classificationD}")" =~ "${packageName}" ]];
						then
							if [[ -z "${classificationL}" ]];
							then
								classificationL="${packageName}"
							else
								classificationL="$(echo -e -n "${classificationL}\n${packageName}")"
							fi
						fi
						if echo "${printableStrings}" | grep -qE "/xposed/|xposed_init";
						then
							localCount=$(expr ${localCount} + 1)
							echo -n "[${localCount}] Found the string \"/xposed/\" or \"xposed_init\" in \`\`${packageName}\`\`, "
							if [[ "${classificationB}" =~ "${packageName}" ]];
							then
								echo "which is already in Classification \$B\$. "
							else
								echo "which was not in and has been added to Classification \$B\$. "
								classificationB="$(echo -e -n "${classificationB}\n${packageName}")"
							fi
						fi
					else
						echo "Failed to resolve the APK file \"${item}\". "
					fi
				else
					echo "A file that should not exist was found at \"${item}\". "
				fi
			fi
		done
		if [[ ${folderCount} -gt 0 ]] && [[ ${fileCount} -gt 0 ]];
		then
			echo "A mixture of folders and files was detected in the \"${dataAppFolder}\" folder. "
		fi
		classificationB=$(echo -n "${classificationB}" | sort | uniq)
		if [[ -n "${classificationB}" ]];
		then
			lengthB=$(echo "${classificationB}" | wc -l)
		else
			lengthB=0
		fi
		echo "Successfully fetched ${lengthB} package name(s) of Classification \$B\$ from GitHub and the local machine. "
		if [[ -n "${classificationL}" ]];
		then
			lengthL=$(echo "${classificationL}" | wc -l)
			echo "Successfully fetched ${lengthL} additional package name(s) from the local machine. "
			echo "Kindly report the package name(s) with the corresponding classification(s) to \"${reportLink}\" if you wish to. "
		else
			echo "No additional package names were fetched from the local machine. "
		fi
	fi
else
	classificationB=""
	lengthB=0
	echo "Failed to fetch package names of Classification \$B\$ from GitHub. "
fi
if [[ ${returnCodeC} == ${EXIT_SUCCESS} ]];
then
	echo "Successfully fetched ${lengthC} package name(s) of Classification \$C\$ from GitHub. "
else
	classificationC=""
	lengthC=0
	echo "Failed to fetch package names of Classification \$C\$ from GitHub. "
fi
if [[ ${returnCodeD} == ${EXIT_SUCCESS} ]];
then
	echo "Successfully fetched ${lengthD} package name(s) of Classification \$D\$ from GitHub. "
else
	classificationD=""
	lengthD=0
	echo "Failed to fetch package names of Classification \$D\$ from GitHub. "
fi
if [[ ${returnCodeB} == ${EXIT_SUCCESS} ]];
then
	blacklistAppList="$(getArray "${classificationB}")"
	whitelistScopeList="$(getWhitelistScopeString "${classificationC}" "${classificationD}")"
else
	blacklistAppList=""
	whitelistScopeList=""
fi
if [[ ${returnCodeD} == ${EXIT_SUCCESS} ]];
then
	whitelistAppList=$(getArray "${classificationD}")
	if [[ ${returnCodeC} == ${EXIT_SUCCESS} ]];
	then
		blacklistScopeListC="$(getBlacklistScopeStringC "${classificationC}")"
		blacklistScopeListD="$(getBlacklistScopeStringD "${classificationD}" "${classificationC}")"
		if [[ -z "${blacklistScopeListC}" ]];
		then
			blacklistScopeList="${blacklistScopeListD}"
		else
			blacklistScopeList="${blacklistScopeListC},${blacklistScopeListD}"
		fi
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
	echo -n "${blacklistConfigContent}" > "${blacklistConfigurationFilePath}"
	if [[ $? -eq ${EXIT_SUCCESS} && -f "${blacklistConfigurationFilePath}" ]];
	then
		echo "Successfully generated the config file \"${blacklistConfigurationFilePath}\". "
	else
		exitCode=$(expr ${exitCode} \| 2)
		echo "Failed to generate the config file \"${blacklistConfigurationFilePath}\". "
	fi
	echo -n "${whitelistConfigContent}" > "${whitelistConfigurationFilePath}"
	if [[ $? -eq ${EXIT_SUCCESS} && -f "${whitelistConfigurationFilePath}" ]];
	then
		echo "Successfully generated the config file \"${whitelistConfigurationFilePath}\". "
	else
		exitCode=$(expr ${exitCode} \| 2)
		echo "Failed to generate the config file \"${whitelistConfigurationFilePath}\". "
	fi
else
	exitCode=$(expr ${exitCode} \| 2)
	echo "Failed to create the folder \"${configFolderPath}\". "
fi
if [[ -z "${blacklistAppList}" || -z "${blacklistScopeList}" || -z "${whitelistAppList}" || -z "${whitelistScopeList}" ]];
then
	echo "At least one list was empty. Please check the configurations generated before importing. "
fi
for sensitiveApplication in ${sensitiveApplications}
do
	if pm list packages | grep -q "${sensitiveApplication}";
	then
		if pm disable "${sensitiveApplication}" &> /dev/null;
		then
			echo "The sensitive application \"${sensitiveApplication}\" was detected, which has been disabled. "
		else
			exitCode=$(expr ${exitCode} \| 2)
			echo "The sensitive application \"${sensitiveApplication}\" was detected, which failed to be disabled. "
		fi
	fi
done
echo ""

# Tricky Store (0b000X00) #
echo "# Tricky Store (0b000X00) #"
readonly trickyStoreFolderPath="../../tricky_store"
readonly trickyStoreTargetFileName="target.txt"
readonly trickyStoreSecurityPatchFileName="security_patch.txt"
readonly trickyStoreTargetFilePath="${trickyStoreFolderPath}/${trickyStoreTargetFileName}"
readonly trickyStoreSecurityPatchFilePath="${trickyStoreFolderPath}/${trickyStoreSecurityPatchFileName}"
readonly patchContent="$(date +%Y%m%d)"

if [[ -d "${trickyStoreFolderPath}" ]];
then
	echo "The tricky store folder was found at \"${trickyStoreFolderPath}\". "
	echo "${patchContent}" > "${trickyStoreSecurityPatchFilePath}"
	if [[ $? -eq ${EXIT_SUCCESS} && -f "${trickyStoreSecurityPatchFilePath}" ]];
	then
		echo "Successfully wrote \"${patchContent}\" to \"${trickyStoreSecurityPatchFilePath}\". "
	else
		exitCode=$(expr ${exitCode} \| 4)
		echo "Failed to write \"${patchContent}\" to \"${trickyStoreSecurityPatchFilePath}\". "
	fi
	abortFlag=${EXIT_SUCCESS}
	if [[ -f "${trickyStoreTargetFilePath}" ]];
	then
		echo "The tricky store target file was found at \"${trickyStoreTargetFilePath}\". "
		cp -fp "${trickyStoreTargetFilePath}" "${trickyStoreTargetFilePath}.bak"
		if [[ $? -eq ${EXIT_SUCCESS} && -f "${trickyStoreTargetFilePath}.bak" ]];
		then
			echo "Successfully copied \"${trickyStoreTargetFilePath}\" to \"${trickyStoreTargetFilePath}.bak\". "
		else
			abortFlag=${EXIT_FAILURE}
			echo "Failed to copy \"${trickyStoreTargetFilePath}\" to \"${trickyStoreTargetFilePath}.bak\". "
		fi
	else
		echo "The copying has been skipped since no tricky store target files were detected. "
	fi
	if [[ ${EXIT_SUCCESS} -eq ${abortFlag} ]];
	then
		lines="$(echo -n "com.google.android.gms")"
		if [[ -n "${classificationB}" ]];
		then
			lines="$(echo -e -n "${lines}\n$(echo -n "${classificationB}")")"
		fi
		if [[ -n "${classificationC}" ]];
		then
			lines="$(echo -e -n "${lines}\n$(echo -n "${classificationC}")")"
		fi
		if [[ -n "${classificationD}" ]];
		then
			lines="$(echo -e -n "${lines}\n$(echo -n "${classificationD}")")"
		fi
		if [[ -n "${classificationL}" ]];
		then
			lines="$(echo -e -n "${lines}\n$(echo -n "${classificationL}")")"
		fi
		lines=$(echo -n "${lines}" | sort | uniq)
		echo "${lines}" > "${trickyStoreTargetFilePath}"
		if [[ $? -eq ${EXIT_SUCCESS} && -f "${trickyStoreTargetFilePath}" ]];
		then
			cnt=$(cat "${trickyStoreTargetFilePath}" | wc -l)
			echo "Successfully wrote ${cnt} target(s) to \"${trickyStoreTargetFilePath}\". "
			expectedCount=$(expr 1 + ${lengthB} + ${lengthC} + ${lengthD} + ${lengthL})
			if [[ ${cnt} == ${expectedCount} ]];
			then
				echo "Successfully verified \"${trickyStoreTargetFilePath}\" (${cnt} = ${expectedCount} = 1 + ${lengthB} + ${lengthC} + ${lengthD} + ${lengthL}). "
			else
				exitCode=$(expr ${exitCode} \| 4)
				echo "Failed to verify \"${trickyStoreTargetFilePath}\" (${cnt} != ${expectedCount} = 1 + ${lengthB} + ${lengthC} + ${lengthD} + ${lengthL}). "
			fi
		else
			exitCode=$(expr ${exitCode} \| 4)
			echo "Failed to write to \"${trickyStoreTargetFilePath}\". "
		fi
	fi
else
	echo "No tricky store folders were detected. "
fi
echo ""

# Shamiko (0b00X000) #
echo "# Shamiko (0b00X000) #"
readonly shamikoInstallationFolderPath="../../modules/zygisk_shamiko"
readonly shamikoConfigurationFolderPath="../../shamiko"
readonly shamikoWhitelistConfigurationFileName="whitelist"
readonly shamikoWhitelistConfigurationFilePath="${shamikoConfigurationFolderPath}/${shamikoWhitelistConfigurationFileName}"

function doFoldersExistToBeNonEmpty
{
	for folder in "$@";
	do
		if [[ ! -d "${folder}" ]];
		then
			return ${EXIT_FAILURE}
		elif [[ -z "$(find "${folder}" -maxdepth 1 -mindepth 1 -print -quit)" ]];
		then
			return ${EXIT_FAILURE}
		fi
	done
	return ${EXIT_SUCCESS}
}

if doFoldersExistToBeNonEmpty "${shamikoInstallationFolderPath}";
then
	echo "The shamiko installation folder was found at \"${shamikoInstallationFolderPath}\". "
	abortFlag=${EXIT_SUCCESS}
	if [[ -d "${shamikoConfigurationFolderPath}" ]];
	then
		echo "The shamiko configuration folder was found at \"${shamikoConfigurationFolderPath}\". "
	else
		echo "The shamiko configuration folder \"${shamikoConfigurationFolderPath}\" did not exist. "
		mkdir -p "${shamikoConfigurationFolderPath}"
		if [[ $? -eq ${EXIT_SUCCESS} && -d "${shamikoConfigurationFolderPath}" ]];
		then
			echo "Successfully created the shamiko configuration folder \"${shamikoConfigurationFolderPath}\". "
		else
			exitCode=$(expr ${exitCode} \| 8)
			abortFlag=${EXIT_FAILURE}
			echo "Failed to create the shamiko configuration folder \"${shamikoConfigurationFolderPath}\". "
		fi
	fi
	if [[ ${EXIT_SUCCESS} -eq ${abortFlag} ]];
	then
		if [[ -f "${shamikoWhitelistConfigurationFilePath}" ]];
		then
			echo "The shamiko whitelist configuration file \"${shamikoWhitelistConfigurationFilePath}\" already existed. "
		else
			echo "The shamiko whitelist configuration file \"${shamikoWhitelistConfigurationFilePath}\" did not exist. "
			touch "${shamikoWhitelistConfigurationFilePath}"
			if [[ $? -eq ${EXIT_SUCCESS} && -f "${shamikoWhitelistConfigurationFilePath}" ]];
			then
				echo "Successfully created the shamiko whitelist configuration file \"${shamikoWhitelistConfigurationFilePath}\". "
			else
				exitCode=$(expr ${exitCode} \| 8)
				echo "Failed to create the shamiko whitelist configuration file \"${shamikoWhitelistConfigurationFilePath}\". "
			fi
		fi
	fi
else
	echo "The shamiko installation folder \"${shamikoInstallationFolderPath}\" did not exist. "
fi
echo ""

# Zygisk Next (0b0X0000) #
echo "# Zygisk Next (0b0X0000) #"
readonly zygiskSolutionInstallationFolderPath="../../modules/zygisksu"
readonly neozygiskConfigurationFolderPath="../../neozygisk"
readonly zygiskNextConfigurationFolderPath="../../zygisksu"
readonly zygiskNextDenylistConfigurationFileName="denylist_enforce"
readonly zygiskNextDenylistConfigurationFilePath="${zygiskNextConfigurationFolderPath}/${zygiskNextDenylistConfigurationFileName}"

if doFoldersExistToBeNonEmpty "${zygiskSolutionInstallationFolderPath}";
then
	echo "The installation folder of the Zygisk solution module was found at \"${zygiskSolutionInstallationFolderPath}\". "
	abortFlag=${EXIT_SUCCESS}
	if [[ -d "${neozygiskConfigurationFolderPath}" ]];
	then
		echo "As Neozygisk is the Zygisk solution module, nothing is required to be handled. "
		abortFlag=${EXIT_FAILURE}
	elif [[ -d "${zygiskNextConfigurationFolderPath}" ]];
	then
		echo "The Zygisk Next configuration folder was found at \"${zygiskNextConfigurationFolderPath}\". "
	else
		echo "The Zygisk Next configuration folder \"${zygiskNextConfigurationFolderPath}\" did not exist. "
		mkdir -p "${zygiskNextConfigurationFolderPath}"
		if [[ $? -eq ${EXIT_SUCCESS} && -d "${zygiskNextConfigurationFolderPath}" ]];
		then
			echo "Successfully created the Zygisk Next configuration folder \"${zygiskNextConfigurationFolderPath}\". "
		else
			exitCode=$(expr ${exitCode} \| 16)
			abortFlag=${EXIT_FAILURE}
			echo "Failed to create the Zygisk Next configuration folder \"${zygiskNextConfigurationFolderPath}\". "
		fi
	fi
	if [[ ${EXIT_SUCCESS} -eq ${abortFlag} ]];
	then
		if [[ -f "${zygiskNextDenylistConfigurationFilePath}" && "1" == "$(cat "${zygiskNextDenylistConfigurationFilePath}")" ]];
		then
			echo "The Zygisk Next denylist configuration file \"${zygiskNextDenylistConfigurationFilePath}\" is already configured. "
		else
			echo "The Zygisk Next denylist configuration file \"${zygiskNextDenylistConfigurationFilePath}\" was not configured. "
			echo -n "1" > "${zygiskNextDenylistConfigurationFilePath}"
			if [[ $? -eq ${EXIT_SUCCESS} && -f "${zygiskNextDenylistConfigurationFilePath}" ]];
			then
				echo "Successfully created the Zygisk Next denylist configuration file \"${zygiskNextDenylistConfigurationFilePath}\". "
			else
				exitCode=$(expr ${exitCode} \| 16)
				echo "Failed to create the Zygisk Next denylist configuration file \"${zygiskNextDenylistConfigurationFilePath}\". "
			fi
		fi
	fi
else
	echo "The Zygisk Next installation folder \"${zygiskSolutionInstallationFolderPath}\" did not exist. "
fi
echo ""

# Update (0bX00000) #
echo "# Update (0bX00000) #"
readonly webrootName="webroot"
readonly webrootFolderPath="${webrootName}"
readonly webrootFilePath="${webrootName}.zip"
readonly webrootUrl="https://raw.githubusercontent.com/TMLP-Team/Bypasser/main/src/webroot.zip"
readonly webrootDigestUrl="https://raw.githubusercontent.com/TMLP-Team/Bypasser/main/src/webroot.zip.sha512"
readonly actionPropFileName="action.prop"
readonly actionPropFilePath="${actionPropFileName}"
readonly webrootActionPropFilePath="${webrootFolderPath}/${actionPropFileName}"
readonly targetAB="A"
readonly targetAction="action${targetAB}.sh"
readonly actionUrl="https://raw.githubusercontent.com/TMLP-Team/Bypasser/main/src/${targetAction}"
readonly actionDigestUrl="https://raw.githubusercontent.com/TMLP-Team/Bypasser/main/src/${targetAction}.sha512"

webrootDigest="$(curl -s "${webrootDigestUrl}")"
if [[ $? -eq ${EXIT_SUCCESS} && -n "${webrootDigest}" ]];
then
	echo "Successfully fetched the SHA-512 value of the latest ZIP file of the web UI. "
	if [[ -d "${webrootFolderPath}" && "$(find "${webrootFolderPath}" -type f ! -name "*.sha512" ! -name "*.prop" -exec sha512sum {} \; | sort)" == "${webrootDigest}" ]];
	then
		echo "The current web UI is already up-to-date. "
	else
		echo "The current web UI is out-of-date and needs to be updated. "
		abortFlag=${EXIT_SUCCESS}
		if [[ -d "${webrootFolderPath}" ]];
		then
			rm -rf "${webrootFolderPath}.bak" && mv -fT "${webrootFolderPath}" "${webrootFolderPath}.bak"
			if [[ $? -eq ${EXIT_SUCCESS} && -d "${webrootFolderPath}.bak" ]];
			then
				echo "Successfully moved \"${webrootFolderPath}\" to \"${webrootFolderPath}.bak\". "
			else
				abortFlag=${EXIT_FAILURE}
				exitCode=$(expr ${exitCode} \| 32)
				echo "Failed to move \"${webrootFolderPath}\" to \"${webrootFolderPath}.bak\". "
			fi
		else
			echo "No old web UI folders were found to be backed up. "
		fi
		if [[ ${EXIT_SUCCESS} -eq ${abortFlag} ]];
		then
			curl -s "${webrootUrl}" -o "${webrootFilePath}" && unzip "${webrootFilePath}" -d "${webrootFolderPath}" && rm -f "${webrootFilePath}"
			if [[ $? -eq ${EXIT_SUCCESS} && -d "${webrootFolderPath}" && "$(find "${webrootFolderPath}" -type f ! -name "*.sha512" ! -name "*.prop" -exec sha512sum {} \; | sort)" == "${webrootDigest}" ]];
			then
				echo "Successfully updated and verified the web UI. "
				if [[ -d "${webrootFolderPath}.bak" ]];
				then
					rm -rf "${webrootFolderPath}.bak"
					if [[ $? -eq ${EXIT_SUCCESS} && ! -d "${webrootFolderPath}.bak" ]];
					then
						echo "Successfully removed \"${webrootFolderPath}.bak\". "
					else
						echo "Failed to remove \"${webrootFolderPath}.bak\". "
					fi
				else
					echo "No old web UI folders that should be removed were found. "
				fi
			else
				exitCode=$(expr ${exitCode} \| 32)
				echo "Failed to update or verify the web UI. "
				if [[ -d "${webrootFolderPath}.bak" ]];
				then
					rm -rf "${webrootFolderPath}" && mv -fT "${webrootFolderPath}.bak" "${webrootFolderPath}"
					if [[ $? -eq ${EXIT_SUCCESS} && -d "${webrootFolderPath}" ]];
					then
						echo "Successfully restored \"${webrootFolderPath}.bak\" to \"${webrootFolderPath}\". "
					else
						echo "Failed to restore \"${webrootFolderPath}.bak\" to \"${webrootFolderPath}\". "
					fi
				else
					echo "No old web UI folders were found for restoring. "
				fi
			fi
		fi
	fi
else
	exitCode=$(expr ${exitCode} \| 32)
	echo "Failed to fetch the SHA-512 value of the latest ZIP file of the web UI. "
fi
shellDigest="$(curl -s "${actionDigestUrl}")"
if [[ $? -eq ${EXIT_SUCCESS} && -n "${shellDigest}" ]];
then
	echo "Successfully fetched the SHA-512 value of the latest \`\`${targetAction}\`\` from GitHub. "
	if [[ -f "${targetAction}" && "$(sha512sum "${targetAction}" | cut -d " " -f1)" == "${shellDigest}" ]];
	then
		echo "The target action \`\`${targetAction}\`\` is already up-to-date. "
		if [[ -f "${actionPropFilePath}" && -f "${webrootActionPropFilePath}" && "$(cat "${actionPropFilePath}")" == "$(cat "${webrootActionPropFilePath}")" ]];
		then
			echo "The action slot of the web UI seemed correct. "
		else
			echo "The action slot of the web UI was inconsistent with the actual one. "
			rm -f "${webrootActionPropFilePath}" && echo -n "$(cat "${actionPropFilePath}")" > "${webrootActionPropFilePath}"
			if [[ $? -eq ${EXIT_SUCCESS} && -f "${actionPropFilePath}" && -f "${webrootActionPropFilePath}" ]];
			then
				echo "Successfully synchronized \"${webrootActionPropFilePath}\" from \"${actionPropFilePath}\". "
			else
				exitCode=$(expr ${exitCode} \| 32)
				echo "Failed to synchronize \"${webrootActionPropFilePath}\" from \"${actionPropFilePath}\". "
			fi
		fi
	else
		echo "The target action \`\`${targetAction}\`\` is out-of-date and needs to be updated. "
		shellContent="$(curl -s "${actionUrl}")"
		if [[ $? -eq ${EXIT_SUCCESS} && -n "${shellContent}" ]];
		then
			echo "Successfully fetched the latest \`\`${targetAction}\`\` from GitHub. "
			if [[ "$(echo "${shellContent}" | sha512sum | cut -d " " -f1)" == "${shellDigest}" ]];
			then
				echo "Successfully verified the latest \`\`${targetAction}\`\`. "
				if echo "${shellContent}" | sh -n;
				then
					echo "The latest \`\`${targetAction}\`\` successfully passed the local shell syntax check (sh). "
					rm -f "${targetAction}"
					echo "${shellContent}" > "${targetAction}"
					if [[ $? -eq ${EXIT_SUCCESS} && -f "${targetAction}" ]];
					then
						echo "Successfully updated \`\`${targetAction}\`\`. "
						rm -f "${actionPropFilePath}" "${webrootActionPropFilePath}"
						echo -n "${targetAB}" > "${actionPropFilePath}" && echo -n "${targetAB}" > "${webrootActionPropFilePath}"
						if [[ $? -eq ${EXIT_SUCCESS} && -f "${actionPropFilePath}" && -f "${webrootActionPropFilePath}" ]];
						then
							echo "Successfully switched to \`\`${targetAction}\`\` in \"${actionPropFilePath}\" and \"${webrootActionPropFilePath}\". "
						else
							exitCode=$(expr ${exitCode} \| 32)
							echo "Failed to switch to \`\`${targetAction}\`\` in \"${actionPropFilePath}\" or \"${webrootActionPropFilePath}\". "
						fi
					else
						exitCode=$(expr ${exitCode} \| 32)
						echo "Failed to update \`\`${targetAction}\`\`. "
					fi
				else
					exitCode=$(expr ${exitCode} \| 32)
					echo "The latest \`\`${targetAction}\`\` failed to pass the local shell syntax check (sh). "
				fi
			else
				exitCode=$(expr ${exitCode} \| 32)
				echo "Failed to verify the latest \`\`${targetAction}\`\`. "
			fi
		else
			exitCode=$(expr ${exitCode} \| 32)
			echo "Failed to fetch the latest \`\`${targetAction}\`\` from GitHub. "
		fi
	fi
else
	exitCode=$(expr ${exitCode} \| 32)
	echo "Failed to fetch the SHA-512 value of the latest \`\`${targetAction}\`\` from GitHub. "
fi
echo ""

# Exit #
readonly endTime=$(date +%s%N)
readonly timeDelta=$(expr ${endTime} - ${startTime} - ${gapTime})

if [[ ${EXIT_SUCCESS} -eq $(expr ${exitCode} \& ${EXIT_FAILURE}) ]];
then
	setPermissions && chmod 755 "${actionFolderPath}"
	if [[ $? -eq ${EXIT_SUCCESS} ]];
	then
		echo "Successfully set permissions. "
	else
		exitCode=$(expr ${exitCode} \| ${EXIT_FAILURE})
		echo "Failed to set permissions. "
	fi
fi
clearCaches
if [[ $? -eq ${EXIT_SUCCESS} ]];
then
	echo "Successfully cleared caches. "
else
	exitCode=$(expr ${exitCode} \| ${EXIT_FAILURE})
	echo "Failed to clear caches. "
fi
echo "Finished executing the \`\`action.sh\`\` in $(expr ${timeDelta} / 1000000000).$(expr ${timeDelta} % 1000000000) second(s) (${exitCode}). "
exit ${exitCode}
