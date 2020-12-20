export ARCHS = arm64 arm64e
# export SDKVERSION = 13.5
#TARGET= iphone:13.0
export THEOS_DEVICE_IP = 192.168.1.91

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BTManager+

BTManager+_LIBRARIES = sparkapplist
BTManager+_FILES = $(wildcard *.x) $(wildcard *.m)
BTManager+_CFLAGS = -fobjc-arc
BTManager+_FRAMEWORK = UIKit
BTManager+_PRIVATE_FRAMEWORK = Preferences OnBoardingKit

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += btmanagerprefs
include $(THEOS_MAKE_PATH)/aggregate.mk