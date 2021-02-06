#!/bin/bash

if [ -z "${1}" ] ; then
	echo "Usage: ${0} <install_prefix>"
	exit 1
fi
PREFIX="${1}"

export PKG_CONFIG_PATH="${PREFIX}/lib64/pkgconfig:${PKG_CONFIG_PATH}"

git submodule update --init --recursive &&
(
	cd vkd3d-proton &&
	(
		cd subprojects &&
		(
			cd Vulkan-Headers &&
			cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" . &&
			make install &&
			cd ..
		) &&
		(
			cd SPIRV-Headers &&
			cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" . &&
			make install &&
			cd ..
		) &&
		(
			cd dxil-spirv &&
			mkdir -p build &&
			cd build &&
			cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" .. &&
			make -j9 &&
			make install &&
			cd ..
		)
		cd ..
	) &&
	meson --buildtype release --prefix "${PREFIX}" build.64 &&
	ninja -C build.64 &&
	ninja -C build.64 install &&
	cd ..
) &&
(
	./configure --prefix="${PREFIX}" --enable-win64 --disable-win16 --with-vkd3d &&
	make depend &&
	make -j9 &&
	make install &&
	ln -vs wine64 "${PREFIX}/bin/wine"
) &&

echo &&
echo "==== Wine built and installed to ${PREFIX} successfully! ===="
echo &&

(
	WINEPATH=$(which wine) &&
	if [ "${WINEPATH}" != "${PREFIX}/bin/wine" ] ; then
		echo "* newly installed wine does not appear first in your PATH and/or conflicts with other versions of wine in your system."
		echo "* in order to be sure to launch correct version do it like this (make script/alias):"
		echo "      PATH=\"${PREFIX}/bin:\${PATH}\" LD_LIBRARY_PATH=\"${PREFIX}/lib64:\${LD_LIBRARY_PATH}\" wine <executable>"
		echo "* you have vkd3d-proton support built into wine now - so don't use wrappers like d3d12.dll anymore, it will run better without!"
	fi
)
