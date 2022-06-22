//
//  MyVertexWrapper.m
//  ARKit_Objc
//
//  Created by Toan Tran on 21/06/2022.
//

#import "MyVertexWrapper.h"

@implementation MyVertexWrapper
- (id) initWithNode:(MyVertex)n{
  self = [super init];
  if(self) {
     node = n;
  }
  return self;
}

- (void) dealloc {
    
}
@end
