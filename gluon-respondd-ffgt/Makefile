include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-respondd-ffgt
PKG_VERSION:=1

include ../gluon.mk

define Package/gluon-respondd-ffgt
  PROVIDES:=gluon-respondd
  TITLE:=Provides node information to the network
  DEPENDS:=+gluon-core +libplatforminfo +libgluonutil +libuci +ubus +respondd
endef

$(eval $(call BuildPackageGluon,gluon-respondd-ffgt))
