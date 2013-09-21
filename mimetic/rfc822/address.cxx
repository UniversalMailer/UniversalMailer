/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: address.cxx,v 1.3 2008-10-07 11:06:26 tat Exp $
 ***************************************************************************/
#include <mimetic/rfc822/address.h>
#include <mimetic/strutils.h>

namespace mimetic 
{
using namespace std;
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//    Rfc822::Address
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//   address     =  mailbox /  group

Address::Address()
: m_isGroup(false)
{
}
/**
 *  Construct an Address object reading free form text from \p ctext
 *  \param text input text
 */
Address::Address(const char* text)
: m_isGroup(false)
{
    set(text);
}

/**
    Construct an Address object reading free form text from \p text
    \param text input text
 */
Address::Address(const string& text)
: m_isGroup(false)
{
    set(text);
}


void Address::set(const string& text)
{
    bool in_dquote = false;
    m_isGroup = false;
    string::const_iterator p = text.begin();
    for(; p < text.end(); ++p)
    {
        if(*p == '"') {
            in_dquote = !in_dquote;
        } else if(*p == ':' && !in_dquote) {
            m_isGroup = true;
            m_group = Group(text);
            return;
        } else if(*p == '<' && !in_dquote) {
             m_mbx = Mailbox(text);
            return;
        }
    }
    m_mbx = Mailbox(text);
    return;
}

std::string Address::str() const
{
    if(isGroup())
        return m_group.str();
    else
        return m_mbx.str();
}

/**
 *  \return returns true if *this represents a \e group as defined in RFC822
 *  \return  false if *this represents a \e mailbox as defined in ../RFC/rfc822.txt
 */
bool Address::isGroup() const
{    
    return m_isGroup;    
}


/**
 *  \return Mailbox object pointer or NULL if this->isGroup()
 */
Mailbox& Address::mailbox()
{    return m_mbx;    }

/**
 *  \return const Mailbox object pointer or NULL if this->isGroup()
 */
const Mailbox& Address::mailbox() const
{    return m_mbx;    }

/**
 *  \return Group object pointer or NULL if !this->isGroup()
 */
Group& Address::group()
{    return m_group;    }

/**
 *  \return const Group object pointer or NULL if !this->isGroup()
 */
const Group& Address::group() const
{    return m_group;    }

FieldValue* Address::clone() const
{
    return new Address(*this);
}


bool Address::operator==(const Address& r) const
{
    return ( isGroup() ? m_group == r.m_group : m_mbx == r.m_mbx );
}

bool Address::operator!=(const Address& r) const
{
    return !operator==(r);
}

}

