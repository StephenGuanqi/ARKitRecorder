//
//  ARFrameHandler.m
//  OCARKitTest
//
//  Created by Guanqi Yu on 30/6/17.
//  Copyright © 2017 Guanqi Yu. All rights reserved.
//

#import "ARFrameHandler.h"

@implementation ARFrameHandler


- (NSString*) getDocumentsDirectory
{
    NSArray* path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [path lastObject];
    return documentPath;
}

- (NSString*) getFilePathWith:(NSString*)folderName and:(NSString*)fileName
{
    NSString* documentPath = [self getDocumentsDirectory];
    NSString* filePath = [[[NSURL fileURLWithPath:documentPath] URLByAppendingPathComponent:folderName] path];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ( ![fileManager fileExistsAtPath:filePath] ){
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:NULL error:NULL];
    }
    return [[filePath stringByAppendingString:@"/"] stringByAppendingString:fileName];
}

- (vector_float3) positionFromTransform:(matrix_float4x4)transform
{
    return vector3(transform.columns[3][0], transform.columns[3][1], transform.columns[3][2]);
}

- (NSMutableArray*) arrayFromTransform4:(matrix_float4x4)transform
{
    NSMutableArray * numArrays = [[NSMutableArray alloc] initWithCapacity:4];
    for (int i = 0; i < 4; i++)
    {
        NSMutableArray* numArray = [[NSMutableArray alloc] initWithCapacity:4];
        for (int j = 0; j < 4; j++){
            NSNumber * number = [NSNumber numberWithFloat:transform.columns[j][i]];
            [numArray addObject:number];
        }
        [numArrays addObject:numArray];
    }
    return numArrays;
}

- (NSMutableArray*) arrayFromTransform3:(matrix_float3x3)transform
{
    NSMutableArray * numArrays = [NSMutableArray array];
    for (int i = 0; i < 3; i++)
    {
        NSMutableArray* numArray = [NSMutableArray array];
        for (int j = 0; j < 3; j++){
            NSNumber * number = [NSNumber numberWithFloat:transform.columns[j][i]];
            [numArray addObject:number];
        }
        [numArrays addObject:numArray];
    }
    return numArrays;
}

- (NSMutableDictionary*) dictFromVector3:(vector_float3)vector
{
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:[NSNumber numberWithFloat:vector[0]] forKey:@"x"];
    [dictionary setObject:[NSNumber numberWithFloat:vector[1]] forKey:@"y"];
    [dictionary setObject:[NSNumber numberWithFloat:vector[2]] forKey:@"z"];
    return dictionary;
}

- (NSString*) getCurrentTime
{
    NSDate * now = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH:mm:ss"];
    NSString *newDateString = [outputFormatter stringFromDate:now];
    return newDateString;
}

- (UIImage*) pixelBufferToUIImage:(CVPixelBufferRef) pixelBuffer
{
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext
                             createCGImage:ciImage
                             fromRect:CGRectMake(0, 0,
                                                 CVPixelBufferGetWidth(pixelBuffer),
                                                 CVPixelBufferGetHeight(pixelBuffer))];
    UIImage *uiImage = [UIImage imageWithCGImage:videoImage];
    CGImageRelease(videoImage);
    return uiImage;
}

- (NSMutableDictionary*) currentFrameInfoToDict:(ARFrame*)frame
{
    NSString* currentTime = [[NSNumber numberWithDouble:[frame timestamp]] stringValue];
    NSString* imageName = [currentTime stringByAppendingString:@".jpg"];
    NSMutableDictionary* jsonObject = [[NSMutableDictionary alloc] init];
    [jsonObject setObject:imageName forKey:@"imageName"];
    [jsonObject setObject:currentTime forKey:@"timeStamp"];
    [jsonObject setObject:[self dictFromVector3:[self positionFromTransform:frame.camera.transform]] forKey:@"cameraPos"];
    [jsonObject setObject:[self dictFromVector3:frame.camera.eulerAngles] forKey:@"cameraEulerAngle"];
    [jsonObject setObject:[self arrayFromTransform4:frame.camera.transform] forKey:@"cameraTransform"];
    [jsonObject setObject:[self arrayFromTransform3:frame.camera.intrinsics] forKey:@"cameraIntrinsics"];
    NSMutableDictionary* imageResolution = [[NSMutableDictionary alloc] init];
    [imageResolution setObject:[NSNumber numberWithFloat:frame.camera.imageResolution.height] forKey:@"height"];
    [imageResolution setObject:[NSNumber numberWithFloat:frame.camera.imageResolution.width] forKey:@"width"];
    [jsonObject setObject:imageResolution forKey:@"imageResolution"];
    [jsonObject setObject:[NSNumber numberWithFloat:frame.lightEstimate.ambientIntensity] forKey:@"lightEstimate"];
    
    return jsonObject;
}

- (void) parse:(ARFrame*)frame toJsonObject:(NSMutableDictionary*)jsonObject andSaveInto:(NSString*)folderName
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSMutableDictionary* jsonNode = [self currentFrameInfoToDict:frame];
        [jsonObject setObject:jsonNode forKey:jsonNode[@"imageName"]];
        NSData* image = UIImageJPEGRepresentation([self pixelBufferToUIImage:frame.capturedImage], 1.0);
        [image writeToFile:[self getFilePathWith:folderName and:jsonNode[@"imageName"]] atomically:NO];
    });
}

- (void) saveAndClear:(NSMutableDictionary*)jsonObject toDir:(NSString*) folderName
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:NULL];
        NSString* jsonPath = [self getFilePathWith:folderName and:[[self getCurrentTime] stringByAppendingString:@".json"]];
        NSLog(@"path to be saved %@", jsonPath);
        [jsonData writeToFile:jsonPath atomically:NO];
        [jsonObject removeAllObjects];
    });
}

@end


