include $(TOPDIR)/rules.mk

PKG_NAME:=ffgt-eol-device
PKG_VERSION:=v2025.1
PKG_RELEASE:=1

include $(TOPDIR)/../package/gluon.mk

define Package/ffgt-eol-device
  TITLE:=Change autoupdater branch to "end-of-life" and add "-EOL" to nodename
  DEPENDS:=+gluon-core
endef

define Package/ffgt-eol-device/description
	Change autoupdater branch to "end-of-life" and add "-EOL" to nodename
endef

$(eval $(call BuildPackageGluon,ffgt-eol-device))
