//
//  SqueezeBox.m
//  SqueezeBox 0.2.0
//
//  Created by CHARLES GILLINGHAM on 9/21/13.
//  Copyright (c) 2013 CHARLES GILLINGHAM. All rights reserved.
//

#import "CDebugMessages.h"
#import "CDebugSelfCheckingObject.h"
#import <objc/runtime.h>

#ifdef DEBUG

// The page width I would like to see things at. Basically, it's the width of the screen I'm looking at.

#define CDebug_PageWidth (160)
#define CDebug_IndentIncrement (6)
int CDebug_Indent = 0;
#define printfi  printf("%*s", CDebug_Indent, ""); printf


NSString * CDebugIndentInnerLines(NSString * s, int indent)
{
    return [s stringByReplacingOccurrencesOfString:@"\n"
                                        withString:[NSString stringWithFormat:@"\n%-*s", indent, ""]];
}



// Create a description of an object that will fit into "maxLength".
// Use the "displayName" property if it has one, otherwise use the description.
// Handle class objects as well.
NSString * CDebugObjectDescription( id object, NSInteger maxLength)
{
    if (maxLength < 1) return @""; // ridiculous, but I need it as an invariant.
    
    if (!object) {
        return @"nil";
    }
    
    NSString * desc;
    if (class_isMetaClass(object_getClass(object))) {
        desc = [NSString stringWithCString: class_getName((Class) object) encoding:NSASCIIStringEncoding];
    } else {
        NSObject * nsObject = (NSObject *) object;
        
        if ([nsObject isKindOfClass:[NSArray class]]) {
            NSArray * a = (NSArray *) object;
            switch (a.count) {
                case 0:
                    return @"@[]";
                case 1:
                    return [NSString stringWithFormat:@"@[%@]", CDebugObjectDescription(a[0], maxLength-3)];
                case 2:
                    return [NSString stringWithFormat:@"@[%@,%@]",
                            CDebugObjectDescription(a[0], (maxLength-4)/2),
                            CDebugObjectDescription(a[1], (maxLength-4)/2)];
                default:
                    return [NSString stringWithFormat:@"@[%@,%@,...]",
                            CDebugObjectDescription(a[0], (maxLength-8)/2),
                            CDebugObjectDescription(a[1], (maxLength-8)/2)];
            }
        } else if ([nsObject respondsToSelector:@selector(displayName)]) {
            desc = ((NSString *) [nsObject performSelector:@selector(displayName)]);
        } else {
            desc = nsObject.description;
        }
    }
    
    if (desc.length > maxLength) {
        return [NSString stringWithFormat:@"%@ ...",[desc substringToIndex:maxLength-4]];
    } else {
        return desc;
    }
}



void CDebugPrintLocation(id objSelf, const char * func, const char * file, int line)
{
    if (objSelf) {
        printfi("Self:       %s\n", (CDebugObjectDescription(objSelf, CDebug_PageWidth-CDebug_Indent-12).UTF8String));
    }
    
    
    if (func &&
        (strcmp(func,file) != 0) // XCTest uses the function name as the description; very confusing to see both. This kludge eliminates it.
        )
    {
        printfi("Function:   %s\n", func);
    }
    
    // Print only the file name, not the path
    if (file) {
        const char * s;
        for(s = file + strlen(file); *s != '/'; s--);
        printfi("File:       \'...%s\'\n",s);
        printfi("Line:       %d\n", line);
    }
}


//------------------------------------------------------------------------------
#pragma mark                   Status Message
//------------------------------------------------------------------------------

void CDebugStatusMsg ( id object, const char * msg )
{
    printf("%40s%s\n", CDebugObjectDescription(object, 40).UTF8String, msg);
}



//------------------------------------------------------------------------------
#pragma mark                   FAIL
//------------------------------------------------------------------------------
// All the failures go through CDebugFail, so you can set a breakpoint on "return NO" below, and see the whole problem.

BOOL CDebugFail(NSString * msg,
                id objSelf,
                const char * func,
                const char * file,
                int line)
{
    
    printfi("FAIL: ");
    if (msg) {
        printf("%s\n", CDebugIndentInnerLines(msg, CDebug_Indent + strlen("FAIL: ") ).UTF8String);
    }
    
    // Only print the location at the top level (i.e., print the location that the original call to CDebug was made from; don't print the location of recursive calls from CDebug.
    if (CDebug_Indent > 0) return NO;
    
    CDebug_Indent += CDebug_IndentIncrement;
    CDebugPrintLocation(objSelf, func, file, line);
    CDebug_Indent -= CDebug_IndentIncrement;
    
    // Set a break point on this line, and you will see all failures, with location and information already printed.
    return NO;
}



