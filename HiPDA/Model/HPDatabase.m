//
//  HPDatabase.m
//  HiPDA
//
//  Created by wujichao on 14-2-23.
//  Copyright (c) 2014年 wujichao. All rights reserved.
//

@interface User : NSObject

@property (nonatomic, strong)NSString *username;
@property (nonatomic, assign)NSInteger uid;
@property (nonatomic, strong)NSDate *last;

@end

@implementation User

@end

#import "HPDatabase.h"

#import "HPHttpClient.h"
#import "NSString+Additions.h"



#define START 759083
#define END 759083

@interface HPDatabase ()

@property (nonatomic, assign) NSInteger current;
@property (nonatomic, strong) NSTimer *countTimer;

@end

@implementation HPDatabase

+ (HPDatabase *)sharedDb {
    static HPDatabase *_sharedDb = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSLog(@"init db");
        
        _sharedDb = [[HPDatabase alloc] init];
        
        NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *dbPath = [docsPath stringByAppendingPathComponent:@"uid.db"];
        _sharedDb.db = [FMDatabase databaseWithPath:dbPath];
    });
    
    return _sharedDb;
}

- (void)open {
    if (![_db open]) {
        NSLog(@"##### db not open ######");
    }
}

- (void)close {
    [_db close];
}

+ (BOOL)prepareDb {
    
    NSLog(@"prepareDb");
    
    BOOL isExist = NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"uid.db"];
    
    isExist = [fileManager fileExistsAtPath:dbPath];
    
    if (!isExist) {
        NSString *defaultDbPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"uid.sqlite"];
        isExist = [fileManager copyItemAtPath:defaultDbPath toPath:dbPath error:&error];
        
        if (!isExist) {
            //NSAssert1(0, @"file to copy db %@", [error localizedDescription]);
            NSLog(@"%@",[error localizedDescription]);
        }
    }
    
    NSLog(@"prepareDb %d", isExist);
    return isExist;
}

/*######################################*/

- (void)setup {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"user.db"];
    
    NSLog(@"%@", path);
    
    _db = [FMDatabase databaseWithPath:path];
    
    if (![_db open]) {
        NSLog(@"!open");
    }
    
    [_db setShouldCacheStatements:YES];
    
    if(0) {
        [_db executeUpdate:@"create table user (username text PRIMARY KEY, uid integer, last)"];
    }
    
    
    
    [self printErrorMsg];
}


- (void)printErrorMsg {
    
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
    
}

- (void)insertUser:(User *)user {
    
    [_db executeUpdate:@"insert into user (username, uid, last) values (?, ?, ?)" ,
     user.username, [NSNumber numberWithInteger:user.uid], user.last];
    
}

- (void)search:(NSString *)username {
    
    NSLog(@"%@, %d", username, [_db intForQuery:@"SELECT uid FROM user WHERE username = ?",username]);
    
}

- (void)test {
    
    [self setup];
    
    /*
    User *u1 = [User new]; u1.username = @"u1"; u1.uid = 121212; u1.last = [NSDate date];
    [self insertUser:u1];
    
    User *u2 = [User new]; u2.username = @"u2"; u2.uid = 2121212; u2.last = [NSDate date];
    [self insertUser:u2];
    
    [self search:@"ww"];
    [self search:@"u1"];
    [self search:@"u2"];
     */
    
    
    
    /*
    FMResultSet *s = [_db executeQuery:@"SELECT * FROM user ORDER BY last"];
    
    //while ([s next]) {
    for (int i = 0; i < 100 && [s next]; i++) {
    
        NSString *username = [s stringForColumnIndex:0];
        NSUInteger uid = [s intForColumnIndex:1];
        NSDate *last = [s dateForColumnIndex:2];
        
        if (last == nil) {
            
        }
        
        
        
        NSLog(@"%@ %ld %@", username, uid, last);
    }
    
    
    */
    
    
    // 1338480000 2012/06/01  count 87792
    /*
    NSLog(@"%f", [HPCommon timeIntervalSince1970WithString:@"2014/02/13"]);

    FMResultSet *s2 = [_db executeQuery:@"SELECT  COUNT(*) FROM user WHERE last>1392220800"];
    if ([s2 next]) {
        int totalCount = [s2 intForColumnIndex:0];
       
        NSLog(@"count %ld", totalCount);
    }
    */
    
    
     /*
    FMResultSet *s3 = [_db executeQuery:@"SELECT * FROM user WHERE last>1325347200 ORDER BY last"];
    for (int i = 0; i < 100 && [s3 next]; i++) {
        
        NSString *username = [s3 stringForColumnIndex:0];
        NSUInteger uid = [s3 intForColumnIndex:1];
        NSDate *last = [s3 dateForColumnIndex:2];
        
        NSLog(@"%@ %ld %@", username, uid, last);
    }
    */
    
    [self genDb];
    
    /*
    _countTimer = [NSTimer scheduledTimerWithTimeInterval: 1 target: self selector: @selector(run) userInfo: nil repeats: YES];
    [_countTimer fire];
    */
    //[self close];
}


