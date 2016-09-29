include /usr/local/share/luggage/luggage.make

TITLE=yo
REVERSE_DOMAIN=com.sheagcraig
PAYLOAD=\
		pack-utilities-yo.app \
		pack-usr-local-bin-yo.py \
		pack-Library-LaunchAgents-com.sheagcraig.yo.on_demand.plist \
		pack-Library-LaunchAgents-com.sheagcraig.yo.login_once.plist \
		pack-Library-LaunchDaemons-com.sheagcraig.yo.cleanup.plist \
		pack-script-postinstall \
		pack-script-preinstall \

PACKAGE_VERSION=$(shell defaults read "$(PWD)/yo.app/Contents/Info.plist" CFBundleShortVersionString)