BOOL CDebugFailedAssertion(NSString * msg,
                           id self, const char * func, const char * file, int line,
                           const char * expr)
{
    
    // Split the string where it makes sense.
    if (!msg) msg = @"Assertion is false:";
  
    int oneRowMaxWidth = (CDebug_PageWidth - CDebug_Indent - strlen("FAIL: ") - (int)msg.length) - 1;
    if (strlen(expr) > oneRowMaxWidth) {
        msg = [NSString stringWithFormat:@"%@\n%s", msg, expr];
    } else {
        msg = [NSString stringWithFormat:@"%@ %s",msg, expr];
    }
   
    return CDebugFail(msg, self, func, file, line);
}




BOOL CDebugFailedComparison(NSString   * problem,
                            id           self,   // The object which initiated the comparison
                            const char * func,
                            const char * file,
                            int          line,
                            id           obj1,   // The objects being compared.
                            id           obj2,
                            const char * obj1Expr,
                            const char * obj2Expr,
                            NSUInteger   maxRows)
{
    NSUInteger indentExtras = CDebug_Indent + strlen("FAIL:  ");
    NSUInteger problemLen = (problem.length < strlen("Reversed") ? strlen("Reversed") : problem.length);
    NSUInteger sameRowExtras = indentExtras + strlen(" | ") + strlen(" | ") + problemLen;
    NSUInteger sameRowMaxEqnLen = (CDebug_PageWidth - sameRowExtras - 1)/2;
    NSUInteger twoRowsMaxEqnLen = (CDebug_PageWidth - indentExtras);
    NSUInteger maxEqnLen = (maxRows == 1 ? sameRowMaxEqnLen : twoRowsMaxEqnLen);
 
    NSString * eqn1, * eqn2, * desc;
    if (obj1Expr != NULL) {
        NSUInteger eqn1Extras = strlen(obj1Expr) + strlen(" == ");
        NSUInteger dMaxLen = maxEqnLen - eqn1Extras;
        desc = CDebugObjectDescription(obj1, dMaxLen);
        eqn1 = [NSString stringWithFormat:@"%s == %@", obj1Expr, desc];
    } else {
        eqn1 = @"<Doesn't exist>";
    }
    if (obj2Expr != NULL) {
        NSUInteger eqn2Extras = strlen(obj2Expr) + strlen(" == ");
        NSUInteger dMaxLen = maxEqnLen - eqn2Extras;
        desc = CDebugObjectDescription(obj2, dMaxLen);
        eqn2 = [NSString stringWithFormat:@"%s == %@", obj2Expr, desc];
    } else {
        eqn2 = @"<Doesn't exist>";
    }
    
    NSUInteger oneRowlen = sameRowExtras + eqn1.length + eqn2.length;
    if (oneRowlen < CDebug_PageWidth) {
        NSUInteger maxLen = (eqn1.length > eqn2.length ? eqn1.length : eqn2.length);
        if (maxLen < strlen("<Doesn't exist>")) maxLen = strlen("<Doesn't exist>");
        if (maxLen <= sameRowMaxEqnLen) {
            desc = [NSString stringWithFormat:@"%-*s | %-*s | %-*s",
                    (int)problemLen, problem.UTF8String,
                    (int)maxLen, eqn1.UTF8String,
                    (int)maxLen, eqn2.UTF8String];
        } else {
            desc = [NSString stringWithFormat:@"%-*s | %@ | %@",
                    (int)problemLen, problem.UTF8String,
                    eqn1, eqn2];
        }
    } else {
        desc = [NSString stringWithFormat:@"%@\n%@\n%@", problem, eqn1, eqn2];
    }
    
    if ([problem isEqualToString:@""]) {
        printfi("OK:   ");
        printf("%s\n", CDebugIndentInnerLines(desc, CDebug_Indent + strlen("OK:   ") ).UTF8String);
        return YES;
    } else {
        return CDebugFail(desc, self, func, file, line);
    }
}


//------------------------------------------------------------------------------
#pragma mark                   ASSERTIONS
//------------------------------------------------------------------------------


