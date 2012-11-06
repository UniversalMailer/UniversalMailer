/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: datetime.cxx,v 1.4 2008-10-07 11:06:26 tat Exp $
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
#include <iomanip>
#include <sstream>
#include <mimetic/rfc822/datetime.h>
#include <mimetic/strutils.h>
#include <mimetic/tokenizer.h>
#include <mimetic/utils.h>


namespace mimetic
{


using namespace std;
using namespace mimetic;

DateTime::Zone::Zone(int iZone)
: m_iZone(iZone), m_iZoneIdx(0)
{
    for(int i = 0; ms_offset[i] != 0; ++i)
        if(iZone == ms_offset[i])
        {
            m_iZoneIdx = i;
        }
}
DateTime::Zone::Zone(const string& txt)
: m_iZone(0), m_iZoneIdx(0), m_sZone(txt)
{
    if(txt.empty())
        return;
    istring iTxt(txt.begin(), txt.end());
    for(int i = 0; ms_label[i] != 0; ++i)
    {
        if(iTxt == ms_label[i])
        {
            m_iZone = ms_offset[i];
            m_iZoneIdx = i;
        }
    }
    if(m_iZone == 0)
    { // check if txt is a numeric timezone (+0200)
        string tz = txt;
        if(tz[0] == '+' || tz[0] == '-' || (tz[0] >= '0' && tz[0] <= '9'))
        {
            int sign = (tz[0] == '-' ? -1 : 1);
            tz.erase(0,1);
            m_iZone = utils::str2int(tz) * sign;
        }
    }
}
bool DateTime::Zone::operator==(const string& mText)
{    
    istring txt(mText.begin(), mText.end());
    return txt == ms_label[m_iZoneIdx] ||
         utils::str2int(mText) == ms_offset[m_iZoneIdx];
}
bool DateTime::Zone::operator==(int iZone)
{    
    return  m_iZone == iZone;
}
string DateTime::Zone::name() const
{
    if(m_iZoneIdx)
        return ms_label[m_iZoneIdx];
    else {
        string sTz = utils::int2str(m_iZone);
        if(m_iZone >= 0)
        {
            sTz.insert(0u, 4-sTz.length(),'0'); // add zeroes
            sTz.insert(0u, 1, '+');
        } else {
            sTz.insert(1, 5-sTz.length(),'0'); // add zeroes
        }
        return sTz;
    }
}
short DateTime::Zone::ordinal() const
{
    return m_iZone;
}

DateTime::Month::Month(int iMonth)
: m_iMonth(iMonth)
{
    if(m_iMonth < 1 || m_iMonth > 12)
        m_iMonth = 0;
}
DateTime::Month::Month(const string& txt)
: m_iMonth(0)
{
    istring iTxt(txt.begin(), txt.end());
    if(iTxt.length() == 3)
    {
        for(int i = 1; i < 13; ++i)
            if(iTxt == ms_label[i][mnShort])
            {
                m_iMonth = i;
                return;
            }
    } else {
        for(int i = 1; i < 13; ++i)
            if(iTxt == ms_label[i][mnLong])
            {
                m_iMonth = i;
                return;
            }
    }
}
bool DateTime::Month::operator==(const string& mText) const
{    
    istring imText(mText.begin(), mText.end());
    return imText == ms_label[m_iMonth][mnShort] ||
         imText == ms_label[m_iMonth][mnLong];
}
bool DateTime::Month::operator==(int iMonth) const
{    
    return  m_iMonth == iMonth;
}
string DateTime::Month::name(bool longName) const
{
    return ms_label[m_iMonth][longName ? mnLong : mnShort];
}
short DateTime::Month::ordinal() const
{
    return m_iMonth;
}


DateTime::DayOfWeek::DayOfWeek(int iDayOfWeek)
: m_iDayOfWeek(iDayOfWeek)
{
    if(m_iDayOfWeek < 1 || m_iDayOfWeek > 7)
        m_iDayOfWeek = 0;
}
    
DateTime::DayOfWeek::DayOfWeek(const string& txt)
: m_iDayOfWeek(0)
{
    istring iTxt(txt.begin(), txt.end());
    if(iTxt.length() == 3)
    {
        for(int i = 1; i < 8; ++i)
        if(iTxt == ms_label[i][mnShort])
        {
                m_iDayOfWeek = i;
                return;
            }
    } else {
        for(int i = 1; i < 8; ++i)
            if(iTxt == ms_label[i][mnLong])
            {
                m_iDayOfWeek = i;
                return;
            }
    }
}
bool DateTime::DayOfWeek::operator==(const string& mText)
{    
    istring imText(mText.begin(), mText.end());
    return imText == ms_label[m_iDayOfWeek][mnShort] ||
         imText == ms_label[m_iDayOfWeek][mnLong];
}
bool DateTime::DayOfWeek::operator==(int iDayOfWeek)
{    
    return  m_iDayOfWeek == iDayOfWeek;
}
string DateTime::DayOfWeek::name(bool longName) const
{
    return ms_label[m_iDayOfWeek][longName ? mnLong : mnShort];
}
short DateTime::DayOfWeek::ordinal() const
{
    return m_iDayOfWeek;
}

//////////////////////////////

const char *DateTime::DayOfWeek::ms_label[][2] = {
                    {"", ""},
                    {"Mon", "Monday"},
                    {"Tue", "Tuesday"},
                    {"Wed", "Wednesday"},
                    {"Thu", "Thursday"},
                    {"Fri", "Friday"},
                    {"Sat", "Saturday"},
                    {"Sun", "Sunday"},
                    {0, 0}
};

const char *DateTime::Month::ms_label[][2] = {
                    {"", ""},
                    {"Jan", "January"},
                    {"Feb", "February"},
                    {"Mar", "March"},
                    {"Apr", "April"},
                    {"May", "May"},
                    {"Jun", "June"},
                    {"Jul", "July"},
                    {"Aug", "August"},
                    {"Sep", "September"},
                    {"Oct", "October"},
                    {"Nov", "November"},
                    {"Dec", "December"},
                    {0, 0}
};

//const char *DateTime::Zone::ms_label[] = {
//    "UT",    "GMT","EST","EDT","CST", "CDT", "MST", "MDT","PST", "PDT", 0
//};

const char *DateTime::Zone::ms_label[] = {
"UNK",
"GMT", "UT", "BST", "CET",
"MET", "EET", "IST","METDST", "MET DST",
"EDT", "CDT", "EST", "CST",
"MDT", "MST", "PDT", "HKT",
"PST", "JST", 0
};

int DateTime::Zone::ms_offset[] = {
0,
+000, +000, +100, +100,
+100, +200, +200, +200, +200,
-400, -500, -500, -600,
-600, -700, -700, +800,
-800 +900,
0
};

/**
 * Default constructor sets the Date to the Epoch (00:00:00 UTC, January 1, 1970)
 */
DateTime::DateTime()
: m_iDayOfWeek(0), m_iDay(1), m_iMonth(1), m_iYear(1970),
  m_iHour(0), m_iMinute(0), m_iSecond(0),
  m_zone("UTC")
{
}

DateTime::DateTime(const string& text)
: m_iDayOfWeek(0), m_iDay(1), m_iMonth(1), m_iYear(1970),
  m_iHour(0), m_iMinute(0), m_iSecond(0),
  m_zone("UTC")
{
    set(text);
}

DateTime::DateTime(const char* cstr)
: m_iDayOfWeek(0), m_iDay(1), m_iMonth(1), m_iYear(1970),
  m_iHour(0), m_iMinute(0), m_iSecond(0),
  m_zone("UTC")
{
    set(cstr);
}

void DateTime::set(const string& input)
{
    if(input.empty())
        return;
    string can_input = remove_external_blanks(canonical(input));
    StringTokenizer stok(&can_input, " ,");
    string tok; int i = 0;
    if(!stok.next(tok)) return;
    if(!tok.empty() && !isdigit(tok[0]))
        m_iDayOfWeek = DayOfWeek(tok).ordinal();
    else {
        // there's no day of week
        m_iDay = utils::str2int(tok);
        ++i;
    }
    
    // gg mon aa[aa]    
    while(i < 3)
    {
        if(!stok.next(tok)) return;
        if(tok.empty())
            continue; /* there's a ' ' after ',' ("Wed, 23 Nov...") */
        switch(i)
        {
        case 0: m_iDay = utils::str2int(tok); break;
        case 1: m_iMonth = Month(tok).ordinal(); break;
        case 2: m_iYear = utils::str2int(tok); break;
        }
        ++i;
    }

    stok.setDelimList(" :");
    for(i = 0; i < 3; ++i)
    {
        if(!stok.next(tok)) return;
        switch(i)
        {
        case 0: m_iHour = utils::str2int(tok); break;
        case 1: m_iMinute = utils::str2int(tok); break;
        case 2: // seconds field is optional
            if(tok.length() == 2)
            {
                m_zone = "";
                m_iSecond = utils::str2int(tok);
            } else {
                m_zone = tok;
            }
            break;
        }
    }

    stok.setDelimList(" ");
    // handles multi word timezones (MET DST)
    while(stok.next(tok))
    {
        if(!m_zone.empty())
            m_zone += " ";
        m_zone += tok;
    }
}


/*
    based on an algorithm of J.I. Perelman [1907].
*/
DateTime::DayOfWeek DateTime::dayOfWeek() const
{
    if(!m_iDayOfWeek)
    { // code from C-Faq Question 20.31
        int y = year(), m = month().ordinal(), d = day();
        static int t[] = {0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4};
        y -= m < 3;
        m_iDayOfWeek = (y + y/4 - y/100 + y/400 + t[m-1] + d) % 7;
        // we use 1(Mon)..7 not 0(Sun)..6 as returned by the previous algorithm
        // so convert
        m_iDayOfWeek = (m_iDayOfWeek == 0 ? 7 : m_iDayOfWeek);
    }
    return DayOfWeek(m_iDayOfWeek);
}

short DateTime::day() const
{
    return m_iDay;
}

DateTime::Month DateTime::month() const
{
    return Month(m_iMonth);
}

short DateTime::year() const
{
    return m_iYear;
}

short DateTime::hour() const
{
    return m_iHour;
}

short DateTime::minute() const
{
    return m_iMinute;
}

short DateTime::second() const
{
    return m_iSecond;
}

DateTime::Zone DateTime::zone() const
{
    return Zone(m_zone);
}


std::string DateTime::str() const
{
    stringstream ss;
    ss << *this;
    return ss.str();
}

FieldValue* DateTime::clone() const
{
    return new DateTime(*this);
}

ostream& operator<<(ostream& os, const DateTime& dt)
{
    int width = (int)os.width(), fill = os.fill();

    os << dt.dayOfWeek().name() << ", "
       << setw(2) << setfill('0') << dt.day() << " "
       << dt.month().name() << " "
       << setw(2) << setfill('0') << dt.year() << " "
       << setw(2) << setfill('0') << dt.hour() << ":"
       << setw(2) << setfill('0') << dt.minute() << ":"
       << setw(2) << setfill('0') << dt.second() << " "
       << dt.zone().name();

    os.width(width);
    os.fill(fill);
    return os;
}


}

