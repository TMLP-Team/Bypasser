#/system/bin/sh
EXIT_SUCCESS=0
EXIT_FAILURE=1
EOF=255
moduleName=Bypasser
cd "${MODPATH}"
ui_print "Welcome to the installer of the ${moduleName} Magisk Module! "
ui_print "This absolute path to this script is \"$(cd "$(dirname "$0")" && pwd)/$(basename "$0")\". "
ui_print "The current working directory is \"$(pwd)\". "

# Magisk #
if ! $BOOTMODE;
then
	ui_print "Warning: Installing from recovery does not make sense currently. "
fi

# Action #
logFilePath="${TMPDIR}/${moduleName}.log"
chmod +x ./action.sh
actionStrings=$(./action.sh)
exitCode=$?
echo -n "$actionStrings" > "${logFilePath}"
if [[ ${EXIT_SUCCESS} == ${exitCode} ]];
then
	ui_print "Successfully executed the \`\`action.sh\`\` (${exitCode}). "
else
	ui_print "Warning: The execution of \`\`action.sh\`\` returned a non-zero exit code (${exitCode}). See \"${logFilePath}\" for details. "
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
