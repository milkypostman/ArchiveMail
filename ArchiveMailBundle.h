//
//  ArchiveMailBundle.h
//  ArchivePlugin
//
//  Created by Donald Ephraim Curtis on 6/17/10.
//  Copyright 2010 University of Iowa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>


@interface ArchiveMailBundle : NSObject {

}

- (IBAction) archiveSelectedMessages:(id)sender;
+ (BOOL)swizzleMethod:(SEL)origSel withMethod:(SEL)altSel inClass:(Class)cls;
+ (BOOL)copyMethod:(SEL)sel fromClass:(Class)origCls toClass:(Class)altCls;


@end
