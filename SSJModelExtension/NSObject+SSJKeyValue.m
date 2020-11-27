//
//  NSObject+SSJKeyValue.m
//  第三方框架解读
//
//  Created by SSJ on 2020/11/25.
//

#import "NSObject+SSJKeyValue.h"
#import <CoreData/CoreData.h>
@implementation NSObject (SSJKeyValue)

/// 字典 -> 模型
/// @param dic 数据源字典
- (instancetype)ssj_ObjectWithDictionary:(NSDictionary *)dic{
    if(!dic)
        return nil;
//    dispatch_group_t group = dispatch_group_create();
//    dispatch_group_enter(group);
//    dispatch_semaphore_t signal = dispatch_semaphore_create(0);
    __weak typeof(self) weakSelf = self;
    [self gainObjc_propertyList:^(NSMutableArray *propertyArray,NSMutableDictionary *propertyDic) {
        for (int i = 0; i < propertyArray.count; i ++) {
            ///取出属性名
            NSString *proName = propertyArray[i];
            //得到属性名对应的value值
            if (![dic isKindOfClass:[NSDictionary class]]) {
                ///如果不是字典类型，直接返回不对dic做处理
                [weakSelf setValue:dic forKey:proName];
                break;
            }
            ///这里对特殊属名字进行转化，服务端有时候会传递类似id这样的敏感字段过来，我们要将自定义的名字替换为服务端返回的那个名字
            id proValue;
            ///转换名字，比如把id替换为idStr,如果没有实现ssj_propertyNameExchange方法，则采用原来的proName
            NSString *proNameExchange = [weakSelf exchangeName:proName];
            proValue = dic[proNameExchange];
            
            ///获取value属性值对应的类型-字符串
            NSString *classNameStr = NSStringFromClass([proValue class]);
            ///如果是字典类型
            if ([classNameStr isEqualToString:@"__NSDictionaryI"] || [classNameStr isEqualToString:@"NSDictionary"] || [classNameStr isEqualToString:@"__NSDictionaryM"]) {
                proValue = [[NSClassFromString(propertyDic[proName]) new] ssj_ObjectWithDictionary:proValue];
            }else if ([classNameStr isEqualToString:@"__NSArrayI"] || [classNameStr isEqualToString:@"NSArray"] || [classNameStr isEqualToString:@"__NSArrayM"]) {///如果是数组类型
                ///如果没实现Ssj_arrayChildClassName方法或者找不到proName对应的类型名
                if(![self foundSsj_arrayChildClassName:proName]){
                    [weakSelf setValue:proValue forKey:proName];
                    continue;
                }
                
                ///arrChildClassDic -> 记录的是数组内元素的类型，格式：@{@"childFileModel":@"ChildFileModel"};
                NSDictionary *arrChildClassDic = [weakSelf ssj_arrayChildClassName];
                ///class就是数组内部元素类型
                Class class = NSClassFromString(arrChildClassDic[proName]);
                ///如果数组元素是字符串，就放过 ->
                if ([arrChildClassDic[proName] isEqualToString:@"NSString"] || [arrChildClassDic[proName] isEqualToString:@"__NSCFString"]) {
                    [weakSelf setValue:proValue forKey:proName];
                    continue;
                }
                ///如果数组元素不是字符串，就一个个去解析，最后拼装成一个新的对象数组 ->
                NSMutableArray *proValueArray = [NSMutableArray new];
                for (id child in ((NSArray *)proValue)) {
                    id proChildValue = [[class new] ssj_ObjectWithDictionary:child];
                    [proValueArray addObject:proChildValue];
                }
                ///新的对象数组，传给proValue
                proValue = proValueArray;
                [weakSelf setValue:proValue forKey:proName];
                continue;
            }else{
                ///
            }
            ///KVC实现赋值
            [weakSelf setValue:proValue forKey:proName];
            ///NSLog(@"doClassWithDic name:%@  value:%@", proName,proValue);
        }
//        dispatch_semaphore_signal(signal);
    }];
//    dispatch_semaphore_wait(signal, DISPATCH_TIME_FOREVER);
    return self;
   
}

