# SSJModelExtension
模仿MJExtension的核心思想，写了一个简易版的框架，实现NSDictionary和数据模型类之间的互相转换
## 使用方法
1、在你的模型.h文件里导入
  #import "SSJModelExtension.h"
2、在你的模型.m文件实现：
```
///指明数组内部元素的类型
 - (NSDictionary *)ssj_arrayChildClassName{
    return @{@"dogs":@"Dog",
             @"breeders":@"Breeder",
    };
}


/// 字段名替换，格式@{@"idStr":@"id",}
- (NSDictionary *)ssj_propertyNameExchange{
    return @{@"idStr":@"id"};
}
```

3、调用方法
```
    ///字典转模型
    SSJZoon *zoon = [[SSJZoon new] ssj_ObjectWithDictionary:dic];

    ///模型转字典
    NSDictionary *dd = [zoon entityToDictionary:zoon];
```
