#!/bin/bash

set -e

# Function to place Firefox windows by desktops after restore session.
# Firefox has long BUG https://bugzilla.mozilla.org/show_bug.cgi?id=372650#c54 (created 2007-03-05!) which make hassle of windows!
# I use at least 11 windows and it is very hard to place them on correct desktop each time. So I write that workaround.
#
# Partially idea borrowed from attempt https://github.com/zepalmer/script-vdr/blob/master/vdr, but I choose different approach:
# instead of periodically save window titles into file (which is very unstable because of many tabs in each) I just label each window with custom label
# by default match with desktop label (name).
# 
# For set Firefox windows custom titles used extension (OpenSource): https://addons.mozilla.org/en-GB/firefox/addon/window-titler/
#
# Now match is very simple - just one grep, but you may use regular expression or special symbols...
# 
# Example:
# I have few desktops with names: Egais, DevOps, Home
# For Firefox windows I set tiltles accordingly (with extension) like "Home", then window title become: "[Home] Google - Mozilla Firefox"
# And it give me abbility understand on which desktop it should be placed.
# So I just call this function like:
# placeWindowOnDesktop Home
#
# Voila. It place all windows which have word "Home" to desktop which name also contain word Home. It does not depends any more from tab opened in that window!
# You may provide second argument to match desktop name if it is not same to match as for window, like:
# placeWindowOnDesktop Home 'Second desktop'
#
# For more clever and automatic way distribute all windows {@see matchAllFirefoxWindowsByDesktops} function
#
# $1 - window sub-sting name. wmctrl by default find only first matching window, but we will place all, if more then one matched!
# $2 - (optional) desktop sub-sting name. It is is not present - $1 used
#
# Direct way: wmctrl -r '[Egais]' -t $( deskName Egais )
function placeWindowOnDesktop(){
	local _desk=( $(deskName ${2:-${1}}) )

	# awk hack by: https://stackoverflow.com/questions/18457486/print-rest-of-the-fields-in-awk/18457573#18457573
	while read window; do
		window=( $window )
		echo -e "Place window ⟪\E[010;92m${window[@]:1}(id=${window[0]})\E[0m⟫ to desktop ⟪\E[010;93m${_desk[@]:1}(id=${_desk[0]})\E[0m⟫"
		wmctrl -i -r ${window[0]} -t ${_desk[0]}
	done < <( wmctrl -l | fgrep "${1}" | awk '{$2=""; $3=""}1' )
}

# $1 - desktop sub-sting name
# Return window id and itsName like: "5 RDC (MSSQL to PG)"
function deskName(){
	wmctrl -d | grep "$1" | cut -d' ' -f1,14-
}

# Example of direct placement
#placeWindowOnDesktop Egais
#placeWindowOnDesktop RosReestr
#placeWindowOnDesktop Home
#placeWindowOnDesktop DevOps
#placeWindowOnDesktop SensoPressTakt
#placeWindowOnDesktop RDC
#placeWindowOnDesktop ЦИК

# Magic function to distribute all Firefox windows by its desktops automatically!
# This is consider only Firefox windows, and get desktop tag-name from [] square brackets.
# F.e. for windows:
# $ wmctrl -lx | fgrep 'Navigator.Firefox'
# 0x03a000c5  3 Navigator.Firefox     2.hubbitus.taskdata [Home] bash - Extract string from brackets - Stack Overflow - Mozilla Firefox
# 0x03a000ad  5 Navigator.Firefox     2.hubbitus.taskdata [RDC] rdc-iac-ansible/cleaning-snapshots.sh at ebf2122335387a66cb043f0480d8f38e6a087d39 · RegDC/rdc-iac-ansible - Mozilla Firefox
# 0x03a00089  5 Navigator.Firefox     2.hubbitus.taskdata [RDC] How to slice an array in Bash - Stack Overflow - Mozilla Firefox
# 0x03a000b9  0 Navigator.Firefox     2.hubbitus.taskdata [Egais] Firefox desktop placement issue - Mozilla Firefox
# Home, RDC and Egais will be searched in desktop names for place windows on it accordingly!
function matchAllFirefoxWindowsByDesktops(){
	for word in $( wmctrl -lx | fgrep 'Navigator.Firefox' | awk -F"[][]" '{print $2}' | sort -u ); do
		placeWindowOnDesktop "[$word]" "$word"
	done
}

matchAllFirefoxWindowsByDesktops
