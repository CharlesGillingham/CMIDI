//
//  CDebugMessages.h
//  CDebug
//
//  Created by CHARLES GILLINGHAM on 9/21/13.
//  Copyright (c) 2013 CHARLES GILLINGHAM. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CDEBUG_INCLUDE_WARNINGS       (YES)

#ifdef DEBUG

//#define CSTATUSMSG(msg)               CDebugStatusMsg(self,msg)

//------------------------------------------------------------------------------
#pragma mark                   Assertions
//------------------------------------------------------------------------------
#define CFAIL(msg)                    CFAIL_GENERAL(msg,self)
#define CFAIL_IN_C(msg)               CFAIL_GENERAL(msg,NULL)
#define CASSERT(expr)                 CASSERT_GENERAL(NULL,self,(expr))
#define CASSERT_MSG(expr,msg)         CASSERT_GENERAL(msg, self,(expr))
#define CASSERT_IN_C(expr)            CASSERT_GENERAL(NULL,NULL,(expr))
#define CASSERTEQUAL(n1,n2)           CASSERTEQUAL_GENERAL(n1,n2)
#define CCHECK(obj)                   CCHECK_GENERAL(obj,NSObject)
#define CCHECK_CLASS(obj,cls)         CCHECK_GENERAL(obj,cls)

// Strictly for convenience
#define CNOERR(expr)                  (CASSERT((expr) == 0))
#define CASSERT_RET(expr)             if (!CASSERT((expr))) return NO
#define CASSERTEQUAL_RET(n1,n2)       if (!CASSERTEQAUL(expr)) return NO


//------------------------------------------------------------------------------
#pragma mark                   Common Errors
//------------------------------------------------------------------------------

// Place this in a class that has a designated initializer
#define CENFORCE_DESIGNATED_INITIALIZER  \
- (id) init { CDebugFail(@"This class has a designated initializer or initializers.",[self class],"init",__FILE__,__LINE__); return nil; [self init]; }

// Place this in the designated initializer of an umbrella class
#define CENFORCE_UMBRELLA_CLASS(c) \
if ([self class] == [c class]) { \
CDebugFail(@"ERROR: This class should not be allocated; only subclasses of this class should be allocated.\n",self,__func__,__FILE__,__LINE__); \
}

//------------------------------------------------------------------------------
#pragma mark                   Trace
//------------------------------------------------------------------------------
#define CDEBUG_TRACE_DEALLOCS

//------------------------------------------------------------------------------
#pragma mark                   CDebugLocation
//------------------------------------------------------------------------------

@interface CDebugLocation : NSObject
+ (instancetype) locationWith: (id) obj : (const char * ) fileName : (const char *) functionName : (int) lineNumber;
@end
#define CDEBUGLOCATION      ([CDebugLocation locationWith:self:__FILE__:__func__:__LINE__])
#define CDEBUGLOCATION_IN_C ([CDebugLocation locationWith:nil:__FILE__:__func__:__LINE__])

//------------------------------------------------------------------------------
#pragma mark                   Test utilities
//------------------------------------------------------------------------------

#define CDEBUG_INCLUDE_INSPECTION_TESTS YES
void CDebugInspectionTestHeader(char * title, char * explain);
void CDebugInspectionTestFooter();

//#define CDEBUG_CHECKPATH      CDebugCheckPath(__COUNTER__,CDEBUGLOCATION)
//#define CDEBUG_CHECKPATH_IN_C CDebugCheckPath(__COUNTER__,CDEBUGLOCATION_IN_C)
void CDebugCheckPath(int i, CDebugLocation * loc); // Use the Macro

void CDebugInitAllPathsTest ();
BOOL CDebugCheckAllPaths( int count );



//------------------------------------------------------------------------------
#pragma mark                   Main 
//------------------------------------------------------------------------------


BOOL CDebugFail(NSString   * msg,
                id           self,
                const char * func,
                const char * file,
                int line);
#define CFAIL_GENERAL(msg,obj)   CDebugFail((msg),(obj),__func__,__FILE__,__LINE__)

BOOL CDebugFailedAssertion(NSString   * msg,
                           id           self,
                           const char * func,
                           const char * file,
                           int line,
                           const char * expr);
#define CASSERT_GENERAL(msg,obj,code) ((code) ? YES : CDebugFailedAssertion(msg,(obj),__func__,__FILE__,__LINE__,#code))


// If consider two floating point numbers equal if they are less than this distance apart.
#define CDebugFloatingPointTolerance (0.0000000000001)

BOOL CDebugEqualObjects(NSObject   * object1,
                        NSObject   * object2,
                        id           self,
                        const char * func,
                        const char * file,
                        int line,
                        const char * obj1Expr,
                        const char * obj2Expr);

BOOL CDebugEqualNumbers(long double  n1,
                        long double  n2,
                        id           self,
                        const char * func,
                        const char * file,
                        int line,
                        const char * obj1Expr,
                        const char * obj2Expr);

BOOL CDebugEqualStrings(const char * s1,
                        const char * s2,
                        id           self,
                        const char * func,
                        const char * file,
                        int line,
                        const char * obj1Expr,
                        const char * obj2Expr);


#define CASSERTEQUAL_GENERAL(n1, n2)\
_Generic(n1,\
    int:               CDebugEqualNumbers,\
    float:             CDebugEqualNumbers,\
    double:            CDebugEqualNumbers,\
    long:              CDebugEqualNumbers,\
    long long:         CDebugEqualNumbers,\
    long double:       CDebugEqualNumbers,\
    unsigned long:     CDebugEqualNumbers,\
    unsigned long long:CDebugEqualNumbers,\
    unsigned char:     CDebugEqualNumbers,\
    char *:            CDebugEqualStrings,\
    const char *:      CDebugEqualStrings,\
    default:           CDebugEqualObjects\
)(n1,n2,self,__func__,__FILE__,__LINE__,#n1,#n2)


BOOL CDebugCheckObject(BOOL       checked,
                       NSObject * object,
                       Class c,
                       const char * func,
                       const char * file,
                       int line,
                       const char * expr);

#define CCHECK_GENERAL(obj,cls) \
  CDebugCheckObject([obj check],(obj),[cls class],__func__,__FILE__,__LINE__,#obj)

//------------------------------------------------------------------------------
#pragma mark                   With DEBUG undefined
//------------------------------------------------------------------------------

#else

#define CFAIL(expr)                         (YES)
#define CFAIL_IN_C(expr)                    (YES)
#define CASSERT(expr)                       (YES)
#define CASSERT_IN_C(expr)                  (YES)
#define CASSERT_MSG(expr,msg)               (YES)
#define CASSERTEQUAL(n1,n2)                 (YES)
#define CASSERTEQUALOBJS(obj1,obj2)         (YES)
#define CNOERR(expr)                        ((expr)==0)
#define CCHECK(obj)                         (YES)
#define CCHECKC(obj,c)                      (YES)
#define CENFORCE_DESIGNATED_INITIALIZER
#define CENFORCE_UMBRELLA_CLASS(c)
#define CDEBUG_TRACE_DEALLOCS

#endif


