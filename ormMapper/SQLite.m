//
//  SQLite.m
//  ormMapper
//
//  Created by Nainterceptor on 23/03/14.
//
//

#import <objc/runtime.h>
#import "SQLite.h"
#import "Bean.h"

@implementation SQLite

@synthesize lastInsert;

static sqlite3 *database;
static NSString * DatabaseLock = nil;
+ (void)initialize {
    [super initialize];
    DatabaseLock = @"Database-Lock";
}
+ (NSString *)databaseLock {
    return DatabaseLock;
}
-(id)init
{
    if (self = [super init])
    {
        self.dbName = @"ormmapper.sqlite";
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir = [documentPaths objectAtIndex:0];
        self.dbPath = [documentsDir stringByAppendingPathComponent:self.dbName];
        if(database == nil && sqlite3_open([self.dbPath UTF8String], &database) != SQLITE_OK) {
            NSAssert(0, @"Erreur d'ouverture de la bdd");
        }

    }
    return self;
}
-(void)insert:(NSMutableDictionary *) dictionnary into:(NSString *) tableName {
    @synchronized ([SQLite databaseLock]) {
    NSMutableArray *cols = [NSMutableArray alloc].init;
    NSMutableArray *placeholders = [NSMutableArray alloc].init;
    for (NSString* key in dictionnary) {
        [cols addObject:key];
        [placeholders addObject:@"?"];
    }
    const char *sqlStatement = [
            [NSString
            stringWithFormat:@"INSERT INTO %@  (%@) VALUES (%@)",
                             tableName,
                             [cols componentsJoinedByString:@","],
                             [placeholders componentsJoinedByString:@","]
            ]
            UTF8String];

    sqlite3_stmt *compiledStatement;

    if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) != SQLITE_OK) {
        char const * error = sqlite3_errmsg(database);
        if (strstr(error, "no such table") != NULL) {
            [self createTableFromBean:tableName];
            [self insert:dictionnary into:tableName];
            return;
        }
        NSAssert1(0, @"Erreur :. '%s'", error);
    }

    int count = 1;
    for (NSString* key in dictionnary) {
        id value = [dictionnary objectForKey:key];
        if ([value isKindOfClass:[NSNumber class]]) {
            sqlite3_bind_int(compiledStatement, count++, [value intValue]);
        } else if ([value isKindOfClass:[NSString class]]) {
            sqlite3_bind_text(compiledStatement, count++, [value UTF8String], -1, SQLITE_TRANSIENT);
        } else if ([value isKindOfClass:[Bean class]]) {
            sqlite3_bind_int(compiledStatement, count++, [[value id] intValue]);
        }
    }

    if(SQLITE_DONE != sqlite3_step(compiledStatement)) {
        NSAssert1(0, @"Erreur :. '%s'", sqlite3_errmsg(database));
    }


    sqlite3_finalize(compiledStatement);
    self.lastInsert = (int) sqlite3_last_insert_rowid(database);
    }
}
-(void)update:(NSMutableDictionary *) dictionnary into:(NSString *) tableName by:(NSString *) property with:(id) value {
    @synchronized ([SQLite databaseLock]) {
    NSMutableArray *cols = [NSMutableArray alloc].init;
    for (NSString* key in dictionnary) {
        [cols addObject:[NSString stringWithFormat:@"%@=?", key]];
    }

    const char *sqlStatement = [
            [NSString
                    stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = ?",
                                     tableName,
                                     [cols componentsJoinedByString:@","],
                                     property

            ]
            UTF8String];

    sqlite3_stmt *compiledStatement;

    if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) != SQLITE_OK) {
        char const * error = sqlite3_errmsg(database);
        if (strstr(error, "no such table") != NULL) {
            [self createTableFromBean:tableName];
            [self update:dictionnary into:tableName by:property with:value];
            return;
        }
        NSAssert1(0, @"Erreur :. '%s'", error);
    }

    int count = 1;
    for (NSString* key in dictionnary) {
        id scannedValue = [dictionnary objectForKey:key];
        if ([scannedValue isKindOfClass:[NSNumber class]]) {
            sqlite3_bind_int(compiledStatement, count++, [scannedValue intValue]);
        } else if ([scannedValue isKindOfClass:[NSString class]]) {
            sqlite3_bind_text(compiledStatement, count++, [scannedValue UTF8String], -1, SQLITE_TRANSIENT);
        } else if ([scannedValue isKindOfClass:[Bean class]]) {
            sqlite3_bind_int(compiledStatement, count++, [[scannedValue id] intValue]);
        }
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        sqlite3_bind_int(compiledStatement, count, [value intValue]);
    } else {
        sqlite3_bind_text(compiledStatement, count, [value UTF8String], -1, SQLITE_TRANSIENT);
    }

    if(SQLITE_DONE != sqlite3_step(compiledStatement)) {
        NSAssert1(0, @"Erreur :. '%s'", sqlite3_errmsg(database));
    }

    sqlite3_finalize(compiledStatement);
    }
}
-(void)delete:(NSString *) tableName by:(NSString *) property with:(id) value {
    @synchronized ([SQLite databaseLock]) {
    const char *sqlStatement = [
            [NSString
                    stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",
                                     tableName,
                                     property

            ]
            UTF8String];

    sqlite3_stmt *compiledStatement;

    if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) != SQLITE_OK) {
        char const * error = sqlite3_errmsg(database);
        if (strstr(error, "no such table") != NULL) {
            [self createTableFromBean:tableName];
            [self delete:tableName by:property with:value];
            return;
        }
        NSAssert1(0, @"Erreur :. '%s'", error);
    }

    if ([value isKindOfClass:[NSNumber class]]) {
        sqlite3_bind_int(compiledStatement, 1, [value intValue]);
    } else {
        sqlite3_bind_text(compiledStatement, 1, [value UTF8String], -1, SQLITE_TRANSIENT);
    }

    if(SQLITE_DONE != sqlite3_step(compiledStatement)) {
        NSAssert1(0, @"Erreur :. '%s'", sqlite3_errmsg(database));
    }

    sqlite3_finalize(compiledStatement);
    }
}
-(NSMutableDictionary *)find:(NSString *) tableName by:(NSString *) property with:(id) value {
    @synchronized ([SQLite databaseLock]) {
    const char *sqlStatement = [
                [NSString
                        stringWithFormat:@"SELECT * FROM %@ WHERE %@=?",
                                         tableName,
                                         property
                ]
                UTF8String];

    sqlite3_stmt *compiledStatement;

    if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) != SQLITE_OK) {
        char const * error = sqlite3_errmsg(database);
        if (strstr(error, "no such table") != NULL) {
            [self createTableFromBean:tableName];
            return [self find:tableName by:property with:value];
        }
        NSAssert1(0, @"Erreur :. '%s'", sqlite3_errmsg(database));
    }

    if ([value isKindOfClass:[NSNumber class]]) {
        sqlite3_bind_int(compiledStatement, 1, [value intValue]);
    } else {
        sqlite3_bind_text(compiledStatement, 1, [value UTF8String], -1, SQLITE_TRANSIENT);
    }

    NSMutableDictionary *dictionary = [NSMutableDictionary alloc].init;
    NSMutableDictionary *cols = [self indexByColumnName:compiledStatement];
    id bean = [[NSClassFromString(tableName) alloc] init];
    while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
        unsigned int count;
        objc_property_t *properties = class_copyPropertyList([bean class], &count);
        for (size_t i = 0; i < count; ++i) {
            const char * currentProperty = sel_getName((SEL)property_getName(properties[i]));
            NSString* key = [NSString stringWithUTF8String:currentProperty];
            objc_property_t propertyObj = class_getProperty([bean class], currentProperty);
            const char * propertyAttrs = property_getAttributes(propertyObj);

            if (strstr(propertyAttrs, "NSNumber") != NULL) {
                int statementVal = sqlite3_column_int(
                        compiledStatement,
                        [[cols objectForKey:key] intValue]
                );
                [dictionary
                        setObject:[NSNumber
                                numberWithInt: statementVal
                        ]
                       forKey:key
                ];
            } else if (strstr(propertyAttrs, "NSString") != NULL) {
                unsigned const char * statementVal = sqlite3_column_text(
                        compiledStatement,
                        [[cols objectForKey:key] intValue]
                );
                [dictionary
                        setObject:[NSString
                                stringWithUTF8String:(const char *) statementVal
                        ]
                        forKey:key
                ];
            } else if (strstr(propertyAttrs, "Bean") != NULL) {
                int statementVal = sqlite3_column_int(
                        compiledStatement,
                        [[cols objectForKey:[NSString stringWithFormat:@"%@_id", key]] intValue]
                );
                [dictionary
                       setObject:[[NSClassFromString([key capitalizedString]) alloc] initWithProperty:@"id" andValue:[NSNumber numberWithInt:statementVal]]
                       forKey:key
                ];
            }
        }
    }
    return dictionary;
    }
}

