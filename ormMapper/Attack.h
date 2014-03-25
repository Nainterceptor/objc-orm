//
//  Pikachu.h
//  ormMapper
//
//  Created by Nainterceptor on 19/03/14.
//
//

#import <Foundation/Foundation.h>
#import "Bean.h"
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>

@interface Attack : Bean

@property (nonatomic, retain) NSNumber *id;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *power;
@property (nonatomic, retain) Bean *pikachu; //Class name, lowercase

@end