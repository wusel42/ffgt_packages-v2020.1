include $(TOPDIR)/rules.mk

PKG_NAME:=ffka-eol-ssid
PKG_VERSION:=1
PKG_RELEASE:=1

include $(TOPDIR)/../package/gluon.mk

define Package/ffka-eol-ssid
  TITLE:=ffka-eol-ssid
  DEPENDS:=+gluon-core
endef

$(eval $(call BuildPackageGluon,ffka-eol-ssid))
