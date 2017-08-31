 //
//  TCModel.m
//
//  Created by 程天聪 on 15/12/21.
//  Copyright © 2015年 CTC. All rights reserved.
//

#import "TCModel.h"
#import <objc/runtime.h>

@implementation TCModel

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
+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    TCModel *model = [self new];
    [model setValuesForKeysWithDictionary:dictionary];
    return model;
}

/** 将json字符串转为model */
+ (instancetype)modelWithJsonString:(NSString *)jsonString {
    NSDictionary *dictioanry = [self dictionaryWithJsonString:jsonString];
    return [self modelWithDictionary:dictioanry];
}

/** json转字典 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (err) return nil;
    return dictionary;
}

/** 字典转json */
+ (NSString *)jsonStringWithDictionary:(NSDictionary *)dictionary {
    NSError *err = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&err];
    if (err) return nil;
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    
    if ([[self.class allProperties] containsObject:key]) {
        // value总共5种情况（空 字典 数组 字符串 基本数据类型）
        if (value==nil || [value isEqual:[NSNull null]]||[value isKindOfClass:[NSNull class]]) {
            // 1.空
            value = @"";
        } else if ([value isKindOfClass:[NSArray class]]) {
            // 2.数组
            NSDictionary *objectClassInArrayDictionary = [self.class objectClassInArray];
            if (objectClassInArrayDictionary) {
                NSMutableArray *array = [NSMutableArray array];
                for (NSString *objectClassInArrayKey in objectClassInArrayDictionary.allKeys) {
                    if ([key isEqualToString:objectClassInArrayKey]) {
                        for (NSDictionary *dic in value) {
                            [array addObject:[[objectClassInArrayDictionary valueForKey:key] modelWithDictionary:dic]];
                        }
                    }
                }
                value = array;
            }
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            // 3.字典
            NSDictionary *attDic = [self.class allAttributes];
            NSString *att = [attDic objectForKey:key];
// 当属性是字典时候 此处判断不做好的处理 容易崩溃
            if (att.length != 0) {
                Class aClass = NSClassFromString(att);
                if (![aClass isKindOfClass:[NSDictionary class]]) {
                    value = [NSClassFromString(att) modelWithDictionary:value];
                }
            }
        } else if ([value isKindOfClass:[NSString class]]) {
            // 4.字符串 （json字符串 字符串 基本数据类型）
            
            // (1)json字符串
//            NSDictionary *jsonDic = [self.class dictionaryWithJsonString:value];
//            if (jsonDic) {
//                // 可以转为字典的json字符串
//                [self setValue:jsonDic forKey:key];
//                return;
//            }
            // (2)普通字符串
            if ([value isEqualToString:@"<null>"] || [value isEqualToString:@"(null)"] || [value isEqualToString:@"（null）"]) {
                // 错误格式的字符串 系统没识别为null和nil
                value = @"";
            } else {
                NSString *type = [[self.class allAttributes] objectForKey:key];
                if (![type isEqualToString:@"NSString"]) {
                    if ([type isEqualToString:@"BOOL"]) {
                        [super setValue:@([value boolValue]) forKey:key];
                        return;
                    } else if ([type isEqualToString:@"NSInteger"]) {
                        [super setValue:@([value integerValue]) forKey:key];
                        return;
                    } else if ([type isEqualToString:@"CGFloat"]) {
                        [super setValue:@([value doubleValue]) forKey:key];
                        return;
                    } else if ([type isEqualToString:@"float"]) {
                        [super setValue:@([value floatValue]) forKey:key];
                        return;
                    } else if ([type isEqualToString:@"int"]) {
                        [super setValue:@([value intValue]) forKey:key];
                        return;
                    }
                }
            }
        }

    }
    [super setValue:value forKey:key];
}

+ (NSDictionary *)objectClassInArray {
    return nil;
}

+ (instancetype)emptyModel {
    TCModel *model = [self new];
    for (NSString *keyPath in [self allProperties]) {
        [model setValue:@"" forKeyPath:keyPath];
    }
    return model;
}

