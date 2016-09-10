//
//  BLETool.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/9/8.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "BLETool.h"
#import "BabyBluetooth.h"
#import "manridyBleDevice.h"
#import "MBProgressHUD.h"
#import "MotionDailyDataModel.h"
#import "MotionFmdbTool.h"

@interface BLETool ()
{
    BabyBluetooth *_baby;
}

@property (nonatomic ,strong) NSMutableArray *deviceArr;

@property (nonatomic ,weak) MotionFmdbTool *fmTool;

@end

@implementation BLETool


#pragma mark - Singleton
static BLETool *bleTool = nil;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _baby = [BabyBluetooth shareBabyBluetooth];
        [self babyDelegate];
    }
    return self;
}

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bleTool = [[self alloc] init];
    });
    
    return bleTool;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bleTool = [super allocWithZone:zone];
    });
    
    return bleTool;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark - action of connecting layer -连接层操作
- (void)scanDevice
{
    [self.deviceArr removeAllObjects];
    _baby.scanForPeripherals().begin();
}

- (void)stopScan
{
    [_baby cancelScan];
}

- (void)connectDevice:(manridyBleDevice *)device
{
    self.currentDev = device;
    _baby.having(device.peripheral).connectToPeripherals().discoverServices().discoverCharacteristics().begin();
}

- (void)unConnectDevice
{
    [_baby cancelAllPeripheralsConnection];
}

- (void)reConnectDevice
{
    
}

- (NSArray *)retrieveConnectedPeripherals
{
    return nil;
}

