#
# Qxt main project file
#
# Do not edit this file.
# Use the configure script to specify compile options.
#

TEMPLATE = subdirs
DESTDIR  = lib

#check Qt version
greaterThan(QT_MAJOR_VERSION, 4) {
     error(Building libqxt with qmake only works with Qt4. Use configure-premake instead.)
}
lessThan(QT_MAJOR_VERSION, 4) | lessThan(QT_MINOR_VERSION, 3) {
   error(LibQxt requires Qt 4.3 or newer but Qt $$[QT_VERSION] was detected.)
}

!symbian:contains( QXT_MODULES, docs ){
    message( building docs )
    include(doc/doc.pri)
}

contains( QXT_MODULES, core ){
    message( building core module )
    sub_core.subdir = src/core
    SUBDIRS += sub_core
}

contains( QXT_MODULES, gui ){
    message( building gui module )
    sub_gui.subdir = src/gui
    sub_gui.depends = sub_core
    SUBDIRS += sub_gui
    !symbian:contains( QXT_MODULES, designer ){
        sub_designer.subdir = src/designer
        sub_designer.depends = sub_core sub_gui
        SUBDIRS += sub_designer
    }
}

contains( QXT_MODULES, network ){
    message( building network module )
    sub_network.subdir = src/network
    sub_network.depends = sub_core
    sub_jsonrpc.subdir = tools/jsonrpcclient
    sub_jsonrpc.depends = sub_network
    SUBDIRS += sub_network sub_jsonrpc
}

contains( QXT_MODULES, sql ){
    message( building sql module )
    sub_sql.subdir = src/sql
    sub_sql.depends = sub_core
    SUBDIRS += sub_sql
}

!symbian:contains(DEFINES,HAVE_DB){
contains( QXT_MODULES, bdb ){
    message( building bdb module )
    sub_berkeley.subdir = src/bdb
    sub_berkeley.depends = sub_core
    SUBDIRS += sub_berkeley
}
}

!symbian:contains(DEFINES,HAVE_ZEROCONF){
contains( QXT_MODULES, zeroconf ){
    message( building zeroconf module )
    sub_zeroconf.subdir = src/zeroconf
    sub_zeroconf.depends = sub_network
    SUBDIRS += sub_zeroconf
}
}

contains( QXT_MODULES, web ){
    message( building web module )
    sub_web.subdir = src/web
    sub_web.depends = sub_core sub_network
    SUBDIRS += sub_web
}

features.path = $$QXT_INSTALL_FEATURES
features.files = $$QXT_SOURCE_TREE/features/qxt.prf $$QXT_BUILD_TREE/features/qxtvars.prf
INSTALLS += features

style.CONFIG = recursive
style.recurse = $$SUBDIRS
style.recurse_target = astyle
QMAKE_EXTRA_TARGETS += style

sub-examples.commands += cd examples && $(QMAKE) $$QXT_SOURCE_TREE/examples/examples.pro && $(MAKE)
QMAKE_EXTRA_TARGETS += sub-examples

sub-tests.commands += cd tests && $(QMAKE) $$QXT_SOURCE_TREE/tests/tests.pro && $(MAKE)
QMAKE_EXTRA_TARGETS += sub-tests

runtests.depends += sub-tests
runtests.commands += cd tests && $(MAKE) test
QMAKE_EXTRA_TARGETS += runtests

unix {
    cov_zerocounters.CONFIG += recursive
    cov_zerocounters.recurse = $$SUBDIRS
    cov_zerocounters.recurse -= sub_designer
    cov_zerocounters.recurse_target = zerocounters
    QMAKE_EXTRA_TARGETS += cov_zerocounters

    cov_capture.CONFIG += recursive
    cov_capture.recurse = $$SUBDIRS
    cov_capture.recurse -= sub_designer
    cov_capture.recurse -= sub_sql # TODO: write unit tests for these!
    cov_capture.recurse_target = capture
    QMAKE_EXTRA_TARGETS += cov_capture

    cov_genhtml.CONFIG += recursive
    cov_genhtml.recurse = $$SUBDIRS
    cov_genhtml.recurse -= sub_designer
    cov_genhtml.recurse -= sub_sql # TODO: write unit tests for these!
    cov_genhtml.recurse_target = genhtml
    QMAKE_EXTRA_TARGETS += cov_genhtml

    coverage.depends += first cov_zerocounters runtests cov_capture cov_genhtml
    QMAKE_EXTRA_TARGETS += coverage

    rpm.depends += clean
    rpm.commands += cd packages && $(MAKE) rpm
    QMAKE_EXTRA_TARGETS += rpm

    deb.depends += clean
    deb.commands += cd packages && $(MAKE) deb
    QMAKE_EXTRA_TARGETS += deb
}

