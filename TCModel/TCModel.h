//
//  TCModel.h
//
//  Created by 程天聪 on 15/12/21.
//  Copyright © 2015年 CTC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface TCModel : NSObject <NSCoding>
/**
 *  TCModel使用注意事项:
 *
 *  若模型属性名和字典键不同时
 *  重写"- (void)setValue:(id)value forUndefinedKey:(NSString *)key"方法.
 *
 *  @param dictionary 数据字典
 *
 *  @return 数据模型
 */
+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary;

/** 将json字符串转为model */
+ (instancetype)modelWithJsonString:(NSString *)jsonString;

/** 返回属性都是空字符串的模型 */
+ (instancetype)emptyModel;

/** 返回所有属性名 */
+ (NSArray *)allProperties;

/** 返回属性类型 */
+ (NSDictionary *)allAttributes;

/** 归档 */
+ (NSData *)archive:(TCModel *)model;

/** 读档 */
+ (instancetype)unarchiveWithData:(NSData *)data;

/** 归档于UserDefaults */
+ (void)archive:(TCModel *)model toUserDefaultsWithKey:(NSString *)key;

/** 读档于UserDefaults */
+ (instancetype)unarchiveModelFromUserDefaultsWithKey:(NSString *)key;

/**
 *  属性类型为数组 数组中的元素是TCModel类 需要重写此方法
 *  @example {@"属性名1":[A_TCModel class], @"属性名2":[B_TCModel class]}
 *  @return 标识属性数组中元素类型的字典
 */
+ (NSDictionary *)objectClassInArray;

@end

/**
 *
 现有问题:只能对简单结构的model归档读档
 *
 */
