//
//  Category.h
//  iTBK
//
//  Created by skye on 9/28/12.
//
//

#import <Foundation/Foundation.h>

@interface Category : NSObject <NSCoding>
{
    // 类目id
    NSNumber                   *_cid;
    // 类目名称
    NSString                   *_name;
    // 类目图片id, 完整URL, host/media/uuid/icon.png 
    NSString                   *_uuid;
    // 子类目列表
    NSArray                    *_subCategory;     
}

@property (nonatomic, retain) NSNumber *cid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, retain) NSArray *subCategory;

@end
