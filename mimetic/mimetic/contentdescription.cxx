/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: contentdescription.cxx,v 1.3 2008-10-07 11:06:25 tat Exp $
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
#include <mimetic/contentdescription.h>

namespace mimetic
{
using namespace std;

const char ContentDescription::label[] = "Content-Description";

ContentDescription::ContentDescription()
{
}

ContentDescription::ContentDescription(const char* cstr)
{
    set(cstr);
}

ContentDescription::ContentDescription(const string& val)
{
    set(val);
}


void ContentDescription::set(const string& val)
{
    m_value = val;
}

string ContentDescription::str() const
{
    return m_value;
}


FieldValue* ContentDescription::clone() const
{
    return new ContentDescription(*this);
}

}
