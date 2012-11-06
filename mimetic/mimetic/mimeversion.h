/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: mimeversion.h,v 1.12 2008-10-07 11:06:26 tat Exp $
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
#ifndef _MIMETIC_MIMEVERSION_H_
#define _MIMETIC_MIMEVERSION_H_
#include <string>
#include <iostream>
#include <mimetic/rfc822/fieldvalue.h>
#include <mimetic/version.h>
namespace mimetic
{

// major & minor are macro defined in /usr/include/sys/sysmacros.h (linux)
// so we'll better use maj & min instead

/// Mime-Version field value
struct MimeVersion: public Version, public FieldValue
{
    static const char label[];
    
    MimeVersion();
    MimeVersion(const std::string&);
    MimeVersion(ver_type, ver_type);

    void set(const std::string&);
    std::string str() const;
protected:
    FieldValue* clone() const;
};

}
#endif
