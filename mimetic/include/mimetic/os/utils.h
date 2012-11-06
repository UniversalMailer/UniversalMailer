/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: utils.h,v 1.9 2008-10-07 11:06:26 tat Exp $
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
#ifndef _MIMETIC_OS_UTILS_H_
#define _MIMETIC_OS_UTILS_H_
#include <string>

namespace mimetic
{
/// Returns host name
std::string gethostname();

/// Returns the ID of the calling process
int getpid();

}

#endif
