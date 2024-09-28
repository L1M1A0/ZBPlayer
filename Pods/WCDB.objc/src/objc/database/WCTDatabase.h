//
// Created by sanhuazhang on 2019/05/02
//

/*
 * Tencent is pleased to support the open source community by making
 * WCDB available.
 *
 * Copyright (C) 2017 THL A29 Limited, a Tencent company.
 * All rights reserved.
 *
 * Licensed under the BSD 3-Clause License (the "License"); you may not use
 * this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 *       https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "Macro.h"
#import "WCTTag.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class WCTError;

/**
 Triggered when database is closed.
 */
typedef void (^WCTCloseBlock)(void);

/**
 Triggered when operation progresses.
 */
typedef bool /* continue or not */ (^WCTProgressUpdateBlock)(double /* percentage */, double /* increment */);

WCDB_API @interface WCTDatabase : NSObject

/**
 @brief Set/Get the tag of the database. Tag is 0 by default.
 @Note The `WCTError` generated by the database will carry its tag. You can set the same tag for related databases for classification.
 */
@property (atomic, assign) WCTTag tag;

/**
 @brief Get the file path of the database
 */
@property (readonly) NSString *path;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;

/**
 @brief Init a database from path.
 @note  All database objects with same path share the same core. So you can create multiple database objects. WCDB will manage them automatically.
        WCDB will not generate a sqlite db handle until the first operation, which is also called as lazy initialization.
 @param path Path to your database
 @return WCTDatabase
 */
- (instancetype)initWithPath:(NSString *)path NS_DESIGNATED_INITIALIZER;

/**
 @brief Init a in-memory database.
 @Note  Since In-memory database share one DB handle among all threads, it does not support multi-threaded concurrent operation.
 @return WCTDatabase
 */
- (instancetype)initInMemoryDatabase NS_DESIGNATED_INITIALIZER;

/**
 @brief close the database.
        Since Multi-threaded operation is supported in WCDB, other operations in different thread can open the closed database. So this method can make sure database is closed in the "onClosed" block. All other operations will be blocked until this method returns.
        A close operation consists of 4 steps:
            1. blockade, which blocks all other operations.
            2. close, which waits until all sqlite db handles return and closes them.
            3. onClosed, which trigger the callback.
            4. unblokade, which unblocks all other operations.
        You can simply call close: to do all steps above or call these separately.
        Since this method will wait until all sqlite db handles return, it may lead to deadlock in some bad practice. The key to avoid deadlock is to make sure all WCDB objects in current thread is dealloced. In detail:
            1. You should not keep WCDB objects, including `WCTHandle`, `WCTPreparedStatement`, `WCTInsert`, `WCTDelete`, `WCTUpdate`, `WCTSelect`, `WCTMultiSelect`. These objects should not be kept. You should get them, use them, then release them(set to nil) right away.
            2. WCDB objects may not be out of its' scope.
            3. Further more, those WCDB objects may be kept by NSAutoReleasePool, which is done by ARC automatically. So you should make sure that all WCDB objects in NSAutoReleasePool is drained.
            The best practice is to call close: in sub-thread and display a loading animation in main thread.

 @param onClosed Trigger on database closed.
 */
- (void)close:(WCDB_NO_ESCAPE WCTCloseBlock)onClosed;

/**
 @brief Vacuum current database.
 It can be used to vacuum a database of any size with limited memory usage.
 @param onProgressUpdated block.
 @see   `WCTProgressUpdateBlock`.
 @return YES if vacuum succeed.
 */
- (BOOL)vacuum:(nullable WCDB_NO_ESCAPE WCTProgressUpdateBlock)onProgressUpdated;

/**
 @brief The wrapper of `PRAGMA auto_vacuum`
 */
- (void)enableAutoVacuum:(BOOL)incremental;

/**
 @brief The wrapper of `PRAGMA incremental_vacuum`
 */
- (BOOL)incrementalVacuum:(int)pages;

/**
 @brief Get the most recent error for current database in the current thread.
        Since it is too cumbersome to get the error after every database operation, it‘s better to use monitoring interfaces to obtain database errors and print them to the log.
 @see   `[WCTDatabase globalTraceError:]`
 @see   `[WCTDatabase traceError:]`
 
 @return WCTError
 */
- (WCTError *)error;

@end

NS_ASSUME_NONNULL_END
