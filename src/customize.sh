#/system/bin/sh
# Welcome #
readonly EXIT_SUCCESS=0
readonly EXIT_FAILURE=1
readonly EOF=255
readonly VK_POWER=13
readonly VK_SCREEN=20
readonly VK_UP=38
readonly VK_DOWN=40
readonly moduleName="Bypasser"
readonly startTime=$(date +%s%N)

function cleanCache()
{
	sync
	echo 3 > /proc/sys/vm/drop_caches
	return 0
}

function getKeyPress()
{
	timeout=5
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
		return ${EOF}
	fi
}

yes "#" | head -n 100 | tr -d '\n'
ui_print "Welcome to the installer of the ${moduleName} Magisk Module! "
ui_print "The absolute path to this script is \"$(cd "$(dirname "$0")" && pwd)/$(basename "$0")\". "
cd "${MODPATH}"
ui_print "The current working directory is \"$(pwd)\". "
cleanCache

# Check #
successCount=0
totalCount=0

if ! $BOOTMODE;
then
	ui_print "Warning: Installing from recovery does not make sense currently. "
fi
find . -type f ! -name "*.sha512" | while read file;
do
	totalCount=$(expr ${totalCount} + 1)
	sha512Computed=$(sha512sum "$file" | cut -d " " -f1)
	sha512FilePath="${file}.sha512"
	if [[ -f "${sha512FilePath}" ]];
	then
		sha512Expected="$(cat "${sha512FilePath}")"
		if [[ "${sha512Computed}" == "${sha512Expected}" ]];
		then
			successCount=$(expr ${successCount} + 1)
			echo "Successfully verified \"${file}\". "
		else
			echo "Failed to verify \"${file}\". "
		fi
	else
		echo "No SHA-512 value files were found to verify \"${file}\". "
	fi
done
if [[ ${totalCount} == ${successCount} ]];
then
	echo "Successfully verified all the files. "
	find . -type f -name "*.sha512" -delete
	if [[ 0 == $? ]];
	then
		echo "Successfully removed all the previous SHA-512 value files. "
	else
		echo "Failed to remove all the previous SHA-512 value files. "
	fi
else
	abort "Failed to verify all the files. "
fi

# Action #
chmod +x ./action.sh
yes "=" | head -n 80 | tr -d '\n'
ui_print ""
actionStrings=$(./action.sh)
exitCode=$?
ui_print "${actionStrings}"
yes "=" | head -n 80 | tr -d '\n'
if [[ ${EXIT_SUCCESS} == ${exitCode} ]];
then
	ui_print "Successfully executed the \`\`action.sh\`\` (${exitCode}). "
else
	ui_print "Warning: The execution of \`\`action.sh\`\` returned a non-zero exit code (${exitCode}). "
fi
if [[ -z "${MAGISK_VER_CODE}" ]];
then
	ui_print "Warning: Cannot guarantee whether the action button is supported. Maybe you can update configurations only by flashing a newer version. "
else
	if [[ ${MAGISK_VER_CODE} -ge 28000 ]];
	then
		ui_print "The action button is supported (${MAGISK_VER_CODE}). "
	else
		ui_print "Warning: The action button is not supported (${MAGISK_VER_CODE}). Maybe you can update configurations only by flashing a newer version. Please try to use the latest manager (Magisk: \${MAGISK_VER_CODE}>= 28000). "
	fi
fi

# Finish #
endTime=$(date +%s%N)
timeDelta=$(expr ${endTime} - ${startTime})
getKeyPress
cleanCache
ui_print "Finished executing the \`\`customize.sh\`\` in $(expr ${timeDelta} / 1000000000).$(expr ${timeDelta} % 1000000000) second(s). "
yes "#" | head -n 100 | tr -d '\n'
