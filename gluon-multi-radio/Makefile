include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-multi-radio
PKG_VERSION:=1
PKG_RELEASE:=2

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-multi-radio
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Fix weird hostnames
  DEPENDS:=+gluon-core
endef

define Package/gluon-multi-radio/description
	Fix weird hostnames, where the owner does not respond.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-multi-radio/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-multi-radio))
