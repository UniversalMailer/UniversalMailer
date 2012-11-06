/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: fileop.h,v 1.7 2008-10-07 11:06:26 tat Exp $
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
#ifndef _MIMETIC_OS_FILEOP_H
#define _MIMETIC_OS_FILEOP_H
#include <string>

/**
  *@author 
  */
namespace mimetic
{

/// Defines some file utility functions
struct FileOp
{
    typedef unsigned int uint;
    /* static funtions */
    static bool remove(const std::string&);
    static bool move(const std::string&, const std::string&);
    static bool exists(const std::string&);

    static uint size(const std::string&);
    static uint ctime(const std::string&); // creation time
    static uint atime(const std::string&); // last time accessed(r/w)
    static uint mtime(const std::string&); // last time written
};

}


#endif

