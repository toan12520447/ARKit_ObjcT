//
//  LineGeometry.m
//  ARKit_Objc
//
//  Created by Toan Tran on 21/06/2022.
//

#import "LineGeometry.h"
#import <SceneKit/SceneKit.h>
#import "ShaderTypes.h"
#include <vector>
@interface LineGeometry(){
    std::vector<SCNVector3>_vectors;
    NSArray *_sides;
    CGFloat _width;
    NSArray *_lengths;
    CGFloat _endCapPosition;
}
@end
@implementation LineGeometry

- (SCNGeometry*) lineByVector:(std::vector<SCNVector3>)vector
                        sides:(NSMutableArray*)side
                        width:(CGFloat)wid
                      lengths:(NSMutableArray*)length
               endCapPosition:(CGFloat)position {
    int indicies[vector.size()];
    SCNVector3 vecs[vector.size()];
    for (size_t i = 0; i < vector.size(); i++) {
        indicies[i] = int(i);
        vecs[i] = vector[i];
    }
    SCNGeometrySource* vertexSource = [SCNGeometrySource geometrySourceWithVertices:vecs count:vector.size()];
    NSData *indexData = [NSData dataWithBytes:indicies length:sizeof(indicies)];
    SCNGeometryElement *element = [SCNGeometryElement geometryElementWithData:indexData
                                                                primitiveType:SCNGeometryPrimitiveTypeTriangleStrip
                                                               primitiveCount:vector.size() - 2
                                                                bytesPerIndex:sizeof(int)];
    SCNGeometry* geo = [SCNGeometry geometryWithSources:@[vertexSource] elements:@[element]];
    _vectors = vector;
    _sides = side;
    _width = wid;
    _lengths = length;
    _endCapPosition = position;
    [geo setWantsAdaptiveSubdivision:YES];
    SCNProgram* line = [[SCNProgram alloc] init];
    [line setVertexFunctionName:@"basic_vertex"];
    [line setFragmentFunctionName:@"basic_fragment"];
    [geo setProgram:line];
    [geo.program setOpaque:NO];
    UIImage* endCapImage = [UIImage imageNamed:@"linecap"];
    SCNMaterialProperty* property = [SCNMaterialProperty materialPropertyWithContents:endCapImage];
    [geo setValue:property forKey:@"endCapTexture"];
    [geo.program handleBindingOfBufferNamed:@"vertices" frequency:SCNBufferFrequencyPerShadable usingBlock:^(id<SCNBufferStream> _Nonnull buffer, SCNNode * _Nonnull node, id<SCNShadable> _Nonnull shadable, SCNRenderer * _Nonnull renderer) {
        LineGeometry *line = (LineGeometry *)node.geometry;
        std::vector<MyVertex> programVertices = [line generateVertexData];
        [buffer writeBytes:&programVertices length:sizeof(MyVertex)*programVertices.size()];
    }];
    return geo;
}

- (std::vector<MyVertex>)generateVertexData{
    std::vector<MyVertex> vertexArray;
    MyVertex vertex;
    for (NSUInteger i = 0; i<_vectors.size(); i++) {
//        vertex.position = vector3([_vectors[i] SCNVector3Value].x, [_vectors[i] SCNVector3Value].y, [_vectors[i] SCNVector3Value].z);
        vertex.vertexCount = (int)_vectors.size();
        vertex.side = [_sides[i] floatValue];
        vertex.width = _width;
        vertex.length = [_lengths[i] floatValue];
        vertex.endCap = _endCapPosition;
        vertex.color = simd_make_float4(1,1,1,1);
        vertex.resolution = simd_make_float2(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
        vertexArray.push_back(vertex);
    }
    return vertexArray;
}



@end
