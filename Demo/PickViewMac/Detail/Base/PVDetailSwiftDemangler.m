#import "PVDetailPrefix.h"
#import "PVDetailSwiftDemangler.h"

#import <dlfcn.h>

typedef char *(*PVSwiftDemangleFunction)(const char *, size_t, char *, size_t *, uint32_t);

@implementation PVDetailSwiftDemangler

+ (NSString *)completedParseWithInput:(NSString *)input {
    return [self demangledStringFromInput:input];
}

+ (NSString *)simpleParseWithInput:(NSString *)input {
    NSString *demangled = [self demangledStringFromInput:input];
    NSRange parameterRange = [demangled rangeOfString:@"(" options:NSBackwardsSearch];
    if (parameterRange.location != NSNotFound && [demangled hasSuffix:@")"]) {
        return [demangled substringToIndex:parameterRange.location];
    }
    return demangled;
}

+ (NSString *)demangledStringFromInput:(NSString *)input {
    if (!input.length) {
        return input ?: @"";
    }

    BOOL looksLikeMangledSwiftName = [input hasPrefix:@"_T"] ||
                                     [input hasPrefix:@"$s"] ||
                                     [input hasPrefix:@"$S"] ||
                                     [input hasPrefix:@"_$s"] ||
                                     [input hasPrefix:@"_$S"];
    if (!looksLikeMangledSwiftName) {
        return input;
    }

    static NSMutableDictionary<NSString *, NSString *> *cache;
    static PVSwiftDemangleFunction demangleFunction = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [NSMutableDictionary dictionary];
        demangleFunction = (PVSwiftDemangleFunction)dlsym(RTLD_DEFAULT, "swift_demangle");
    });
    @synchronized (cache) {
        NSString *cachedValue = cache[input];
        if (cachedValue) return cachedValue;
    }

    NSString *demangled = nil;
    if (demangleFunction) {
        const char *mangledName = input.UTF8String;
        char *result = demangleFunction(mangledName, strlen(mangledName), NULL, NULL, 0);
        if (result) {
            demangled = [NSString stringWithUTF8String:result];
            free(result);
        }
    }

    if (!demangled.length) {
        NSTask *task = [[NSTask alloc] init];
        task.launchPath = @"/usr/bin/xcrun";
        task.arguments = @[@"swift-demangle", input];
        NSPipe *pipe = [NSPipe pipe];
        task.standardOutput = pipe;
        task.standardError = [NSPipe pipe];
        @try {
            [task launch];
            [task waitUntilExit];
            NSData *data = [pipe.fileHandleForReading readDataToEndOfFile];
            NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            demangled = [output stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
            NSRange separatorRange = [demangled rangeOfString:@" ---> " options:NSBackwardsSearch];
            if (separatorRange.location != NSNotFound) {
                demangled = [demangled substringFromIndex:NSMaxRange(separatorRange)];
            }
        } @catch (__unused NSException *exception) {
        }
    }

    demangled = demangled.length ? demangled : input;
    @synchronized (cache) {
        cache[input] = demangled;
    }
    return demangled;
}

@end
