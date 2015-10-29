//
//  CAudioUnit+UI.m
//  CAudioUnits
//
//  Created by CHARLES GILLINGHAM on 7/11/13.
//  Copyright (c) 2015 CHARLES GILLINGHAM. All rights reserved.
//

#import "CAudioUnit_Internal.h"
#import <AudioUnit/AUCocoaUIView.h>
 

// -----------------------------------------------------------------------------
#pragma mark                CocoaViewInfo
// -----------------------------------------------------------------------------

@interface CocoaViewInfo : NSObject
@property UInt32 numberOfClasses;
@end


@implementation CocoaViewInfo {
    AudioUnitCocoaViewInfo * _viewInfo;
}
@synthesize numberOfClasses;

- (id) initWithAudioUnit: (AudioUnit) au
{
    if (self = [super init]) {
        UInt32  dataSize;
        Boolean isWritable;
        if (AudioUnitGetPropertyInfo(au,
                                     kAudioUnitProperty_CocoaUI,
                                     kAudioUnitScope_Global,
                                     0,
                                     &dataSize,
                                     &isWritable ) != noErr) {
            _viewInfo = nil;
            return nil;
        }
        
        numberOfClasses = (dataSize - sizeof(CFURLRef)) / sizeof(CFStringRef);
        
        _viewInfo = (AudioUnitCocoaViewInfo *)malloc(dataSize);
        if (AudioUnitGetProperty(au,
                                 kAudioUnitProperty_CocoaUI,
                                 kAudioUnitScope_Global,
                                 0,
                                 _viewInfo,
                                 &dataSize) != noErr) {
            free (_viewInfo);
            _viewInfo = nil;
            return nil;
        }
    }
    return self;
}


- (NSURL *) bundleURL
{
    return (__bridge NSURL *)(_viewInfo->mCocoaAUViewBundleLocation);
}


- (NSString *) classsNameForFactoryAtIndex: (UInt32) index
{
    if (index >= numberOfClasses) {
        return nil;
    } else {
        return (__bridge NSString *)(_viewInfo->mCocoaAUViewClass[index]);
    }
}


- (void) dealloc
{
    if (_viewInfo) {
        UInt32 i;
        for (i = 0; i < numberOfClasses; i++)
            CFRelease(_viewInfo->mCocoaAUViewClass[i]);
        free (_viewInfo);
    }
}


@end


/// -----------------------------------------------------------------------------
#pragma mark                CAudioUnit+UI
// -----------------------------------------------------------------------------


@implementation CAudioUnit (UI)

- (NSView *) cocoaView
{
    CocoaViewInfo * cocoaViewInfo = [[CocoaViewInfo alloc] initWithAudioUnit: self.audioUnit];
    if (!cocoaViewInfo) return nil;
    
    NSURL * bundleURL = [cocoaViewInfo bundleURL];
    if (!bundleURL) return nil;
    
    NSBundle *viewBundle = [NSBundle bundleWithPath:[bundleURL path]];
    if (!viewBundle) return nil;
    
    // Only try the first view (at index=0)
    NSString * factoryClassName = [cocoaViewInfo classsNameForFactoryAtIndex: 0];
    if (!factoryClassName) return nil;
    
    Class factoryClass = [viewBundle classNamed:factoryClassName];
    if (!factoryClass ||
        ![factoryClass conformsToProtocol:@protocol(AUCocoaUIBase)] ||
        ![factoryClass instancesRespondToSelector:@selector(interfaceVersion)] ||
        ![factoryClass instancesRespondToSelector:@selector(uiViewForAudioUnit:withSize:)]) {
        return nil;
    }
    
    id factoryInstance = [[factoryClass alloc] init];
    if (!factoryInstance) {
        return nil;
    }
    
    // WHAT SIZE??? I want it to be it's "default size" or it's "normal" size
    NSSize s = {0,0};
    return [factoryInstance uiViewForAudioUnit:self.audioUnit withSize:s];
}


- (NSView *) genericView
{
    AUGenericView * auView = [[AUGenericView alloc] initWithAudioUnit: self.audioUnit];
    [auView setShowsExpertParameters:YES];
    return auView;
}


- (NSViewController *) viewController
{
    NSView * auView = [self cocoaView];
    if (!auView) {
        auView = [self genericView];
    }
    
    NSViewController * vc = [NSViewController new];
    vc.view = auView;
    return vc;
}


@end