- (void)genDb {
    
    
    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath   = [docsPath stringByAppendingPathComponent:@"uid.db"];
    FMDatabase *db_out     = [FMDatabase databaseWithPath:dbPath];
    if (![db_out open]) {
        NSLog(@"!open");
    }
    
    [db_out executeUpdate:@"create table user (username text PRIMARY KEY, uid integer)"];
    
    
    //FMResultSet *s2 = [_db executeQuery:@"SELECT * FROM user WHERE last>1338480000 ORDER BY last DESC"];
    FMResultSet *s2 = [_db executeQuery:@"SELECT * FROM user ORDER BY last"];
    
    while ([s2 next]) {
        
        
        NSString *username = [s2 stringForColumnIndex:0];
        NSInteger uid = [s2 intForColumnIndex:1];
        NSDate *last = [s2 dateForColumnIndex:2];
        
        
        //NSLog(@"%@ %ld %@", username, uid, last);
        
        if (!last) {
            NSLog(@"%@ %ld %@", username, uid, last);
            [db_out executeUpdate:@"insert into user (username, uid) values (?, ?)" ,
             username, [NSNumber numberWithInteger:uid]];
        }
        /*
        [db_out executeUpdate:@"insert into user (username, uid) values (?, ?)" ,
         username, [NSNumber numberWithInt:uid]];
        */
    }
    
    [db_out close];
    
}

- (void)run {
    
    NSLog(@"run %ld", _current);
    
    if (! _current ) _current = START;
    
    for (NSInteger i = _current; i < _current + 50; i++) {
        [self getUserWithUid:i];
    }
    
    _current += 50;
    
    if (_current >= END/*709961*/) {
        [_countTimer invalidate];
    }
    
}

- (void)start {
    _countTimer = [NSTimer scheduledTimerWithTimeInterval: 1 target: self selector: @selector(run) userInfo: nil repeats: YES];
    [_countTimer fire];
}

- (void)stop {
    [_countTimer invalidate];
    //[self close];
}


- (void)getUserWithUid:(NSInteger)uid {
    
    //NSLog(@"find uid %ld", uid);
    
    [HPDatabase loadProfilePageWithUid:uid block:^(NSString *html, NSError *error) {
        
        
        if (error) {
            
            if (error.code == -1011) {
                ;
            } else {
                NSLog(@"uid %ld, error %@", uid, [error localizedDescription]);
            }
            
        } else {
            
            User *user = [User new];
            
            NSString *username = [html stringBetweenString:@"<h1>" andString:@" <img src=\"images/default/online_buddy"];
            if (!username) {
                username = [html stringBetweenString:@"<h1>" andString:@"</h1>"];
            }
            
            NSString *lastString = [html stringBetweenString:@"上次访问: " andString:@"</li>"];
            
            static NSDateFormatter *df;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                df = [[NSDateFormatter alloc] init];
                [df setDateFormat:@"yyyy-M-dd HH:mm"];
            });

            
            NSDate *last = nil;
            
            if ( username ) {
                
                user.username = username;
                user.uid = uid;
                
                if (lastString) {
                    
                    last = [df dateFromString:lastString];
                    user.last = last;
                    
                }
                
                [self insertUser:user];
                
                if (uid >= END) {
                    [self close];
                }
                
                NSLog(@"get uid %ld %@ %@", uid, username, last);
                
            } else {
                NSLog(@"get uid %ld ERROR", uid);
            }
        }
    }];
}



+ (void)loadProfilePageWithUid:(NSInteger)uid
                           block:(void (^)(NSString *html, NSError *error))block
{
    NSString *urlString = [NSString stringWithFormat:@"forum/space.php?uid=%ld", uid];
    
    //
    [[HPHttpClient sharedClient] getPathContent:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, NSString *html) {
        
        //NSLog(@"post html %@", html);

        if (!html && block) {
            NSDictionary *details = [NSDictionary dictionaryWithObject:@"html decode error" forKey:NSLocalizedDescriptionKey];
            block(@"", [NSError errorWithDomain:@"world" code:200 userInfo:details]);
            return;
        }
        
        if (block)
            block(html, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(@"", error);
        }
    }];
}

@end
