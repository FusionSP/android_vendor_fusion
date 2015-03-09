# World APN list
PRODUCT_COPY_FILES += \
    vendor/fusion/prebuilt/etc/apns-conf.xml:system/etc/apns-conf.xml

# World SPN overrides list
PRODUCT_COPY_FILES += \
    vendor/fusion/prebuilt/etc/spn-conf.xml:system/etc/spn-conf.xml

# Selective SPN list for operator number who has the problem.
PRODUCT_COPY_FILES += \
    vendor/fusion/prebuilt/etc/selective-spn-conf.xml:system/etc/selective-spn-conf.xml
