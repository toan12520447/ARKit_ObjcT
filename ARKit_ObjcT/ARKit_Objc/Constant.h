//
//  Constant.h
//  ARKit_Objc
//
//  Created by Toan Tran on 20/06/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
static NSString *resourceFolder = @"art.scnassets";
typedef NS_ENUM(NSInteger, LINE_WIDTH){
    LINE_WIDTH_Large,
    LINE_WIDTH_Medium,
    LINE_WIDTH_Small,
};
typedef NS_ENUM(NSInteger, ViewMode){ 
    DRAWING,
    OBJECT
};
@interface Constant : NSObject

float LINE_WIDTH_float(LINE_WIDTH width);

@end

NS_ASSUME_NONNULL_END
