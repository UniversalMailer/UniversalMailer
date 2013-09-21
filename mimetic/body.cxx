/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: body.cxx,v 1.3 2008-10-07 11:06:25 tat Exp $
 ***************************************************************************/

#include <mimetic/mimeentity.h>
#include <mimetic/body.h>

namespace mimetic
{
using std::string;

Body::Body()
: m_owner(0)
{
}

void Body::set(const std::string& text)
{
    this->assign(text);
}

void Body::owner(MimeEntity* owner)
{
    m_owner = owner;
}

MimeEntity* Body::owner()
{
    return m_owner;
}

const MimeEntity* Body::owner() const
{
    return m_owner;
}

bool Body::load(const string& fqn)
{
    File in(fqn);
    if(!in)
        return false;
    this->clear();
    File::iterator beg = in.begin(), end = in.end();
    std::copy(beg, end, back_inserter(*this) );
    return true;
}

MimeEntityList& Body::parts()
{
    return m_parts;
}

const MimeEntityList& Body::parts() const
{
    return m_parts;
}

void Body::preamble(const string& v)
{
    m_preamble = v;
}

const string& Body::preamble() const
{
    return m_preamble;
}

string& Body::preamble()
{
    return m_preamble;
}

void Body::epilogue(const string& v)
{
    m_epilogue = v;
}

const string& Body::epilogue() const
{
    return m_epilogue;
}

string& Body::epilogue()
{
    return m_epilogue;
}

}

