//
//  AppDelegate.h
//  flynn
//
//  Created by nopper on 13/02/13.
//  Copyright (c) 2013 nopper. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <sys/sysctl.h>
#include <sys/types.h>
#include <mach/mach.h>
#include <mach/processor_info.h>
#include <mach/mach_host.h>

#import "TableCpuViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    NSImage *rootImage;
    NSImage *currIcon;
    NSBitmapImageRep *bitmap;
    NSGraphicsContext *context;
    NSTimer *timer;
    
    NSSlider *updateSlider;
    NSTextField *updateLabel;
    NSTableView *coreView;
    
    IBOutlet TableCpuViewController *cpuController;

    int currIndex;
    int maxIndex;
    int currSequence;
    int maxSequence;
    
    processor_info_array_t cpuInfo, prevCpuInfo;
    mach_msg_type_number_t numCpuInfo, numPrevCpuInfo;
    unsigned numCPUs;
    NSTimer *updateTimer;
    NSLock *CPUUsageLock;
    
    float cpu_usage;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSMenu *dockMenu;
@property (assign) IBOutlet NSSlider *updateSlider;
@property (assign) IBOutlet NSTextField *updateLabel;
@property (assign) IBOutlet NSTableView *coreView;

-(NSImage*) loadIconNumber: (int) index;
-(void) onTimeout: (NSTimer *)timer;
-(void) updateCpu;

- (IBAction)onPreferences:(id)sender;
- (IBAction)onSliderChange:(id)sender;

@end
