//
//  TableCpuViewController.m
//  flynn
//
//  Created by nopper on 01/03/13.
//  Copyright (c) 2013 nopper. All rights reserved.
//

#import "TableCpuViewController.h"
#import "Cpu.h"

@implementation TableCpuViewController
@synthesize list;

- (void)dealloc
{
    [super dealloc];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSLog(@"Number of elements %ld", (unsigned long)[list count]);
    return [list count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    Cpu *c = [list objectAtIndex:row];
    NSString *identifier = [tableColumn identifier];
    return [c valueForKey:identifier];
}

- (BOOL)atLeastOneActive
{
    Cpu *current;
    NSEnumerator *iter = [list objectEnumerator];
    
    while (current = [iter nextObject])
        if (current.monitored)
            return TRUE;
    
    return FALSE;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    
    Cpu *c = [list objectAtIndex:row];
    NSString *identifier = [tableColumn identifier];
    [c setValue:object forKey:identifier];
    
    BOOL active = [self atLeastOneActive];
    
    if (active)
        [[NSUserDefaults standardUserDefaults] setBool:c.monitored forKey:c.name];
    else
        c.monitored = !c.monitored;
}

- (id)initWithCpuCount:(NSInteger)numCPUs
{
    self = [super init];
    list = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < (int)numCPUs; i++)
    {
        Cpu *c = [[[Cpu alloc] initWithId:i] autorelease];
        [list addObject:c];
    }
    
    if (![self atLeastOneActive])
    {
        Cpu *current;
        NSEnumerator *iter = [list objectEnumerator];
        
        while (current = [iter nextObject])
        {
            current.monitored = TRUE;
            [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:current.name];
        }
    }
    
    NSLog(@"%ld CPU objects created", [list count]);
    
    [tableView reloadData];
    return self;
}

@end
