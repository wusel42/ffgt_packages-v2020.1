include $(TOPDIR)/rules.mk

PKG_NAME:=4830-mapped-email
PKG_VERSION:=v2026.1
PKG_RELEASE:=1

include $(TOPDIR)/../package/gluon.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/4830-mapped-email
  TITLE:=Create alias mapping
  DEPENDS:=+gluon-core
endef

define Package/4830-mapped-email/description
	Create an alias out of an email address
endef

#define Package/4830-mapped-email/install
#	$(CP) ./files/* $(1)/
#	$(INSTALL_DIR) $(1)/usr/sbin/
#	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/get_image_name $(1)/usr/sbin/
#endef

$(eval $(call BuildPackageGluon,4830-mapped-email))
