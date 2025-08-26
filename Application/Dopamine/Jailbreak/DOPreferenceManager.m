//
//  PreferenceManager.m
//  Dopamine
//
//  Created by Lars Fröder on 13.01.24.
//

#import "DOPreferenceManager.h"

@implementation DOPreferenceManager

+ (instancetype)sharedManager
{
    static DOPreferenceManager *preferenceManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        preferenceManager = [[DOPreferenceManager alloc] init];
    });
    return preferenceManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _preferencesPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.opa334.Dopamine-roothide.plist"];
        [self loadPreferences];
    }
    return self;
}

- (void)loadPreferences
{
    _preferences = [NSDictionary dictionaryWithContentsOfFile:_preferencesPath].mutableCopy ?: [NSMutableDictionary new];
}

- (void)savePreferences
{
    [_preferences writeToFile:_preferencesPath atomically:YES];
}

- (id)preferenceValueForKey:(NSString *)key
{
    return [_preferences objectForKey:key];
}

- (BOOL)boolPreferenceValueForKey:(NSString *)key fallback:(BOOL)fallback
{
    NSNumber *num = [self preferenceValueForKey:key];
    if (num) {
        return num.boolValue;
    }
    return fallback;
}

- (void)setPreferenceValue:(NSObject *)obj forKey:(NSString *)key
{
    [_preferences setObject:obj forKey:key];
    [self savePreferences];
}

- (void)removePreferenceValueForKey:(NSString *)key
{
    [_preferences removeObjectForKey:key];
    [self savePreferences];
}

- (NSString *)stringPreferenceValueForKey:(NSString *)key fallback:(NSString *)fallback
{
    NSString *value = [self preferenceValueForKey:key];
    if (value && [value isKindOfClass:[NSString class]] && value.length > 0) {
        return value;
    }
    return fallback;
}

- (NSString *)getEffectiveIOSVersionString
{
    BOOL forceVersionEnabled = [self boolPreferenceValueForKey:@"forceVersionEnabled" fallback:NO];
    if (forceVersionEnabled) {
        NSString *customVersion = [self stringPreferenceValueForKey:@"customIOSVersion" fallback:@""];
        if (customVersion.length > 0) {
            return [NSString stringWithFormat:@"Version %@ (Forced)", customVersion];
        }
    }
    
    return NSProcessInfo.processInfo.operatingSystemVersionString;
}

@end
