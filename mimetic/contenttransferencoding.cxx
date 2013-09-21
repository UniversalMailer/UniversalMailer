/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: contenttransferencoding.cxx,v 1.3 2008-10-07 11:06:25 tat Exp $
 ***************************************************************************/
#include <mimetic/contenttransferencoding.h>

namespace mimetic
{
using namespace std;

const char ContentTransferEncoding::label[] = "Content-Transfer-Encoding";
const char ContentTransferEncoding::base64[] = "base64";
const char ContentTransferEncoding::quoted_printable[] = "quoted-printable";
const char ContentTransferEncoding::binary[] = "binary";
const char ContentTransferEncoding::sevenbit[] = "7bit";
const char ContentTransferEncoding::eightbit[] = "8bit";

ContentTransferEncoding::ContentTransferEncoding()
{
}

ContentTransferEncoding::ContentTransferEncoding(const char* cstr)
: m_mechanism(cstr)
{
}


ContentTransferEncoding::ContentTransferEncoding(const string& mechanism)
: m_mechanism(mechanism)
{
}

const istring& ContentTransferEncoding::mechanism() const
{    
    return m_mechanism;    
}

void ContentTransferEncoding::mechanism(const string& mechanism)
{    
    m_mechanism = mechanism;
}

void ContentTransferEncoding::set(const string& val)
{
    mechanism(val);
}

string ContentTransferEncoding::str() const
{
    return mechanism();
}

FieldValue* ContentTransferEncoding::clone() const
{
    return new ContentTransferEncoding(*this);
}

}