///模型转字典
- (NSDictionary *)entityToDictionary:(id)entity
{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *dicReturn = [NSMutableDictionary new];
    [self gainObjc_propertyList:^(NSMutableArray *propertyArray, NSMutableDictionary *propertyDic) {
        for (int i = 0; i < propertyArray.count; i ++) {
            ///取出属性名
            NSString *proName = propertyArray[i];
            ///转换名字，备用
            NSString *proNameExchange = [self exchangeName:proName];
            ///获取属性值
            const char* propertyName =  (char*) [proName cStringUsingEncoding:NSUTF8StringEncoding];;
            id value = [entity performSelector:NSSelectorFromString([NSString stringWithUTF8String:propertyName])];
            ///获取属性值类型并判断是不是foundation框架的类型
            NSString *valueClassName = [propertyDic objectForKey:proName];
            Class valueClass = NSClassFromString(valueClassName);
            if ([self isClassFromFoundation:valueClass]) {
                if ([valueClassName isEqualToString:@"__NSArrayI"] || [valueClassName isEqualToString:@"NSArray"]) {///如果是数组类型
                    ///这里要对数组进行内部元素类型判断
                    ///如果没实现Ssj_arrayChildClassName方法或者找不到proName对应的类型名
                    if(![self foundSsj_arrayChildClassName:proName]){
                        [dicReturn setValue:value forKey:proNameExchange];
                        continue;
                    }
                    ///arrChildClassDic -> 记录的是数组内元素的类型，格式：@{@"childFileModel":@"ChildFileModel"};
                    NSDictionary *arrChildClassDic = [weakSelf ssj_arrayChildClassName];
                    ///class就是数组内部元素类型
                    Class class = NSClassFromString(arrChildClassDic[proName]);
                    
                    ///如果数组元素是字符串，就不去解析直接放过 ->
                    if ([arrChildClassDic[proName] isEqualToString:@"NSString"]) {
                        [dicReturn setValue:value forKey:proNameExchange];
                        continue;
                    }
                    ///如果数组元素不是字符串，就一个个去解析，最后拼装成一个新的对象数组 ->
                    NSMutableArray *proValueArray = [NSMutableArray new];
                    for (id child in ((NSArray *)value)) {
                        id proChildValue = [[class new] entityToDictionary:child];
                        [proValueArray addObject:proChildValue];
                    }
                    ///新的对象数组，传给proValue
                    value = proValueArray;
                }
                ///如果提示value为nil，看看propertyArray是否包含proName这个属性，或者你可以实现ssj_propertyNameExchange方法来替换
                if (!value) {
                    NSLog(@"-------------------");
                    NSLog(@"-------------------");
                    NSLog(@"-------------------");
                    NSLog(@"");
                    NSLog(@"-------------------找不到%@这个字段名--------",proName);
                    NSLog(@"");
                    NSLog(@"-------------------");
                    NSLog(@"-------------------");
                    NSLog(@"-------------------");
                    NSLog(@"-------------------");
                    value = @"";
                }
                [dicReturn setObject:value forKey:proNameExchange];
                
            }else{
                ///不是foundation框架的类型，需要进一步解析
                id objValue = [value entityToDictionary:value];
                [dicReturn setObject:objValue forKey:proNameExchange];
            }
            
        }
    }];
    return dicReturn;
    
}

/// 查看实体类是否实现ssj_arrayChildClassName方法，
/// @param proName 要查找的key
- (BOOL)foundSsj_arrayChildClassName:(NSString *)proName{
    /// ->获取数组内元素的类型
    if(![self respondsToSelector:@selector(ssj_arrayChildClassName)]){
        ///如果没有实现这个方法，那么就无法对数组内的元素进行对象化
        return false;
    }
    ///arrChildClassDic -> 记录的是数组内元素的类型，格式：@{@"childFileModel":@"ChildFileModel"};
    NSDictionary *arrChildClassDic = [self ssj_arrayChildClassName];
    ///class就是数组内部元素类型
    if (!arrChildClassDic[proName]) {
        ///如果ssj_arrayChildClassName方法没有指定当前数组属性内部的子元素类型，那么就放过
        return false;
    }
    return YES;
}

