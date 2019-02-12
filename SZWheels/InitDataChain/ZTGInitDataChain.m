//
//  ZTGInitDataChain.m
//  ztjyyd
//
//  Created by ChaohuiChen on 24/05/2018.
//  Copyright © 2018 szy. All rights reserved.
//

#import "ZTGInitDataChain.h"
#import <SZCategories/NSObject+ZTThread.h>

#define kLockTimeOut (5 * NSEC_PER_SEC)

@interface ZTGInitDataChain ()
/**
 Task Group
 */
@property (nonatomic, strong) dispatch_group_t taskGroup;
@property (nonatomic, strong) dispatch_semaphore_t groupLock;
@property (nonatomic, assign) NSUInteger groupTaskCount;

@property (nonatomic, copy) dispatch_block_t allTaskCompleteBlk;

/**
 InitDataQueue
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *,ZTGDataItem *> *dataInitMap;
@property (nonatomic, strong) dispatch_semaphore_t dataInitLock;

@end

@implementation ZTGInitDataChain
- (id)init {
    if (self = [super init]) {        
        _groupLock = dispatch_semaphore_create(1);
        _taskGroup = dispatch_group_create();
        
        _dataInitLock = dispatch_semaphore_create(1);
        _dataInitMap = [NSMutableDictionary dictionaryWithCapacity:6];
    }
    return self;
}


#pragma mark - group
- (void)addTaskToGroup{
    dispatch_semaphore_wait(_groupLock, DISPATCH_TIME_FOREVER);
    NSLog(@"___ add task");
    _groupTaskCount ++;
    dispatch_group_enter(_taskGroup);
    dispatch_semaphore_signal(_groupLock);
}
- (void)removeTaskFromGroup{
    dispatch_semaphore_wait(_groupLock, DISPATCH_TIME_FOREVER);
    if (_groupTaskCount > 0) {
        NSLog(@"___ remove task");
        _groupTaskCount --;
        dispatch_group_leave(_taskGroup);
    }
    dispatch_semaphore_signal(_groupLock);
}

- (void)completeAllTaskInGroup:(dispatch_block_t)complete {
    dispatch_semaphore_wait(_groupLock, DISPATCH_TIME_FOREVER);
    _allTaskCompleteBlk = complete;
    
    @weakify(self);
    dispatch_group_notify(_taskGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        _groupTaskCount = 0;
        
        [NSObject zt_runInMainThread:^{
            NSLog(@"___ finish all tasks");
            if (self.allTaskCompleteBlk) self.allTaskCompleteBlk();
            self.allTaskCompleteBlk = nil;
        }];
    });
    dispatch_semaphore_signal(_groupLock);
}


#pragma mark - data init queue
- (void)addTaskToGroupWhenNoCache:(NSString *)key {
    if (![self dataWithKey:key].cache) {
        [self addTaskToGroup];
    } else {
        NSLog(@"___ not need waiting");
    }
}
- (void)removeTaskFromGroupWhenNoCache:(NSString *)key {
    if (![self dataWithKey:key].cache) {
        [self removeTaskFromGroup];
    }
}

- (BOOL)registerDataItem:(NSString *)key index:(NSInteger)index{
    if ([NSString zt_isEmptyStr:key]) {
        return NO;
    }
    dispatch_semaphore_wait(_dataInitLock, kLockTimeOut);
    ZTGDataItem *data = [_dataInitMap zt_safeObjectForKey:key];
    if (!data) {
        data = [[ZTGDataItem alloc] init];
        data.uKey = key;
        data.index = index;
        [_dataInitMap setObject:data forKey:key];
    }
    dispatch_semaphore_signal(_dataInitLock);
    return YES;
}

- (void)updateWithCahce:(id)cache key:(NSString *)key {
    if (!cache || [NSString zt_isEmptyStr:key]) {
        return;
    }
    dispatch_semaphore_wait(_dataInitLock, kLockTimeOut);
    ZTGDataItem *data = [_dataInitMap zt_safeObjectForKey:key];
    if (data) {
        data.dataModel = cache;
        data.cache = YES;
    }
    dispatch_semaphore_signal(_dataInitLock);
}
- (void)updateWithRefresh:(id)refresh key:(NSString *)key {
    if (!refresh || [NSString zt_isEmptyStr:key]) {
        return;
    }
    
    dispatch_semaphore_wait(_dataInitLock, kLockTimeOut);
    ZTGDataItem *data = [_dataInitMap zt_safeObjectForKey:key];
    if (data) {
        data.dataModel = refresh;
        data.refresh = YES;
    }
    dispatch_semaphore_signal(_dataInitLock);
}
- (void)updateWithError:(NSError *)error key:(NSString *)key {
    if (!error || [NSString zt_isEmptyStr:key]) {
        return;
    }
    dispatch_semaphore_wait(_dataInitLock, kLockTimeOut);
    ZTGDataItem *data = [_dataInitMap zt_safeObjectForKey:key];
    if (data) {
        data.error = error;
    }
    dispatch_semaphore_signal(_dataInitLock);
}
- (void)clearWithKey:(NSString *)key {
    dispatch_semaphore_wait(_dataInitLock, kLockTimeOut);
    [_dataInitMap zt_safeRemoveObjectForKey:key];
    dispatch_semaphore_signal(_dataInitLock);
}
- (void)clearAllDataItems {
    dispatch_semaphore_wait(_dataInitLock, kLockTimeOut);
    [_dataInitMap removeAllObjects];
    dispatch_semaphore_signal(_dataInitLock);
}
- (ZTGDataItem *)dataWithKey:(NSString *)key {
    return [_dataInitMap zt_safeObjectForKey:key];
}
- (NSArray *)dataItemQueue {
    NSArray *list = [NSArray arrayWithArray:_dataInitMap.allValues];
    return [list sortedArrayUsingComparator:^NSComparisonResult(ZTGDataItem *obj1, ZTGDataItem *obj2) {
        return obj1.index > obj2.index ? NSOrderedDescending : NSOrderedAscending;
    }];
}
- (NSDictionary *)fetchDataInitQueueMap {
    return _dataInitMap;
}
@end


#pragma mark - ZTGDataItem Class
@implementation ZTGDataItem
@end