BOOL CDebugEqualNumbers(long double n1,
                        long double n2,
                        id           self,
                        const char * func,
                        const char * file,
                        int line,
                        const char * obj1Expr,
                        const char * obj2Expr)
{
    if (isnan(n1)) {
        return CDebugFail([NSString stringWithFormat:@"%s is not a number", obj1Expr], self, file, func, line);
        
    } else if (isnan(n2)) {
        return CDebugFail([NSString stringWithFormat:@"%s is not a number", obj2Expr], self, file, func, line);
        
    } else if (n1 != n2) {
        if (floor(n1) == n1 && floor(n2) == n2) {

            return CDebugFailedComparison(@"Unequal",
                                   self, func, file, line,
                                   [NSNumber numberWithInteger:floor(n1)],
                                   [NSNumber numberWithInteger:floor(n2)],
                                   obj1Expr, obj2Expr, NO);
        } else {
            
            // Compare floating point numbers
            double diff = n1 - n2;
            if (diff < 0) diff = -diff;
            if (diff < CDebugFloatingPointTolerance) {
                return YES;
            }
            
            return CDebugFailedComparison(@"Unequal",
                                   self, func, file, line,
                                   [NSNumber numberWithFloat:n1],
                                   [NSNumber numberWithFloat:n2],
                                   obj1Expr, obj2Expr, NO);
        }
    }
    
    return YES;
}



BOOL CDebugEqualStrings(const char * s1,
                        const char * s2,
                        id           self,
                        const char * func,
                        const char * file,
                        int line,
                        const char * obj1Expr,
                        const char * obj2Expr)
{
    return CDebugEqualObjects([NSString stringWithCString:s1 encoding:NSASCIIStringEncoding],
                              [NSString stringWithCString:s2 encoding:NSASCIIStringEncoding],
                              self,
                              func, file, line,
                              obj1Expr, obj2Expr);
}





BOOL CDebugEqualLists(NSArray    * list1,
                      NSArray    * list2,
                      id           self,
                      const char * func,
                      const char * file,
                      int line,
                      const char * list1Expr,
                      const char * list2Expr)
{
    if ([list1 isEqualToArray:list2]) return YES;
    
    NSUInteger problems = 0;
    NSUInteger maxProblems = 4;
    NSInteger i,j;
    id obj1, obj2;
    
    // Count the number of problems, to decide how to describe them:
    // If there are 4 problems or less, then just print the rows with problems; otherwise, print all the rows.
    for (i = 0, j = 0; (i < list1.count || j < list2.count) && problems <= maxProblems; i++, j++) {
        if (i >= list1.count) {
            problems++;
        } else if (j >= list2.count) {
            problems++;
        } else {
            obj1 = list1[i];
            obj2 = list2[j];
            
            if (![obj1 isEqual:obj2]) {
                problems++;
                
                // Skip missing or reversed.
                if (i+1 < list1.count && [list1[i+1] isEqualTo:list2[j]]) i++;
                if (j+1 < list2.count && [list1[i] isEqualTo:list2[j+1]]) j++;
            }
        }
    }
    
    if (problems == 0) return YES;
    
    CDebug_Indent+=CDebug_IndentIncrement;
    
    // Show all
    const char * obj1Expr, * obj2Expr;
    NSString * problem;
    NSUInteger maxRows = 1;

    for (i = 0, j = 0; (i < list1.count || j < list2.count); i++, j++) {
        obj1Expr = [NSString stringWithFormat:@"%s[%d]", list1Expr, (int)i].UTF8String;
        obj2Expr = [NSString stringWithFormat:@"%s[%d]", list2Expr, (int)j].UTF8String;
        
        maxRows = 2;
        problem = nil; // Don't print a message if this is still nil.
        
        if (i >= list1.count) {
            obj1 = nil;
            obj1Expr = NULL;
            obj2 = list2[j];
            problem = @"Added";
        } else if (j >= list2.count) {
            obj1 = list1[i];
            obj2 = nil;
            obj2Expr = NULL;
            problem = @"Missing";
        } else {
            obj1 = list1[i];
            obj2 = list2[j];
            
            if ([obj1 isEqual: obj2]) {
               
                // If there are more than 4 problems, just print the whole list so we can inspect it.f
                if (problems > maxProblems) {
                    problem = @"";
                    maxRows = 1;
                }
            } else if (i+1 < list1.count && [list1[i+1] isEqual:list2[j]]) {
                if (j+1 < list2.count && [list1[i] isEqual:list2[j+1]]) {
                    problem = @"Reversed";
                } else {
                    problem = @"Missing";
                    obj2Expr = NULL;
                    obj2 = nil;
                    j--;
                }
            } else if (j+1 < list2.count && [list1[i] isEqual:list2[j+1]]) {
                problem = @"Added";
                obj1Expr = NULL;
                obj1 = nil;
                i--;
            } else if (j > 0 && i > 0 && ([list1[i-1] isEqual:list2[j]]) && ([list1[i] isEqual:list2[j-1]])) {
                problem = @"Reversed";
            } else {
                CDebugEqualObjects(list1[i],list2[j],
                                   NULL,NULL,NULL,line,
                                   obj1Expr, obj2Expr);
                continue;
            }
        }
        
        if (problem) {
            CDebugFailedComparison(problem,
                                   nil, NULL, NULL, 0,
                                   obj1, obj2, obj1Expr, obj2Expr, maxRows);
        }
    }
    
    CDebug_Indent -= CDebug_IndentIncrement;
    CDebugFailedComparison(@"Unequal lists", self, func, file, line, list1, list2, list1Expr, list2Expr, 3);
    return NO;
}



