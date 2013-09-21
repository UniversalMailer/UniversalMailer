/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: header.cxx,v 1.3 2008-10-07 11:06:25 tat Exp $
 ***************************************************************************/
#include <mimetic/header.h>

namespace mimetic
{
using namespace std;

// MIME-Version:
const MimeVersion& Header::mimeVersion() const
{
    return getField<MimeVersion>(MimeVersion::label);
}

MimeVersion& Header::mimeVersion()
{
    return getField<MimeVersion>(MimeVersion::label);
}

void Header::mimeVersion(const MimeVersion& val)
{
    setField(MimeVersion::label, val);
}

// Content-Type
const ContentType& Header::contentType() const
{
    return getField<ContentType>(ContentType::label);
}

ContentType& Header::contentType()
{
    return getField<ContentType>(ContentType::label);
}

void Header::contentType(const ContentType& val)
{
    setField(ContentType::label, val);
}

// Content-Transfer-Encoding
const ContentTransferEncoding& Header::contentTransferEncoding() const
{
    return getField<ContentTransferEncoding>(ContentTransferEncoding::label);
}

ContentTransferEncoding& Header::contentTransferEncoding()
{
    return getField<ContentTransferEncoding>(ContentTransferEncoding::label);
}

void Header::contentTransferEncoding(const ContentTransferEncoding& val)
{
    setField(ContentTransferEncoding::label, val);
}

// Content-Disposition
const ContentDisposition& Header::contentDisposition() const
{
    return getField<ContentDisposition>(ContentDisposition::label);
}

ContentDisposition& Header::contentDisposition()
{
    return getField<ContentDisposition>(ContentDisposition::label);
}

void Header::contentDisposition(const ContentDisposition& val)
{
    setField(ContentDisposition::label, val);
}

// Content-Description
const ContentDescription& Header::contentDescription() const
{
    return getField<ContentDescription>(ContentDescription::label);
}

ContentDescription& Header::contentDescription()
{
    return getField<ContentDescription>(ContentDescription::label);
}

void Header::contentDescription(const ContentDescription& val)
{
    setField(ContentDescription::label, val);
}

// Content-Id
const ContentId& Header::contentId() const
{
    return getField<ContentId>(ContentId::label);
}

ContentId& Header::contentId()
{
    return getField<ContentId>(ContentId::label);
}

void Header::contentId(const ContentId& val)
{
    setField(ContentId::label, val);
}

}

