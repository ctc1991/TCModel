//
//  TCModel.m
//
//  Created by ctc on 15/12/21.
//  Copyright © 2015年 CTC. All rights reserved.
//

#import "TCModel.h"
#import <objc/runtime.h>

@implementation TCModel

- (instancetype)init {
    if (self = [super init]) {
        [self initData];
    }
    return self;
}

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    TCModel *model = [self new];
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        [model setValuesForKeysWithDictionary:dictionary];
    }
    return model;
}

/** 将json字符串转为model */
+ (instancetype)modelWithJson:(NSString *)json {
    id dictionary = [self dictionaryWithJson:json];
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        return [self modelWithDictionary:dictionary];
    } else {
        return [self new];
    }
}


/** 所有属性初始化 */
- (void)initData {
    for (NSString *key in self.class.propertyNames) {
        NSString *type = self.class.attributes[key];
        if ([NSClassFromString(type) isSubclassOfClass:[NSDictionary class]]) {
            [self setValue:[NSDictionary dictionary] forKey:key];
        } else if ([NSClassFromString(type) isSubclassOfClass:[NSArray class]]) {
            [self setValue:[NSArray array] forKey:key];
        } else {
            [self setValue:nil forKey:key];
        }
    }
}

/** json转字典 */
+ (NSDictionary *)dictionaryWithJson:(NSString *)json {
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    if (!jsonData) return nil;
    NSError *err;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&err];
    if (err) return nil;
    return dictionary;
}

/** 字典转json */
+ (NSString *)jsonWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary) return nil;
    NSError *err = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&err];
    if (err) return nil;
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([self isEmptyWithValue:value]) {
        value = @"";
    } else if ([value isKindOfClass:[NSArray class]]) {
        value = [self handleArrayWithKey:key value:value];
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        value = [self handleDictionaryWithKey:key value:value];
    }
    [super setValue:value forKey:key];
}

/// 判断传入的值是否为空
- (BOOL)isEmptyWithValue:(id)value {
    if (value==nil || [value isEqual:[NSNull null]] || [value isKindOfClass:[NSNull class]]) {
        return YES;
    } else if ([value isKindOfClass:[NSString class]] && ([value isEqualToString:@"<null>"] || [value isEqualToString:@"(null)"] || [value isEqualToString:@"（null）"])) {
        return YES;
    }
    return NO;
}

/// 填充数组的处理
- (id)handleArrayWithKey:(NSString *)key value:(id)value {
    if (self.class.objectClassInArray) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSString *objectClassInArrayKey in self.class.objectClassInArray.allKeys) {
            if ([key isEqualToString:objectClassInArrayKey]) {
                for (NSDictionary *dic in value) {
                    [array addObject:[[self.class.objectClassInArray valueForKey:key] modelWithDictionary:dic]];
                }
                return [array copy];
            }
        }
    }
    return value;
}

/// 填充字典的处理
- (id)handleDictionaryWithKey:(NSString *)key value:(id)value {
    NSString *type = [self.class.attributes objectForKey:key];
    Class aClass = NSClassFromString(type);
    if (![aClass isSubclassOfClass:[NSDictionary class]]) {
        value = [aClass modelWithDictionary:value];
    }
    return value;
}

+ (NSDictionary <NSString *,Class>*) objectClassInArray {
    return nil;
}

+ (NSArray *)propertyNames {
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

+ (NSDictionary *)attributes {
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
 32  64
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
- (NSData *)archive {
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}
+ (instancetype)unarchiveWithData:(NSData *)data {
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}
+ (instancetype)unarchiveWithUserDefaultsKey:(NSString *)key {
    return [self unarchiveWithData:[[NSUserDefaults standardUserDefaults]objectForKey:key]];
}
+ (void)archive:(TCModel *)model userDefaultsKey:(NSString *)key{
    [[NSUserDefaults standardUserDefaults] setObject:[self archive:model] forKey:key];
}
- (void)archiveWithUserDefaultsKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:[self archive] forKey:key];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        for (NSString *keyPath in self.class.propertyNames) {
            [self setValue:[aDecoder decodeObjectForKey:keyPath] forKey:keyPath];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    for (NSString *keyPath in self.class.propertyNames) {
        [aCoder encodeObject:[self valueForKey:keyPath] forKey:keyPath];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"json中字段\"%@\"没有填充到%@中",key,self.class);
}

// 重写描述,解决一般情况下自定义model类无法直观展示.
- (NSString *)description {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (NSString *key in self.class.propertyNames) {
        id value = [self valueForKey:key];
        if ([value isKindOfClass:[TCModel class]]) {
            value = [value description];
        } else if ([value isKindOfClass:[NSArray class]]) {
            if ([[self.class objectClassInArray] valueForKey:key]) {
                NSMutableArray *array = [value mutableCopy];
                for (int i=0; i<[value count]; i++) {
                    array[i] = [value[i] description];
                }
                value = [array copy];
            }
        }
        dictionary[key] = value;
    }
    return [TCModel jsonWithDictionary:dictionary];
}

@end



