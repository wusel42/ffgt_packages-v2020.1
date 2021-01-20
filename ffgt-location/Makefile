include $(TOPDIR)/rules.mk

PKG_NAME:=ffgt-location
PKG_VERSION:=1
PKG_RELEASE:=1

include $(TOPDIR)/../package/gluon.mk

define Package/ffgt-location
  TITLE:=FFGT Location lib
  DEPENDS:=+libiwinfo
endef

define Package/ffgt-location/description
	Provides tools for WiFi-location.
endef

$(eval $(call BuildPackageGluon,ffgt-location))
