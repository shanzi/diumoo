//
//  SMTabBar.h
//  InspectorTabBar
//
//  Created by Stephan Michels on 30.01.12.
//  Copyright (c) 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SMBar.h"


@class SMTabBarItem;
@protocol SMTabBarDelegate;

@interface SMTabBar : SMBar

@property (nonatomic,strong) NSArray *items;
@property (nonatomic,strong) SMTabBarItem *selectedItem;
@property (nonatomic, unsafe_unretained) IBOutlet id<SMTabBarDelegate> delegate;

@end


@protocol SMTabBarDelegate <NSObject>

@optional
- (void)tabBar:(SMTabBar *)tabBar willSelectItem:(SMTabBarItem *)item;
- (void)tabBar:(SMTabBar *)tabBar didSelectItem:(SMTabBarItem *)item;

@end