#import "PVFVMInspectorJSON.h"

@implementation PVFVMInspectorJSON

+ (id)normalizedPayloadFromResponse:(NSDictionary *)response {
  NSDictionary *result = [response[@"result"] isKindOfClass:NSDictionary.class]
                             ? response[@"result"]
                             : nil;
  if (result == nil) {
    return response;
  }

  id serviceResponse = result[@"response"];
  if (serviceResponse != nil) {
    return [self unwrapInspectorValue:serviceResponse];
  }

  id nestedResult = result[@"result"];
  if (nestedResult != nil) {
    return [self unwrapInspectorValue:nestedResult];
  }
  return response;
}

+ (NSString *)nodeIDFromDictionary:(NSDictionary *)dictionary {
  id valueID = dictionary[@"valueId"];
  if ([valueID isKindOfClass:NSString.class]) {
    return valueID;
  }
  id objectID = dictionary[@"objectId"];
  return [objectID isKindOfClass:NSString.class] ? objectID : nil;
}

+ (NSString *)firstIsolateIDFromVMResponse:(NSDictionary *)response {
  NSDictionary *result = [response[@"result"] isKindOfClass:NSDictionary.class]
                             ? response[@"result"]
                             : nil;
  NSArray *isolates = [result[@"isolates"] isKindOfClass:NSArray.class]
                          ? result[@"isolates"]
                          : nil;
  for (NSDictionary *isolate in isolates) {
    if ([isolate[@"name"] isEqual:@"main"] &&
        [isolate[@"id"] isKindOfClass:NSString.class]) {
      return isolate[@"id"];
    }
  }
  NSDictionary *first = [isolates.firstObject isKindOfClass:NSDictionary.class]
                            ? isolates.firstObject
                            : nil;
  return [first[@"id"] isKindOfClass:NSString.class] ? first[@"id"] : nil;
}

+ (NSNumber *)numberFromValue:(id)value {
  if ([value isKindOfClass:NSNumber.class]) {
    return value;
  }
  if ([value isKindOfClass:NSString.class]) {
    double number = [value doubleValue];
    if (isfinite(number)) {
      return @(number);
    }
  }
  return nil;
}

+ (NSString *)prettyJSONStringForObject:(id)object {
  if (![NSJSONSerialization isValidJSONObject:object]) {
    return [object description];
  }
  NSData *data = [NSJSONSerialization
      dataWithJSONObject:object
                 options:NSJSONWritingPrettyPrinted | NSJSONWritingSortedKeys
                   error:nil];
  NSString *string = [[NSString alloc] initWithData:data
                                           encoding:NSUTF8StringEncoding];
  return string ?: [object description];
}

+ (void)printCompleteJSONString:(NSString *)json {
  NSString *output =
      [NSString stringWithFormat:@"FULL_FLUTTER_INSPECTOR_JSON_BEGIN\n%@\nFULL_"
                                 @"FLUTTER_INSPECTOR_JSON_END\n",
                                 json];
  NSData *data = [output dataUsingEncoding:NSUTF8StringEncoding];
  [[NSFileHandle fileHandleWithStandardOutput] writeData:data];
}

+ (id)unwrapInspectorValue:(id)value {
  if ([value isKindOfClass:NSString.class]) {
    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
    if (data != nil) {
      id decoded = [NSJSONSerialization JSONObjectWithData:data
                                                   options:0
                                                     error:nil];
      if (decoded != nil) {
        return [self unwrapInspectorValue:decoded];
      }
    }
  }

  if ([value isKindOfClass:NSDictionary.class]) {
    id nestedResult = value[@"result"];
    if (nestedResult != nil) {
      return [self unwrapInspectorValue:nestedResult];
    }
  }
  return value;
}

@end