BOOL CDebugEqualData(NSData     * data1,
                     NSData     * data2,
                    id           self,
                     const char * func,
                     const char * file,
                     int line,
                     const char * obj1Expr,
                     const char * obj2Expr)
{
    if ([data1 isEqualToData:data2]) return YES;
    
    // Change them into lists and compare byte by byte.
    NSMutableArray * list1 = [NSMutableArray arrayWithCapacity:data1.length];
    for (NSUInteger i = 0; i < data1.length; i++) {
        [list1 addObject:[NSNumber numberWithInteger:((Byte *)data1.bytes)[i]]];
    }
    NSMutableArray * list2 = [NSMutableArray arrayWithCapacity:data2.length];
    for (NSUInteger i = 0; i < data1.length; i++) {
        [list2 addObject:[NSNumber numberWithInteger:((Byte *)data2.bytes)[i]]];
    }
    NSString * data1Expr = [NSString stringWithFormat:@"%s.bytes", obj1Expr];
    NSString * data2Expr = [NSString stringWithFormat:@"%s.bytes", obj2Expr];
    
    return CDebugEqualLists(list1, list2, self, func, file, line, data1Expr.UTF8String, data2Expr.UTF8String);
}




BOOL CDebugEqualObjects(NSObject   * object1,
                        NSObject   * object2,
                        id           self,
                        const char * func,
                        const char * file,
                        int line,
                        const char * obj1Expr,
                        const char * obj2Expr)
{
    if (object1 == object2) {
        return YES;
    }
    
    if (!object1) {
        NSString * msg  = [NSString stringWithFormat:@"%s is nil", obj1Expr];
        return CDebugFail(msg, self, func, file, line);
    }
    
    if (!object2) {
        NSString * msg  = [NSString stringWithFormat:@"%s is nil", obj2Expr];
        return CDebugFail(msg, self, func, file, line);
    }
    
    if ([object1 isKindOfClass:[NSNumber class]] &&
        [object2 isKindOfClass:[NSNumber class]])
    {
        return CDebugEqualNumbers(((NSNumber *) object1).doubleValue,
                                  ((NSNumber *) object2).doubleValue,
                                  self, func, file, line, obj1Expr, obj2Expr);
    }
    
    if ([object1 isKindOfClass:[NSArray class]] &&
        [object2 isKindOfClass:[NSArray class]])
    {
        return CDebugEqualLists((NSArray *) object1, (NSArray *) object2,
                                self, func, file, line, obj1Expr, obj2Expr);
    }
    
    if ([object1 isKindOfClass:[NSData class]] &&
        [object2 isKindOfClass:[NSData class]])
    {
        return CDebugEqualData((NSData *) object1, (NSData *) object2,
                               self, func, file, line, obj1Expr, obj2Expr);
    }
    
   if (![object1 isEqual:object2]) {
       
       // See if it has a version which prints more detail.
       if ([object1 respondsToSelector:@selector(checkIsEqual:)]) {
           NSObject <CDebugSelfCheckingObject> * obj1 = (NSObject <CDebugSelfCheckingObject> *) object1;
           CDebug_Indent+=CDebug_IndentIncrement;
           [obj1 checkIsEqual:object2];
           CDebug_Indent-=CDebug_IndentIncrement;
       }
      
       return CDebugFailedComparison(@"Unequal", self, func, file, line, object1, object2, obj1Expr, obj2Expr, 3);
    }
    
    return YES;
}