/// 获取当前类所有属性列表
/// @param block    返回信息 ->
///     propertyArray：返回属性名数组
///     propertyDic：属性名对应的类名字典
- (void)gainObjc_propertyList:(void(^)(NSMutableArray *propertyArray,NSMutableDictionary *propertyDic))block{
    NSMutableDictionary *dic = [NSMutableDictionary new];
    NSMutableArray *propertyArrays = [NSMutableArray new];
    unsigned int propertyCount = 0;
    ///通过运行时获取当前类的属性
    objc_property_t *propertys = class_copyPropertyList([self class], &propertyCount);
    
    //把属性放到数组中
    for (int i = 0; i < propertyCount; i ++) {
        ///取出第一个属性
        objc_property_t property = propertys[i];
        //得到属性对应的名称
        NSString *name = @(property_getName(property));
        [propertyArrays addObject:name];
        ///NSLog(@"name:%@", name);
        const char * type =property_getAttributes(property);
        
        //           NSString *attr = [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
        NSString * typeString = [NSString stringWithUTF8String:type];
        NSArray * attributes = [typeString componentsSeparatedByString:@","];
        NSString * typeAttribute = [attributes objectAtIndex:0];
        NSString * propertyType = [typeAttribute substringFromIndex:1];
        const char * rawPropertyType = [propertyType UTF8String];
        ///NSLog(@"属性类名：%s------%s",type,rawPropertyType);
        NSString *rawPropertyTypeDealWith = [NSString stringWithFormat:@"%s",rawPropertyType];
        ///去掉前面的@
        NSString *rawPropertyTypeDealWith01 = [rawPropertyTypeDealWith stringByReplacingOccurrencesOfString:@"@" withString:@""];
        //去掉前面的前后的“
        NSString *rawPropertyTypeDealWith02 = [rawPropertyTypeDealWith01 stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        //这里的rawPropertyTypeDealWith02就是属性名对应的类型名-字符串
        [dic setValue:rawPropertyTypeDealWith02 forKey:name];
    }
    if(block){
        block(propertyArrays,dic);
    }
}

///判断是否foundation框架的类型
- (BOOL)isClassFromFoundation:(Class)c
{
    if (c == [NSObject class] || c == [NSManagedObject class]) return YES;
    
    static NSSet *foundationClasses;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 集合中没有NSObject，因为几乎所有的类都是继承自NSObject，具体是不是NSObject需要特殊判断
        foundationClasses = [NSSet setWithObjects:
                             [NSURL class],
                             [NSDate class],
                             [NSValue class],
                             [NSData class],
                             [NSError class],
                             [NSArray class],
                             [NSDictionary class],
                             [NSString class],
                             [NSAttributedString class], nil];
    });
    
    __block BOOL result = NO;
    [foundationClasses enumerateObjectsUsingBlock:^(Class foundationClass, BOOL *stop) {
        if ([c isSubclassOfClass:foundationClass]) {
            result = YES;
            *stop = YES;
        }
    }];
    return result;
}

///替换名字，针对id转idStr这样的类似情况
- (NSString *)exchangeName:(NSString *)proName{
    if([self respondsToSelector:@selector(ssj_propertyNameExchange)]){
        NSDictionary *exchangeNameDic = [self ssj_propertyNameExchange];
        if (exchangeNameDic) {
            NSString *exchangeProName = exchangeNameDic[proName];
            ///这里的exchangeProName才是服务端返回json里真正的名字，比如id
            if (!exchangeProName) {
                return proName;
            }else{
                return exchangeProName;
            }
        }else{
            return proName;
        }
    }
    return proName;
}

@end
