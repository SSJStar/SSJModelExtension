//
//  SSJZoon.m
//  SSJModelExtensionDemo
//
//  Created by SSJ on 2020/11/26.
//

#import "SSJZoon.h"


@implementation SSJZoon
- (NSDictionary *)ssj_arrayChildClassName{
    return @{@"dogs":@"Dog",
             @"breeders":@"Breeder",
    };
}


/// 字段名替换，格式@{@"idStr":@"id",}
- (NSDictionary *)ssj_propertyNameExchange{
    return @{@"idStr":@"id"};
}
@end

@implementation Director
/// 字段名替换，格式@{@"idStr":@"id",}
- (NSDictionary *)ssj_propertyNameExchange{
    return @{@"idStr":@"id"};
}
@end

@implementation Breeder
- (NSDictionary *)ssj_propertyNameExchange{
    return @{@"idStr":@"id"};
}
@end

@implementation Dog
- (NSDictionary *)ssj_propertyNameExchange{
    return @{@"idStr":@"id"};
}
@end