BOOL CDebugCheckObject (BOOL check,
                        NSObject * object,
                        Class c,
                        const char * func,
                        const char * file,
                        int line,
                        const char * objectExpression)
{
    if (!object) {
        return CDebugFail([NSString stringWithFormat:@"Self-check failed on %s. Object is nil",
                           objectExpression],
                          object, func, file, line);
    } else if (![object isKindOfClass:c]) {
        return CDebugFail([NSString stringWithFormat:@"Self-check failed on %s. Object is of the wrong class",
                           objectExpression],
                          object, func, file, line);
    } else if (![object conformsToProtocol:@protocol(CDebugSelfCheckingObject)]) {
        return CDebugFail([NSString stringWithFormat:@"Self-check failed on %s. Object does not implement [self check].",
                           objectExpression],
                          object, func, file, line);
    } else {
       if (!check) {
            return CDebugFail([NSString stringWithFormat:@"Self-check failed on %s.",
                               objectExpression],
                              object, func, file, line);
        } else {
            return YES;
        }
    }
}



//------------------------------------------------------------------------------
#pragma mark                   Common Errors
//------------------------------------------------------------------------------



void CDebugUmbrellaClassError(Class c,
                              id object,
                              const char * func,
                              const char * file,
                              int line)
{
    if ([object class] == c) {
        CDebugFail(@"ERROR: This class should not be allocated; only subclasses of this class should be allocated.",object,func,file,line);
    }
    
}

//------------------------------------------------------------------------------
#pragma mark                   Test Aids
//------------------------------------------------------------------------------

void CDebugInspectionTestHeader(char * title, char * message) {
    printf("\n\n\n--------------------------------------------------------------------------\n");
    printf("%s\n", title);
    printf("%s\n", message);
}


void CDebugInspectionTestFooter()
{
    printf("\n\n\n--------------------------------------------------------------------------\n\n\n");
}


//------------------------------------------------------------------------------
#pragma mark                   All Paths Testing
//------------------------------------------------------------------------------


@interface CDebugLocation ()
@property id obj;
@property const char * fileName;
@property const char * functionName;
@property int lineNumber;
@end

@implementation CDebugLocation
@synthesize obj, fileName, functionName, lineNumber;

+ (instancetype) locationWith: (id) obj : (const char * ) fileName : (const char *) functionName : (int) lineNumber
{
    CDebugLocation * loc = [CDebugLocation new];
    loc.obj = obj;
    loc.fileName = fileName;
    loc.functionName = functionName;
    loc.lineNumber = lineNumber;
    return loc;
}


- (void) show
{
    if (obj) {
        printfi("Self:       %s\n", (CDebugObjectDescription(obj, CDebug_PageWidth-CDebug_Indent-12).UTF8String));
    }
    
    
    if (functionName &&
        (strcmp(functionName,fileName) != 0) // XCTest uses the function name as the description; very confusing to see both. This kludge eliminates it.
        )
    {
        printfi("Function:   %s\n", functionName);
    }
    
    // Print only the file name, not the path
    if (fileName) {
        const char * s;
        for(s = fileName + strlen(fileName); *s != '/'; s--);
        printfi("File:       \'...%s\'\n",s);
        printfi("Line:       %d\n", lineNumber);
    }
   
}

@end




#define CDEBUG_PATHMAX 500

BOOL CDebug_PathWasExecuted[CDEBUG_PATHMAX];
CDebugLocation * CDebug_PathLocation[CDEBUG_PATHMAX];


void CDebugInitAllPathsTest ()
{
    for (NSUInteger i = 0; i < CDEBUG_PATHMAX; i++) {
        CDebug_PathWasExecuted[i] = NO;
    }
}


void CDebugCheckPath(int i, CDebugLocation * loc)
{
    CDebug_PathWasExecuted[i] = YES;
    CDebug_PathLocation[i] = loc;
}


BOOL CDebugCheckAllPaths( int count )
{
    BOOL fOK = YES;
    for (int i = 0; i < count; i++) {
        if (!CDebug_PathWasExecuted[i]) {
 
            int startLine = 0;
            for (NSInteger j = i; j >= 0; j--) {
                if (CDebug_PathWasExecuted[j]) {
                    startLine = CDebug_PathLocation[j].lineNumber;
                    break;
                }
            }
            
            int stopLine = 1000000;
            for (NSInteger j = i; j < count; j++) {
                if (CDebug_PathWasExecuted[j]) {
                    stopLine = CDebug_PathLocation[j].lineNumber;
                    break;
                }
            }
        

            NSString * msg = [NSString stringWithFormat:@"Path(s) on lines between %d and %d were not executed (case %d)", startLine, stopLine,i];
            CDebugFail(msg, nil, NULL, NULL, 0);
            fOK = NO;
        }
    }
    return fOK;
}


#endif