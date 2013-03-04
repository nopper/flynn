//
//  AppDelegate.m
//  flynn
//
//  Created by nopper on 13/02/13.
//  Copyright (c) 2013 nopper. All rights reserved.
//

#import "AppDelegate.h"
#import "Cpu.h"

@implementation AppDelegate
@synthesize window;
@synthesize dockMenu;
@synthesize updateLabel;
@synthesize updateSlider;
@synthesize coreView;

- (void)dealloc
{
    [super dealloc];
}

#define MAX_INDEX 28

- (NSImage*)loadIconNumber: (int) index
{
    int width = 48;
    int height = 64;
    
    NSRect rect = CGRectMake(0, (26 - index) * height, width, height);

    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext: context];
    [rootImage drawAtPoint: NSZeroPoint fromRect: rect operation: NSCompositeCopy fraction: 1.0];
    [context flushGraphics];
    [NSGraphicsContext restoreGraphicsState];
    
    NSImage *image = [[NSImage alloc] initWithCGImage:[bitmap CGImage] size:NSMakeSize(width, height)];
    [image autorelease];
    return image;
}

- (void)updateCpu
{
    float totalUsage = 0;
    int counter = 0;
    
    natural_t numCPUsU = 0U;
    kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUsU, &cpuInfo, &numCpuInfo);
    
    if (err == KERN_SUCCESS)
    {
        [CPUUsageLock lock];
        
        for(unsigned i = 0U; i < numCPUs; ++i)
        {
            float inUse, total;
            
            if(prevCpuInfo)
            {
                inUse = (
                  (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER]   - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER]) +
                  (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM]) +
                  (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE]   - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE])
                );
                total = inUse + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE]);
            }
            else
            {
                inUse = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
                total = inUse + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
            }
            
            float currentUsage = inUse / total;            
            Cpu *cpu = [[cpuController list] objectAtIndex:i];
                        
            if (!isnan(currentUsage) && cpu.monitored)
            {
                totalUsage += currentUsage;
                counter++;
            }
        }
        
        totalUsage /= counter;
        cpu_usage = totalUsage;
        
        [CPUUsageLock unlock];
        
        if (prevCpuInfo)
        {
            size_t prevCpuInfoSize = sizeof(integer_t) * numPrevCpuInfo;
            vm_deallocate(mach_task_self(), (vm_address_t)prevCpuInfo, prevCpuInfoSize);
        }
        
        prevCpuInfo = cpuInfo;
        numPrevCpuInfo = numCpuInfo;
        
        cpuInfo = NULL;
        numCpuInfo = 0U;
    } else {
        NSLog(@"Error!");
        [NSApp terminate:nil];
    }
}

- (void)onTimeout:(NSTimer *)timer
{
    [self updateCpu];
    
    NSLog(@"Total CPU usage is %f", cpu_usage);
    
    currIndex = (int)(cpu_usage * 5) % maxIndex;
    currSequence = (currSequence + 1) % 3;
    currIndex += 5 * currSequence;
    
    NSLog(@"Current index %d", currIndex);
    currIcon = [self loadIconNumber:currIndex];
    [NSApp setApplicationIconImage:currIcon];
}

- (IBAction)onSliderChange:(id)sender
{
    float interval = [updateSlider floatValue] / 10.0;
    NSString *string = [[NSString alloc] initWithFormat:@"Update every %.2f seconds", interval];
    [updateLabel setStringValue:string];
    [string autorelease];
    
    [[NSUserDefaults standardUserDefaults] setFloat:interval forKey:@"updateInterval"];
    
    if (timer)
        [timer invalidate];
    
    NSLog(@"Restarting update timer interval every %.2f seconds", interval);
    
    timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(onTimeout:) userInfo:nil repeats:YES];
    [timer fire];
}

- (IBAction)onPreferences:(id)sender
{
    NSLog(@"Showing preferences");
    window.isVisible = TRUE;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    int mib[2U] = { CTL_HW, HW_NCPU };
    size_t sizeOfNumCPUs = sizeof(numCPUs);
    int status = sysctl(mib, 2U, &numCPUs, &sizeOfNumCPUs, NULL, 0U);
    
    if (status)
        numCPUs = 1;
    
    [cpuController initWithCpuCount:numCPUs];
    [coreView setDataSource:cpuController];
    
    CPUUsageLock = [[NSLock alloc] init];
    
    window.isVisible = false;
    
    NSString *texturePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"flynn_full.png"];
    
    rootImage = [[NSImage alloc] initWithContentsOfFile:texturePath];
    
    if (![rootImage isValid])
        NSLog(@"Unable to load the root image");
    
    int width = 48;
    int height = 64;
    
    bitmap = [[NSBitmapImageRep alloc]
              initWithBitmapDataPlanes:NULL
              pixelsWide:width
              pixelsHigh:height
              bitsPerSample:8
              samplesPerPixel:4
              hasAlpha:YES
              isPlanar:NO
              colorSpaceName:NSDeviceRGBColorSpace
              bitmapFormat:0
              bytesPerRow:width * 4
              bitsPerPixel:32];

    context = [NSGraphicsContext graphicsContextWithBitmapImageRep: bitmap];
    [context retain];
    
    currIndex = 0;
    maxIndex = 27;
    
    currSequence = 0;
    maxSequence = 5;
    
    currIcon = [self loadIconNumber:currIndex];
    [NSApp setApplicationIconImage:currIcon];
    
    float interval = [[NSUserDefaults standardUserDefaults] floatForKey:@"updateInterval"] * 10.0;
    
    if (interval == 0)
        interval = 10;
    
    [updateSlider setFloatValue:interval];
    [self onSliderChange:nil];
}

- (NSMenu *)applicationDockMenu:(NSApplication *)sender
{
    return dockMenu;
}

@end