+ (NSArray *)allProperties {
    u_int count;
    objc_property_t *properties  = class_copyPropertyList(self, &count);
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
    for (int i=0;i<count;i++) {
        const char* propertyName = property_getName(properties[i]);
        [propertiesArray addObject: [[NSString stringWithUTF8String: propertyName] copy]];
    }
    free(properties);
    return propertiesArray;
}

/** 得到所有非基本数据类型属性类型 */
+ (NSDictionary *)allAttributes {
    u_int count;
    objc_property_t *properties  = class_copyPropertyList(self, &count);
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (int i=0;i<count;i++) {
        const char* propertyName = property_getName(properties[i]);
        [propertiesArray addObject: [NSString stringWithUTF8String: propertyName]];
        const char * attributes = property_getAttributes(properties[i]);//获取属性类型
        NSString *attributesString = [NSString stringWithUTF8String: attributes];
        if ([attributesString containsString:@"@"] ) {
            // 包含@，非基本数据类型
            NSString *attributeName = [[[[attributesString componentsSeparatedByString:@","] firstObject] componentsSeparatedByString:@"\""] objectAtIndex:1];
            [dic setObject:attributeName forKey:[NSString stringWithUTF8String: propertyName]];
        } else {
            NSString *attributeName = [[[[attributesString componentsSeparatedByString:@","] firstObject] componentsSeparatedByString:@"\""] objectAtIndex:0];
            [dic setObject:[self baseTypeName:[attributeName substringFromIndex:1]] forKey:[NSString stringWithUTF8String: propertyName]];
        }
    }
    free(properties);
    return dic;
}

/** 返回正确的基本数据类型名 */
+ (NSString *)baseTypeName:(NSString *)name {
    if ([name isEqualToString:@"B"] || [name isEqualToString:@"c"]) {
        // 32位系统 BOOL类型位Tc 64位 TB
        return @"BOOL";
    } else if ([name isEqualToString:@"q"] || [name isEqualToString:@"l"]) {
        return @"NSInteger";
    } else if ([name isEqualToString:@"d"]) {
        return @"CGFloat";
    } else if ([name isEqualToString:@"f"]) {
        return @"float";
    } else if ([name isEqualToString:@"i"]) {
        return @"int";
    }
    return nil;
}
/*
 NSInteger	i	q
 CGFloat	f	d
 int		i	i
 float		f	f
 double		d	d
 BOOL		c	B
 bool		B	B
 char		c	c
 */

//归档
+ (NSData *)archive:(TCModel *)model {
    return [NSKeyedArchiver archivedDataWithRootObject:model];
}
+ (instancetype)unarchiveWithData:(NSData *)data {
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}
+ (instancetype)unarchiveModelFromUserDefaultsWithKey:(NSString *)key {
    return [self unarchiveWithData:[[NSUserDefaults standardUserDefaults]objectForKey:key]];
}
+ (void)archive:(TCModel *)model toUserDefaultsWithKey:(NSString *)key{
    [[NSUserDefaults standardUserDefaults] setObject:[self archive:model] forKey:key];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        for (NSString *keyPath in [self.class allProperties]) {
                [self setValue:[aDecoder decodeObjectForKey:keyPath] forKey:keyPath];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    for (NSString *keyPath in [self.class allProperties]) {
        [aCoder encodeObject:[self valueForKey:keyPath] forKey:keyPath];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
//    NSLog(@"key\"%@\"没有找到%@中的属性",key,self.class);
}

// 重写描述,解决一般情况下自定义model类无法直观展示.
- (NSString *)description {
    NSArray *properties = [self.class allProperties];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (NSString *key in properties) {
        NSString *let = [key mutableCopy];
        id value = [self valueForKey:let];
        dictionary[let] = value;
//        NSLog(@"let:%@",let);
    }
    return [TCModel jsonStringWithDictionary:dictionary];
}

@end



