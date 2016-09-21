//
//  AppDelegate.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/7/25.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "AppDelegate.h"
#import <BmobSDK/Bmob.h>
#import "RegistAndLoginViewController.h"
#import "MainViewController.h"
#import "PKRevealController.h"

@interface AppDelegate ()
{
    NSMutableArray *peripherals;

}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //云服务器的配置id
    [Bmob registerWithAppKey:@"8c426dee71396d48334853c72d431074"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    //设置navigationbar的背景颜色以及title，item的颜色
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGBWithAlpha(0x2c91F4, 1)];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar
      appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    //判断距离上次登陆过了多久
    [self judgeLastLogin];
    
    return YES;
}

- (void)judgeLastLogin
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"LastLogin"]) {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        [gregorian setFirstWeekday:2];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastLogin"];
        NSDate *nowDate = [NSDate date];
        
        NSDateComponents *dayComponents = [gregorian components:NSDayCalendarUnit fromDate:lastDate toDate:nowDate options:0];
        
        DeBugLog(@"距离上次登录间距min== %ld,day = %ld",(long)dayComponents.minute ,dayComponents.day);
        //超过24小时，就重新登陆
        if (dayComponents.day >= 1) {
            self.window.rootViewController = [[RegistAndLoginViewController alloc] initWithNibName:@"RegistAndLoginViewController" bundle:nil];
        }else {
            
            UIViewController *vc = [[UIViewController alloc] init];
            vc.view.backgroundColor = [UIColor redColor];
            
            PKRevealController *revealController = [PKRevealController revealControllerWithFrontViewController:[[UINavigationController alloc] initWithRootViewController:[[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil]]  leftViewController:vc];
            self.window.rootViewController = revealController;
        }
        
    }else {
        self.window.rootViewController = [[RegistAndLoginViewController alloc] initWithNibName:@"RegistAndLoginViewController" bundle:nil];
    }
}

- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        DeBugLog(@"联网成功");
    }else {
        DeBugLog(@"onGetNetworkState %d",iError);
    }
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        DeBugLog(@"授权成功");
    }else {
        DeBugLog(@"onGetPermissionState %d",iError);
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
