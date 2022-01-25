include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-migrate-ffbi
PKG_VERSION:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-migrate-ffbi
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Migrate settings from FFBI-FW to Gluon
  DEPENDS:=+gluon-core
endef

define Package/gluon-migrate-ffbi/description
	Migrate settings (nodename, contact, ...) from FFBI-FW to Gluon
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-migrate-ffbi/install
	$(CP) ./files/* $(1)/
endef

define Package/gluon-migrate-ffbi/postinst
endef

$(eval $(call BuildPackage,gluon-migrate-ffbi))
