FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
    file://sulka_harden_configuration.cfg \
    file://0100-Do-not-read-stop-string-from-bootstopkeycrypt.patch \
"

SULKA_UBOOT_PASSWORD ??= ""

do_configure:append () {
    if [ -z "${SULKA_UBOOT_PASSWORD}" ]; then
        bbwarn "U-Boot console password is not set. Interactive login to U-Boot will be disabled."
    fi
    sed -i  "s/@@SULKA_UBOOT_PASSWORD@@/${SULKA_UBOOT_PASSWORD}/g" ${B}/.config
}
