//
//  MyVertexWrapper.h
//  ARKit_Objc
//
//  Created by Toan Tran on 21/06/2022.
//

#import <Foundation/Foundation.h>
#import "ShaderTypes.h"
NS_ASSUME_NONNULL_BEGIN

@interface MyVertexWrapper : NSObject{
@public

   MyVertex node;
}
- (id) initWithNode:(MyVertex )n;
@end

NS_ASSUME_NONNULL_END
