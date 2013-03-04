//
//  Cpu.m
//  flynn
//
//  Created by nopper on 02/03/13.
//  Copyright (c) 2013 nopper. All rights reserved.
//

#import "Cpu.h"

@implementation Cpu
@synthesize name, monitored;

- (void)delloc
{
    [name release];
    [super dealloc];
}

- (id)initWithId:(NSInteger)cpuId
{
    if (self = [super init])
    {
        name = [[NSString alloc] initWithFormat:@"Core %ld", (long)cpuId];
        monitored = [[NSUserDefaults standardUserDefaults] boolForKey:name];
    }
    
    return self;
}



@end
