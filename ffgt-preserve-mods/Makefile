include $(TOPDIR)/rules.mk

PKG_NAME:=ffgt-preserve-mods
PKG_VERSION:=1
PKG_RELEASE:=$(GLUON_VERSION).$(GLUON_SITE_CODE)-$(GLUON_RELEASE).$(GLUON_CONFIG_VERSION)

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(TOPDIR)/../package/gluon.mk

define Package/ffgt-preserve-mods
  SECTION:=ffgt
  CATEGORY:=Customization
  TITLE:=Allows for a rc.local like script to be executed after every firmware update
  DEPENDS:=+gluon-core
endef

define Package/ffgt-preserve-mods/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,ffgt-preserve-mods))
