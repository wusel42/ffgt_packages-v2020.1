include $(TOPDIR)/rules.mk

PKG_NAME:=ffgt-geolocator
PKG_VERSION:=1
PKG_RELEASE:=1

include $(TOPDIR)/../package/gluon.mk

define Package/ffgt-geolocator
  TITLE:=FFGT Geolocator
  DEPENDS:=+ffgt-location
endef

define Package/ffgt-geolocator/description
	Provides WiFi based positioning
endef

$(eval $(call BuildPackageGluon,ffgt-geolocator))
