//
//  ARFrameHandler.h
//  OCARKitTest
//
//  Created by Guanqi Yu on 30/6/17.
//  Copyright © 2017 Guanqi Yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>


@interface ARFrameHandler : NSObject
- (NSMutableDictionary*) currentFrameInfoToDict:(ARFrame*)frame;
- (void) parse:(ARFrame*)frame toJsonObject:(NSMutableDictionary*)jsonObject andSaveInto:(NSString*)folderName;
- (void) saveAndClear:(NSMutableDictionary*)jsonObject toDir:(NSString*) folderName;
- (NSString*) getCurrentTime;
@end
