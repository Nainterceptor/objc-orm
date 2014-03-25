//
//  Adapter.m
//  ormMapper
//
//  Created by Nainterceptor on 23/03/14.
//
//

#import "Adapter.h"

@implementation Adapter

- (void)insert:(NSMutableDictionary *)dictionnary into:(NSString *)tableName {
}

- (void)update:(NSMutableDictionary *)dictionnary into:(NSString *)tableName by:(NSString *)property with:(id)value {
}

- (void)delete:(NSString *)tableName by:(NSString *)property with:(id)value {
}

- (NSMutableDictionary *)find:(NSString *)tableName by:(NSString *)property with:(id)value {
    return [NSMutableDictionary alloc].init;
}

@end