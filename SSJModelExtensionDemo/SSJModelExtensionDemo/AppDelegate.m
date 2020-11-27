//
//  AppDelegate.m
//  SSJModelExtensionDemo
//
//  Created by SSJ on 2020/11/26.
//

#import "AppDelegate.h"
#import "MainVC.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[MainVC new]];
    nav.navigationBar.translucent = NO;
    self.window.rootViewController = nav;
    
    return YES;
}



@end
