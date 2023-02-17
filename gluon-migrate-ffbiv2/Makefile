include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-migrate-ffbiv2
PKG_VERSION:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-migrate-ffbiv2
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Migrate settings from FFBI-FW to Gluon
  DEPENDS:=+gluon-core
endef

define Package/gluon-migrate-ffbiv2/description
	Migrate settings (nodename, contact, ...) from FFBI-FW to Gluon
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-migrate-ffbiv2/install
	$(CP) ./files/* $(1)/
endef

define Package/gluon-migrate-ffbiv2/postinst
endef

$(eval $(call BuildPackage,gluon-migrate-ffbiv2))
