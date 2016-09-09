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
#import <BmobSDK/Bmob.h>
#import "BabyBluetooth.h"
#import "MBProgressHUD.h"
#import "CBPeripheralSingleton.h"

#import "RegistAndLoginViewController.h"

#import "MainViewController.h"

#import "PKRevealController.h"

@interface AppDelegate ()
{
    NSMutableArray *peripherals;
//    BabyBluetooth *baby;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //初始化BabyBluetooth 蓝牙库
//    baby = [BabyBluetooth shareBabyBluetooth];
    //设置蓝牙委托
//    [self babyDelegate];
    
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
        
        NSLog(@"距离上次登录间距min== %ld,day = %ld",dayComponents.minute ,dayComponents.day);
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

#if 0
//蓝牙网关初始化和委托方法设置
-(void)babyDelegate{
    
    //__weak typeof(self) weakSelf = self;
    __weak typeof(self) weakSelf = self;
    [baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state == CBCentralManagerStatePoweredOn) {
//            [MBProgressHUD showInfoWithStatus:@"设备打开成功，开始扫描设备"];
//            [MBProgressHUD showHUDAddedTo:weakSelf.window animated:YES];
            [weakSelf StartScan];
        }
    }];
    
    //设置扫描到设备的委托
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"搜索到了设备:%@",peripheral.name);
        weakSelf.peripheralSing.peripheral=peripheral;
//        if ([peripheral.name isEqualToString:@"YK661DM20A"]) {
//            weakSelf.peripheralSing.peripheral=peripheral;
            [weakSelf StartdiscoverServices:peripheral];
//        }
        //[weakSelf insertTableView:peripheral];
    }];
    //设置设备连接成功的委托
    [baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        NSLog(@"设备：%@--连接成功",peripheral.name);
        //Myperipheral=peripheral;
        //[weakSelf StartdiscoverServices];
    }];
    //设置设备连接失败的委托
    [baby setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--连接失败",peripheral.name);
    }];
    //设置设备断开连接的委托
    [baby setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--断开连接",peripheral.name);
    }];
    
    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        for (CBService *service in peripheral.services) {
            NSLog(@"搜索到服务:%@",service.UUID.UUIDString);
//            [weakSelf insertSectionToTableView:service];
        }
    }];
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        
        for (CBCharacteristic *c in service.characteristics) {
            NSLog(@"charateristic name is :%@",c.UUID);
        }
//        [weakSelf insertRowToTableView:service];
    }];
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
    }];
    //设置发现characteristics的descriptors的委托
    [baby setBlockOnDiscoverDescriptorsForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
            NSLog(@"CBDescriptor name is :%@",d.UUID);
        }
    }];
    //设置读取Descriptor的委托
    [baby setBlockOnReadValueForDescriptors:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    
    //设置查找设备的过滤器
    [baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        //设置查找规则是名称大于1 ， the search rule is peripheral.name length > 2
        if ([peripheralName isEqualToString:@"YK661DM20A"]) {
            return YES;
        }
        return NO;
    }];
}

-(void)BleInit{
    //初始化其他数据 init other
    peripherals = [[NSMutableArray alloc]init];
    
    //初始化BabyBluetooth 蓝牙库
    baby = [BabyBluetooth shareBabyBluetooth];
    //设置蓝牙委托
    self.services = [[NSMutableArray alloc]init];
    [self babyDelegate];
    
}
-(void)StartScan{
    //停止之前的连接
    [baby cancelAllPeripheralsConnection];
    //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态。
    baby.scanForPeripherals().begin();
}
-(void)StartdiscoverServices:(CBPeripheral*)Per{
    baby.having(Per).and.connectToPeripherals().and.discoverServices().and.discoverCharacteristics().begin();
}
-(void)Record{
    CBCharacteristic *recordBuf =  [BabyToy findCharacteristicFormServices:self.services UUIDString:@"xxxxxx"];
    //设置要监听的服务特征值
    if (recordBuf) {
        [self.peripheralSing.peripheral setNotifyValue:YES forCharacteristic:recordBuf];
    }
}
-(void)SendStart:(NSString *)value {
//    NSString *value=@"xxxxxxxxx";
    // 设置要发送的命令（开始发送数据）
    NSData *data = [self hexToBytes:value];
    CBCharacteristic *currentCharacteristic = [BabyToy findCharacteristicFormServices:self.services UUIDString:@"xxxxxxxx"];
    //设置要发送的服务特征值
    [self.peripheralSing.peripheral writeValue:data forCharacteristic:currentCharacteristic type:CBCharacteristicWriteWithResponse];
}
-(void)SendEnd:(NSString *)value {
//    NSString *value=@"xxxxxxxx";
    // 设置要发送的命令（停止发送数据）
    NSData *data = [self hexToBytes:value];
    CBCharacteristic *currentCharacteristic = [BabyToy findCharacteristicFormServices:self.services UUIDString:@"xxxxxxxxx"];
    //设置要发送的服务特征值
    [self.peripheralSing.peripheral writeValue:data forCharacteristic:currentCharacteristic type:CBCharacteristicWriteWithResponse];
}

//NSString转换为NSdata，这样就省去了一个一个字节去写入
- (NSData *)hexToBytes:(NSString *)str
{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= str.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [str substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

#endif

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
