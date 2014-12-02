//
//  CBSHKConfigurator.m
//  ChildBook
//
//  Created by Dmitry Kuznetsov on 22.02.14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "CBSHKConfigurator.h"

@implementation CBSHKConfigurator

#pragma mark - Facebook

-(NSString*)facebookAppId{
    return @"356795431123643";
}

-(NSString*)facebookLocalAppId{
    return @"00a0fd5e0eacd7f48b6b7002a74dace8";
}

- (NSArray *)facebookListOfPermissions
{
    return [NSArray arrayWithObjects:@"publish_stream", @"publish_actions", @"offline_access", nil];
}

- (NSString *)facebookURLShareDescription
{
    return @"";
}

#pragma mark - Twitter

-(NSString*)twitterConsumerKey{
    return @"J0i58ACmocJ94SNloDBEog";
}

-(NSString*)twitterSecret{
    return  @"nFhKyoSnhyOajiMEY6NNuwmi5r1eoWjSr5ERiCl00";
}

#pragma mark - VC

- (NSString *)vkontakteAppId
{
    return @"4657418";
}

@end
