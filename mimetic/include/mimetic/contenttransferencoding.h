/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: contenttransferencoding.h,v 1.12 2008-10-07 11:06:25 tat Exp $
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
#ifndef _MIMETIC_CONTENT_TRANSFER_ENCODING_H_
#define _MIMETIC_CONTENT_TRANSFER_ENCODING_H_
#include <string>
#include <mimetic/strutils.h>
#include <mimetic/rfc822/fieldvalue.h>

namespace mimetic
{


/// Content-Transfer-Encoding field value
struct ContentTransferEncoding: public FieldValue
{
    static const char label[];
    ContentTransferEncoding();
    ContentTransferEncoding(const char*);
    ContentTransferEncoding(const std::string&);
    const istring& mechanism() const;
    void mechanism(const std::string&);
    
    void set(const std::string&);
    std::string str() const;
protected:
    FieldValue* clone() const;
private:
    istring m_mechanism;
};

}

#endif

