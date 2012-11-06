INCLUDES=-I$(top_srcdir) 
includedir=@INCLUDEDIR@/rfc822

noinst_LTLIBRARIES = libmimeticrfc822.la

include_HEADERS=address.h datetime.h group.h mailboxlist.h rfc822.h \
 addresslist.h field.h header.h message.h body.h fieldvalue.h mailbox.h \
 messageid.h

libmimeticrfc822_la_SOURCES=address.cxx field.cxx header.cxx message.cxx \
 addresslist.cxx fieldvalue.cxx mailbox.cxx messageid.cxx datetime.cxx \
 group.cxx mailboxlist.cxx
