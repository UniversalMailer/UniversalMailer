/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: mailbox.cxx,v 1.3 2008-10-07 11:06:27 tat Exp $
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
#include <mimetic/rfc822/mailbox.h>
#include <mimetic/strutils.h>

namespace mimetic 
{
using namespace std;


/** Basic constructor */
Mailbox::Mailbox()
{
}


/**
    Parses \p text and sets \e mailbox, \e domain, \e sourceroute and \e label
*/
Mailbox::Mailbox(const char* cstr)
{
    set(cstr);    
}
Mailbox::Mailbox(const string& text)
{
    set(text);    
}


std::string Mailbox::str() const
{
    string rs;
    bool hasLabel = !m_label.empty(), hasRoute = !m_route.empty();

    if(hasLabel)
    {
        rs = m_label + " <";
        if(hasRoute)
            rs = m_route+ ":";
    }

    rs += m_mailbox + "@" + m_domain;
    if(hasLabel)
        rs += ">";
    return rs;
}

void Mailbox::set(const string& input)
{
    if(!input.size())
        return;

    // NOTE
    // std::string uses copy-on-write so all char* pointer
    // will be invalidated after the first modify (op+, op+=,
    // string::erase, etc) so we must reset all pointers after
    // the string::erase or/and we cannot cache begin() end()

    int t = (int)(input.length() -1);
    if(input[t] == '>')
    {
        bool in_dquote = false, in_comment = false;
        int endoff = t - 1;
        for(int x = (int)(input.length() -1); x >= 0; --x)
        {
            string::value_type ch = input[x];
            if(in_comment && ch == '(') {
                in_comment = false;
                continue;
            } else if(ch == ')') {
                    in_comment = true;
            } else if(ch == '@' && m_domain.size() == 0) {
                m_domain.assign(input, x+1, endoff - x);
                endoff = x-1;
            } else if(ch == ':') {
                m_mailbox.assign(input, x+1, endoff - x);
                endoff = x-1;
            } else if(ch == '<') {
                if(input[endoff+1] == ':')
                    m_route.assign(input, x+1, endoff - x);
                else
                    m_mailbox.assign(input, x+1, endoff - x);
                m_label.assign(input, 0 , x);
                for(int t = (int)(m_label.length()-1); t > 0; --t)
                {
                    if(m_label[t] == ' ')
                        m_label.erase(t, 1);
                    else
                        break;
                }
                return;
            } else if(ch == '"') {
                in_dquote = !in_dquote;
            }
        }
    } else {
        bool in_dquote = false, in_comment = false;
        for(int x = (int)(input.length() -1); x >= 0; --x)
        {
            string::value_type ch = input[x];
            string::size_type len = input.length();

            if(in_comment && ch == '(') {
                in_comment = false;
                continue;
            } else if(ch == ')') {
                    in_comment = true;
            } else if(ch == '@' && !in_dquote && !in_comment) {
                m_domain.assign(input, x+1, len - x);
                m_mailbox.assign(input, 0, x);
                break;
            } else if(ch == '"') {
                in_dquote = !in_dquote;
            }
        }
    }
}


/**
    Returns \e true if  \e *this is equal to \p right.
    Two Mailbox objects are equal if have the same \e mailbox, the same
    \e domain and the same \e source \e routing (if set)
    Note that \e domain and \e source \e route comparisons 
    are case-insensitive
    \param right object to compare against
*/
bool Mailbox::operator==(const Mailbox& right) const
{
    return mailbox() == right.mailbox() && 
        istring(domain()) == domain() &&
        istring(sourceroute()) == right.sourceroute();
}

/**
    Returns \e true if  \e *this is NOT equal to \p right
    Two Mailbox objects are different if have different \e mailbox or different
    \e domain.
    Note that \e domain comparison is case-insensitive
    \param right object to compare against
*/
bool Mailbox::operator!=(const Mailbox& right) const
{
    return !operator==(right);
}


/** Sets the \e mailbox */
void Mailbox::mailbox(const string& mbx)
{    
    m_mailbox = mbx;
}

/** Sets the \e domain */
void Mailbox::domain(const string& dom)
{    
    m_domain = dom;
}

/** Sets the \e label */
void Mailbox::label(const string& label)
{    
    m_label = label;
}

/** Sets the \e source route */
void Mailbox::sourceroute(const string& route)
{    
    m_route = route;    
}

/** Gets the \e mailbox */
string Mailbox::mailbox(int bCanonical) const
{
    return (bCanonical ? canonical(m_mailbox, true): m_mailbox);    
}

/** Gets the \e domain */
string Mailbox::domain(int bCanonical) const
{    
    return (bCanonical ? canonical(m_domain, true) : m_domain);
}

/** Gets the \e label */
string Mailbox::label(int bCanonical) const
{    
    return (bCanonical ? canonical(m_label) : m_label);
}

/** Gets the \e source route */
string Mailbox::sourceroute(int bCanonical) const
{    
    return (bCanonical ? canonical(m_route, true) : m_route);    
}

FieldValue* Mailbox::clone() const
{
    return new Mailbox(*this);
}

}
