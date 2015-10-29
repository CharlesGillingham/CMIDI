//
//  CAUNoErr.h
//  CAudioUnits
//
//  Created by CHARLES GILLINGHAM on 9/16/15.
//  Copyright (c) 2015 CharlesGillingham. All rights reserved.
//

#ifdef DEBUG
Boolean CAUNoErr(OSStatus errCode, char * code);
#define CAUNOERR(expr)  CAUNoErr(expr,#expr)
#else
// Can't use NSAssert, because this is included in C files.
#define CAUNOERR(expr)  assert((expr)==0)
#endif