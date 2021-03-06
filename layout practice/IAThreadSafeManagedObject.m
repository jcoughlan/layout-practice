//
//  IAThreadSafeManagedObject.m
//
//  Created by Adam Roth on 15/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IAThreadSafeManagedObject.h"
#import "BKSCoreDataManager.h"
#import <objc/runtime.h>

void dynamicSetter(id self, SEL _cmd, id obj);

@implementation IAThreadSafeManagedObject

- (id) init {
    if (self = [super init]) {
        //myThread = nil;
    }
    return self;
}

- (id) initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context {
    if (self = [super initWithEntity:entity insertIntoManagedObjectContext:context]) {
        if (myThread != [NSThread currentThread]) {
            //myThread = nil;
        }
    }
    
    return self;
}

- (void) awakeFromInsert {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        myThread = [NSThread currentThread];
    });
}

- (void) awakeFromFetch {
    dispatch_async(dispatch_get_main_queue(), ^{
        myThread = [NSThread currentThread];
    });
}

- (NSThread*) myThread {
    return myThread;
}

- (void) recallDynamicSetter:(SEL)sel withObject:(id)obj {
    dynamicSetter(self, sel, obj);
}

- (void) runInvocationOnCorrectThread:(NSInvocation*)call {
    if (! [self myThread] || [NSThread currentThread] == [self myThread]) {
        //okay to invoke
        [call invoke];
    }
    else {
        //remap to the correct thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self runInvocationOnCorrectThread:call];
        });
        //[self performSelector:@selector(runInvocationOnCorrectThread:) onThread:myThread withObject:call waitUntilDone:YES];
    }
}

void dynamicSetter(id self, SEL _cmd, id obj) {
    if (! [self myThread] || [NSThread currentThread] == [self myThread]) {
        //okay to execute
        //XXX:  clunky way to get the property name, but meh...
        
        NSString* propertyName =  NSStringFromSelector(_cmd);
        propertyName = [IAThreadSafeManagedObject propertyNameFromSetterWithString:propertyName];
        
        // NSLog(@"Setting property:%@ on thread %@", propertyName,[NSThread currentThread]);
        if(![obj isKindOfClass:[NSNull class]]&& obj)
        {
            [self willChangeValueForKey:propertyName];
//            NSLog(@"setting %@ for property:%@", [obj description], propertyName);
            
            [self setPrimitiveValue:obj forKey:propertyName];
            [self didChangeValueForKey:propertyName];
        }
    }
    else {
        //call back on the correct thread
        NSMethodSignature* sig = [self methodSignatureForSelector:@selector(recallDynamicSetter:withObject:)];
        NSInvocation* call = [NSInvocation invocationWithMethodSignature:sig];
        [call retainArguments];
        call.target = self;
        call.selector = @selector(recallDynamicSetter:withObject:);
        [call setArgument:&_cmd atIndex:2];
        [call setArgument:&obj atIndex:3];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self runInvocationOnCorrectThread:call];
        });
    }
}

+ (NSArray*)declaredPropertyNames {
    NSMutableArray* properties = [NSMutableArray array];
    
    unsigned int numProperties = 0;
    objc_property_t* objcProps = class_copyPropertyList([self class], &numProperties);
    for (int index = 0; index < numProperties; index++) {
        objc_property_t prop = objcProps[index];
        const char* name = property_getName(prop);
        if (name) {
            [properties addObject:[NSString stringWithCString:name encoding:[NSString defaultCStringEncoding]]];
        }
        else {
            NSLog(@"Found an unnamed property...?");
        }
    }
    free(objcProps);
    
    return properties;
}

+ (NSString*)propertyNameFromSetter:(SEL)selector {
    NSString* targetSel = NSStringFromSelector(selector);
    NSString* propertyNameUpper = [targetSel substringFromIndex:3];  //remove the 'set'
    NSString* firstLetter = [[propertyNameUpper substringToIndex:1] lowercaseString];
    NSString* propertyName = [NSString stringWithFormat:@"%@%@", firstLetter, [propertyNameUpper substringFromIndex:1]];
    propertyName = [propertyName substringToIndex:[propertyName length] - 1];   //remove the trailing ':'
    
    return propertyName;
}

+ (NSString*)propertyNameFromSetterWithString:(NSString*)setter {
    NSString* targetSel = setter;
    NSString* propertyNameUpper = [targetSel substringFromIndex:3];  //remove the 'set'
    NSString* firstLetter = [[propertyNameUpper substringToIndex:1] lowercaseString];
    NSString* propertyName = [NSString stringWithFormat:@"%@%@", firstLetter, [propertyNameUpper substringFromIndex:1]];
    propertyName = [propertyName substringToIndex:[propertyName length] - 1];   //remove the trailing ':'
    
    return propertyName;
}
+ (BOOL) resolveInstanceMethod:(SEL)sel {
    NSString* targetSel = NSStringFromSelector(sel);
    if ([targetSel hasPrefix:@"set"] && [targetSel rangeOfString:@"Primitive"].location == NSNotFound && [targetSel rangeOfString:@":"].location != NSNotFound) {
        NSString* propertyName = [self propertyNameFromSetter:sel];
        if ([[self declaredPropertyNames] containsObject:propertyName]) {
            class_addMethod([self class], sel, (IMP)dynamicSetter, "v@:@");
            return YES;
        }
    }
    
    return [super resolveInstanceMethod:sel];
}

@end
