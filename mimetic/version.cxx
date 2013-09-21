/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: version.cxx,v 1.4 2008-10-07 11:06:26 tat Exp $
 ***************************************************************************/
#include <iostream>
#include <mimetic/libconfig.h>
#include <mimetic/version.h>
#include <mimetic/utils.h>
#include <mimetic/tokenizer.h>

namespace mimetic
{
using namespace std;

const Version version("0.9.7");


Version::Version()
: m_maj(0), m_min(0), m_build(0)
{
}

Version::Version(const string& s)
: m_maj(0), m_min(0), m_build(0)
{
    set(s);
}

Version::Version(ver_type maj, ver_type min, ver_type build)
: m_maj(maj), m_min(min), m_build(build)
{
}

Version::ver_type Version::maj() const
{
    return m_maj;
}

Version::ver_type Version::min() const
{
    return m_min;
}

Version::ver_type Version::build() const
{
    return m_build;
}

void Version::maj(Version::ver_type maj)
{
    m_maj = maj;
}

void Version::min(Version::ver_type min)
{
    m_min = min;
}

void Version::build(Version::ver_type build)
{
    m_build = build;
}

void Version::set(ver_type maj, ver_type min, ver_type build)
{
    m_maj = maj;
    m_min = min;
    m_build = build;
}

string Version::str() const
{
    return utils::int2str(m_maj) + "." + utils::int2str(m_min) + 
        (m_build > 0 ? "." + utils::int2str(m_build) : "");
}

void Version::set(const string& s)
{
    StringTokenizer stok(&s, ".");
    string tok;
    if(stok.next(tok))
        m_maj = utils::str2int(tok);    
    if(stok.next(tok))
        m_min = utils::str2int(tok);    
    if(stok.next(tok))
        m_build = utils::str2int(tok);    
}

bool Version::operator==(const Version& r) const
{
    return m_maj == r.m_maj && m_min == r.m_min && m_build == r.m_build;
        
}

bool Version::operator!=(const Version& r) const
{
    return m_maj != r.m_maj || m_min != r.m_min || m_build != r.m_build;
}

bool Version::operator<(const Version& r) const
{
    return m_maj < r.m_maj || m_min < r.m_min || m_build < r.m_build;
}

bool Version::operator>(const Version& r) const
{
    return m_maj > r.m_maj || m_min > r.m_min || m_build > r.m_build;
}

bool Version::operator<=(const Version& r) const
{
    return m_maj <= r.m_maj || m_min <= r.m_min || m_build <= r.m_build;
}

bool Version::operator>=(const Version& r) const
{
    return m_maj >= r.m_maj || m_min >= r.m_min || m_build >= r.m_build;
}

ostream& operator<<(ostream& os, const Version& v)
{
    return os << v.str();
}

}
