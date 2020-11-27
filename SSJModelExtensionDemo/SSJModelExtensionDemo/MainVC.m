//
//  MainVC.m
//  SSJModelExtensionDemo
//
//  Created by SSJ on 2020/11/26.
//

#import "MainVC.h"
#import "SSJZoon.h"
@interface MainVC ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (weak, nonatomic) IBOutlet UILabel *dogsLabel;

@property (weak, nonatomic) IBOutlet UILabel *breedersLabel;

@property (weak, nonatomic) IBOutlet UITextView *directorTextView;

@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    ///这里直接读取json文件，返回字典数据（模拟网络请求）
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    if (!dic) {
        return;
    }
    
    ///字典转模型
    SSJZoon *zoon = [[SSJZoon new] ssj_ObjectWithDictionary:dic];
    NSLog(@"idStr------%@",zoon.idStr);
    ///模型转字典
    NSDictionary *dd = [zoon entityToDictionary:zoon];
    NSLog(@"dd-----%@",dd);
    
    
    
    
    self.nameLabel.text = [@"动物园名字:" stringByAppendingString:zoon.zoonName];
    self.addressLabel.text = [@"动物园地址:" stringByAppendingString:zoon.zoonAddress];;
    
    NSString *dogsName = @"园区犬们名字：";
    for (Dog *dog in zoon.dogs) {
        dogsName = [[dogsName stringByAppendingString:dog.name] stringByAppendingString:@" "];
    }
    
    self.dogsLabel.text = dogsName;
    
    NSString *breedersName = @"饲养员们名字：";
    for (Breeder *breeder in zoon.breeders) {
        breedersName = [[breedersName stringByAppendingString:breeder.name] stringByAppendingString:@" "];
    }
    
    self.breedersLabel.text = breedersName;
    
    NSString *breedersInfo = [NSString stringWithFormat:@"园长信息：\n姓名-%@ \n年龄-%@ \n性别-%@",zoon.director.name,zoon.director.age,zoon.director.sex];
    self.directorTextView.text = breedersInfo;
}



@end
