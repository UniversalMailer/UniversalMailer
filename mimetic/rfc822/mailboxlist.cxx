/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: mailboxlist.cxx,v 1.3 2008-10-07 11:06:27 tat Exp $
 ***************************************************************************/
#include <mimetic/rfc822/mailboxlist.h>
#include <mimetic/strutils.h>

namespace mimetic
{

using namespace std;

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//    Rfc822::MailboxList
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//   1#mailbox (i.e. comma-separated list of mailbox)

MailboxList::MailboxList()
{
}

/**
    Parses \p text and adds Mailbox objects to the list
    \param text input text
 */
MailboxList::MailboxList(const char* text)
{
    set(text);
}

MailboxList::MailboxList(const string& text)
{
    set(text);
}

void MailboxList::set(const std::string& value)
{
    bool in_dquote = false;
    int blanks = 0;
    string item;
    string::const_iterator bit = value.begin(), eit = value.end();
    string::const_iterator p = bit;
    for(; p != eit; ++p)
    {
        if(*p == '"') {
            in_dquote = !in_dquote;
        } else if(*p == ',' && !in_dquote) {
            push_back( Mailbox(string(bit,p)) );
            bit = p + 1;
            blanks = 0;
        } else if(*p == ' ') {
            blanks++;
        }
    }
    if( (p-bit) != blanks)// not a only-blanks-string
        push_back( Mailbox(string(bit,p)) );
}

string MailboxList::str() const
{
    string rs;
    const_iterator first = begin();
    const_iterator bit = begin(), eit = end();
    for(; bit != eit; ++bit)
    {
        if(bit != first)
            rs += ", ";
        rs += bit->str();    
    }
    return rs;
}


FieldValue* MailboxList::clone() const
{
    return new MailboxList(*this);
}


}
