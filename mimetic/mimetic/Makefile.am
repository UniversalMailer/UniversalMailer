SUBDIRS=codec os rfc822 parser
EXTRA_DIST=config_win32.h config_win32.h.in
lib_LTLIBRARIES = libmimetic.la

INCLUDES=-I$(top_srcdir)
#CPPFLAGS=-Winline
includedir=@INCLUDEDIR@

include_HEADERS= \
 body.h contenttransferencoding.h mimeentity.h tokenizer.h \
 circular_buffer.h contenttype.h mimeentitylist.h tree.h \
 fieldparam.h mimetic.h utils.h \
 contentdescription.h header.h mimeversion.h version.h \
 contentdisposition.h libconfig.h streambufs.h \
 contentid.h message.h strutils.h 

libmimetic_la_SOURCES=body.cxx contenttransferencoding.cxx message.cxx \
 utils.cxx contentdescription.cxx contenttype.cxx mimeentity.cxx version.cxx \
 contentdisposition.cxx fieldparam.cxx mimeversion.cxx \
 contentid.cxx header.cxx strutils.cxx

libmimetic_la_LIBADD =codec/libmimeticcodec.la os/libmimeticos.la rfc822/libmimeticrfc822.la 

# ver: interface:revision:age
libmimetic_la_LDFLAGS= -version-info 0:0:0


config_win32.h: config_win32.h.in
	CONFIG_FILES=$@ CONFIG_HEADERS= $(SHELL) $(top_builddir)/config.status
