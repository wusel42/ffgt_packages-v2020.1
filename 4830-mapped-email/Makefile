include $(TOPDIR)/rules.mk

PKG_NAME:=4830-mapped-email
PKG_VERSION:=v2026.1
PKG_RELEASE:=1

include $(TOPDIR)/../package/gluon.mk
#include $(INCLUDE_DIR)/cmake.mk

define Package/4830-mapped-email
  TITLE:=Create alias mapping
  DEPENDS:=+gluon-core
endef

define Package/4830-mapped-email/description
	Create an alias out of an email address
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(call Build/Compile/Default)
endef

define Package/4830-mapped-email/install
    mkdir -p $(1)/usr/sbin/
	$(CP) $(PKG_BUILD_DIR)/mapped_email $(1)/usr/sbin/mapped_email
endef

$(eval $(call BuildPackageGluon,4830-mapped-email))
