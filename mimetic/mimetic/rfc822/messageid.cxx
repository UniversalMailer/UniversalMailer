/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: messageid.cxx,v 1.4 2008-10-07 11:06:27 tat Exp $
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
#include <ctime>
#include <mimetic/rfc822/messageid.h>

namespace mimetic
{

unsigned int MessageId::ms_sequence_number = 0;

/// pass the thread_id argument if you're using mimetic with threads
MessageId::MessageId(uint32_t thread_id)
{
    std::string host = gethostname();
    if(!host.length())
        host = "unknown";

    m_msgid = "m" + utils::int2str((int)time(0)) + "." + utils::int2str(getpid()) + 
        "." + utils::int2str(thread_id) + 
        utils::int2str(++ms_sequence_number) + "@" + host;
}

MessageId::MessageId(const std::string& value)
: m_msgid(value)
{
}

std::string MessageId::str() const
{
    return m_msgid;
}

void MessageId::set(const std::string& value)
{
    m_msgid = value;
}

FieldValue* MessageId::clone() const
{
    return new MessageId(*this);
}

}
