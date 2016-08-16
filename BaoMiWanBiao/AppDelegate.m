//
//  AppDelegate.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/7/25.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "AppDelegate.h"
#import "RegistAndLoginViewController.h"
#import "MiBaoXiangViewController.h"
#import "MiMaBenViewController.h"
#import "MotionStatusViewController.h"
#import "MotionLineViewController.h"
#import "MotionHistoryViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    //注册界面作为根视图控制器
    //self.window.rootViewController = [[RegistAndLoginViewController alloc] initWithNibName:@"RegistAndLoginViewController" bundle:[NSBundle mainBundle]];
    
    //密保箱作为根视图控制器
    //self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[MiBaoXiangViewController alloc] init]];
    
    //密码本作为根视图控制器
//    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[MiMaBenViewController alloc] init]];
    
    //运动状态作为根视图控制器
    //self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[MotionStatusViewController alloc] initWithNibName:@"MotionStatusViewController" bundle:nil]];
    
    //运动轨迹作为根视图控制器
    //self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[MotionLineViewController alloc] init]];
    
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[MotionHistoryViewController alloc] initWithNibName:@"MotionHistoryViewController" bundle:nil]];
    
    
    return YES;
}

- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        NSLog(@"联网成功");
    }else {
        NSLog(@"onGetNetworkState %d",iError);
    }
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        NSLog(@"授权成功");
    }else {
        NSLog(@"onGetPermissionState %d",iError);
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
