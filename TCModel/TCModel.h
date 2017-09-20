//
//  TCModel.h
//
//  Created by ctc on 15/12/21.
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
+ (nonnull instancetype)modelWithDictionary:(nonnull NSDictionary *)dictionary;

/** 将json字符串转为model */
+ (nonnull instancetype)modelWithJson:(nonnull NSString *)json;

/** 返回所有属性名 */
+ (nonnull NSArray *)propertyNames;

/** 返回属性与属性类型 */
+ (nonnull NSDictionary <NSString *,id>*)attributes;

/** 归档 */
+ (nonnull NSData *)archive:(nonnull TCModel *)model;
/** 归档 */
- (nonnull NSData *)archive;
/** 读档 */
+ (nullable instancetype)unarchiveWithData:(nonnull NSData *)data;

/** 归档于UserDefaults */
+ (void)archive:(nonnull TCModel *)model userDefaultsKey:(nonnull NSString *)key;
/** 归档于UserDefaults */
- (void)archiveWithUserDefaultsKey:(nonnull NSString *)key;
/** 读档于UserDefaults */
+ (nullable instancetype)unarchiveWithUserDefaultsKey:(nonnull NSString *)key;
/** json转字典 */
+ (nullable NSDictionary *)dictionaryWithJson:(nullable NSString *)json NS_SWIFT_NAME(dictionary(_:));
/** 字典转json */
+ (nullable NSString *)jsonWithDictionary:(nullable NSDictionary *)dictionary NS_SWIFT_NAME(json(_:));
/**
 *  属性类型为数组 数组中的元素是TCModel类 需要重写此方法
 *  @example {@"属性名1":[A_TCModel class], @"属性名2":[B_TCModel class]}
 *  @return 标识属性数组中元素类型的字典
 */
+ (nonnull NSDictionary <NSString *,Class>*)objectClassInArray;

@end
