/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: fieldvalue.h,v 1.13 2008-10-07 11:06:26 tat Exp $
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
#ifndef _MIMETIC_RFC822_FIELDVALUE_H_
#define _MIMETIC_RFC822_FIELDVALUE_H_
#include <string>
#include <mimetic/strutils.h>

namespace mimetic
{


/// Value of an header field (base class)
struct FieldValue
{
    FieldValue();
    virtual ~FieldValue();
    virtual void set(const std::string& val) = 0;
    virtual std::string str() const = 0;
    virtual FieldValue* clone() const = 0;
    friend std::ostream& operator<<(std::ostream&, const FieldValue&);
protected:
    friend class Rfc822Header;
    bool typeChecked() const;
    void typeChecked(bool);
private:
    bool m_typeChecked;
};

/// Unstructured field value
struct StringFieldValue: public FieldValue
{
    StringFieldValue();
    StringFieldValue(const std::string&);
    void set(const std::string&);
    std::string str() const;
    const std::string& ref() const;
    std::string& ref();
protected:
    FieldValue* clone() const;
private:
    std::string m_value;
};

}

#endif

