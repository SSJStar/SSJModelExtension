//
//  NSObject+SSJKeyValue.h
//  第三方框架解读
//
//  Created by SSJ on 2020/11/25.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
NS_ASSUME_NONNULL_BEGIN

@interface NSObject (SSJKeyValue)

#pragma mark -------- 调用方法 ---------
/// 字典 -> 模型
/// @param dic 数据源字典
- (instancetype)ssj_ObjectWithDictionary:(NSDictionary *)dic;

/// 模型 -> 字典
/// @param entity 模型
- (NSDictionary *)entityToDictionary:(id)entity;

#pragma mark -------- 如果模型内存在数组对象，一定要实现ssj_arrayChildClassName方法 ---------

///返回数组属性内部元素的类型名
///返回一个字典@{@"dogs":@"Dog",}
///     key：数组类型的属性名，value:对应的数组内元素的类型字符串
///      dogs这个属性名的类型是一个数组，后面的Dog代表这个数组内每个元素的类型
- (NSDictionary *)ssj_arrayChildClassName;


/// 字段名替换，格式@{@"idStr":@"id",}
- (NSDictionary *)ssj_propertyNameExchange;

@end

NS_ASSUME_NONNULL_END
