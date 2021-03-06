//
//  AppDelegate.m
//  Voice2Note
//
//  Created by liaojinxing on 14-6-11.
//  Copyright (c) 2014年 jinxing. All rights reserved.
//

#import "AppDelegate.h"
#import "NoteListViewController.h"
#import "NoteManager.h"
#import "UIColor+VNHex.h"
#import "UMSocial.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaSSOHandler.h"
#import "UMSocialWechatHandler.h"
#import "VNConstants.h"
#import "VNNote.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    [self customNaviBar];
    [self registerNotification];
    [self registerUmengSDK];

    // 初始化笔记
    [self addInitFileIfNeeded];

    NoteListViewController *noteListViewController = [[NoteListViewController alloc] init];
    UINavigationController *rootViewController = [[UINavigationController alloc] initWithRootViewController:noteListViewController];

    self.window.rootViewController = rootViewController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state.
    // This can occur for certain types of temporary interruptions (such as an
    // incoming phone call or SMS message) or when the user quits the application
    // and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down
    // OpenGL ES frame rates. Games should use this method to pause the game.
    // 图标上的数字减1
    application.applicationIconBadgeNumber -= 1;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate
    // timers, and store enough application state information to restore your
    // application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called
    // instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state;
    // here you can undo many of the changes made on entering the background.
}

/**
 这里处理新浪微博SSO授权之后跳转回来，和微信分享完成之后跳转回来
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
}

/**
 这里处理新浪微博SSO授权进入新浪微博客户端后进入后台，再返回原来应用
 */
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the
    // application was inactive. If the application was previously in the
    // background, optionally refresh the user interface.
    [UMSocialSnsService applicationDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if
    // appropriate. See also applicationDidEnterBackground:.
}

- (void)addInitFileIfNeeded {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"hasInitFile"]) {
        VNNote *note =
            [[VNNote alloc] initWithTitle:nil
                                  content:NSLocalizedString(@"AboutText", @"")
                              createdDate:[NSDate date]
                               updateDate:[NSDate date]];
        [[NoteManager sharedManager] storeNote:note];
        [userDefaults setBool:YES forKey:@"hasInitFile"];
        // 立即同步
        [userDefaults synchronize];
    }
}

/**
 *  本地通知注册成功后调用的方法
 */
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    NSLog(@"本地通知注册成功");
}

/**
 *  本地通知注册失败调用的方法
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"error is:%@", error);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAppName message:notification.alertBody delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];

    NSDictionary *dic = [[NSDictionary alloc] init];
    // 这里可以接受到本地通知中心发送的消息
    dic = notification.userInfo;
    NSLog(@"user info = %@", [dic objectForKey:@"key"]);

    // 图标上的数字减 1
    application.applicationIconBadgeNumber -= 1;

    // 移除当前所有的本地通知
    [application cancelAllLocalNotifications];

    // 移除指定的通知
    [application cancelLocalNotification:notification];
}

- (void)registerNotification {

    // iOS 8 添加权限访问
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound categories:nil]];
    }
}

- (void)registerUmengSDK {
    // 设置友盟社会化组件appkey
    [UMSocialData setAppKey:@"56d10e08e0f55a23a30014d5"];

    // 打开调试log的开关
    [UMSocialData openLog:YES];

    // 如果你要支持不同的屏幕方向，需要这样设置，否则在 iPhone 只支持一个竖屏方向
    [UMSocialConfig setSupportedInterfaceOrientations:UIInterfaceOrientationMaskAll];

    // 设置微信 AppId，设置分享 url，默认使用友盟的网址
    [UMSocialWechatHandler setWXAppId:@"wxdc1e388c3822c80b" appSecret:@"a393c1527aaccb95f3a4c88d6d1455f6" url:@"http://www.umeng.com/social"];

    // 打开新浪微博的 SSO 开关
    // 将在新浪微博注册的应用appkey、redirectURL替换下面参数，并在 info.plist 的 URL Scheme 中相应添加 wb+appkey，如"wb3921700954"，详情请参考官方文档。
    [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:@"3921700954"
                                              secret:@"04b48b094faeb16683c32669824ebdad"
                                         RedirectURL:@"http://sns.whalecloud.com/sina2/callback"];

    //打开腾讯微博 SSO 开关，设置回调地址，只支持 32 位
    //    [UMSocialTencentWeiboHandler openSSOWithRedirectUrl:@"http://sns.whalecloud.com/tencent2/callback"];

    //    //设置分享到QQ空间的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:@"100424468" appKey:@"c7394704798a158208a74ab60104f0ba" url:@"http://www.umeng.com/social"];
    //    //设置支持没有客户端情况下使用SSO授权
    [UMSocialQQHandler setSupportWebView:YES];
}

- (void)customNaviBar {
    // Customize navigation style
    [[UINavigationBar appearance] setBarTintColor:[UIColor systemColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

    NSDictionary *navbarTitleTextAttributes = [NSDictionary
        dictionaryWithObjectsAndKeys:[UIColor whiteColor],
                                     NSForegroundColorAttributeName, nil];
    [[UINavigationBar appearance]
        setTitleTextAttributes:navbarTitleTextAttributes];

    [[UIApplication sharedApplication]
        setStatusBarStyle:UIStatusBarStyleLightContent];
}

@end
