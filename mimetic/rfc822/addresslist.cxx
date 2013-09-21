/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: addresslist.cxx,v 1.3 2008-10-07 11:06:26 tat Exp $
 ***************************************************************************/
#include <mimetic/rfc822/addresslist.h>
#include <mimetic/strutils.h>

namespace mimetic 
{

using namespace std;

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//    Rfc822::AddressList
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//   1#address (i.e. comma-separated list of address)

AddressList::AddressList()
{
}
/**
    Parses \p text and adds Address objects to the list
    \param text input text
 */
AddressList::AddressList(const string& text)
{
    set(text);
}

AddressList::AddressList(const char* cstr)
{
    set(cstr);
}

void AddressList::set(const string& text)
{
    bool in_group = false, in_dquote = false;
    int blanks = 0;
    string item;
    string::const_iterator p = text.begin();
    string::const_iterator beg = p;
    for(; p < text.end(); p++)
    {
        if(*p == '"') {
            in_dquote = !in_dquote;
        } else if(*p == ':' && !in_dquote) {
            in_group = true;
        } else if(*p == ';' && !in_dquote) {
            in_group = false;
        } else if(*p == ',' && !in_dquote) {
            if(in_group)
                continue;
            push_back(Address(string(beg,p)));
            beg = p + 1;
            blanks = 0;
        } else if(*p == ' ') {
            blanks++;
        }
    }
    if( (p-beg) != blanks)// not a only-blanks-string
        push_back(Address(string(beg,p)));
}

std::string AddressList::str() const
{
    string rs;
    const_iterator first = begin(), bit = first, eit = end();
    for(; bit != eit; ++bit)
    {
        if(bit != first)
            rs +=  ", ";
        rs += bit->str();
    }
    return rs;
}

FieldValue* AddressList::clone() const
{
    return new AddressList(*this);
}

}
