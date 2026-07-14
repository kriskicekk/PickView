//
//  PVFlutterInspectionModel.m
//  PickViewCore
//

#import "PVFlutterInspectionModel.h"

#define PV_COPY_STRING(coder, key) [[coder decodeObjectForKey:key] copy] ?: @""
#define PV_ENCODE_OBJECT(property) [coder encodeObject:self.property forKey:@ #property]

@implementation PVFlutterNodeReference
+ (BOOL)supportsSecureCoding {
    return YES;
}
- (instancetype)init {
    if (self = [super init]) {
        _recordIdentifier = @"";
        _engineIdentifier = @"";
        _isolateID = @"";
        _objectGroup = @"";
        _objectID = @"";
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)coder {
    PV_ENCODE_OBJECT(recordIdentifier);
    PV_ENCODE_OBJECT(engineIdentifier);
    PV_ENCODE_OBJECT(isolateID);
    PV_ENCODE_OBJECT(objectGroup);
    PV_ENCODE_OBJECT(objectID);
}
- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        _recordIdentifier = PV_COPY_STRING(coder, @"recordIdentifier");
        _engineIdentifier = PV_COPY_STRING(coder, @"engineIdentifier");
        _isolateID = PV_COPY_STRING(coder, @"isolateID");
        _objectGroup = PV_COPY_STRING(coder, @"objectGroup");
        _objectID = PV_COPY_STRING(coder, @"objectID");
    }
    return self;
}
- (id)copyWithZone:(NSZone *)zone {
    PVFlutterNodeReference *value = [[[self class] allocWithZone:zone] init];
    value.recordIdentifier = self.recordIdentifier;
    value.engineIdentifier = self.engineIdentifier;
    value.isolateID = self.isolateID;
    value.objectGroup = self.objectGroup;
    value.objectID = self.objectID;
    return value;
}
@end

@implementation PVFlutterDetailField
+ (BOOL)supportsSecureCoding {
    return YES;
}
- (instancetype)init {
    if (self = [super init]) {
        _identifier = @"";
        _title = @"";
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)coder {
    PV_ENCODE_OBJECT(identifier);
    PV_ENCODE_OBJECT(title);
    [coder encodeInteger:self.valueKind forKey:@"valueKind"];
    PV_ENCODE_OBJECT(textValue);
    PV_ENCODE_OBJECT(numberValue);
    [coder encodeDouble:self.rectValue.origin.x forKey:@"rect.x"];
    [coder encodeDouble:self.rectValue.origin.y forKey:@"rect.y"];
    [coder encodeDouble:self.rectValue.size.width forKey:@"rect.width"];
    [coder encodeDouble:self.rectValue.size.height forKey:@"rect.height"];
    [coder encodeDouble:self.sizeValue.width forKey:@"size.width"];
    [coder encodeDouble:self.sizeValue.height forKey:@"size.height"];
}
- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        _identifier = PV_COPY_STRING(coder, @"identifier");
        _title = PV_COPY_STRING(coder, @"title");
        _valueKind = [coder decodeIntegerForKey:@"valueKind"];
        _textValue = [[coder decodeObjectForKey:@"textValue"] copy];
        _numberValue = [coder decodeObjectForKey:@"numberValue"];
        _rectValue = CGRectMake([coder decodeDoubleForKey:@"rect.x"], [coder decodeDoubleForKey:@"rect.y"],
                                [coder decodeDoubleForKey:@"rect.width"], [coder decodeDoubleForKey:@"rect.height"]);
        _sizeValue = CGSizeMake([coder decodeDoubleForKey:@"size.width"], [coder decodeDoubleForKey:@"size.height"]);
    }
    return self;
}
- (id)copyWithZone:(NSZone *)zone {
    PVFlutterDetailField *value = [[[self class] allocWithZone:zone] init];
    value.identifier = self.identifier;
    value.title = self.title;
    value.valueKind = self.valueKind;
    value.textValue = self.textValue;
    value.numberValue = self.numberValue;
    value.rectValue = self.rectValue;
    value.sizeValue = self.sizeValue;
    return value;
}
@end

