//
//  TableCpuViewController.h
//  flynn
//
//  Created by nopper on 01/03/13.
//  Copyright (c) 2013 nopper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableCpuViewController : NSObject<NSTableViewDataSource> {
    IBOutlet NSTableView *tableView;
    NSMutableArray *list;
}

- (id)initWithCpuCount:(NSInteger)numCPUs;

@property (copy) NSMutableArray *list;

@end
