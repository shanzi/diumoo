//
//  DMSearchItemView.h
//  diumoo
//
//  Created by Shanzi on 12-10-21.
//
//

#import <Cocoa/Cocoa.h>

@interface DMSearchCollectionView : NSCollectionView
@property(nonatomic,unsafe_unretained) id target;
-(NSManagedObject*) selectedItem;
@end

@interface DMSearchCollectionViewItem : NSCollectionViewItem

@end


@interface DMSearchItemView : NSView
@property(readwrite) BOOL selected;
@end
