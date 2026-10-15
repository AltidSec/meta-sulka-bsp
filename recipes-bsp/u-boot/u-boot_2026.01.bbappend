FILESEXTRAPATHS:prepend:sulka-hardening := "${THISDIR}/${PN}:"

SRC_URI:append:sulka-hardening = " \
    file://sulka_harden_configuration.cfg \
    file://0100-Do-not-read-stop-string-from-bootstopkeycrypt.patch \
    file://0101-Add-unlocking-checking-feature.patch \
    file://0102-Unlock-if-crypted-stop-string-entered.patch \
    file://0103-Do-not-drop-into-CLI-if-not-unlocked.patch \
    file://0104-Implement-command-allowlisting.patch \
"

SULKA_UBOOT_PASSWORD ??= ""

do_configure:append:sulka-hardening () {
    if [ -z "${SULKA_UBOOT_PASSWORD}" ]; then
        bbwarn "U-Boot console password is not set. Interactive login to U-Boot will be disabled."
    fi
    sed -i  "s/@@SULKA_UBOOT_PASSWORD@@/${SULKA_UBOOT_PASSWORD}/g" ${B}/.config
}

# Verified boot: U-Boot boots only signed FIT images. The uboot-sign class
# adds the public key to the control device tree in do_uboot_assemble_fitimage.
SRC_URI:append:sulka-verified-boot = " file://sulka_verified_boot.cfg"
SRC_URI:append:sulka-verified-boot:qemuarm64 = " \
    file://sulka_verified_boot_qemuarm64.cfg \
    file://0200-Allow-qemu-arm-to-use-a-separate-device-tree.patch \
"

# The control device tree of qemu_arm64 is empty, as U-Boot normally uses the
# one QEMU generates at run time. Use the device tree of the QEMU virt machine
# dumped at build time instead, so that the public key is in a device tree
# built into U-Boot.
DEPENDS:append:sulka-verified-boot:qemuarm64 = " qemu-virt-dtb"
do_compile:append:sulka-verified-boot:qemuarm64() {
    install -m 0644 ${RECIPE_SYSROOT}/boot/devicetree/qemu-virt.dtb ${B}/${UBOOT_DTB_BINARY}
}

SULKA_UBOOT_ROOT_MODE ??= "rw"
SULKA_UBOOT_ROOT_MODE:sulka-read-only-rootfs = "ro"
do_configure:append:sulka-verified-boot:qemuarm64() {
    sed -i "s/@@SULKA_UBOOT_ROOT_MODE@@/${SULKA_UBOOT_ROOT_MODE}/g" ${B}/.config
}
