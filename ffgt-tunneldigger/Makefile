include $(TOPDIR)/rules.mk

PKG_NAME:=ffgt-tunneldigger
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/ffgtso/tunneldigger.git
PKG_SOURCE_DATE:=2022-07-21
PKG_SOURCE_VERSION:=587f9f2da97f4f6c7dca3f124ceb8b6f85842148

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/ffgt-tunneldigger
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libnl-tiny +kmod-l2tp +kmod-l2tp-eth +librt +libpthread
  TITLE:=L2TPv3 tunnel broker client, FFGT Testversion
  PROVIDES:=tunneldigger
endef

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include/libnl-tiny \
	-I$(STAGING_DIR)/usr/include \
	-DLIBNL_TINY

define Build/Prepare
	$(call Build/Prepare/Default)
	$(CP) $(PKG_BUILD_DIR)/client/* $(PKG_BUILD_DIR)
endef

define Package/ffgt-tunneldigger/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tunneldigger $(1)/usr/bin/tunneldigger
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/tunneldigger.init $(1)/etc/init.d/tunneldigger
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/config.default $(1)/etc/config/tunneldigger
endef

define Package/ffgt-tunneldigger/conffiles
/etc/config/tunneldigger
endef

$(eval $(call BuildPackage,ffgt-tunneldigger))
