/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: message.cxx,v 1.4 2008-10-07 11:06:27 tat Exp $
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
#include <mimetic/rfc822/message.h>
#include <mimetic/strutils.h>
#include <mimetic/utils.h>


namespace mimetic 
{

using namespace std;

ostream& operator<<(ostream& os, const Message& m)
{
    // header field
    Rfc822Header::const_iterator hbit, heit;
    hbit = m.header().begin(), heit = m.header().end();
    for(; hbit != heit; ++hbit)
        os << *hbit;
    // empty line, header/body separator
    os << crlf;
    // body
    os << m.body();
    os.flush();
    return os;    
}

Rfc822Header& Message::header()
{
    return m_header;
}

const Rfc822Header& Message::header() const
{
    return m_header;
}

Rfc822Body& Message::body()
{    
    return m_body;    
}

const Rfc822Body& Message::body() const
{    
    return m_body;    
}

}