-(void)createTableFromBean:(NSString *) tableName {
    @synchronized ([SQLite databaseLock]) {
    id bean = [[NSClassFromString(tableName) alloc] init];
    NSMutableArray *cols = [NSMutableArray alloc].init;
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([bean class], &count);
    for (size_t i = 0; i < count; ++i) {
        const char * currentProperty = sel_getName((SEL)property_getName(properties[i]));
        NSString* key = [NSString stringWithUTF8String:currentProperty];
        objc_property_t propertyObj = class_getProperty([bean class], currentProperty);
        const char * propertyAttrs = property_getAttributes(propertyObj);

        if ([key isEqualToString:@"id"]) {
            [cols addObject:[NSString stringWithFormat:@"'%@' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE", key]];
        } else if (strstr(propertyAttrs, "NSNumber") != NULL) {
            [cols addObject:[NSString stringWithFormat:@"'%@' INTEGER", key]];
        } else if (strstr(propertyAttrs, "NSString") != NULL) {
            [cols addObject:[NSString stringWithFormat:@"'%@' VARCHAR", key]];
        } else if (strstr(propertyAttrs, "Bean") != NULL) {
            [cols addObject:[NSString stringWithFormat:@"'%@_id' INTEGER", key]];
            [cols addObject:[NSString stringWithFormat:@"FOREIGN KEY (%@_id) REFERENCES %@(id) ON DELETE CASCADE", key, key]];
        }
    }
    const char * sqlStatement = [
            [NSString
            stringWithFormat:
                    @"CREATE TABLE IF NOT EXISTS '%@' (%@)",
                    tableName,
                    [cols componentsJoinedByString:@", "]
            ]
            UTF8String
    ];

    char *err;
    sqlite3_exec(database, sqlStatement, NULL, NULL, &err);
    }
}

-(NSMutableDictionary *)indexByColumnName:(sqlite3_stmt *)init_statement {

    NSMutableArray *keys = [NSMutableArray alloc].init;
    NSMutableArray *values = [NSMutableArray alloc].init;

    int num_fields = sqlite3_column_count(init_statement);

    for(int index_value = 0; index_value < num_fields; index_value++) {
        const char* field_name = sqlite3_column_name(init_statement, index_value);
        if (!field_name){
            field_name="";
        }
        NSString *col_name = [NSString stringWithUTF8String:field_name];
        NSNumber *index_num = [NSNumber numberWithInt:index_value];
        [keys addObject:col_name];
        [values addObject:index_num];
    }

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];

    return dictionary;
}
@end
