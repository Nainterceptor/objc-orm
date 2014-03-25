//
//  Adapter.h
//  ormMapper
//
//  Created by Nainterceptor on 23/03/14.
//
//

#import <Foundation/Foundation.h>

@interface Adapter : NSObject

@property(nonatomic, retain) NSString *dbName;
@property(nonatomic, retain) NSString *dbPath;

- (void)insert:(NSMutableDictionary *)dictionnary into:(NSString *)tableName;

- (void)update:(NSMutableDictionary *)dictionnary into:(NSString *)tableName by:(NSString *)property with:(id)value;

- (void)delete:(NSString *)tableName by:(NSString *)property with:(id)value;

- (NSMutableDictionary *)find:(NSString *)tableName by:(NSString *)property with:(id)value;

@end
