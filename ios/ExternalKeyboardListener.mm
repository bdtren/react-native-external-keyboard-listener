#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(ExternalKeyboardListener, NSObject)
RCT_EXTERN_METHOD(startListening)
RCT_EXTERN_METHOD(stopListening)
RCT_EXTERN_METHOD(checkKeyboardConnection
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(isBluetoothEnabled
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(enableBluetooth
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup {
  return NO;
}

@end
