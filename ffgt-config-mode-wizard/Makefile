include $(TOPDIR)/rules.mk

PKG_NAME:=ffgt-config-mode-wizard
PKG_VERSION:=1
PKG_RELEASE:=1

include ../gluon.mk

define Package/ffgt-config-mode-wizard
  TITLE:=Set geographic location of a node
  DEPENDS:=+gluon-config-mode-core +gluon-node-info +4830-mapped-email
endef

$(eval $(call BuildPackageGluon,ffgt-config-mode-wizard))
