//
//  Category.m
//  iTBK
//
//  Created by skye on 9/28/12.
//
//

#import "Category.h"

@implementation Category

@synthesize cid             = _cid;
@synthesize name            = _name;
@synthesize uuid            = _uuid;
@synthesize subCategory     = _subCategory;

#pragma mark - NSCoding

- (id)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self){
        self.cid         = [coder decodeObjectForKey:@"cid"];
        self.name        = [coder decodeObjectForKey:@"name"];
        self.uuid        = [coder decodeObjectForKey:@"uuid"];
        self.subCategory = [coder decodeObjectForKey:@"subCategory"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.cid forKey:@"cid"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.uuid forKey:@"uuid"];
    [coder encodeObject:self.subCategory forKey:@"subCategory"];
}

@end
