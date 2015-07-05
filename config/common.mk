PRODUCT_BRAND ?= Fusion

ifneq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))
# determine the smaller dimension
TARGET_BOOTANIMATION_SIZE := $(shell \
  if [ $(TARGET_SCREEN_WIDTH) -lt $(TARGET_SCREEN_HEIGHT) ]; then \
    echo $(TARGET_SCREEN_WIDTH); \
  else \
    echo $(TARGET_SCREEN_HEIGHT); \
  fi )

# get a sorted list of the sizes
bootanimation_sizes := $(subst .zip,, $(shell ls vendor/fusion/prebuilt/common/bootanimation))
bootanimation_sizes := $(shell echo -e $(subst $(space),'\n',$(bootanimation_sizes)) | sort -rn)

# find the appropriate size and set
define check_and_set_bootanimation
$(eval TARGET_BOOTANIMATION_NAME := $(shell \
  if [ -z "$(TARGET_BOOTANIMATION_NAME)" ]; then
    if [ $(1) -le $(TARGET_BOOTANIMATION_SIZE) ]; then \
      echo $(1); \
      exit 0; \
    fi;
  fi;
  echo $(TARGET_BOOTANIMATION_NAME); ))
endef
$(foreach size,$(bootanimation_sizes), $(call check_and_set_bootanimation,$(size)))

ifeq ($(TARGET_BOOTANIMATION_HALF_RES),true)
PRODUCT_BOOTANIMATION := vendor/fusion/prebuilt/common/bootanimation/halfres/$(TARGET_BOOTANIMATION_NAME).zip
else
PRODUCT_BOOTANIMATION := vendor/fusion/prebuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip
endif
endif

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.enterprise_mode=1 \
    ro.com.android.dateformat=MM-dd-yyyy \
    ro.com.android.dataroaming=false \
    ro.setupwizard.network_required=false \
    ro.setupwizard.gservices_delay=-1

PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=1

# Tether for all
PRODUCT_PROPERTY_OVERRIDES += persist.sys.dun.override=0

ifneq ($(TARGET_BUILD_VARIANT),eng)
# Enable ADB authentication
ADDITIONAL_DEFAULT_PROPERTIES += ro.adb.secure=1
endif

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/fusion/prebuilt/common/bin/backuptool.sh:system/bin/backuptool.sh \
    vendor/fusion/prebuilt/common/bin/backuptool.functions:system/bin/backuptool.functions \
    vendor/fusion/prebuilt/common/bin/50-fusion.sh:system/addon.d/50-fusion.sh \
    vendor/fusion/prebuilt/common/bin/blacklist:system/addon.d/blacklist

# Signature compatibility validation
PRODUCT_COPY_FILES += \
    vendor/fusion/prebuilt/common/bin/otasigcheck.sh:system/bin/otasigcheck.sh

# init.d support
PRODUCT_COPY_FILES += \
    vendor/fusion/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/fusion/prebuilt/common/bin/sysinit:system/bin/sysinit

# fstrim support
PRODUCT_COPY_FILES += \
    vendor/fusion/prebuilt/common/etc/init.d/99fstrim:system/etc/init.d/99fstrim

# userinit support
PRODUCT_COPY_FILES += \
    vendor/fusion/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit

# SuperSU
PRODUCT_COPY_FILES += \
    vendor/fusion/prebuilt/common/etc/UPDATE-SuperSU.zip:system/addon.d/UPDATE-SuperSU.zip \
    vendor/fusion/prebuilt/common/etc/init.d/99SuperSUDaemon:system/etc/init.d/99SuperSUDaemon

# Fusion-specific init file
PRODUCT_COPY_FILES += \
    vendor/fusion/prebuilt/common/etc/init.cm.rc:root/init.cm.rc \

# Bring in camera effects
PRODUCT_COPY_FILES +=  \
    vendor/fusion/prebuilt/common/media/LMprec_508.emd:system/media/LMprec_508.emd \
    vendor/fusion/prebuilt/common/media/PFFprec_600.emd:system/media/PFFprec_600.emd

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:system/usr/keylayout/Vendor_045e_Product_0719.kl

# Copy latinime for gesture typing
PRODUCT_COPY_FILES += \
    vendor/fusion/prebuilt/common/lib/libjni_latinimegoogle.so:system/lib/libjni_latinimegoogle.so

# Chromium Prebuilt
ifeq ($(PRODUCT_PREBUILT_WEBVIEWCHROMIUM),yes)
-include prebuilts/chromium/$(TARGET_DEVICE)/chromium_prebuilt.mk
endif

# This is Fusion!
PRODUCT_COPY_FILES += \
    vendor/fusion/config/permissions/com.fusion.android.xml:system/etc/permissions/com.fusion.android.xml

# T-Mobile theme engine
include vendor/fusion/config/themes_common.mk

# Screen recorder
PRODUCT_PACKAGES += \
    ScreenRecorder \
    libscreenrecorder

