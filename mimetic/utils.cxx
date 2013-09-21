/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: utils.cxx,v 1.4 2008-10-07 15:43:55 tat Exp $
 ***************************************************************************/
#include <mimetic/utils.h>
#include <sstream>
#include <stdlib.h>

namespace mimetic
{

using namespace std;


/**
 * same as std::endl but NOT flush the buffer
 */
std::ostream& nl(std::ostream& os)
{
    return os.put('\n');
}

/**
 * writes "\r\n" to the ostream \p ps
 */
std::ostream& crlf(std::ostream& os)
{
    return os.write("\r\n", 2);
}

namespace utils
{

struct Int
{
    Int(int n)
    : m_i(n)
    {
        stringstream ss;
        ss << m_i;
        ss >> m_si;
    }
    Int(const std::string& ns)
    {
        stringstream ss;
        ss << ns;
        ss >> m_i;
        if(ss.fail())
            m_i = 0;
        stringstream ss2;
        ss2 << m_i;
        ss2 >> m_si;
    }
    operator int() const
    {
        return m_i;
    }

    operator string() const
    {
        return m_si;
    }
private:
    int m_i;
    std::string m_si;
};


bool string_is_blank(const std::string& s)
{
    size_t i, len = s.length();

    for(i = 0; i < len; ++i)
        if(!isblank(s[i]))
            return false;
    return true;
}

/// extract the filename from a fqn
string extractFilename(const string& fqn)
{
    string::size_type pos;
    if((pos = fqn.find_last_of(PATH_SEPARATOR)) != string::npos)
    {
        return fqn.substr(++pos);
    } else
        return fqn;
}



string int2hex(unsigned int n)
{
    if(n == 0)
        return "0";
    static char tb[] = { 
        '0', '1', '2', '3', 
        '4', '5', '6', '7', 
        '8', '9', 'a', 'b', 
        'c', 'd', 'e', 'f'
    };
    size_t sz = sizeof(n), zeros = 0; 
    string r;
    char cp;
    for(size_t i = 0; i < sz*2; ++i)
    {
        cp = (n >> (i*4)) & 0xF;
        if(cp == 0)
            zeros++;
        else {
            if(zeros)
                r.insert((string::size_type)0, zeros, '0');
            zeros = 0;
            r.insert((string::size_type)0, 1, tb[cp]);
        }
    }
    return r;
}


string int2str(int n)
{
    Int i(n);
    return i;
}

int str2int(const string& str)
{
    return ::atoi(str.c_str());
}

} // ns utils

} // ns mimetic
