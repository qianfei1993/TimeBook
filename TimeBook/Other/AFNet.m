//
//  AFNet.m
//
//  Created by SKY
//  Copyright © 翊sky. All rights reserved.
//

#import "AFNet.h"
/**
 * If you are not satisfied, you can continue to package
 */
@implementation AFNet

+ (id)shareManager {
    
    static AFHTTPSessionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
        
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        //allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO//如果是需要验证自建证书，需要设置为YES
        securityPolicy.allowInvalidCertificates = NO;
        //validatesDomainName 是否需要验证域名，默认为YES；
        securityPolicy.validatesDomainName = YES;
        manager.securityPolicy  = securityPolicy;
        
        manager.requestSerializer.timeoutInterval = 12.f;
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/html",@"text/plain",@"text/javascript",nil];
    });
    return manager;
}

+ (void)getRequestHttpURL:(NSString *)url
                completation:(SuccessBlock)success
                     failure:(FailureBlock)netFailure {
    
    [self checkNetworkReachabilityStatus];
    
    AFHTTPSessionManager *manager = [AFNet shareManager];
    
    [self setNetworkActivityIndicator:YES];
    
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        id responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if (responseData == nil) {
            return;
        }
        
        if (success && responseData) {
            success(responseData);
        }
        
        [self setNetworkActivityIndicator:NO];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self setNetworkActivityIndicator:NO];
        
        if (netFailure) {
            netFailure(error);
        }
        
    }];
    
}
+ (void)postRequestHttpURL:(NSString *)url
                    parameter:(id)parameter
                 completation:(SuccessBlock)success
                      failure:(FailureBlock)netFailure {
    
    [self checkNetworkReachabilityStatus];
    
    AFHTTPSessionManager *manager = [AFNet shareManager];
    
    [self setNetworkActivityIndicator:YES];
    
    [manager POST:url parameters:parameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        id responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if (responseData == nil) {
            return;
        }
        
        if (success && responseData) {
            success(responseData);
        }
        
        [self setNetworkActivityIndicator:NO];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self setNetworkActivityIndicator:NO];
        if (netFailure) {
            netFailure(error);
        }
        
    }];
    
}

+ (void)postUploadURL:(NSString *)url
              parameters:(NSDictionary *)parameters
                formData:(FormDataBlock)uploadData
                progress:(ProgressBlock)progress
            completation:(SuccessBlock)success
                 failure:(FailureBlock)failure {
    
    [self checkNetworkReachabilityStatus];
    
    AFHTTPSessionManager *manager = [AFNet shareManager];
    
    [self setNetworkActivityIndicator:YES];
    
    [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        if (uploadData) {
            uploadData(formData);
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        if (progress) {
            progress(uploadProgress);
        }
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        id responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if (success && responseData) {
            success(responseData);
        }

        [self setNetworkActivityIndicator:NO];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self setNetworkActivityIndicator:NO];
        
        if (failure) {
            failure(error);
        }
        
    }];
    
}

//检查网络
+ (void)checkNetworkReachabilityStatus{
    
    // 如果要检测网络状态的变化, 必须要用检测管理器的单例startMoitoring
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:{//手机网络
                NSLog(@"手机网络");
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi:{//wifi
                NSLog(@"wifi");
                break;
            }
            case AFNetworkReachabilityStatusNotReachable://没网
            case AFNetworkReachabilityStatusUnknown:{//未知
                NSLog(@"没网");
                return;
                break;
            }
            default:
                break;
        }
        
    }];
}

//网络活动指示
+ (void)setNetworkActivityIndicator:(BOOL)sign {
    UIApplication *app = [UIApplication sharedApplication];
    [app setNetworkActivityIndicatorVisible:sign];
}
@end
