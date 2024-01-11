#!/usr/bin/bash

# set -xe
# scriptName=$(basename "$0")
scriptName="$0"

g_fmt_opt=""
g_icon_path=""
g_desktopFile=""

Desktop_Open() {
	local desktopFile=$1
	local cmd=$(grep '^Exec' $desktopFile | tail -1 | 
			sed 's/^Exec=//' | sed 's/%.//')
			# sed 's/^"//g' | sed 's/" *$//g')
	local iconFilePath=$(GetIconPath "$desktopFile")
	notify "Open desktop file $desktopFile" 
	echo "Execute command $cmd"
	eval "$cmd " >& /dev/null &
}

GetIconPath() {
	local desktopFile=$1
	local iconName=$(grep '^Icon' $desktopFile | sed 's/^Icon=//' )
	if [ -z "$iconName" ]; then
		echo "No Icon in $desktopFile"
		return -1
	else
		echo "$iconName"
	fi
}

search_desktop_file_by_app_name() {
	local winPattern=$1
	local appsDir="/usr/share/applications/ $HOME/Desktop/"
	local desktopFile=$(find $appsDir -name "*.desktop" | 
		xargs grep -i "Name=${winPattern}" | 
		head -n1 | cut -d: -f1)
	echo "$desktopFile"
	if [ -n "$desktopFile" ]; then
		return $?
	else
		notify "No found desktop file for $winPattern in $appsDir"
	fi
}

get_win_by_pattern() {
	local winPattern="$1"
	# get winId and winClass
	# local allWinInfo=$(wmctrl -xl | awk '{print $1,$3}')
	local allWinInfo=$(wmctrl -xl)
	local winId=$(echo "$allWinInfo" | grep -i "$winPattern" |
			head -n1 | cut -d' ' -f1)
	echo "$winId"
}

notify() {
	local msg="$1"
	if [ -n "$g_icon_path" ]; then
		local opt="-i $g_icon_path"
	fi
	notify-send "$scriptName" "$msg" $opt
	echo "$msg"
}

fmt_info() {
	msg="$1"
	echo "$msg"
}

global_init() {
	g_desktopFile=$(search_desktop_file_by_app_name $winPattern)
	if [ "$?" -ne 0 ]; then
		notify "Fail to find desktop file for $winPattern"
		exit -1
	fi
	local iconFilePath=$(GetIconPath "$g_desktopFile")
	if [ $? -eq 0 ]; then
		g_icon_path="$iconFilePath"
	else
		echo "Fail to find icon in $g_desktopFile"
	fi
}

GetLastActiveWinId() {
	local winId=$(xprop -root | grep "^_NET_CLIENT_LIST_STACKING" | \
		awk '{print $(NF-2)}' | tr -d ',')
	# printf %d $winId
	echo $winId
}

###############################################################
######################### main ################################
###############################################################

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <win pattern>"
    exit -1
fi

winPattern=$1
global_init $winPattern

winId=$(get_win_by_pattern $winPattern)
if [ -n "$winId" ]; then
	currentActiveWinId=$(printf 0x%08x $(xdotool getactivewindow))
	if [ "$winId" = "$currentActiveWinId" ]; then
		lastActiveWinId=$(GetLastActiveWinId)
		echo "WinId=$winId is already actived."
		echo "Switch to last active win $lastActiveWinId."
		wmctrl -i -a "$lastActiveWinId"
		# xvkbd -xsendevent -text '\[Alt]\[Tab]'
	else
		echo "Activating winId $winId"
		wmctrl -i -a "$winId"
	fi
else
	echo "No found $winPattern window in desktop."
	echo "Start app from .desktop file."
	if [ -n "$g_desktopFile" ]; then
		Desktop_Open "$g_desktopFile"
	else
		exit 1
	fi
fi

