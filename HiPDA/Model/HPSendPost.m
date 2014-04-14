//
//  HPSendPost.m
//  HiPDA
//
//  Created by wujichao on 13-11-11.
//  Copyright (c) 2013年 wujichao. All rights reserved.
//

#import "HPSendPost.h"
#import "HPThread.h"
#import "HPNewPost.h"
#import "HPUser.h"
#import "HPAccount.h"
#import "HPHttpClient.h"
#import "HPSetting.h"
#import "AFHTTPRequestOperation.h"

#import "NSString+Additions.h"
#import <NSString+Emoji/NSString+Emoji.h>

@implementation HPSendPost


// 新帖 回复 or 引用 (高级编辑器)
+ (void)sendPostWithContent:(NSString *)content
                     action:(ActionType)actionType
                        fid:(NSInteger)fid //fid=[thread.fid]
                        tid:(NSInteger)tid
                       post:(HPNewPost *)post/*quote*/
                postcontent:(NSString *)postcontent/*quote*/
                    subject:(NSString *)subject/*newThread*/
                thread_type:(NSInteger)thread_type
                   formhash:(NSString *)formhash
                     images:(NSArray *)images
                      block:(void (^)(NSString *msg, NSError *error))block
{
    //http://www.hi-pda.com/forum/post.php?action=reply&fid=57&tid=1272185&extra=&replysubmit=yes
    
    NSString *path;
    
    int timestamp = [[NSDate date] timeIntervalSince1970];
    NSString *timestampStr = [NSString stringWithFormat:@"%d", timestamp];
    
    NSString *postTail = [NSString stringWithFormat:@"\t%@", [Setting postTail]];
    NSLog(@"postTail %@", postTail);
    
    
    NSDictionary *parameters;
    
    NSLog(@"actionType %d", actionType);
    
    content = [content stringByReplacingEmojiUnicodeWithCheatCodes];
    if (subject) subject = [subject stringByReplacingEmojiUnicodeWithCheatCodes];
    
    switch (actionType) {
        case ActionTypeReply:
        {
            // post.php?action=reply&fid=57&tid=1278617&extra=page=1&replysubmit=yes"
            path = [NSString stringWithFormat:
                    @"forum/post.php?action=reply"
                    "&fid=%d"
                    "&tid=%d"
                    "&extra=&replysubmit=yes"
                    , 100, tid];
            //post.user.uid = 644982;
            //post.user.username = @"geka";
            parameters = @{
                           @"formhash":formhash,
                           @"posttime":timestampStr,
                           @"wysiwyg":@"1",
                           @"usesig":@"1",
                           @"noticeauthor":[NSString stringWithFormat:@"r|%d|[i]%@[/i]",post.user.uid, post.user.username],
                           /*@"noticeauthor":[NSString stringWithFormat:@"r|%d|[i]%@[/i]",644982, @"geka"],*/
                           @"noticetrimstr":[NSString stringWithFormat:@"[b]回复 [url=http://www.hi-pda.com/forum/redirect.php?goto=findpost&pid=%d&ptid=%d]%d#[/url] [i]%@[/i] [/b]", post.pid, tid, post.floor, post.user.username],
                           @"noticeauthormsg":@"",
                           @"subject":@"",
                           @"message":[NSString stringWithFormat:@"[b]回复 [url=http://www.hi-pda.com/forum/redirect.php?goto=findpost&pid=%d&ptid=%d]%d#[/url] [i]%@[/i] [/b] \n    %@%@", post.pid, tid, post.floor, post.user.username, content, postTail]
                           };
            break;
        }
        case ActionTypeQuote:
        {
            // post.php?action=reply&fid=57&tid=1278617&extra=page=1&replysubmit=yes"
            path = [NSString stringWithFormat:
                    @"forum/post.php?action=reply"
                    "&fid=%d"
                    "&tid=%d"
                    "&extra=&replysubmit=yes"
                    , fid, tid];
            
            // i don't know why
            // but it solve the problem
            postcontent = [postcontent stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            //NSLog(@"%@", postcontent);
            
            NSString *noticetrimstr = [NSString stringWithFormat:@"[quote]%@\n[size=2][color=#999999]%@ 发表于 %@[/color][url=http://www.hi-pda.com/forum/redirect.php?goto=findpost&pid=%d&ptid=%d][img]http://www.hi-pda.com/forum/images/common/back.gif[/img][/url][/size][/quote]", postcontent, post.user.username, [HPNewPost dateString:post.date], post.pid, tid];
            
            
            parameters = @{
                           @"formhash":formhash,
                           @"posttime":timestampStr,
                           @"wysiwyg":@"1",
                           @"usesig":@"1",
                           @"noticeauthor":[NSString stringWithFormat:@"q|%d|%@",post.user.uid, post.user.username],
                           @"noticetrimstr":noticetrimstr,
                           @"noticeauthormsg":@"",
                           @"subject":@"",
                           @"message":[NSString stringWithFormat:@"%@\n\n    %@%@", noticetrimstr, content, postTail]
                           };
            
            //NSLog(@"noticetrimstr %@ \n%@",noticetrimstr, [HPSendPost replaceUnicode:parameters[@"noticetrimstr"]]);
           
            break;
        }
        case ActionTypeNewPost:
        {
            // post.php?action=reply&fid=57&tid=1278617&extra=page=1&replysubmit=yes"
            path = [NSString stringWithFormat:
                    @"forum/post.php?action=reply"
                    "&fid=%d"
                    "&tid=%d"
                    "&extra=&replysubmit=yes"
                    , fid, tid];
            
            parameters = @{
                           @"formhash":formhash,
                           @"message":[NSString stringWithFormat:@"%@%@", content, postTail],
                           @"noticeauthor":@"",
                           @"noticeauthormsg":@"",
                           @"noticetrimstr":@"",
                           @"posttime":timestampStr,
                           @"subject":@"",
                           @"usesig":@"1",
                           @"wysiwyg":@"1"
                           };
            break;
        }
        case ActionTypeNewThread:
        {
            //post.php?action=newthread&fid=57&extra=&topicsubmit=yes
            path = [NSString stringWithFormat:
                    @"forum/post.php?action=newthread"
                    "&fid=%d"
                    "&extra=&topicsubmit=yes"
                    , fid];
            
            parameters = @{
                           @"formhash":formhash,
                           @"posttime":timestampStr,
                           @"wysiwyg":@"1",
                           @"usesig":@"1",
                           @"iconid":@"",
                           @"subject":subject,
                           @"message":[NSString stringWithFormat:@"%@%@", content, postTail],
                           @"typeid":S(@"%d", thread_type),
                           @"tags":@"",
                           @"attention_add":@"1"
                           };
            
            NSLog(@"parameters %@", parameters);
            break;
        }
        default:
            NSLog(@"action type error");
            break;
    }
    
    
    if ([images count]) {
        // add image
        
        NSMutableDictionary *new_parameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
        for (NSString *image in images) {
            NSString *key = [NSString stringWithFormat:@"attachnew[%@][description]", image];
            
            [new_parameters setObject:@"" forKey:key];
        }
        
        parameters = [NSDictionary dictionaryWithDictionary:new_parameters];
    }
    
    NSLog(@"send post %@, %@, images %@", path, parameters, images);
    
    
    [[HPHttpClient sharedClient] postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *html = [HPHttpClient GBKresponse2String:responseObject];
        
        //NSLog(@"Response : %@", html);
        
        //alert_info
        //<div class="alert_info">
        //<p>对不起，您两次发表间隔少于 30 秒，请不要灌水！</p>
        //</div>//
        
        //alert_error
        //<div class="alert_error">
        //<p>您无权进行当前操作，原因如下：</p>
        //<p>对不起，您还未登录，无权访问该版块。</p>
        NSString *alert_info = [html stringBetweenString:@"<div class=\"alert_info\">\n<p>" andString:@"</p>"];
        NSString *alert_error = [html stringBetweenString:@"<div class=\"alert_error\">\n<p>" andString:@"</p></div>"];
        
        
        if (block) {
            if (alert_info || alert_error || !html) {
                
                NSString *err;
                if (alert_info) err = alert_info;
                else err = alert_error;
                
                NSDictionary *details = [NSDictionary dictionaryWithObject:err forKey:NSLocalizedDescriptionKey];
                block(@"", [NSError errorWithDomain:@"world" code:200 userInfo:details]);
                
            } else {
                block(@"success", nil);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(@"", error);
        }
    }];
    
}

+ (void)sendThreadWithFid:(NSInteger)fid
                     type:(NSInteger)type
                  subject:(NSString *)subject
                  message:(NSString *)message
                   images:(NSArray *)images
                 formhash:(NSString *)formhash
                    block:(void (^)(NSString *msg, NSError *error))block
{
    [HPSendPost sendPostWithContent:message
                             action:ActionTypeNewThread
                                fid:fid
                                tid:0
                               post:nil
                        postcontent:nil
                            subject:subject
                        thread_type:type
                           formhash:formhash
                             images:images block:block];
}


/*
 fid tid
 */
+ (void)sendReplyWithThread:(HPThread *)thread
                    content:(NSString *)content
               imagesString:(NSArray *)imagesString
                   formhash:(NSString *)formhash
                      block:(void (^)(NSString *msg, NSError *error))block
{
    [HPSendPost sendPostWithContent:content
                             action:ActionTypeNewPost
                                fid:thread.fid
                                tid:thread.tid
                               post:nil
                        postcontent:nil
                            subject:nil
                        thread_type:0
                           formhash:formhash
                             images:imagesString
                              block:block];
}



+ (void)uploadImage:(NSData *)imageData
          imageName:(NSString *)imageName
      progressBlock:(void (^)(CGFloat progress))progressBlock
              block:(void (^)(NSString *attach, NSError *error))block {
    
    [HPSendPost loadParameters:ActionTypeNewThread fid:0 tid:0 re:0 block:^(NSDictionary *parameters, NSError *error) {
        if (error) {
            block(@"", error);
        } else {
            
            //http://www.hi-pda.com/forum/misc.php?action=swfupload&operation=upload&simple=1&type=image
            NSString *path = @"forum/misc.php?action=swfupload&operation=upload&simple=1&type=image";
            
            NSString *uid = [parameters objectForKey:@"uid"];
            NSString *hash = [parameters objectForKey:@"hash"];
            NSString *fileName = imageName?imageName:[NSString stringWithFormat:@"iOS_fly_%d", arc4random() % 101];
            
            if ([uid isEqual:[NSNull null]] || [hash isEqual:[NSNull null]]) {
                NSLog(@"error !uid || !hash");
                
                if (block) {
                    NSDictionary *details = [NSDictionary dictionaryWithObject:@"(⊙o⊙)哦, 没抓到(!uid||!hash)" forKey:NSLocalizedDescriptionKey];
                    block(@"", [NSError errorWithDomain:@"world" code:200 userInfo:details]);
                }
                return;
            }
            
            NSMutableURLRequest *request = [[HPHttpClient sharedClient] multipartFormRequestWithMethod:@"POST" path:path parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                [formData appendPartWithFormData:[uid dataUsingEncoding:NSUTF8StringEncoding] name:@"uid"];
                [formData appendPartWithFormData:[hash dataUsingEncoding:NSUTF8StringEncoding] name:@"hash"];
                [formData appendPartWithFileData:imageData name:@"Filedata" fileName:[NSString stringWithFormat:@"%@.jpeg", fileName] mimeType:@"image/jpeg"];
            }];
            
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *op, id responseObject) {
                NSString *html = [HPHttpClient GBKresponse2String:responseObject];
                
                NSLog(@"response %@", html);
                
                NSArray *ret = [html componentsSeparatedByString:@"|"];
                
                if (block) {
                    if ([ret[0] isEqualToString:@"DISCUZUPLOAD"]
                        && [ret[1] isEqualToString:@"0"]) {
                        block(ret[2], nil);
                    } else {
                        NSDictionary *details = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"上传错误, %@", ret] forKey:NSLocalizedDescriptionKey];
                        
                        block(@"", [NSError errorWithDomain:@"world" code:200 userInfo:details]);
                    }
                }
                
            } failure:^(AFHTTPRequestOperation *op, NSError *err) {
                NSLog(@"fail %@", [err localizedDescription]);
                block(@"", err);
            }];
            
            // if you want progress updates as it's uploading, uncomment the following:
            [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
                //NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
                
                float progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
                
                if (progressBlock) {
                    progressBlock(progress);
                }
            }];
            
            [[HPHttpClient sharedClient] enqueueHTTPRequestOperation:operation];
        }
    }];
}

