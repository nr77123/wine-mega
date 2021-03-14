#!/bin/bash

if [ -z "${1}" ] ; then
	echo "Usage: ${0} <install_prefix>"
	exit 1
fi
PREFIX="${1}"
ORIGINAL_PATH="${PATH}"

export PKG_CONFIG_PATH="${PREFIX}/lib64/pkgconfig:${PKG_CONFIG_PATH}"

if [ -z "${CFLAGS}" ] ; then
	CFLAGS="-O3 -march=native -s"
fi
if [ -z "${CXXFLAGS}" ] ; then
	CXXFLAGS="-O3 -march=native -s"
fi
if [ -z "${MAKEOPTS}" ] ; then
	MAKEOPTS="-j9"
fi
export CFLAGS="${CFLAGS}"
export CXXFLAGS="${CXXFLAGS}"

git submodule update --init --recursive &&
(
	cd vkd3d-proton &&
	(
		cd subprojects &&
		(
			cd Vulkan-Headers &&
			git reset --hard &&
			git clean -fd &&
			git pull origin master &&
			cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" . &&
			make install &&
			cd ..
		) &&
		(
			cd SPIRV-Headers &&
			git reset --hard &&
			git clean -fd &&
			git pull origin master &&
			cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" . &&
			make install &&
			cd ..
		) &&
		(
			cd dxil-spirv &&
			git reset --hard &&
			git clean -fd &&
			git pull origin master &&
			mkdir -p build &&
			cd build &&
			cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" .. &&
			make -j9 &&
			make install &&
			cd ..
		)
		cd ..
	) &&
	git reset --hard &&
	git clean -fd &&
	git pull origin master &&
	meson --buildtype release --prefix "${PREFIX}" build.64 &&
	ninja -C build.64 &&
	ninja -C build.64 install &&
	cd ..
) &&
(
	./configure --prefix="${PREFIX}" --enable-win64 --disable-win16 --with-vkd3d &&
	make depend &&
	make ${MAKEOPTS} &&
	make install &&
	if ! [ -a "${PREFIX}/bin/wine" ] ; then
		ln -vs wine64 "${PREFIX}/bin/wine"
	fi
) &&

echo &&
echo "==== Wine built and installed to ${PREFIX} successfully! ====" &&
echo &&

(
	PATH="${ORIGINAL_PATH}" &&
	WINEPATH=$(which wine) &&
	if [ "${WINEPATH}" != "${PREFIX}/bin/wine" ] ; then
		echo "* newly installed wine (${PREFIX}/bin/wine) does not appear first in your PATH (${WINEPATH}) and/or conflicts with other versions of wine in your system."
		echo "* in order to be sure to launch correct version do it like this (make script/alias):"
		echo "      PATH=\"${PREFIX}/bin:\${PATH}\" LD_LIBRARY_PATH=\"${PREFIX}/lib64:\${LD_LIBRARY_PATH}\" wine <executable>"
		echo "* you have vkd3d-proton support built into wine now - so don't use wrappers like d3d12.dll anymore, it will run better without!"
	fi
)
