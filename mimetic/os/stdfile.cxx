/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: stdfile.cxx,v 1.3 2008-10-07 11:06:26 tat Exp $
 ***************************************************************************/
#include <iostream>
#include <fstream>
#include <cstring>
#include <sys/stat.h>
#include <stdio.h>
#include <time.h>
#include <fcntl.h>
#include <errno.h>
#include <mimetic/os/file.h>
#include <mimetic/libconfig.h>
#ifdef HAVE_DIRENT_H
#include <dirent.h>
#endif
#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif


using namespace std;


namespace mimetic
{


StdFile::StdFile()
: m_stated(false), m_fd(-1)
{
}

StdFile::StdFile(const string& fqn, int mode)
: m_fqn(fqn), m_stated(false), m_fd(-1)
{
    memset(&m_st,0, sizeof(m_st));
    if(!stat())
        return;
    open(mode);
}

void StdFile::open(const std::string& fqn, int mode /*= O_RDONLY*/)
{
    m_fqn = fqn;
    open(mode);
}

void StdFile::open(int mode)
{
    m_fd = ::open(m_fqn.c_str(), mode);
}

StdFile::~StdFile()
{
    if(m_fd)
        close();
}

StdFile::iterator StdFile::begin()
{
    return iterator(this);
}

StdFile::iterator StdFile::end()
{
    return iterator();
}

uint StdFile::read(char* buf, int bufsz)
{
    int r;
    do
    {
        r = (int)::read(m_fd, buf, bufsz);
    } while(r < 0 && errno == EINTR);
    return r;
}

StdFile::operator bool() const
{
    return m_fd > 0;
}

bool StdFile::stat()
{
    return m_stated || (m_stated = (::stat(m_fqn.c_str(), &m_st) == 0));
}

void StdFile::close() 
{
    while(::close(m_fd) < 0 && errno == EINTR)
        ;
    m_fd = -1;
}


}

