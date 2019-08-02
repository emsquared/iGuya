#!/bin/sh

set -e

cd "${IGUYA_WORKSPACE_TEMP_DIR}/"

# Make a copy of the Info.plist file in the .tmp folder
# This will be the Info.plist file manipulated with the version
# information that is generated below.

infoPlistSource="${IGUYA_WORKSPACE_DIR}/Resources/Info.plist"
infoPlistTarget="${IGUYA_WORKSPACE_TEMP_DIR}/Info.plist"

if [ ! -f "${infoPlistTarget}" ] || [ "${infoPlistTarget}" -ot "${infoPlistSource}" ]; then
	echo "Step 1: Info.plist file doesn't exist and/or is oudated. Performing copy."

	# Copy with -p flag to preserve modification time
	cp -p "${infoPlistSource}" "${infoPlistTarget}"
else
	echo "Step 1: Info.plist file hasn't changed."
fi

# Write the version information to the Info.plist file.
# The build version is the date of the last commit in git.
gitBundle=`which git`

if [ -z "${gitBundle}" ]; then
	bundleVersionNew="000000.00"
else 
	gitDateOfLastCommit=`"${gitBundle}" log -n1 --format="%at"`

	bundleVersionNew=`/bin/date -u -r "${gitDateOfLastCommit}" "+%y%m%d.%H"`
fi;

bundleVersionOld=$(/usr/libexec/PlistBuddy -c "Print \"CFBundleVersion\"" Info.plist)

if [ "${bundleVersionOld}" != "${bundleVersionNew}" ]; then
	echo "Step 2: Writing version: New ('${bundleVersionNew}'), Old ('${bundleVersionOld}')"

	/usr/libexec/PlistBuddy -c "Set \"CFBundleVersion\" \"${bundleVersionNew}\"" Info.plist
else
	echo "Step 2: The version hasn't changed."
fi

exit 0;