# Fusion packages
PRODUCT_PACKAGES += \
    AudioFX \
    CMFileManager \
    DashClock \
    DeskClock \
    Eleven \
    FusionOTA \
    LockClock \
    OmniSwitch \
    Trebuchet

# Fusion extra packages
PRODUCT_PACKAGES += \
    libemoji \
    SpareParts \
    LiveWallpapersPicker \
    vim \
    Development \
    LatinIME \
    BluetoothExt \
    Profiles \
    KernelAdiutor

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.root_access=0

# Viper4Android
PRODUCT_COPY_FILES += \
    vendor/fusion/prebuilt/common/etc/viper4android/viper4android.apk:system/app/Viper4Android/viper4android.apk

# Bring in all video files
$(call inherit-product, frameworks/base/data/videos/VideoPackage2.mk)

# Include Fusion audio files
include vendor/fusion/config/fusion_audio.mk

# Include Fusion LatinIME dictionaries
PRODUCT_PACKAGE_OVERLAYS += vendor/fusion/overlay/dictionaries

# Prebuilts for Fusion
PRODUCT_COPY_FILES += \
    vendor/fusion/prebuilt/KernelTweaker.apk:system/app/KernelTweaker.apk \
    vendor/fusion/prebuilt/KernelMonitor.apk:system/app/KernelMonitor.apk

# CM Platform Library
PRODUCT_PACKAGES += \
    org.cyanogenmod.platform-res \
    org.cyanogenmod.platform \
    org.cyanogenmod.platform.xml

# CM Hardware Abstraction Framework
PRODUCT_PACKAGES += \
    org.cyanogenmod.hardware \
    org.cyanogenmod.hardware.xml

# Extra tools in Fusion
PRODUCT_PACKAGES += \
    libsepol \
    e2fsck \
    mke2fs \
    tune2fs \
    bash \
    nano \
    htop \
    powertop \
    lsof \
    mount.exfat \
    fsck.exfat \
    mkfs.exfat \
    mkfs.f2fs \
    fsck.f2fs \
    fibmap.f2fs \
    ntfsfix \
    ntfs-3g \
    gdbserver \
    micro_bench \
    oprofiled \
    sqlite3 \
    strace

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

# rsync
PRODUCT_PACKAGES += \
    rsync

# Stagefright FFMPEG plugin
PRODUCT_PACKAGES += \
    libstagefright_soft_ffmpegadec \
    libstagefright_soft_ffmpegvdec \
    libFFmpegExtractor \
    media_codecs_ffmpeg.xml

#ROOT
PRODUCT_PACKAGES += \
    procmem \
    procrank \
    su

PRODUCT_PACKAGE_OVERLAYS += vendor/fusion/overlay/common

# Fusion version
RELEASE = false
FUSIONSP_VERSION_MAJOR = 6
FUSIONSP_VERSION_MINOR = 0

# release
ifeq ($(RELEASE),true)
    FUSIONSP_VERSION_STATE := $(shell date +%Y%m%d)
    FUSIONSP_VERSION := Fusion-v$(FUSIONSP_VERSION_MAJOR).$(FUSIONSP_VERSION_MINOR)-$(TARGET_PRODUCT)-OFFICIAL-$(FUSIONSP_VERSION_STATE)
else
    FUSIONSP_VERSION_STATE := $(shell date +%Y%m%d)
    FUSIONSP_VERSION := Fusion-v$(FUSIONSP_VERSION_MAJOR).$(FUSIONSP_VERSION_MINOR)-$(TARGET_PRODUCT)-NIGHTLY-$(FUSIONSP_VERSION_STATE)
endif

# HFM Files
PRODUCT_COPY_FILES += \
        vendor/fusion/prebuilt/etc/hosts.alt:system/etc/hosts.alt \
        vendor/fusion/prebuilt/etc/hosts.og:system/etc/hosts.og


PRODUCT_PROPERTY_OVERRIDES += \
    fusion.ota.version=$(shell date -u +%Y%m%d) \
    ro.fusionsp.version=$(FUSIONSP_VERSION)

ifndef CM_PLATFORM_SDK_VERSION
  # This is the canonical definition of the SDK version, which defines
  # the set of APIs and functionality available in the platform.  It
  # is a single integer that increases monotonically as updates to
  # the SDK are released.  It should only be incremented when the APIs for
  # the new release are frozen (so that developers don't write apps against
  # intermediate builds).
  CM_PLATFORM_SDK_VERSION := 1
endif

ifeq ($(RELEASE),true)
# Disable multithreaded dexopt by default
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.dalvik.multithread=false
endif

# by default, do not update the recovery with system updates
PRODUCT_PROPERTY_OVERRIDES += persist.sys.recovery_update=false

# CyanogenMod Platform SDK Version
PRODUCT_PROPERTY_OVERRIDES += \
  ro.cm.build.version.plat.sdk=$(CM_PLATFORM_SDK_VERSION)

-include $(WORKSPACE)/build_env/image-auto-bits.mk

-include vendor/cyngn/product.mk

$(call inherit-product-if-exists, vendor/extra/product.mk)

# Inherit sabermod configs.
include vendor/fusion/config/sm.mk

