//
//  NSObject+UMExtensions.h
//  UniversalMailer
//
//  Created by luca on 24/05/16.
//  Copyright © 2017 noware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (UMExtensions)

+ (void)addMethod: (SEL) selector fromClass: (Class)fClass;
+ (void)addClassMethod: (SEL)selector fromClass: (Class)fClass;

+ (void)swizzleMethod: (SEL)left withMethod: (SEL)right;
+ (void)swizzleClassMethod: (SEL)left withMethod: (SEL)right;

@end