#pragma mark - 写入层操作
- (void)writeDataToPeripheral:(NSString *)info
{
    if (self.currentDev.peripheral) {
        [self.currentDev.peripheral writeValue:[self hexToBytes:info] forCharacteristic:self.currentDev.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
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
    
    NSLog(@"data = %@",data);
    return data;
}

#pragma mark - BabyDelegate
- (void)babyDelegate
{
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(_baby) weakBaby = _baby;
    
    [_baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state == CBCentralManagerStatePoweredOn) {
            //            [SVProgressHUD showInfoWithStatus:@"设备打开成功，开始扫描设备"];
            NSLog(@"蓝牙已打开");
        }else {
            NSLog(@"蓝牙已关闭");
        }
    }];
    
    //设置扫描到设备的委托
    [_baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
//        NSLog(@"搜索到了设备:%@",peripheral.name);
        
        if (![weakSelf.deviceArr containsObject:peripheral]) {
            [weakSelf.deviceArr addObject:peripheral];
            manridyBleDevice *device = [[manridyBleDevice alloc] initWith:peripheral andAdvertisementData:advertisementData];
            
            //扫描成功回调
            [weakSelf.discoverDelegate manridyBLEDidDiscoverDeviceWithMAC:device];
        }
    }];
    
    //设置设备连接成功的委托
    [_baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        NSLog(@"连接到了设备:%@",peripheral.name);
        
        //currPeripheral指向我们点击的cell的peripheral
        weakSelf.currentDev.peripheral = peripheral;
        
        //指定返回我们需要的服务
        [peripheral discoverServices:@[[CBUUID UUIDWithString:kServiceUUID]]];
        
        if (weakSelf.currentDev) {
            //连接成功回调
            [weakSelf.connectDelegate manridyBLEDidConnectDevice:weakSelf.currentDev];
        }
    }];
    
    //设置发现设备的Services的委托
    [_baby setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        
        for (CBService *service in peripheral.services) {
//            NSLog(@"搜索到服务:%@",service.UUID.UUIDString);
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:kWriteCharacteristicUUID]] forService:service];
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:kNotifyCharacteristicUUID]] forService:service];
        }
    }];
    
    //设置发现设service的Characteristics的委托
    [_baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        for (CBCharacteristic *c in service.characteristics) {
            if ([c.UUID isEqual:[CBUUID UUIDWithString:kWriteCharacteristicUUID]]) {
                [CBPeripheralSingleton sharePeripheral].device.writeCharacteristic = c;
                weakSelf.currentDev.writeCharacteristic = c;
            }
            if ([c.UUID isEqual:[CBUUID UUIDWithString:kNotifyCharacteristicUUID]]) {
                [CBPeripheralSingleton sharePeripheral].device.notifyCharacteristic = c;
                weakSelf.currentDev.notifyCharacteristic = c;
                
                [weakBaby notify:weakSelf.currentDev.peripheral characteristic:c block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                    NSLog(@"改变后的特征值 = %@",characteristics.value);
                    
#warning 这里对delegate有没有接收对象作出判断失败，当没有对象接受时，还是会崩溃
                    if (weakSelf.writeDelegate && [weakSelf.writeDelegate respondsToSelector:@selector(receiveData:)]) {
                        [weakSelf.writeDelegate receiveData:characteristics.value];
                        
                    }else {
                        
                        NSData *data = characteristics.value;
                        //这里将数据写入运动类数据写入数据库中
                        const unsigned char *hexBytesLight = [data bytes];
                        
                        NSString *Str1 = [NSString stringWithFormat:@"%02x", hexBytesLight[0]];
                        NSLog(@"标识符 = %@",Str1);
                        
                        //运动数据解析
                        if ([Str1 isEqualToString:@"03"]) {
                            NSData *stepData = [data subdataWithRange:NSMakeRange(2, 3)];
                            int stepValue = [weakSelf parseIntFromData:stepData];
                            NSLog(@"今日步数 = %d",stepValue);
                            NSString *stepStr = [NSString stringWithFormat:@"%d",stepValue];
                            
                            NSData *mileageData = [data subdataWithRange:NSMakeRange(5, 3)];
                            int mileageValue = [weakSelf parseIntFromData:mileageData];
                            NSLog(@"今日里程数 = %d",mileageValue);
                            NSString *mileageStr = [NSString stringWithFormat:@"%d",mileageValue];
                            
                            NSData *kcalData = [data subdataWithRange:NSMakeRange(8, 3)];
                            int kcalValue = [weakSelf parseIntFromData:kcalData];
                            NSLog(@"卡路里 = %d",kcalValue);
                            NSString *kCalStr = [NSString stringWithFormat:@"%d",kcalValue];
                            
                            NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
                            [dateformatter setDateFormat:@"YYYY-MM-dd"];
                            NSDate *currentDate = [NSDate date];
                            NSString *currentDateString = [dateformatter stringFromDate:currentDate];
                            
                            MotionDailyDataModel *motionModel = [MotionDailyDataModel modelWith:currentDateString step:stepStr kCal:kCalStr mileage:mileageStr bpm:nil];
                            
                            
                            [weakSelf.fmTool insertModel:motionModel];
                        }
                    }
                    
                }];
                
            }
        }
    }];
    
    
    //写入特征成功block
    [_baby setBlockOnDidWriteValueForCharacteristic:^(CBCharacteristic *characteristic, NSError *error) {
        
        if (!error) {
            NSLog(@"写入特征成功 = %@,UUID = %@",characteristic.value ,characteristic.UUID);
            
        }else {
            NSLog(@"写入特征失败 = %@",characteristic.UUID);
        }
        
    }];
    
    //设置读取characteristics的委托
    [_baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
    }];
    
    //设置发现characteristics的descriptors的委托
    [_baby setBlockOnDiscoverDescriptorsForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
            NSLog(@"CBDescriptor name is :%@",d.UUID);
        }
    }];
    
    //设置读取Descriptor的委托
    [_baby setBlockOnReadValueForDescriptors:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    
    //设置设备断开连接的委托
    [_baby setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--断开连接",peripheral.name);
        
        [weakSelf.connectDelegate manridyBLEDidDisconnectDevice:weakSelf.currentDev];
    }];
    
    
    //设置查找设备的过滤器
    [_baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        
        //最常用的场景是查找某一个前缀开头的设备
        //        if ([peripheralName hasPrefix:@"Pxxxx"] ) {
        //            return YES;
        //        }
        //        return NO;
        
        //设置查找规则是名称大于0 ， the search rule is peripheral.name length > 0
        if (peripheralName.length >0) {
            return YES;
        }
        return NO;
    }];
    
    
    [_baby setBlockOnCancelAllPeripheralsConnectionBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelAllPeripheralsConnectionBlock");
    }];
    
    [_baby setBlockOnCancelScanBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelScanBlock");
    }];
    
    
    /*设置babyOptions
     
     参数分别使用在下面这几个地方，若不使用参数则传nil
     - [centralManager scanForPeripheralsWithServices:scanForPeripheralsWithServices options:scanForPeripheralsWithOptions];
     - [centralManager connectPeripheral:peripheral options:connectPeripheralWithOptions];
     - [peripheral discoverServices:discoverWithServices];
     - [peripheral discoverCharacteristics:discoverWithCharacteristics forService:service];
     
     该方法支持channel版本:
     [baby setBabyOptionsAtChannel:<#(NSString *)#> scanForPeripheralsWithOptions:<#(NSDictionary *)#> connectPeripheralWithOptions:<#(NSDictionary *)#> scanForPeripheralsWithServices:<#(NSArray *)#> discoverWithServices:<#(NSArray *)#> discoverWithCharacteristics:<#(NSArray *)#>]
     */
    
    //示例:
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    //连接设备->
    [_baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    
}

//补充内容，因为没有三个字节转int的方法，这里补充一个通用方法,16进制转换成10进制
- (unsigned)parseIntFromData:(NSData *)data{
    
    NSString *dataDescription = [data description];
    NSString *dataAsString = [dataDescription substringWithRange:NSMakeRange(1, [dataDescription length]-2)];
    
    unsigned intData = 0;
    NSScanner *scanner = [NSScanner scannerWithString:dataAsString];
    [scanner scanHexInt:&intData];
    return intData;
}

#pragma mark - 懒加载
- (NSMutableArray *)deviceArr
{
    if (!_deviceArr) {
        _deviceArr = [NSMutableArray array];
    }
    
    return _deviceArr;
}


@end
