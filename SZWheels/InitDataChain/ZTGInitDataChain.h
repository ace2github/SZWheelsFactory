//
//  ZTGInitDataChain.h
//  ztjyyd
//
//  Created by ChaohuiChen on 24/05/2018.
//  Copyright © 2018 szy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZTGDataItem;
@interface ZTGInitDataChain : NSObject
//dispatch_group_enter
- (void)addTaskToGroup;
//dispatch_group_leave
- (void)removeTaskFromGroup;
//register completblock when task finished！
- (void)completeAllTaskInGroup:(dispatch_block_t)complete;


#pragma mark - data queue
/**
 会进入dispatch_group的情形
 1、如果key为空或者无此key值时候
 2、如果key存在，且cache不存在
 
 无需离开dispatch_group的情形
 3、如果key存在，且cache存在，则不会进入
 */
- (void)addTaskToGroupWhenNoCache:(NSString *)key;

/**
 会离开dispatch_group的情形
 1、如果key为空或者无此key值时候
 2、如果key存在，且cache不存在
 
 无需离开dispatch_group的情形
 3、如果key存在，且cache存在
 */
- (void)removeTaskFromGroupWhenNoCache:(NSString *)key;

/**
 注册初始化数据模型，根据Cache、Response、Error等数据链信，
 决定链数据是否成功，如登录初始化账号数据流程等
 */
- (BOOL)registerDataItem:(NSString *)key index:(NSInteger)index;

/**
 更新数据的缓存部分
 */
- (void)updateWithCahce:(id)cache key:(NSString *)key;
/**
 更新网络请求字段
 */
- (void)updateWithRefresh:(id)refresh key:(NSString *)key ;
/**
 设置错误信息
 */
- (void)updateWithError:(NSError *)error key:(NSString *)key;

- (void)clearWithKey:(NSString *)key;
- (void)clearAllDataItems;

- (ZTGDataItem *)dataWithKey:(NSString *)key;
/**
 获取列表，改列表已经按照index升序排序
 */
- (NSArray *)dataItemQueue;
- (NSDictionary *)fetchDataInitQueueMap;
@end


@interface ZTGDataItem : NSObject
@property (nonatomic, copy) NSString *uKey;
@property (nonatomic, assign) BOOL cache; //加载缓存是否成功
@property (nonatomic, assign) BOOL refresh; //请求服务器是否成功
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) id dataModel;
@property (nonatomic, assign) NSInteger index;
@end
