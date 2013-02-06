

#import "AppDelegate.h"
#import "LeTemperatureAlarmService.h"   // For the Notification strings


@implementation AppDelegate

@synthesize window = _window;

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAlarmServiceEnteredBackgroundNotification object:self];
//    NSLog(@"Entered background...");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAlarmServiceEnteredForegroundNotification object:self];
//    NSLog(@"Entered foreground...");
}

@end
