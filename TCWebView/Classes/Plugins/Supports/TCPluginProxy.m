//
//  TCPluginProxy.m
//  TCWebView
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import "TCPluginProxy.h"
#import "TCPluginCommand.h"
#import "TCWebView.h"
#import "TCPlugin.h"
#import <objc/runtime.h>

@interface TCPluginProxy()

@property (nonatomic, weak) TCWebViewController *webViewController;
@property (nonatomic, strong) NSMutableDictionary *plugins;

@end

@implementation TCPluginProxy

/**
 *  构造插件代理类，JS通过该类调用系统里的插件
 *
 *  @param webViewController RCWebViewController对象
 *
 *  @return RCPluginProxy
 */
- (instancetype)initWithWebViewController:(TCWebViewController *)webViewController {
    if (self = [super init]) {
        _webViewController = webViewController;
        [self loadPlugins:_webViewController];
    }
    return self;
}

/**
 *  调用插件的方法
 *
 *  @param className  插件类名
 *  @param methodName 方法名
 *  @param arguments  调用参数
 *  @param callbackID JS回调函数ID
 *
 *  @return 方法处理结果，如果没有返回值则返回nil
 */
- (id)execute:(NSString *)className
   methodName:(NSString *)methodName
    arguments:(NSArray *)arguments
   callbackID:(NSString *)callbackID {
    
    TCPluginCommand *command = [[TCPluginCommand alloc] initWithClassName:className
                                                               methodName:methodName
                                                                arguments:arguments
                                                               callbackID:callbackID];
    
    return [self execute:command];
}

#pragma mark - Private Methods

/**
 *  调用插件的方法
 *
 *  @param command 插件参数封装
 *
 *  @return 方法处理结果，如果没有返回值则返回nil
 */
- (id)execute:(TCPluginCommand *)command {
    NSString *className = command.className;
    TCPlugin *plugin = self.plugins[className];
    if (!plugin) {
        Class class = NSClassFromString(className);
        if (!class || ![class isSubclassOfClass:[TCPlugin class] ]) {
            NSLog(@"ERROR，插件'%@'不存在，插件必须继承自TCPlugin", className);
            return nil;
        }
        plugin = [[class alloc] initWithWebViewController:self.webViewController];
        self.plugins[className] = plugin;
    }
    
    // 声明返回值变量
    id returnValue;
    double started = [[NSDate date] timeIntervalSince1970] * 1000.0;
    NSString *methodName = [NSString stringWithFormat:@"%@:", command.methodName];
    SEL selector = NSSelectorFromString(methodName);
    if ([plugin respondsToSelector:selector]) {
        NSMethodSignature *methodSignature = [[plugin class] instanceMethodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setTarget:plugin];
        [invocation setSelector:selector];
        [invocation setArgument:&command atIndex:2];
        [invocation retainArguments];
        [invocation invoke];
        
        // 获得返回值类型
        const char *returnType = methodSignature.methodReturnType;
        if (strcmp(returnType, @encode(void)) == 0) { // 如果没有返回值，也就是消息声明为void，那么returnValue=nil
            returnValue = nil;
        } else if (strcmp(returnType, @encode(id)) == 0) { // 如果返回值为对象，那么为变量赋值
            [invocation getReturnValue:&returnValue];
        } else { // 如果返回值为普通类型NSInteger BOOL
            // 返回值长度
            NSUInteger length = [methodSignature methodReturnLength];
            
            // 根据长度申请内存
            void *buffer = (void *)malloc(length);
            
            // 为变量赋值
            [invocation getReturnValue:buffer];
            if (strcmp(returnType, @encode(BOOL)) == 0) {
                returnValue = [NSNumber numberWithBool:*((BOOL*)buffer)];
            } else if(strcmp(returnType, @encode(NSInteger)) == 0) {
                returnValue = [NSNumber numberWithInteger:*((NSInteger*)buffer)];
            } else {
                returnValue = [NSValue valueWithBytes:buffer objCType:returnType];
            }
        }
    } else {
        NSLog(@"ERROR：方法'%@'在插件'%@'中没有定义。", methodName, command.className);
        returnValue = nil;
    }
    double elapsed = [[NSDate date] timeIntervalSince1970] * 1000.0 - started;
    if (elapsed > 10) {
        NSLog(@"THREAD WARNING：方法'%@'调用花费'%f'ms。建议在后台线程执行。", command.methodName, elapsed);
    }
    
    return returnValue;
}

/**
 *  加载非懒加载插件
 *
 *  @param webViewController RCWebViewController
 */
- (void)loadPlugins:(TCWebViewController *)webViewController {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"plugins" ofType:@"bundle"];
    NSBundle *pluginsBundle = [NSBundle bundleWithPath:bundlePath];
    NSString *configPath = [pluginsBundle pathForResource:@"config" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:configPath];
    NSDictionary *pluginConfigs = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    
    /**
     *  预先加载plugins.bundle/config.json里非懒加载的插件
     */
    self.plugins = [NSMutableDictionary dictionary];
    for (NSDictionary *pluginConfig in pluginConfigs) {
        NSString *className = pluginConfig[@"class"];
        BOOL lazy = [pluginConfig[@"lazy"] boolValue];
        if (!lazy) {
            Class class = NSClassFromString(className);
            if (!class || ![class isSubclassOfClass:[TCPlugin class] ]) {
                NSLog(@"ERROR，插件'%@'不存在，请检查plugins.bundle/conifg.json配置文件，插件必须继承自RHPlugin", className);
            }
            self.plugins[className] = [[class alloc] initWithWebViewController:webViewController];
        }
    }
}

/**
 *  卸载插件
 */
- (void)unloadPlugins {
    NSLog(@"释放插件");
    [[_plugins allValues] makeObjectsPerformSelector:@selector(dispose)];
    _plugins = nil;
}

- (void)dealloc {
    NSLog(@"销毁插件代理对象");
}

@end
