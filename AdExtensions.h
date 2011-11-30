//
//  AdExtensions.h
//  securesubmission
//
//  Created by Paul Kehrer on 8/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


@interface NSString (AdExtensions)
- (NSString *) md5;
+ (NSString *) URLEncodeString:(NSString*)string;
- (NSString *) URLEncodeString;
@end

@interface NSData (AdExtensions)
- (NSData*)dataByHmacSHA256EncryptingWithKey:(NSData*)key;
- (NSString*)stringWithHexBytes;
+ (NSData*)dataWithRandomBytes:(int)length;
@end


//from https://github.com/gekitz/UIDevice-with-UniqueIdentifier-for-iOS-5
@interface UIDevice (AdExtensions)

/*
 * @method uniqueDeviceIdentifier
 * @description use this method when you need a unique identifier in one app.
 * It generates a hash from the MAC-address in combination with the bundle identifier
 * of your app.
 */

- (NSString *) uniqueDeviceIdentifier;

/*
 * @method uniqueGlobalDeviceIdentifier
 * @description use this method when you need a unique global identifier to track a device
 * with multiple apps. as example a advertising network will use this method to track the device
 * from different apps.
 * It generates a hash from the MAC-address only.
 */

- (NSString *) uniqueGlobalDeviceIdentifier;

@end
