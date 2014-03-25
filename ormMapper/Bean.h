//
//  Bean.h
//  ormMapper
//
//  Created by Nainterceptor on 23/03/14.
//
//

#import <Foundation/Foundation.h>

@class Adapter;

@interface Bean : NSObject

@property (nonatomic, retain) NSNumber *id;

-(id)initWithProperty:(NSString *)property andValue:(id)value;

-(void) dump;
-(void) persist;
-(void) remove;

@end