TARGET := iphone:clang:latest:13.0
ARCHS := arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MomoFloatingButton

MomoFloatingButton_FILES = Tweak.x
MomoFloatingButton_CFLAGS = -fobjc-arc
MomoFloatingButton_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS)/makefiles/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"