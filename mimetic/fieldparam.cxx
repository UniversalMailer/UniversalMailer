/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: fieldparam.cxx,v 1.3 2008-10-07 11:06:25 tat Exp $
 ***************************************************************************/
#include <mimetic/fieldparam.h>
#include <mimetic/utils.h>

namespace mimetic
{

using namespace std;

FieldParam::FieldParam()
{
}

FieldParam::FieldParam(const string& lpv)
{
    string::const_iterator bit = lpv.begin(), eit = lpv.end();
    for( ; bit != eit; ++bit)
    {
        if(*bit == '=')
        {
            string n(lpv.begin(), bit), v(++bit, eit);
            m_name = remove_external_blanks(n);
            m_value = remove_dquote(remove_external_blanks(v));
            break;
        }
    }
}

FieldParam::FieldParam(const string& n, const string& v)
{    
    name(n);    
    value(v);
}

const istring& FieldParam::name() const
{    
    return m_name;                
}

const string& FieldParam::value() const
{    
    return m_value;                
}

void FieldParam::name(const string& n)
{    
    m_name = n;
}

void FieldParam::value(const string& v)
{    
    m_value = v;
}

ostream& operator<<(ostream& os, const FieldParam& p)
{
    os << p.name() << "=";
    const string& val = p.value();
    if(val.find_first_of("()\\<>\"@,;:/[]?=") != string::npos)
        return os << "\"" << val << "\"";
    else
        return os << val;
}

}
