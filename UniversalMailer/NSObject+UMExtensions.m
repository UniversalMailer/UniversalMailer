//
//  NSObject+UMExtensions.m
//  UniversalMailer
//
//  Created by luca on 24/05/16.
//  Copyright © 2016 noware. All rights reserved.
//

#import "NSObject+UMExtensions.h"

#import <objc/runtime.h>

@implementation NSObject (UMExtensions)

+ (void)addMethod: (SEL)selector fromClass: (Class)fClass {
    Method method = class_getInstanceMethod(fClass, selector);
    class_addMethod(self.class, selector, method_getImplementation(method), method_getTypeEncoding(method));
}

+ (void)swizzleMethod: (SEL)left withMethod: (SEL)right {
    Method m1 = class_getInstanceMethod(self.class, left);
    Method m2 = class_getInstanceMethod(self.class, right);
    if( m1 ){
        if( m2 ){
            method_exchangeImplementations(m1, m2);
        }
    }
}

+ (void)addClassMethod: (SEL)selector fromClass: (Class)fClass {
    Method method = class_getInstanceMethod(fClass, selector);
    class_addMethod(object_getClass(self), selector, method_getImplementation(method), method_getTypeEncoding(method));
}

+ (void)swizzleClassMethod: (SEL)left withMethod: (SEL)right {
    Method m1 = class_getClassMethod(self.class, left);
    Method m2 = class_getClassMethod(self.class, right);
    if( m1 && m2 ){
        method_exchangeImplementations(m1, m2);
    }
}

@end
