/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: contenttype.cxx,v 1.3 2008-10-07 11:06:25 tat Exp $
 ***************************************************************************/
#include <cstdlib>
#include <ctime>
#include <sstream>
#include <iomanip>
#include <cassert>
#include <mimetic/contenttype.h>
#include <mimetic/tokenizer.h>
#include <mimetic/utils.h>

namespace mimetic
{
using namespace std;

const char ContentType::label[] = "Content-Type";

int ContentType::Boundary::ms_i = 0;
string ContentType::Boundary::ms_common_boundary = string();


ContentType::Boundary::Boundary()
{
    if(ms_i++ == 0)
    { // initialize static boundary string
        const char tb[] = "0123456789"
                "abcdefghijklmnopqrstuvwxyz"
                "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                "-_."; // "=+,()/"
        stringstream ss;
        srand((unsigned int)time(0));
        short tbSize = sizeof(tb)-1;
        for(uint i=0; i < 48; ++i)
        {
            unsigned int r = rand();
            ss << tb[r % tbSize];
        }
        ms_common_boundary = "----" + ss.str();
    }
    m_boundary = ms_common_boundary + "=_" + utils::int2hex(ms_i) + "_";
}

ContentType::Boundary::operator const string&() const
{
    return m_boundary;
}

ContentType::ContentType()
{
//    m_paramList.push_back(Param("charset", "us-ascii"));
}

ContentType::ContentType(const char* cstr)
{
    set(cstr);
}

ContentType::ContentType(const string& value)
{
    set(value);
}

ContentType::ContentType(const string& stype, const string& ssubtype)
{
    set(stype, ssubtype);
}

void ContentType::set(const string& stype, const string& ssubtype)
{
    type(stype);
    subtype(ssubtype);
}

bool ContentType::isMultipart() const
{
    return m_type == "multipart";
}

void ContentType::param(const string& name, const string& value)
{
    ParamList::iterator bit = m_paramList.begin(),  eit = m_paramList.end();
    for(; bit != eit; ++bit)
    {
        if(bit->name() == name)
        {
            bit->value(value);    
            return;
        }
    }
    m_paramList.push_back(Param(name, value));
}

const string& ContentType::param(const string& field) const
{
    ParamList::const_iterator bit = m_paramList.begin(),  eit = m_paramList.end();
    for(; bit != eit; ++bit)
    {
        if(bit->name() == field)
            return bit->value();    
    }
    return nullstring;
}

void ContentType::type(const string& v)
{    
    m_type = v;
//    if(isMultipart())
//        m_paramList.push_back(ContentType::Param("boundary", Boundary()));            
}

void ContentType::subtype(const string& v)
{    
    m_subtype = v;
}

const istring& ContentType::type() const
{    
    return m_type;                    
}

const istring& ContentType::subtype() const
{    
    return m_subtype;                    
}

const ContentType::ParamList& ContentType::paramList() const
{    
    return m_paramList;                
}

ContentType::ParamList& ContentType::paramList()
{    
    return m_paramList;                
}


void ContentType::set(const string& val)
{
    StringTokenizer stok(&val, ";");
    string ct;
    if(!stok.next(ct))
        return;
    
    // parse type/subtype
    string stype, ssubtype;
    stok.setDelimList("/");
    stok.setSource(&ct);
    stok.next(stype);
    stok.next(ssubtype);
    set(stype, ssubtype);

    // parse field params
    string params(val, min(val.length(), ct.length() + 1));
    if(!params.length())
        return;
    string paramValue;
    stok.setDelimList(";");
    stok.setSource(&params);
    while(stok.next(paramValue))
    {
        ContentType::Param p(paramValue);
        m_paramList.push_back(p);
    }
}

string ContentType::str() const
{
    string ostr = m_type + "/" + m_subtype;
    ParamList::const_iterator bit = m_paramList.begin(), 
                eit = m_paramList.end();
    for(; bit != eit; ++bit)
        ostr += "; " + bit->name() + "=\"" + bit->value() + "\"";
    return ostr;
}


FieldValue* ContentType::clone() const
{
    return new ContentType(*this);
}

}