+ (void)loadParametersWithBlock:(void (^)(NSDictionary *parameters, NSError *error))block {
    [HPSendPost loadParameters:0 fid:0 tid:0 re:0 block:block];
}

+ (void)loadParameters:(ActionType)actionType
                   fid:(NSInteger)fid
                   tid:(NSInteger)tid
                    re:(NSInteger)re
                 block:(void (^)(NSDictionary *parameters, NSError *error))block
{
    
    // 测试下来 参数应该是一样的
    // 注释掉 break
    
    NSString *path;
    switch (actionType) {
        case ActionTypeReply:
        {
            // http://www.hi-pda.com/forum/post.php?action=reply&fid=57&tid=1278361&reppost=22793296
            //break;
        }
        case ActionTypeQuote:
        {
            //http://www.hi-pda.com/forum/post.php?action=reply&fid=57&tid=1278361&repquote=22793296
            //break;
        }
        case ActionTypeNewPost:
        {
            //http://www.hi-pda.com/forum/post.php?action=reply&fid=57&tid=1278407
            //break;
        }
        case ActionTypeNewThread:
        {
            //http://www.hi-pda.com/forum/post.php?action=newthread&fid=57
            
            path = [NSString stringWithFormat:@"forum/post.php?action=newthread&fid=57"];
            
            break;
        }
        default:
            NSLog(@"unkonwn ActionType %d", actionType);
            break;
    }
    
    NSLog(@"loadParameters path %@", path);
    [[HPHttpClient sharedClient] getPathContent:path parameters:nil success:^(AFHTTPRequestOperation *operation, NSString *html) {
        
        //id="formhash" value="82a18cad" />
        NSString *formhash = [html stringBetweenString:@"id=\"formhash\" value=\"" andString:@"\""];
        
        //id="posttime" value="1381639105" />
        NSString *posttime = [html stringBetweenString:@"id=\"posttime\" value=\"" andString:@"\""];
        
        //name="uid" value="644982">
        NSString *uid = [html stringBetweenString:@"name=\"uid\" value=\"" andString:@"\""];
        
        //name="hash" value="56ffb4c9e25da81f57226d959ccf94f9">
        NSString *hash = [html stringBetweenString:@"name=\"hash\" value=\"" andString:@"\""];
        
        NSDictionary *parameters = @{
                                     @"formhash":(formhash?formhash:[NSNull null]),
                                     @"posttime":(posttime?posttime:[NSNull null]),
                                     @"uid":(uid?uid:[NSNull null]),
                                     @"hash":(hash?hash:[NSNull null])
                                     };
        
        NSLog(@"get parameters %@", parameters);
        
        if (block) {
            block(parameters, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block([NSDictionary dictionary], error);
        }
    }];
}

+ (void)loadFormhashAndPid:(ActionType)type
                      post:(HPNewPost *)target
                       tid:(NSInteger)tid
                      page:(NSInteger)page
                     block:(void (^)(NSString *formhash, HPNewPost *correct_post, NSError *error))block {
    
    
    [HPNewPost loadThreadWithTid:tid
                            page:page
                    forceRefresh:YES
                       printable:NO
                        authorid:0
                 redirectFromPid:0
                           block:^(NSArray *posts, NSDictionary *parameters, NSError *error)
    {
        
        if (!error) {
            NSString *formhash = [parameters objectForKey:@"formhash"];
            __block HPNewPost *correct_post = nil;
            
            [posts enumerateObjectsUsingBlock:^(HPNewPost *post, NSUInteger idx, BOOL *stop) {
                
                //NSLog(@"%@ vs %@", target.user.username, post.user.username);
                //NSLog(@"%d vs %d", target.floor, post.floor);
                
                if ([target.user.username isEqualToString:post.user.username] &&
                    target.floor == post.floor) {
                
                    correct_post = post;
                    *stop = YES;
                }
            }];
            
            block(formhash, correct_post, error);
        } else {
            block(nil, nil, error);
        }
    }];
}



+ (NSString *)replaceUnicode:(NSString *)unicodeStr
{
    
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
    NSString *tempStr3 = [[@"\""stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                          mutabilityOption:NSPropertyListImmutable
                                                                    format:NULL
                                                          errorDescription:NULL];
    NSLog(@"%@",returnStr);
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
}

@end
