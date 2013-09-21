/***************************************************************************
    copyright            : (C) 2002-2008 by Stefano Barbato
    email                : stefano@codesink.org

    $Id: fileop.cxx,v 1.5 2008-10-07 11:06:26 tat Exp $
 ***************************************************************************/
#include <mimetic/os/fileop.h>
#include <mimetic/libconfig.h>
#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif
#ifdef HAVE_SYS_TYPES_H
#include <sys/types.h>
#endif
#ifdef HAVE_SYS_STAT_H
#include <sys/stat.h>
#endif

using namespace std;

namespace mimetic
{

//static
bool FileOp::remove(const string& fqn)
{
    return unlink(fqn.c_str()) == 0;
}

//static
bool FileOp::move(const string& oldf, const string& newf)
{
#if defined(CONFIG_UNIX)
    if(link(oldf.c_str(), newf.c_str()) == 0)
    {
        unlink(oldf.c_str());
        return true;
    }
    return false;
#elif defined(CONFIG_WIN32)
  return(rename(oldf.c_str(), newf.c_str()) == 0);
#else
#error sys not supported
#endif
}
//static
bool FileOp::exists(const string& fqn)
{
    struct stat st;
    return ::stat(fqn.c_str(), &st) == 0;
}

//static
uint FileOp::size(const string& fqn)
{
    struct stat st;
    if(::stat(fqn.c_str(), &st) == 0)
        return (uint)st.st_size;
    else
        return 0;
}

//static
uint FileOp::ctime(const string& fqn)
{
    struct stat st;
    if(::stat(fqn.c_str(), &st) == 0)
        return (uint)st.st_ctime;
    else
        return 0;
}

//static
uint FileOp::atime(const string& fqn)
{
    struct stat st;
    if(::stat(fqn.c_str(), &st) == 0)
        return (uint)st.st_atime;
    else
        return 0;
}

//static
uint FileOp::mtime(const string& fqn)
{
    struct stat st;
    if(::stat(fqn.c_str(), &st) == 0)
        return (uint)st.st_mtime;
    else
        return 0;
}

}


