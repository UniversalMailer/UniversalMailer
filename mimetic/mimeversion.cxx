/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: mimeversion.cxx,v 1.3 2008-10-07 11:06:26 tat Exp $
 ***************************************************************************/
#include <iostream>
#include <mimetic/mimeversion.h>
#include <mimetic/utils.h>

namespace mimetic
{
using namespace std;

const char MimeVersion::label[] = "Mime-Version";


MimeVersion::MimeVersion()
: Version()
{
}

MimeVersion::MimeVersion(const string& s)
: Version(s)
{
}

MimeVersion::MimeVersion(ver_type maj, ver_type min)
: Version(maj, min)
{
}

string MimeVersion::str() const
{
    return Version::str();
}

void MimeVersion::set(const string& s)
{
    Version::set(s);
}

FieldValue* MimeVersion::clone() const
{
    return new MimeVersion(*this);
}

}
