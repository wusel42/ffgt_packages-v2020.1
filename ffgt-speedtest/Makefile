include $(TOPDIR)/rules.mk

PKG_NAME:=ffgt-speedtest
PKG_VERSION:=1
PKG_RELEASE:=0

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(TOPDIR)/../package/gluon.mk

define Package/ffgt-speedtest
  SECTION:=gluon
  CATEGORY:=Gluon
  DEPENDS:=+gluon-core +micrond +wget-nossl
  TITLE:=Guess WAN speeds
endef

define Package/ffgt-speedtest/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackageGluon,$(PKG_NAME)))
