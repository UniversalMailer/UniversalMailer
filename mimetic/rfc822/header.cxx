/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: header.cxx,v 1.3 2008-10-07 11:06:27 tat Exp $
 ***************************************************************************/
#include <mimetic/rfc822/header.h>
#include <mimetic/rfc822/field.h>
#include <mimetic/strutils.h>

namespace mimetic
{
using namespace std;
    
// find_by_name
Rfc822Header::find_by_name::find_by_name(const std::string& name)
: m_name(name)
{
}

bool Rfc822Header::find_by_name::operator()(const Field& f) const
{    
    return m_name == f.name();        
}

#if 0
// Rfc822Header
Rfc822Header::~Rfc822Header()
{
    /*
    iterator bit = begin(), eit = end();
    for(; bit != eit; ++bit)
        delete *bit;
    */
    clear();
}
#endif

bool Rfc822Header::hasField(const string& name) const
{
    const_iterator it;
    it = find_if(begin(),end(), find_by_name(name));
    return it != end();
}


const Field& Rfc822Header::field(const std::string& name) const
{
    const_iterator it;
    it = find_if(begin(),end(), find_by_name(name));
    if(it != end())
        return *it;
    else
        return Field::null;
}

Field& Rfc822Header::field(const std::string& name)
{
    iterator it;
    it = find_if(begin(),end(), find_by_name(name));
    if(it != end())
        return *it;
    else {
        Field f;
        iterator it;
        it = insert(end(), f);
        it->name(name);
        it->m_pValue = new StringFieldValue;
        return *it;
    }
}

// Sender:
const Mailbox& Rfc822Header::sender() const
{
    return getField<Mailbox>("Sender");
}
Mailbox& Rfc822Header::sender()
{
    return getField<Mailbox>("Sender");
}
void Rfc822Header::sender(const Mailbox& r)
{
    setField("Sender", r);
}

// From:
const MailboxList& Rfc822Header::from() const
{
    return getField<MailboxList>("From");
}

MailboxList& Rfc822Header::from()
{
    return getField<MailboxList>("From");
}

void Rfc822Header::from(const MailboxList& mbxList)
{
    setField("From", mbxList);
}

// Subject:
const std::string& Rfc822Header::subject() const
{
    const StringFieldValue& fv = getField<StringFieldValue>("Subject");
    return fv.ref();
}

std::string& Rfc822Header::subject()
{
    StringFieldValue& fv = getField<StringFieldValue>("Subject");
    return fv.ref();
}

void Rfc822Header::subject(const std::string& s)
{
    setField("Subject", StringFieldValue(s));
}

// To:
const AddressList& Rfc822Header::to() const
{
    return getField<AddressList>("To");
}

AddressList& Rfc822Header::to()
{
    return getField<AddressList>("To");
}

void Rfc822Header::to(const AddressList& al)
{
    setField("To", al);
}


// Reply-To
const AddressList& Rfc822Header::replyto() const
{
    return getField<AddressList>("Reply-To");
}

AddressList& Rfc822Header::replyto()
{
    return getField<AddressList>("Reply-To");
}

void Rfc822Header::replyto(const AddressList& al)
{
    setField("Reply-To", al);
}

// CC
const AddressList& Rfc822Header::cc() const
{
    return getField<AddressList>("CC");
}

AddressList& Rfc822Header::cc()
{
    return getField<AddressList>("CC");
}

void Rfc822Header::cc(const AddressList& al)
{
    setField("CC", al);
}

// BCC
const AddressList& Rfc822Header::bcc() const
{
    return getField<AddressList>("BCC");
}

AddressList& Rfc822Header::bcc()
{
    return getField<AddressList>("BCC");
}

void Rfc822Header::bcc(const AddressList& al)
{
    setField("BCC", al);
}

// Message-ID 
const MessageId& Rfc822Header::messageid() const
{
    return getField<MessageId>("Message-ID");
}

MessageId& Rfc822Header::messageid()
{
    return getField<MessageId>("Message-ID");
}

void Rfc822Header::messageid(const MessageId& al)
{
    setField("Message-ID", al);
}
#if 0

// Message-ID:
const Field Rfc822Header::messageid() const
{
    return getField("Message-ID");
}
Field& Rfc822Header::messageid()
{
    return getField("Message-ID");
}
Field& Rfc822Header::messageid(const string& value)
{
    return getField("Message-ID", value);
}

#endif

}
