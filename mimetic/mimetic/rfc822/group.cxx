/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: group.cxx,v 1.3 2008-10-07 11:06:26 tat Exp $
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
#include <mimetic/rfc822/group.h>
#include <mimetic/strutils.h>

namespace mimetic
{

using namespace std;


// * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//    Rfc822::Group
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//     group       =  phrase ":" [#mailbox] ";"
Group::Group()
{
}

Group::Group(const char* cstr)
{
    set(cstr);
}

Group::Group(const string& text)
{
    set(text);
}

static string::size_type find_not_in_quote(const string& s, const string::value_type& c)
{
    int len = (int)s.length();
    bool in_dquote = false;
    for(int i =0; i < len; ++i)
    {
        if(s[i] == '"')
            in_dquote = !in_dquote;
        else if( s[i] == c && !in_dquote) {
            return i;
        }
    }
    return string::npos;
}

std::string Group::str() const
{
    string rs = m_name;
    const_iterator bit = begin(), first = bit, eit = end();
    for(; bit != eit; ++bit)
    {
        if(bit != first)
            rs += ",";
        rs += bit->str();
    }
    return rs + ";";
}

void Group::set(const string& text)
{
    m_text = text;
    size_type colon = find_not_in_quote(m_text, ':');
    if(colon == string::npos)
        return; // empty or invalid
    bool in_dquote = false;
    int in_par = 0, in_angle = 0;
    string mailbox;
    string::iterator p = m_text.begin(), start;
    m_name.assign(m_text, 0, colon);
    m_name = remove_external_blanks(m_name);
    for(p += ++colon, start = p; p < m_text.end(); ++p)
    {
        if(*p == ';' || *p == ',')
        { 
            if(in_dquote || in_par || in_angle)
                continue;
            string mbx(start, p);
            mbx = remove_external_blanks(mbx);
            push_back(Mailbox(mbx));
            if(*p == ';')
                return;
            start = p + 1;
        } else if(*p == '"') {
            in_dquote = !in_dquote;
        } else if(*p == '<') {
            ++in_angle;
        } else if(*p == '>') {
            --in_angle;
        } else if(*p == '(') {
            ++in_par;
        } else if(*p == ')') {
            --in_par;
        } 
    }
    // trailing ';' missing
    push_back(Mailbox(string(start, p-1)));
}

string Group::name(int bCanonical) const
{    return (bCanonical ? canonical(m_name) : m_name);    }

void Group::name(const string& name)
{    m_name = name;    }

FieldValue* Group::clone() const
{
    return new Group(*this);
}

}