@implementation PVFlutterDetailSection
+ (BOOL)supportsSecureCoding {
    return YES;
}
- (instancetype)init {
    if (self = [super init]) {
        _identifier = @"";
        _title = @"";
        _initiallyExpanded = YES;
        _fields = @[];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)coder {
    PV_ENCODE_OBJECT(identifier);
    PV_ENCODE_OBJECT(title);
    [coder encodeBool:self.initiallyExpanded forKey:@"initiallyExpanded"];
    PV_ENCODE_OBJECT(fields);
}
- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        _identifier = PV_COPY_STRING(coder, @"identifier");
        _title = PV_COPY_STRING(coder, @"title");
        _initiallyExpanded = ![coder containsValueForKey:@"initiallyExpanded"] || [coder decodeBoolForKey:@"initiallyExpanded"];
        _fields = [[coder decodeObjectForKey:@"fields"] copy] ?: @[];
    }
    return self;
}
- (id)copyWithZone:(NSZone *)zone {
    PVFlutterDetailSection *value = [[[self class] allocWithZone:zone] init];
    value.identifier = self.identifier;
    value.title = self.title;
    value.initiallyExpanded = self.initiallyExpanded;
    value.fields = [[NSArray alloc] initWithArray:self.fields copyItems:YES];
    return value;
}
@end

@implementation PVFlutterLayoutGroup
+ (BOOL)supportsSecureCoding {
    return YES;
}
- (instancetype)init {
    if (self = [super init]) {
        _objectID = @"";
        _widgetType = @"";
        _renderObjectType = @"";
        _managedNodeIDs = @[];
        _fields = @[];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)coder {
    PV_ENCODE_OBJECT(objectID);
    PV_ENCODE_OBJECT(widgetType);
    PV_ENCODE_OBJECT(renderObjectType);
    PV_ENCODE_OBJECT(managedNodeIDs);
    PV_ENCODE_OBJECT(fields);
    PV_ENCODE_OBJECT(rawJSON);
}
- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        _objectID = PV_COPY_STRING(coder, @"objectID");
        _widgetType = PV_COPY_STRING(coder, @"widgetType");
        _renderObjectType = PV_COPY_STRING(coder, @"renderObjectType");
        _managedNodeIDs = [[coder decodeObjectForKey:@"managedNodeIDs"] copy] ?: @[];
        _fields = [[coder decodeObjectForKey:@"fields"] copy] ?: @[];
        _rawJSON = [[coder decodeObjectForKey:@"rawJSON"] copy];
    }
    return self;
}
- (id)copyWithZone:(NSZone *)zone {
    PVFlutterLayoutGroup *value = [[[self class] allocWithZone:zone] init];
    value.objectID = self.objectID;
    value.widgetType = self.widgetType;
    value.renderObjectType = self.renderObjectType;
    value.managedNodeIDs = self.managedNodeIDs;
    value.fields = [[NSArray alloc] initWithArray:self.fields copyItems:YES];
    value.rawJSON = self.rawJSON;
    return value;
}
@end

@implementation PVFlutterNodeDetail
+ (BOOL)supportsSecureCoding {
    return YES;
}
- (instancetype)init {
    if (self = [super init]) {
        _reference = [PVFlutterNodeReference new];
        _widgetType = @"";
        _elementType = @"";
        _renderObjectType = @"";
        _capabilities = @[];
        _sections = @[];
        _layoutGroups = @[];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)coder {
    PV_ENCODE_OBJECT(reference);
    PV_ENCODE_OBJECT(widgetType);
    PV_ENCODE_OBJECT(elementType);
    PV_ENCODE_OBJECT(renderObjectType);
    PV_ENCODE_OBJECT(capabilities);
    PV_ENCODE_OBJECT(sections);
    PV_ENCODE_OBJECT(layoutGroups);
    PV_ENCODE_OBJECT(rawJSON);
}
- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        _reference = [coder decodeObjectForKey:@"reference"] ?: [PVFlutterNodeReference new];
        _widgetType = PV_COPY_STRING(coder, @"widgetType");
        _elementType = PV_COPY_STRING(coder, @"elementType");
        _renderObjectType = PV_COPY_STRING(coder, @"renderObjectType");
        _capabilities = [[coder decodeObjectForKey:@"capabilities"] copy] ?: @[];
        _sections = [[coder decodeObjectForKey:@"sections"] copy] ?: @[];
        _layoutGroups = [[coder decodeObjectForKey:@"layoutGroups"] copy] ?: @[];
        _rawJSON = [[coder decodeObjectForKey:@"rawJSON"] copy];
    }
    return self;
}
- (id)copyWithZone:(NSZone *)zone {
    PVFlutterNodeDetail *value = [[[self class] allocWithZone:zone] init];
    value.reference = self.reference.copy;
    value.widgetType = self.widgetType;
    value.elementType = self.elementType;
    value.renderObjectType = self.renderObjectType;
    value.capabilities = self.capabilities;
    value.sections = [[NSArray alloc] initWithArray:self.sections copyItems:YES];
    value.layoutGroups = [[NSArray alloc] initWithArray:self.layoutGroups copyItems:YES];
    value.rawJSON = self.rawJSON;
    return value;
}
@end

#undef PV_COPY_STRING
#undef PV_ENCODE_OBJECT
