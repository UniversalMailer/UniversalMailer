/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: contentid.cxx,v 1.3 2008-10-07 11:06:25 tat Exp $
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
#include <mimetic/contentid.h>
#include <ctime>

namespace mimetic
{
unsigned int ContentId::ms_sequence_number = 0;

const char ContentId::label[] = "Content-ID";

ContentId::ContentId()
{
    std::string host = gethostname();
    if(!host.length())
        host = "unknown";
  m_cid = "c" + utils::int2str((int)time(0)) + "." + utils::int2str(getpid()) +
        "." + utils::int2str(++ms_sequence_number) + "@" + host;
}

ContentId::ContentId(const char* cstr)
:m_cid(cstr)
{
}


ContentId::ContentId(const std::string& value)
:m_cid(value)
{
}

void ContentId::set(const std::string& value)
{
    m_cid = value;
}

std::string ContentId::str() const
{
    return m_cid;
}

FieldValue* ContentId::clone() const
{
    return new ContentId(*this);
}

}
