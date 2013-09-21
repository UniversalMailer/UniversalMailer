/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: mimeentity.cxx,v 1.5 2008-10-07 11:06:25 tat Exp $
 ***************************************************************************/
#include <iostream>
#include <fstream>
#include <streambuf>
#include <algorithm>
#include <mimetic/mimeentity.h>
#include <mimetic/tokenizer.h>
#include <mimetic/strutils.h>
#include <mimetic/libconfig.h>
#include <mimetic/codec/codec.h>
#include <mimetic/parser/itparser.h>
#include <mimetic/streambufs.h>

namespace mimetic
{

using namespace std;

void MimeEntity::load(istream& is, int mask)
{
    typedef istreambuf_iterator<char> it_type;
    typedef it_type::iterator_category it_cat;
    IteratorParser<it_type, it_cat> prs(*this);
    prs.iMask(mask);
    prs.run( it_type(is), it_type());
}

bool MimeEntity::hasField(const string& name) const
{
    return m_header.hasField(name);
}

ostream& MimeEntity::write(ostream& os, const char* eol) const
{
    enum { max_line_len = 76 };
    if(eol != 0)
    {
        // TODO
        //build nl2localnl filter streambuf
    }
    // header field
    Header::const_iterator hbit = header().begin(), heit = header().end();
    for(; hbit != heit; ++hbit)
        hbit->write(os, max_line_len) << crlf;
    const ContentType& ct = m_header.contentType();
    // body
    if(ct.isMultipart())
    {
        string boundary = "--" + ct.param("boundary");
        if(body().preamble().length())
            os << crlf << body().preamble();
        // opening boundary
        if(body().parts().size() == 0)
            os << crlf << boundary << crlf;
        MimeEntityList::const_iterator bit, eit;
        bit = body().parts().begin(), eit = body().parts().end();
        for(; bit != eit; ++bit)
        {
            os << crlf << boundary << crlf;
            MimeEntity* pMe = *bit;
            os << *pMe;
        }
        // closing boundary
        os << crlf << boundary + "--" << crlf;
        if(body().epilogue().length())
            os << body().epilogue();
    } else if(ct.type() == "message" && ct.subtype() == "rfc822") {
        MimeEntityList::const_iterator bit, eit;
        bit = body().parts().begin(), eit = body().parts().end();
        for(; bit != eit; ++bit)
        {
            os << crlf; 
            MimeEntity* pMe = *bit;
            os << *pMe;
        }
    } else {
        os << crlf << body();
    }
    os.flush();
    return os;    
}

ostream& operator<<(ostream& os, const MimeEntity& m)
{
    return m.write(os);
}


// called by all constructors()
void MimeEntity::commonInit()
{
    m_body.owner(this);
}


MimeEntity::MimeEntity()
{
    commonInit();
}


MimeEntity::MimeEntity(std::istream& is)
{
    commonInit();
    load(is);
}

MimeEntity::~MimeEntity()
{
    MimeEntityList::iterator bit = m_body.parts().begin(), 
        eit = m_body.parts().end();
    for(; bit != eit; ++bit)
        if(*bit)
            delete *bit;
    m_body.clear();
}

Header& MimeEntity::header()
{
    return m_header;
}

const Header& MimeEntity::header() const
{
    return m_header;
}

Body& MimeEntity::body()
{
    return m_body;
}

const Body& MimeEntity::body() const
{
    return m_body;
}

MimeEntity::size_type MimeEntity::size() const
{
    count_streambuf csb;
    ostream os(&csb);
    os << *this;
    return csb.size();
}




}
