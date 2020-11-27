//
//  SSJZoon.h
//  SSJModelExtensionDemo
//
//  Created by SSJ on 2020/11/26.
//

#import <Foundation/Foundation.h>
#import "SSJModelExtension.h"
NS_ASSUME_NONNULL_BEGIN

@class Director;


@interface SSJZoon : NSObject
///编号
@property (nonatomic , strong) NSString *idStr;
///动物园名字
@property (nonatomic , strong) NSString *zoonName;
///动物园地址
@property (nonatomic , strong) NSString *zoonAddress;
///狗
@property (nonatomic , strong) NSArray *dogs;
///饲养员
@property (nonatomic , strong) NSArray *breeders;
///动物园园长
@property (nonatomic , strong) Director *director;
@end





@interface Dog : NSObject
///编号
@property (nonatomic , strong) NSString *idStr;
///名字
@property (nonatomic , strong) NSString *name;
///年龄
@property (nonatomic , strong) NSString *age;
///性别
@property (nonatomic , strong) NSString *sex;
@end


@interface Breeder : NSObject
///编号
@property (nonatomic , strong) NSString *idStr;
///名字
@property (nonatomic , strong) NSString *name;
///年龄
@property (nonatomic , strong) NSString *age;
///性别
@property (nonatomic , strong) NSString *sex;
@end

@interface Director : NSObject
///编号
@property (nonatomic , strong) NSString *idStr;
///名字
@property (nonatomic , strong) NSString *name;
///年龄
@property (nonatomic , strong) NSString *age;
///性别
@property (nonatomic , strong) NSString *sex;
@end
NS_ASSUME_NONNULL_END
