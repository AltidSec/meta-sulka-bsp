SUMMARY = "Device tree of the QEMU virt machine"
DESCRIPTION = "Dumps the device tree QEMU generates for the virt machine, \
using the machine, CPU, SMP and memory options runqemu uses. With verified \
boot it is used as the U-Boot control device tree, which carries the public key, \
and the device tree in the signed FIT image."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

COMPATIBLE_MACHINE = "qemuarm64"
PROVIDES = "virtual/dtb"

INHIBIT_DEFAULT_DEPS = "1"
DEPENDS = "qemu-system-native dtc-native"

inherit deploy

S = "${UNPACKDIR}"

# The device tree describes the memory size and the CPUs, so the image must
# be run with the same options. QEMU leaves the devices the firmware uses,
# such as the PL061 GPIO controller, out of the device tree when it runs
# firmware, so dump it with a placeholder firmware image. Only its presence
# matters.
QEMU_DTB_OPTS = "${QB_MACHINE},dumpdtb=${B}/qemu-virt.dtb ${QB_CPU} ${QB_SMP} ${QB_MEM} -bios ${B}/placeholder-firmware.bin"

do_compile() {
    truncate -s 4096 ${B}/placeholder-firmware.bin
    ${QB_SYSTEM_NAME} ${QEMU_DTB_OPTS} -nographic
    # QEMU generates new random seeds on every run. A seed dumped at build
    # time would be the same on every boot, which defeats KASLR and seeds the
    # kernel random number generator with a known value.
    fdtput -d ${B}/qemu-virt.dtb /chosen kaslr-seed
    fdtput -d ${B}/qemu-virt.dtb /chosen rng-seed
    # Remove the padding QEMU adds, and fail early if the device tree is not valid
    dtc -I dtb -O dtb -o ${B}/qemu-virt-packed.dtb ${B}/qemu-virt.dtb
    mv ${B}/qemu-virt-packed.dtb ${B}/qemu-virt.dtb
}

do_install() {
    install -D -m 0644 ${B}/qemu-virt.dtb ${D}/boot/devicetree/qemu-virt.dtb
}

do_deploy() {
    install -m 0644 ${B}/qemu-virt.dtb ${DEPLOYDIR}/qemu-virt.dtb
}
addtask deploy after do_install before do_build

FILES:${PN} = "/boot/devicetree"
SYSROOT_DIRS += "/boot"
PACKAGE_ARCH = "${MACHINE_ARCH}"
