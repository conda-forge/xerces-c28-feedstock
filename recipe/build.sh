#! /bin/bash

set -ex

if [ -n "$OSX_ARCH" ] ; then
    export CXXFLAGS="$CXXFLAGS -stdlib=libc++"
    platform=macosx
else
    platform=linux
fi

# We've added stock (version 3) xerces-c as a build-time dep to make sure that
# we don't clobber any of its files -- if we create a file with the same name,
# conda-build will think that it comes from the main package. But, we don't
# actually want it to be available! So clobber its files.

rm -rf $PREFIX/include/xercesc $PREFIX/lib/libxerces-c* $PREFIX/lib/pkgconfig/xerces-c*

export XERCESCROOT=$(pwd)
cd src/xercesc
bash ./runConfigure -p$platform -c$CC -x$CXX -minmem -nsocket -tnative -rpthread -b64 -P$PREFIX
make # note: build is not parallel-compatible
make install

# We need to rename our output files so as to not conflict with the files in
# the stock (version 3) xerces-c. This includes the unversioned dynamic
# library files.

cd $PREFIX
find . '(' -name '*.la' -o -name '*.a' ')' -delete
mv include/xercesc include/xercesc28
rm -f lib/libxerces-c${SHLIB_EXT} lib/libxerces-depdom${SHLIB_EXT}
