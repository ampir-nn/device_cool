#
# Copyright (C) 2018 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from c106 device
$(call inherit-product, device/coolpad/c106/device.mk)

# Inherit some common LineageOS stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

## Device identifier. This must come after all inclusions
PRODUCT_DEVICE := c106
PRODUCT_NAME := lineage_c106
PRODUCT_BRAND := coolpad
PRODUCT_MANUFACTURER := coolpad

PRODUCT_GMS_CLIENTID_BASE := android-leeco

PRODUCT_BUILD_PROP_OVERRIDES += \
    TARGET_DEVICE=le_c106 \
    PRODUCT_NAME=c106_CN \
    PRIVATE_BUILD_DESC="C106CN00X1000MPX1707040 C106-user 7.1.1 eng.buildf.20170704.040154 release-keys"

BUILD_FINGERPRINT := Coolpad/VCR-A0/C106:7.1.1/C106CN00X1000MPX1707040/buildfrmsz_17-88:user/release-keys

PRODUCT_SYSTEM_PROPERTY_BLACKLIST += ro.product.model

# Release name
PRODUCT_RELEASE_NAME := c106
