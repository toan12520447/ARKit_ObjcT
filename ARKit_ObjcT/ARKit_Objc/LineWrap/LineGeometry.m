//
//  LineGeometry.m
//  ARKit_Objc
//
//  Created by Toan Tran on 21/06/2022.
//

#import "LineGeometry.h"
#import <SceneKit/SceneKit.h>
#import "ShaderTypes.h"
#import "MyVertexWrapper.h"

@interface LineGeometry(){
    NSArray<NSValue *> *_vectors;
    NSArray *_sides;
    CGFloat _width;
    NSArray *_lengths;
    CGFloat _endCapPosition;
    
}
@end
@implementation LineGeometry

- (instancetype)initVectors:(NSArray<NSValue*> *)vectors sides:(NSArray *)sides width:(CGFloat)width lengths:(NSArray *)lengths endCapPosition:(CGFloat)endCapPosition{
    NSMutableArray<NSNumber*> *indices = [[NSMutableArray alloc] init];
    for (int i = 0; i<vectors.count; i++) {
        [indices addObject:[NSNumber numberWithInt:i]];
    }
    SCNVector3 vertices[] = {};
    for (NSUInteger i = 0; i< vectors.count; i++) {
        vertices[i] = [vectors[i] SCNVector3Value];
    }
//    NSMutableData *vertexData = [NSMutableData dataWithBytes:vertices length:vectors.count * sizeof(SCNVector3)];
//    SCNGeometrySource *source = [SCNGeometrySource geometrySourceWithData:vertexData
//                                                                         semantic:SCNGeometrySourceSemanticVertex
//                                                                      vectorCount:vectors.count
//                                                                  floatComponents:YES
//                                                              componentsPerVector:3
//                                                                bytesPerComponent:sizeof(float)
//                                                                       dataOffset:0
//                                                                       dataStride:sizeof(SCNVector3)];
    SCNGeometrySource *source = [SCNGeometrySource geometrySourceWithVertices:vertices count:vectors.count];
    
    UInt8 indicesA[] = {};
    for (NSUInteger i = 0; i< indices.count; i++) {
        indicesA[i] = [indices[i] intValue];
    }
    NSData *indexData = [NSData dataWithBytes:indicesA length:indices.count * sizeof(int)];
    
    // Now without runtime error
    SCNGeometryElement *element = [SCNGeometryElement geometryElementWithData:indexData primitiveType:SCNGeometryPrimitiveTypeTriangleStrip primitiveCount:indices.count - 2 bytesPerIndex:sizeof(int)];
    //        self.init()
    self = [LineGeometry geometryWithSources:@[source] elements:@[element]];
    _vectors = vectors;
    _sides = sides;
    _width = width;
    _lengths = lengths;
    _endCapPosition = endCapPosition;
    
    self.wantsAdaptiveSubdivision = true;
    
    
    SCNProgram *lineProgram = [[SCNProgram alloc] init];
    lineProgram.vertexFunctionName = @"basic_vertex";
    lineProgram.fragmentFunctionName = @"basic_fragment";
    self.program = lineProgram;
    [self.program setOpaque:false];
    
    UIImage *endCapImage = [UIImage imageNamed:@"linecap"];
    SCNMaterialProperty *endCapTexture = [SCNMaterialProperty materialPropertyWithContents:endCapImage];
    [self setValue:endCapTexture forKey:@"endCapTexture"];
    
    [self.program handleBindingOfBufferNamed:@"vertices" frequency:SCNBufferFrequencyPerShadable usingBlock:^(id<SCNBufferStream>  _Nonnull buffer, SCNNode * _Nonnull node, id<SCNShadable>  _Nonnull shadable, SCNRenderer * _Nonnull renderer) {
        LineGeometry *line = (LineGeometry *)node.geometry;
        if (line) {
            NSArray *vertextData = [line generateVertexData];
            MyVertex programVertices[] = {};
            for (NSUInteger i = 0; i< vertextData.count; i++) {
                MyVertexWrapper *wrap = vertextData[i];
                programVertices[i] = wrap->node;
            }
            NSUInteger length = sizeof(MyVertex) * vertextData.count;
            [buffer writeBytes:programVertices length:length];
        }
    }];
    return self;
}

- (NSArray *)generateVertexData{
    NSMutableArray *vertexArray = [[NSMutableArray alloc] init];
    MyVertex vertex;
    for (NSUInteger i = 0; i<_vectors.count; i++) {
        vertex.position = vector3([_vectors[i] SCNVector3Value].x, [_vectors[i] SCNVector3Value].y, [_vectors[i] SCNVector3Value].z);
        vertex.vertexCount = (int)_vectors.count;
        vertex.side = [_sides[i] floatValue];
        vertex.width = _width;
        vertex.length = [_lengths[i] floatValue];
        vertex.endCap = _endCapPosition;
        vertex.color = simd_make_float4(1,1,1,1);
        vertex.resolution = simd_make_float2(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
        MyVertexWrapper *nw = [[MyVertexWrapper alloc] initWithNode:vertex];
        [vertexArray addObject:nw];
    }
    return vertexArray;
}



@end
