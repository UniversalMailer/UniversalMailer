/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: mimeentitylist.h,v 1.8 2008-10-07 11:06:25 tat Exp $
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
#ifndef _MIMETIC_MIME_ENTITY_LIST_
#define _MIMETIC_MIME_ENTITY_LIST_
#include <list>
#include <string>

namespace mimetic
{

class MimeEntity;

/// List of MimeEntity classes
typedef std::list<MimeEntity*> MimeEntityList;


}

#endif
