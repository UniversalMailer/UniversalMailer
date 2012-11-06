/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: stdfile.h,v 1.9 2008-10-07 11:06:26 tat Exp $
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
#ifndef _MIMETIC_OS_STDFILE_H
#define _MIMETIC_OS_STDFILE_H
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <cstdio>
#include <string>
#include <iterator>
#include <mimetic/os/fileop.h>
#include <mimetic/os/file_iterator.h>

namespace mimetic
{

// File class
struct StdFile: public FileOp
{
    typedef ifile_iterator iterator;
    StdFile();
    StdFile(const std::string&, int mode = O_RDONLY);
    ~StdFile();
    operator bool() const;
    void open(const std::string&, int mode = O_RDONLY);
    void close();
    uint read(char*, int);

    iterator begin();
    iterator end();
protected:
    void open(int flags);
    bool stat();

    std::string m_fqn;
    bool m_stated;
    struct stat m_st;
    int m_fd;
};

}


#endif

