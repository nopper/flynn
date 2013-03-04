//
//  Cpu.h
//  flynn
//
//  Created by nopper on 02/03/13.
//  Copyright (c) 2013 nopper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cpu : NSObject {
@private
    NSString *name;
    BOOL monitored;
}

@property (copy) NSString *name;
@property (assign) BOOL monitored;

- (id)initWithId:(NSInteger)cpuId;

@end
