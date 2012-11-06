/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: contentdescription.h,v 1.12 2008-10-07 11:06:25 tat Exp $
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
#ifndef _MIMETIC_CONTENT_DESCRIPTION_H_
#define _MIMETIC_CONTENT_DESCRIPTION_H_
#include <string>
#include <mimetic/rfc822/fieldvalue.h>

namespace mimetic
{

/// Content-Description field value
struct ContentDescription: public FieldValue
{
    static const char label[];
    ContentDescription();
    ContentDescription(const char*);
    ContentDescription(const std::string&);
    void set(const std::string&);
    std::string str() const;
protected:
    FieldValue* clone() const;
private:
    std::string m_value;
};

}

#endif

