// Copyright (c) The HLSL2GLSLFork Project Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE.txt file.


#ifndef _COMMON_INCLUDED_
#define _COMMON_INCLUDED_

#ifdef _WIN32
   #include <basetsd.h>
#elif defined (solaris)
   #include <sys/int_types.h>
   #define UINT_PTR uintptr_t
#else
   #include <cstdint>
   #define UINT_PTR uintptr_t
#endif

/* windows only pragma */
#ifdef _MSC_VER
   #pragma warning(disable : 4786) // Don't warn about too long identifiers
   #pragma warning(disable : 4514) // unused inline method
   #pragma warning(disable : 4201) // nameless union
#endif

#include <set>
#include <vector>
#include <map>
#include <string>
#include <cstdio>
#include <sstream>

#include <cassert>

#include "PoolAlloc.h"
#include "../MachineIndependent/preprocessor/sourceloc.h"

#if !defined(_WIN32)
#define _vsnprintf vsnprintf
#define _stricmp strcasecmp
#endif

//
// Put POOL_ALLOCATOR_NEW_DELETE in base classes to make them use this scheme.
//
#define POOL_ALLOCATOR_NEW_DELETE(A)                                  \
    void* operator new(size_t s) { return (A).allocate(s); }          \
    void* operator new(size_t, void *_Where) { return (_Where);	}     \
    void operator delete(void*) { }                                   \
    void operator delete(void *, void *) { }                          \
    void* operator new[](size_t s) { return (A).allocate(s); }        \
    void* operator new[](size_t, void *_Where) { return (_Where);	} \
    void operator delete[](void*) { }                                 \
    void operator delete[](void *, void *) { }

namespace hlsl2glsl {

//
// Pool version of string.
//
typedef pool_allocator<char> TStringAllocator;
typedef std::basic_string <char, std::char_traits<char>, TStringAllocator > TString;
inline TString* NewPoolTString(const char* s)
{
   void* memory = GlobalPoolAllocator.allocate(sizeof(TString));
   return new(memory) TString(s);
}

//
// Pool allocator versions of containers
//
template <class T> class TVector : public std::vector<T, pool_allocator<T> >
{
public:
   typedef typename std::vector<T, pool_allocator<T> >::size_type size_type;
   TVector() : std::vector<T, pool_allocator<T> >()
   {
   }
   TVector(const pool_allocator<T>& a) : std::vector<T, pool_allocator<T> >(a)
   {
   }
   TVector(size_type i): std::vector<T, pool_allocator<T> >(i)
   {
   }
};


//
// templatized min and max functions.
//
template <class T> T Min(const T a, const T b)
{
   return a < b ? a : b;
}
template <class T> T Max(const T a, const T b)
{
   return a > b ? a : b;
}

//
// Create a TString object from an integer.
//
inline const TString String(const int i, const int base = 10)
{
   char text[16];     // 32 bit ints are at most 10 digits in base 10

   // we assume base 10 for all cases
   snprintf(text, sizeof(text), "%d", i);

   return text;
}

inline void ReplaceString (std::string& target, const std::string& search, const std::string& replace, size_t startPos=0)
{
	if (search.empty())
		return;
	
	std::string::size_type p = startPos;
	while ((p = target.find (search, p)) != std::string::npos)
	{
		target.replace (p, search.size (), replace);
		p += replace.size ();
	}
}

} // namespace hlsl2glsl

#endif // _COMMON_INCLUDED_

