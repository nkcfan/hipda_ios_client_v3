//
//  HPSendPost.h
//  HiPDA
//
//  Created by wujichao on 13-11-11.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HPNewPost;
@class HPThread;

enum {
    ActionTypeReply     = 0,
    ActionTypeQuote     = 1,
    ActionTypeNewPost   = 2,
    ActionTypeNewThread = 3
} ;
typedef NSUInteger ActionType;


@interface HPSendPost : NSObject

// send post
+ (void)sendPostWithContent:(NSString *)content
                     action:(ActionType)actionType
                        fid:(NSInteger)fid
                        tid:(NSInteger)tid
                       post:(HPNewPost *)post/*quote*/
                postcontent:(NSString *)postcontent/*quote*/
                    subject:(NSString *)subject/*newThread*/
                thread_type:(NSInteger)thread_type
                   formhash:(NSString *)formhash
                     images:(NSArray *)images
                      block:(void (^)(NSString *msg, NSError *error))block;

+ (void)sendThreadWithFid:(NSInteger)fid
                     type:(NSInteger)type
                  subject:(NSString *)subject
                  message:(NSString *)message
                   images:(NSArray *)images
                 formhash:(NSString *)formhash
                    block:(void (^)(NSString *msg, NSError *error))block;

+ (void)loadParametersWithBlock:(void (^)(NSDictionary *parameters, NSError *error))block;
/*
+ (void)loadParameters:(ActionType )actionType
                   fid:(NSInteger)fid
                   tid:(NSInteger)tid
                    re:(NSInteger)re
                 block:(void (^)(NSDictionary *parameters, NSError *error))block;
*/

+ (void)sendReplyWithThread:(HPThread *)thread
                    content:(NSString *)content
               imagesString:(NSArray *)imagesString
                   formhash:(NSString *)formhash
                      block:(void (^)(NSString *msg, NSError *error))block;

+ (void)loadFormhashAndPid:(ActionType)type
                      post:(HPNewPost *)target
                       tid:(NSInteger)tid
                      page:(NSInteger)page
                     block:(void (^)(NSString *formhash, HPNewPost *correct_post, NSError *error))block;

+ (void)uploadImage:(NSData *)imageData
          imageName:(NSString *)imageName
      progressBlock:(void (^)(CGFloat progress))progressBlock
              block:(void (^)(NSString *attach, NSError *error))block;

@end
