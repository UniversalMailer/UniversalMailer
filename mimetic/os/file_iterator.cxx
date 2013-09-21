/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: file_iterator.cxx,v 1.3 2008-10-07 11:06:26 tat Exp $
 ***************************************************************************/
#include <iostream>
#include <iomanip>
#include <iterator>
#include <fstream>
#include <sys/stat.h>
#include <stdio.h>
#include <time.h>
#include <fcntl.h>
#include <errno.h>
#include <mimetic/libconfig.h>
#include <mimetic/os/file_iterator.h>
#include <mimetic/os/file.h>
#include <mimetic/libconfig.h>
#ifdef HAVE_DIRENT_H
#include <dirent.h>
#endif
#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif
#ifdef HAVE_SYS_TIME_H
#include <sys/time.h>
#endif

namespace mimetic
{

using namespace std;

ifile_iterator::ifile_iterator()
: m_eof(1), m_buf(0), m_ptr(0), m_count(0), m_pFile(0), m_read(0)
{
    setBufsz();
}


ifile_iterator::ifile_iterator(StdFile* pFile)
: m_eof(0), m_buf(0), m_ptr(0), m_count(0), m_pFile(pFile), m_read(0)
{
    setBufsz();
    if(m_pFile == 0)
    {
        m_eof = 1;
        return;
    }
    m_ptr = m_buf = new value_type[m_bufsz];
    underflow();
}

void ifile_iterator::setBufsz() 
{
    #ifdef HAVE_GETPAGESIZE
    m_bufsz = getpagesize();
    #else
    m_bufsz = defBufsz;
    #endif
}

void ifile_iterator::cp(const ifile_iterator& r)
{
    if(m_buf)
        delete[] m_buf;
    m_eof = 1;
    m_buf = m_ptr = 0;
    m_count = m_read = 0;
    m_pFile = 0;
    if(r.m_eof || r.m_pFile == 0)
        return;
    m_eof = r.m_eof;
    m_count = r.m_count;
    m_pFile = r.m_pFile;
    m_read = r.m_read;
    m_bufsz = r.m_bufsz;

    m_ptr = m_buf = new value_type[m_bufsz];
    for(int i = 0; i < m_count; ++i)
        m_ptr[i] = r.m_ptr[i];
    return;
}

ifile_iterator& ifile_iterator::operator=(const ifile_iterator& r)
{
    cp(r);
    return *this;
}

ifile_iterator::ifile_iterator(const ifile_iterator& r)
: m_buf(0)
{
    cp(r);
}


ifile_iterator::~ifile_iterator()
{
    if(m_buf)
        delete[] m_buf;
    if(m_pFile == 0)
        return;
    m_eof = 1;
    m_pFile = 0;
}


void ifile_iterator::underflow()
{
    if(m_eof)
        return;
    m_count = m_pFile->read(m_buf, m_bufsz);
    if(m_count > 0)
    {
        m_ptr = m_buf;
        m_read += m_count;
    } else {
        m_count = 0;
        m_eof = 1;
    }
}

}

