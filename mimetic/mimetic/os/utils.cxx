/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: utils.cxx,v 1.3 2008-10-07 11:06:26 tat Exp $
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#include <sys/types.h>
#include <mimetic/libconfig.h>
#include <mimetic/os/utils.h>
#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif

namespace mimetic
{

std::string gethostname()
{
#ifdef CONFIG_WIN32
    /* WSAStartup(...) must be called before any Winsock func */
    return std::string();
#else
    char buf[64];
    if(::gethostname(buf, 64) < 0)
        return std::string();
    else
        return std::string(buf);
#endif
}

int getpid()
{
    return ::getpid();
}

}

