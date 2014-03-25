//
//  Bean.m
//  ormMapper
//
//  Created by Nainterceptor on 23/03/14.
//
//

#import "Bean.h"
#import "SQLite.h"
#import <objc/runtime.h>
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

@implementation Bean

@synthesize id;

- (SQLite *)getAdapter {
    return [SQLite alloc].init;//Change adapter here
}

- (id)initWithData:(NSDictionary *)datas {
    if (self = [super init]) {

        NSString *scannedProperty;
        unsigned int count;
        objc_property_t *properties = class_copyPropertyList([self class], &count);
        for (size_t i = 0; i < count; ++i) {
            scannedProperty = [NSString stringWithUTF8String:sel_getName((SEL) property_getName(properties[i]))];
            id scannedValue = [datas valueForKey:scannedProperty];
            [self setValue:scannedValue forKey:scannedProperty];
        }
        free(properties);
    }
    return self;
}

- (id)initWithProperty:(NSString *)property andValue:(id)value {
    NSDictionary *fromDB = [self.getAdapter find:NSStringFromClass([self class]) by:property with:value];
    return [self initWithData:fromDB];
}

- (void)dump {
    [self performBlockInBackground:^{
        NSString *property;
        id value;
        unsigned int count;
        objc_property_t *properties = class_copyPropertyList([self class], &count);
        NSLog(@"%@ :", NSStringFromClass([self class]));
        for (size_t i = 0; i < count; ++i) {
            property = [NSString stringWithUTF8String:sel_getName((SEL) property_getName(properties[i]))];
            value = [self valueForKey:property];
            NSLog(@"- %@ : %@", property, value);
        }
        free(properties);
    }];
}

- (void)cascadeChildren:(NSArray *)properties {
    for (NSArray *childrenList in properties) {
        for (id bean in childrenList) {
            [bean setValue:self forKey:[NSStringFromClass([self class]) lowercaseString]];
            [bean persist];
        }
    }
}

- (void)persist {
    NSMutableDictionary *dictionary = [NSMutableDictionary alloc].init;
    NSMutableArray *children = [NSMutableArray alloc].init;
    NSString *property;
    id value;
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (size_t i = 0; i < count; ++i) {
        property = [NSString stringWithUTF8String:sel_getName((SEL) property_getName(properties[i]))];
        value = [self performSelector:NSSelectorFromString(property)];
        if ([value isKindOfClass:[NSArray class]]) {
            [children addObject:value];
        } else if ([value isKindOfClass:[Bean class]]) {
            [dictionary setObject:[value id] forKey:[NSString stringWithFormat:@"%@_id", property]];
        } else if (value != nil) {
            [dictionary setObject:value forKey:property];
        }
    }
    free(properties);

    if (self.id == nil) {
        [self performBlockInBackground:^{
            id adapter = [self getAdapter];
            [adapter insert:dictionary into:NSStringFromClass([self class])];
            self.id = [NSNumber numberWithInt:[adapter lastInsert]];
            [self cascadeChildren:children];
        }];

    } else {
        [self performBlockInBackground:^{
            id adapter = [self getAdapter];
            [adapter update:dictionary into:NSStringFromClass([self class]) by:@"id" with:self.id];
            [self cascadeChildren:children];
        }];
    }

}

- (void)remove {
    [self performBlockInBackground:^{
        [self.getAdapter delete:NSStringFromClass([self class]) by:@"id" with:self.id];
    }];
}

- (void)performBlockInBackground:(void (^)())block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSLog(@"%@", [NSThread currentThread]);
        block();
    });
}
@end
