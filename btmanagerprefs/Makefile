include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = btmanagerprefs

btmanagerprefs_LIBRARIES = sparkapplist
btmanagerprefs_FILES = BTMRootListController.m BTMAppListController.m BTMDeviceOrderController.m BTMDeviceListController.m BTMDeviceConfigController.m BTMCreditsController.m
btmanagerprefs_INSTALL_PATH = /Library/PreferenceBundles
btmanagerprefs_FRAMEWORKS = UIKit
btmanagerprefs_PRIVATE_FRAMEWORKS = Preferences
btmanagerprefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/btmanagerprefs.plist$(ECHO_END)
