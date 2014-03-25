//
//  SQLite.h
//  ormMapper
//
//  Created by Nainterceptor on 23/03/14.
//
//

#import <Foundation/Foundation.h>
#import "Adapter.h"
#import <sqlite3.h>

@interface SQLite : Adapter

@property(nonatomic) int lastInsert;

- (id)init;

@end
