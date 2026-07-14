//
//  PVDetailFlutterViewController.m
//  PickViewMac
//

#import "PVDetailPrefix.h"
#import "PVDetailFlutterViewController.h"

#import "PVDisplayItem.h"
#import "PVFlutterInspectionModel.h"
#import "PVDetailDashboardCardTitleControl.h"
#import "PVDetailNumberInputView.h"
#import "PVDetailTextFieldView.h"

const CGFloat PVFlutterInspectorPanelWidth = 260.0;

static CGFloat const PVFlutterPanelInset = 10.0;
static CGFloat const PVFlutterSectionSpacing = 10.0;
static CGFloat const PVFlutterFieldSpacing = 9.0;

typedef NS_ENUM(NSUInteger, PVFlutterInspectorDomain) {
    PVFlutterInspectorDomainWidget = 0,
    PVFlutterInspectorDomainRenderObject,
    PVFlutterInspectorDomainDebug,
};

typedef NS_ENUM(NSUInteger, PVFlutterInspectorFieldStyle) {
    PVFlutterInspectorFieldStyleText = 0,
    PVFlutterInspectorFieldStyleTextArea,
    PVFlutterInspectorFieldStyleNumber,
    PVFlutterInspectorFieldStyleBoolean,
    PVFlutterInspectorFieldStyleColor,
    PVFlutterInspectorFieldStyleRect,
    PVFlutterInspectorFieldStyleSize,
    PVFlutterInspectorFieldStyleJSON,
    PVFlutterInspectorFieldStyleInfo,
};

@interface PVFlutterInspectorFieldModel : NSObject
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *value;
@property(nonatomic, copy) NSString *secondaryText;
@property(nonatomic) PVFlutterInspectorFieldStyle style;
@property(nonatomic) BOOL booleanValue;
@property(nonatomic) CGRect rectValue;
@property(nonatomic) CGSize sizeValue;
@property(nonatomic, strong, nullable) NSColor *colorValue;
@end

@implementation PVFlutterInspectorFieldModel
@end

@interface PVFlutterInspectorSectionModel : NSObject
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *subtitle;
@property(nonatomic, strong) NSColor *accentColor;
@property(nonatomic) BOOL initiallyExpanded;
@property(nonatomic, copy) NSArray<PVFlutterInspectorFieldModel *> *fields;
@end

@implementation PVFlutterInspectorSectionModel
- (instancetype)init {
    if (self = [super init]) {
        _initiallyExpanded = YES;
        _fields = @[];
        _accentColor = NSColor.systemBlueColor;
    }
    return self;
}
@end

@interface PVFlutterInspectorPresentation : NSObject
@property(nonatomic, copy) NSString *widgetType;
@property(nonatomic, copy) NSString *elementType;
@property(nonatomic, copy) NSString *renderObjectType;
@property(nonatomic, copy) NSString *nodeKind;
@property(nonatomic, copy) NSArray<NSString *> *capabilities;
@property(nonatomic, copy) NSDictionary<NSNumber *, NSArray<PVFlutterInspectorSectionModel *> *> *sectionsByDomain;
@end

@implementation PVFlutterInspectorPresentation
@end

@interface PVFlutterInspectorPresentationCacheEntry : NSObject
@property(nonatomic, copy) NSString *signature;
@property(nonatomic, strong) PVFlutterInspectorPresentation *presentation;
@end

@implementation PVFlutterInspectorPresentationCacheEntry
@end

@interface PVFlutterInspectorPresentationBuilder : NSObject
+ (PVFlutterInspectorPresentation *)presentationForItem:(PVDisplayItem *)item
                                                  detail:(PVFlutterNodeDetail *)detail;
+ (PVFlutterInspectorFieldModel *)infoField:(NSString *)title value:(NSString *)value;
@end

@implementation PVFlutterInspectorPresentationBuilder

+ (PVFlutterInspectorPresentation *)presentationForItem:(PVDisplayItem *)item
                                                  detail:(PVFlutterNodeDetail *)detail {
    PVFlutterInspectorPresentation *presentation = [PVFlutterInspectorPresentation new];
    presentation.widgetType = detail.widgetType.length ? detail.widgetType : item.displayName;
    presentation.elementType = detail.elementType.length ? detail.elementType : item.viewClassName;
    presentation.renderObjectType = detail.renderObjectType.length ? detail.renderObjectType : item.layerClassName;
    presentation.nodeKind = [self nodeKindFromDetail:detail widgetType:presentation.widgetType];

    NSMutableOrderedSet<NSString *> *capabilities = [NSMutableOrderedSet orderedSet];
    if (presentation.nodeKind.length) [capabilities addObject:presentation.nodeKind];
    [capabilities addObjectsFromArray:detail.capabilities ?: @[]];
    presentation.capabilities = capabilities.array;

    NSMutableArray<PVFlutterInspectorSectionModel *> *widgetSections = [NSMutableArray array];
    NSMutableArray<PVFlutterInspectorSectionModel *> *renderSections = [NSMutableArray array];
    NSMutableArray<PVFlutterInspectorSectionModel *> *debugSections = [NSMutableArray array];

    PVFlutterDetailSection *diagnostics = [self sectionWithIdentifier:@"diagnostics" detail:detail];
    NSArray *diagnosticObjects = [self JSONObjectsFromFields:diagnostics.fields];
    NSArray *widgetProperties = [self diagnosticFieldsFromObjects:diagnosticObjects technical:NO];
    if (widgetProperties.count) {
        NSString *title = [self propertySectionTitleForKind:presentation.nodeKind
                                                widgetType:presentation.widgetType];
        [widgetSections addObject:[self section:title
                                         subtitle:@"Widget configuration from DiagnosticsNode"
                                           accent:[self widgetAccent]
                                           fields:widgetProperties]];
    }

    [self appendRelationSection:@"layoutModifiers"
                          title:@"Layout modifiers"
                         accent:[self layoutAccent]
                         detail:detail
                             to:widgetSections];
    [self appendRelationSection:@"interactions"
                          title:@"Interaction"
                         accent:[self interactionAccent]
                         detail:detail
                             to:widgetSections];
    [self appendRelationSection:@"semantics"
                          title:@"Semantics"
                         accent:[self semanticsAccent]
                         detail:detail
                             to:widgetSections];

    for (PVFlutterLayoutGroup *group in detail.layoutGroups ?: @[]) {
        NSMutableArray<PVFlutterInspectorFieldModel *> *fields = [NSMutableArray array];
        [fields addObject:[self textField:@"RenderObject"
                                    value:group.renderObjectType
                                secondary:@""]];
        [fields addObject:[self numberField:@"Managed children"
                                      value:[NSString stringWithFormat:@"%@", @(group.managedNodeIDs.count)]
                                  secondary:@""]];
        for (PVFlutterDetailField *field in group.fields) {
            NSDictionary *relation = [self JSONObjectFromString:field.textValue];
            NSArray *properties = [relation[@"properties"] isKindOfClass:NSArray.class]
                ? relation[@"properties"] : @[];
            [fields addObjectsFromArray:[self diagnosticFieldsFromObjects:properties technical:NO]];
        }
        NSString *title = [NSString stringWithFormat:@"Children layout: %@",
                           group.widgetType.length ? group.widgetType : @"Unknown"];
        NSString *subtitle = group.renderObjectType.length ? group.renderObjectType : @"Child layout policy";
        [widgetSections addObject:[self section:title
                                         subtitle:subtitle
                                           accent:[self layoutAccent]
                                           fields:fields]];
    }

    NSMutableArray<PVFlutterInspectorFieldModel *> *boxFields = [NSMutableArray array];
    PVFlutterInspectorFieldModel *frame = [PVFlutterInspectorFieldModel new];
    frame.title = @"Frame in parent";
    frame.style = PVFlutterInspectorFieldStyleRect;
    frame.rectValue = item.frame;
    [boxFields addObject:frame];
    PVFlutterInspectorFieldModel *size = [PVFlutterInspectorFieldModel new];
    size.title = @"Size";
    size.style = PVFlutterInspectorFieldStyleSize;
    size.sizeValue = item.bounds.size;
    [boxFields addObject:size];
    [boxFields addObject:[self numberField:@"Visual children"
                                    value:[NSString stringWithFormat:@"%@", @(item.subitems.count)]
                                secondary:@""]];
    [renderSections addObject:[self section:@"Box model"
                                    subtitle:@"Parent-relative geometry in logical pixels"
                                      accent:[self renderAccent]
                                      fields:boxFields]];

    PVFlutterDetailSection *rendering = [self sectionWithIdentifier:@"rendering" detail:detail];
    NSMutableArray *renderFields = [NSMutableArray array];
    for (PVFlutterDetailField *field in rendering.fields ?: @[]) {
        [renderFields addObject:[self presentationFieldFromDetailField:field]];
    }
    if (renderFields.count) {
        [renderSections addObject:[self section:@"Paint pipeline"
                                        subtitle:@"How this RenderObject contributes pixels"
                                          accent:[self paintAccent]
                                          fields:renderFields]];
    }

    PVFlutterDetailSection *decoration = [self sectionWithIdentifier:@"decoration" detail:detail];
    NSMutableArray *decorationFields = [NSMutableArray array];
    for (NSDictionary *value in [self JSONObjectsFromFields:decoration.fields]) {
        [decorationFields addObjectsFromArray:[self decorationFieldsFromDictionary:value]];
    }
    if (decorationFields.count) {
        [renderSections addObject:[self section:@"Decoration"
                                        subtitle:@"Flutter box paint translated from diagnostics"
                                          accent:[self paintAccent]
                                          fields:decorationFields]];
    }

    NSMutableArray *displayFields = [NSMutableArray array];
    if (item.backgroundColorText.length) {
        NSColor *backgroundColor = [self colorFromDescription:item.backgroundColorText];
        [displayFields addObject:[self colorField:@"Background"
                                            color:backgroundColor
                                             text:item.backgroundColorText]];
    }
    [displayFields addObject:[self numberField:@"Opacity"
                                        value:[NSString stringWithFormat:@"%.3g", item.alpha]
                                    secondary:@""]];
    [displayFields addObject:[self booleanField:@"Visible" value:!item.hidden]];
    [displayFields addObject:[self booleanField:@"Screenshot eligible" value:item.shouldCaptureImage]];
    NSString *screenshotValue = item.soloScreenshot || item.groupScreenshot ? @"Available" : @"Not captured";
    [displayFields addObject:[self textField:@"Screenshot" value:screenshotValue secondary:@""]];
    [renderSections addObject:[self section:@"Compositing output"
                                    subtitle:@"Final visibility and capture state"
                                      accent:[self effectAccent]
                                      fields:displayFields]];

    NSMutableArray *runtimeFields = [NSMutableArray array];
    [runtimeFields addObject:[self infoField:@"Widget" value:presentation.widgetType]];
    [runtimeFields addObject:[self infoField:@"Element" value:presentation.elementType]];
    [runtimeFields addObject:[self infoField:@"RenderObject" value:presentation.renderObjectType]];
    NSArray *technicalDiagnostics = [self diagnosticFieldsFromObjects:diagnosticObjects technical:YES];
    for (PVFlutterInspectorFieldModel *field in technicalDiagnostics) {
        field.style = PVFlutterInspectorFieldStyleInfo;
        field.secondaryText = @"";
    }
    [runtimeFields addObjectsFromArray:technicalDiagnostics];
    [debugSections addObject:[self section:@"Runtime objects"
                                   subtitle:@"Widget, Element and RenderObject identity"
                                     accent:[self debugAccent]
                                     fields:runtimeFields]];

    PVFlutterNodeReference *reference = detail.reference ?: item.flutterReference;
    NSMutableArray *VMFields = [NSMutableArray array];
    [VMFields addObject:[self infoField:@"Engine" value:reference.engineIdentifier]];
    [VMFields addObject:[self infoField:@"Isolate" value:reference.isolateID]];
    [VMFields addObject:[self infoField:@"Object group" value:reference.objectGroup]];
    [VMFields addObject:[self infoField:@"Object ID" value:reference.objectID]];
    [VMFields addObject:[self infoField:@"Controller" value:reference.recordIdentifier]];
    [debugSections addObject:[self section:@"VM service"
                                   subtitle:@"Connection used for Inspector extensions"
                                     accent:[self debugAccent]
                                     fields:VMFields]];

    NSMutableArray *rawFields = [NSMutableArray array];
    if (detail.rawJSON.length) {
        [rawFields addObject:[self JSONField:@"Inspector node" value:detail.rawJSON]];
    }
    if (diagnosticObjects.count) {
        NSString *JSON = [self prettyJSONStringForObject:diagnosticObjects];
        [rawFields addObject:[self JSONField:@"Diagnostics properties" value:JSON]];
    }
    if (rawFields.count) {
        PVFlutterInspectorSectionModel *rawSection = [self section:@"Raw diagnostics"
                                                          subtitle:@"Unmodified JSON returned by Flutter Inspector"
                                                            accent:[self debugAccent]
                                                            fields:rawFields];
        rawSection.initiallyExpanded = NO;
        [debugSections addObject:rawSection];
    }

    presentation.sectionsByDomain = @{
        @(PVFlutterInspectorDomainWidget): widgetSections.copy,
        @(PVFlutterInspectorDomainRenderObject): renderSections.copy,
        @(PVFlutterInspectorDomainDebug): debugSections.copy,
    };
    return presentation;
}

+ (void)appendRelationSection:(NSString *)identifier
                        title:(NSString *)title
                       accent:(NSColor *)accent
                       detail:(PVFlutterNodeDetail *)detail
                           to:(NSMutableArray<PVFlutterInspectorSectionModel *> *)sections {
    PVFlutterDetailSection *source = [self sectionWithIdentifier:identifier detail:detail];
    if (!source.fields.count) return;
    NSMutableArray *fields = [NSMutableArray array];
    for (NSDictionary *relation in [self JSONObjectsFromFields:source.fields]) {
        NSString *type = [relation[@"type"] isKindOfClass:NSString.class] ? relation[@"type"] : @"Unknown";
        NSString *renderObject = [relation[@"renderObjectType"] isKindOfClass:NSString.class]
            ? relation[@"renderObjectType"] : @"";
        NSString *description = [relation[@"description"] isKindOfClass:NSString.class]
            ? relation[@"description"] : renderObject;
        [fields addObject:[self textField:type value:description secondary:renderObject]];
        NSArray *properties = [relation[@"properties"] isKindOfClass:NSArray.class]
            ? relation[@"properties"] : @[];
        [fields addObjectsFromArray:[self diagnosticFieldsFromObjects:properties technical:NO]];
    }
    if (fields.count) {
        [sections addObject:[self section:title subtitle:@"Attached to the selected visual node" accent:accent fields:fields]];
    }
}

+ (PVFlutterDetailSection *)sectionWithIdentifier:(NSString *)identifier
                                            detail:(PVFlutterNodeDetail *)detail {
    for (PVFlutterDetailSection *section in detail.sections ?: @[]) {
        if ([section.identifier isEqual:identifier]) return section;
    }
    return nil;
}

+ (NSArray<NSDictionary *> *)JSONObjectsFromFields:(NSArray<PVFlutterDetailField *> *)fields {
    NSMutableArray *result = [NSMutableArray array];
    for (PVFlutterDetailField *field in fields ?: @[]) {
        id value = [self JSONObjectFromString:field.textValue];
        if ([value isKindOfClass:NSDictionary.class]) [result addObject:value];
    }
    return result.copy;
}

+ (NSDictionary *)JSONObjectFromString:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    id value = data.length ? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil;
    return [value isKindOfClass:NSDictionary.class] ? value : nil;
}

+ (NSArray<PVFlutterInspectorFieldModel *> *)diagnosticFieldsFromObjects:(NSArray *)objects
                                                               technical:(BOOL)technical {
    NSMutableArray *fields = [NSMutableArray array];
    for (id value in objects ?: @[]) {
        if (![value isKindOfClass:NSDictionary.class]) continue;
        NSDictionary *property = value;
        NSString *name = [property[@"name"] isKindOfClass:NSString.class] ? property[@"name"] : @"Property";
        NSString *description = [property[@"description"] isKindOfClass:NSString.class]
            ? property[@"description"] : @"";
        NSString *level = [property[@"level"] isKindOfClass:NSString.class] ? property[@"level"] : @"";
        BOOL hidden = [level isEqual:@"hidden"] || [self isTechnicalPropertyName:name];
        if (technical != hidden) continue;
        if (!technical && (description.length == 0 || [description isEqual:@"null"])) continue;
        PVFlutterInspectorFieldModel *field = [self diagnosticFieldFromDictionary:property];
        if (field) [fields addObject:field];
    }
    return fields.copy;
}

+ (BOOL)isTechnicalPropertyName:(NSString *)name {
    static NSSet<NSString *> *names;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        names = [NSSet setWithArray:@[@"depth", @"widget", @"key", @"dirty", @"dependencies"]];
    });
    return [names containsObject:name];
}

+ (PVFlutterInspectorFieldModel *)diagnosticFieldFromDictionary:(NSDictionary *)property {
    NSString *name = [property[@"name"] isKindOfClass:NSString.class] ? property[@"name"] : @"Property";
    NSString *propertyType = [property[@"propertyType"] isKindOfClass:NSString.class]
        ? property[@"propertyType"] : @"";
    NSString *description = [property[@"description"] isKindOfClass:NSString.class]
        ? property[@"description"] : @"";
    id value = property[@"value"];

    if ([propertyType isEqual:@"bool"] ||
        ([value isKindOfClass:NSNumber.class] &&
         ([description isEqual:@"true"] || [description isEqual:@"false"]))) {
        BOOL boolValue = [value respondsToSelector:@selector(boolValue)]
            ? [value boolValue] : [description isEqual:@"true"];
        return [self booleanField:name value:boolValue];
    }
    if ([propertyType containsString:@"Color"] || [property[@"type"] isEqual:@"ColorProperty"]) {
        NSColor *color = [self colorFromDiagnosticProperty:property];
        return [self colorField:name color:color text:description];
    }
    if ([value isKindOfClass:NSNumber.class]) {
        return [self numberField:name value:description.length ? description : [value description] secondary:propertyType];
    }
    NSString *text = [value isKindOfClass:NSString.class] ? value : description;
    PVFlutterInspectorFieldModel *field = [self textField:name value:text secondary:propertyType];
    if ([name isEqualToString:@"data"] || [propertyType isEqualToString:@"String"]) {
        field.style = PVFlutterInspectorFieldStyleTextArea;
    }
    return field;
}

+ (NSArray<PVFlutterInspectorFieldModel *> *)decorationFieldsFromDictionary:(NSDictionary *)decoration {
    NSMutableArray *fields = [NSMutableArray array];
    NSString *kind = [decoration[@"kind"] isKindOfClass:NSString.class] ? decoration[@"kind"] : @"Decoration";
    NSString *shape = [decoration[@"shape"] isKindOfClass:NSString.class] ? decoration[@"shape"] : @"";
    [fields addObject:[self textField:@"Type" value:kind secondary:shape]];

    NSColor *background = [self colorFromComponentDictionary:decoration[@"backgroundColor"]];
    if (background) [fields addObject:[self colorField:@"Background" color:background text:[self hexStringForColor:background]]];
    NSNumber *radius = [decoration[@"cornerRadius"] isKindOfClass:NSNumber.class] ? decoration[@"cornerRadius"] : nil;
    if (radius) [fields addObject:[self numberField:@"Corner radius"
                                               value:[NSString stringWithFormat:@"%@ logical px", radius]
                                           secondary:@""]];
    NSDictionary *border = [decoration[@"border"] isKindOfClass:NSDictionary.class] ? decoration[@"border"] : nil;
    if (border) {
        NSColor *borderColor = [self colorFromComponentDictionary:border[@"color"]];
        NSString *borderValue = [NSString stringWithFormat:@"%@ logical px · %@",
                                 border[@"width"] ?: @0,
                                 borderColor ? [self hexStringForColor:borderColor] : @"no color"];
        [fields addObject:[self colorField:@"Border" color:borderColor text:borderValue]];
    }
    NSArray *shadows = [decoration[@"shadows"] isKindOfClass:NSArray.class] ? decoration[@"shadows"] : @[];
    [shadows enumerateObjectsUsingBlock:^(NSDictionary *shadow, NSUInteger index, BOOL *stop) {
        NSString *text = [NSString stringWithFormat:@"offset (%@, %@) · blur %@ · spread %@",
                          shadow[@"offsetX"] ?: @0, shadow[@"offsetY"] ?: @0,
                          shadow[@"blurRadius"] ?: @0, shadow[@"spreadRadius"] ?: @0];
        NSColor *color = [self colorFromComponentDictionary:shadow[@"color"]];
        [fields addObject:[self colorField:[NSString stringWithFormat:@"Shadow %@", @(index + 1)] color:color text:text]];
    }];
    NSNumber *elevation = [decoration[@"elevation"] isKindOfClass:NSNumber.class] ? decoration[@"elevation"] : nil;
    if (elevation) [fields addObject:[self numberField:@"Elevation" value:elevation.stringValue secondary:@""]];
    return fields.copy;
}

+ (PVFlutterInspectorFieldModel *)presentationFieldFromDetailField:(PVFlutterDetailField *)field {
    PVFlutterInspectorFieldModel *result = [PVFlutterInspectorFieldModel new];
    result.title = field.title ?: field.identifier;
    switch (field.valueKind) {
        case PVFlutterDetailValueKindBoolean:
            result.style = PVFlutterInspectorFieldStyleBoolean;
            result.booleanValue = field.numberValue.boolValue;
            result.value = result.booleanValue ? @"On" : @"Off";
            break;
        case PVFlutterDetailValueKindNumber:
            result.style = PVFlutterInspectorFieldStyleNumber;
            result.value = field.numberValue.stringValue ?: field.textValue ?: @"";
            break;
        case PVFlutterDetailValueKindColorARGB: {
            result.style = PVFlutterInspectorFieldStyleColor;
            uint32_t argb = field.numberValue.unsignedIntValue;
            result.colorValue = [NSColor colorWithSRGBRed:((argb >> 16) & 0xff) / 255.0
                                                    green:((argb >> 8) & 0xff) / 255.0
                                                     blue:(argb & 0xff) / 255.0
                                                    alpha:((argb >> 24) & 0xff) / 255.0];
            result.value = [self hexStringForColor:result.colorValue];
            break;
        }
        case PVFlutterDetailValueKindRect:
            result.style = PVFlutterInspectorFieldStyleRect;
            result.rectValue = field.rectValue;
            break;
        case PVFlutterDetailValueKindSize:
            result.style = PVFlutterInspectorFieldStyleSize;
            result.sizeValue = field.sizeValue;
            break;
        case PVFlutterDetailValueKindJSON:
            result.style = PVFlutterInspectorFieldStyleJSON;
            result.value = field.textValue ?: @"";
            break;
        default:
            result.style = PVFlutterInspectorFieldStyleText;
            result.value = field.textValue ?: @"";
            break;
    }
    return result;
}

+ (PVFlutterInspectorSectionModel *)section:(NSString *)title
                                    subtitle:(NSString *)subtitle
                                      accent:(NSColor *)accent
                                      fields:(NSArray *)fields {
    PVFlutterInspectorSectionModel *section = [PVFlutterInspectorSectionModel new];
    section.title = title ?: @"";
    section.subtitle = subtitle ?: @"";
    section.accentColor = accent;
    section.fields = fields ?: @[];
    return section;
}

+ (PVFlutterInspectorFieldModel *)textField:(NSString *)title
                                       value:(NSString *)value
                                   secondary:(NSString *)secondary {
    PVFlutterInspectorFieldModel *field = [PVFlutterInspectorFieldModel new];
    field.title = title ?: @"";
    field.value = value ?: @"";
    field.secondaryText = secondary ?: @"";
    field.style = PVFlutterInspectorFieldStyleText;
    return field;
}

+ (PVFlutterInspectorFieldModel *)infoField:(NSString *)title value:(NSString *)value {
    PVFlutterInspectorFieldModel *field = [self textField:title value:value secondary:@""];
    field.style = PVFlutterInspectorFieldStyleInfo;
    return field;
}

+ (PVFlutterInspectorFieldModel *)numberField:(NSString *)title
                                         value:(NSString *)value
                                     secondary:(NSString *)secondary {
    PVFlutterInspectorFieldModel *field = [self textField:title value:value secondary:secondary];
    field.style = PVFlutterInspectorFieldStyleNumber;
    return field;
}

+ (PVFlutterInspectorFieldModel *)booleanField:(NSString *)title value:(BOOL)value {
    PVFlutterInspectorFieldModel *field = [PVFlutterInspectorFieldModel new];
    field.title = title ?: @"";
    field.value = value ? @"On" : @"Off";
    field.booleanValue = value;
    field.style = PVFlutterInspectorFieldStyleBoolean;
    return field;
}

+ (PVFlutterInspectorFieldModel *)colorField:(NSString *)title
                                        color:(NSColor *)color
                                         text:(NSString *)text {
    PVFlutterInspectorFieldModel *field = [PVFlutterInspectorFieldModel new];
    field.title = title ?: @"";
    field.value = text ?: @"";
    field.colorValue = color;
    field.style = PVFlutterInspectorFieldStyleColor;
    return field;
}

+ (PVFlutterInspectorFieldModel *)JSONField:(NSString *)title value:(NSString *)value {
    PVFlutterInspectorFieldModel *field = [PVFlutterInspectorFieldModel new];
    field.title = title ?: @"";
    field.value = value ?: @"";
    field.style = PVFlutterInspectorFieldStyleJSON;
    return field;
}

+ (NSString *)nodeKindFromDetail:(PVFlutterNodeDetail *)detail widgetType:(NSString *)widgetType {
    PVFlutterDetailSection *rendering = [self sectionWithIdentifier:@"rendering" detail:detail];
    for (PVFlutterDetailField *field in rendering.fields ?: @[]) {
        if ([field.identifier isEqual:@"kind"] && field.textValue.length) return field.textValue;
    }
    NSString *base = [[widgetType componentsSeparatedByString:@"<"] firstObject] ?: widgetType;
    if ([base containsString:@"Text"] || [base isEqual:@"RichText"]) return @"text";
    if ([base containsString:@"Image"] || [base isEqual:@"Icon"]) return @"image";
    if ([base containsString:@"Button"] || [base isEqual:@"Switch"] || [base isEqual:@"Slider"]) return @"control";
    if ([base isEqual:@"SizedBox"] || [base isEqual:@"Spacer"]) return @"spacing";
    if ([base containsString:@"Scroll"] || [base containsString:@"ListView"] || [base containsString:@"GridView"]) return @"scroll";
    return @"box";
}

+ (NSString *)propertySectionTitleForKind:(NSString *)kind widgetType:(NSString *)widgetType {
    if ([kind isEqual:@"text"]) return @"Text";
    if ([kind isEqual:@"image"]) return @"Image";
    if ([kind isEqual:@"control"]) return @"Control";
    if ([kind isEqual:@"scroll"]) return @"Scroll behavior";
    if ([kind isEqual:@"spacing"]) return @"Spacing";
    return widgetType.length ? [NSString stringWithFormat:@"%@ properties", widgetType] : @"Widget properties";
}

+ (NSColor *)colorFromDiagnosticProperty:(NSDictionary *)property {
    NSDictionary *components = [property[@"valueProperties"] isKindOfClass:NSDictionary.class]
        ? property[@"valueProperties"] : nil;
    NSColor *color = [self colorFromComponentDictionary:components];
    if (color) return color;
    NSString *description = [property[@"description"] isKindOfClass:NSString.class]
        ? property[@"description"] : @"";
    return [self colorFromDescription:description];
}

+ (NSColor *)colorFromComponentDictionary:(id)value {
    if (![value isKindOfClass:NSDictionary.class]) return nil;
    NSDictionary *components = value;
    NSNumber *red = [components[@"red"] isKindOfClass:NSNumber.class] ? components[@"red"] : nil;
    NSNumber *green = [components[@"green"] isKindOfClass:NSNumber.class] ? components[@"green"] : nil;
    NSNumber *blue = [components[@"blue"] isKindOfClass:NSNumber.class] ? components[@"blue"] : nil;
    NSNumber *alpha = [components[@"alpha"] isKindOfClass:NSNumber.class] ? components[@"alpha"] : nil;
    if (!red || !green || !blue || !alpha) return nil;
    CGFloat divisor = MAX(MAX(red.doubleValue, green.doubleValue), MAX(blue.doubleValue, alpha.doubleValue)) > 1.0 ? 255.0 : 1.0;
    return [NSColor colorWithSRGBRed:red.doubleValue / divisor
                               green:green.doubleValue / divisor
                                blue:blue.doubleValue / divisor
                               alpha:alpha.doubleValue / divisor];
}

+ (NSColor *)colorFromDescription:(NSString *)description {
    if (!description.length) return nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:
        @"Color\\(alpha:\\s*([0-9.]+),\\s*red:\\s*([0-9.]+),\\s*green:\\s*([0-9.]+),\\s*blue:\\s*([0-9.]+)"
                                                                               options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:description options:0 range:NSMakeRange(0, description.length)];
    if (match.numberOfRanges == 5) {
        CGFloat alpha = [[description substringWithRange:[match rangeAtIndex:1]] doubleValue];
        CGFloat red = [[description substringWithRange:[match rangeAtIndex:2]] doubleValue];
        CGFloat green = [[description substringWithRange:[match rangeAtIndex:3]] doubleValue];
        CGFloat blue = [[description substringWithRange:[match rangeAtIndex:4]] doubleValue];
        return [NSColor colorWithSRGBRed:red green:green blue:blue alpha:alpha];
    }
    NSRegularExpression *hexRegex = [NSRegularExpression regularExpressionWithPattern:@"Color\\(0x([0-9A-Fa-f]{8})\\)"
                                                                                options:0 error:nil];
    match = [hexRegex firstMatchInString:description options:0 range:NSMakeRange(0, description.length)];
    if (match.numberOfRanges == 2) {
        unsigned long long argb = 0;
        [[NSScanner scannerWithString:[description substringWithRange:[match rangeAtIndex:1]]] scanHexLongLong:&argb];
        return [NSColor colorWithSRGBRed:((argb >> 16) & 0xff) / 255.0
                                   green:((argb >> 8) & 0xff) / 255.0
                                    blue:(argb & 0xff) / 255.0
                                   alpha:((argb >> 24) & 0xff) / 255.0];
    }
    return nil;
}

+ (NSString *)hexStringForColor:(NSColor *)color {
    NSColor *RGB = [color colorUsingColorSpace:NSColorSpace.sRGBColorSpace];
    if (!RGB) return @"Color";
    NSInteger alpha = lround(RGB.alphaComponent * 255.0);
    NSInteger red = lround(RGB.redComponent * 255.0);
    NSInteger green = lround(RGB.greenComponent * 255.0);
    NSInteger blue = lround(RGB.blueComponent * 255.0);
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX%02lX", (long)alpha, (long)red, (long)green, (long)blue];
}

+ (NSString *)prettyJSONStringForObject:(id)object {
    NSData *data = [NSJSONSerialization dataWithJSONObject:object
                                                   options:NSJSONWritingPrettyPrinted | NSJSONWritingSortedKeys
                                                     error:nil];
    return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : [object description];
}

+ (NSColor *)widgetAccent { return [NSColor colorWithSRGBRed:0.05 green:0.55 blue:0.48 alpha:1.0]; }
+ (NSColor *)layoutAccent { return [NSColor colorWithSRGBRed:0.12 green:0.45 blue:0.82 alpha:1.0]; }
+ (NSColor *)renderAccent { return [NSColor colorWithSRGBRed:0.10 green:0.58 blue:0.78 alpha:1.0]; }
+ (NSColor *)paintAccent { return [NSColor colorWithSRGBRed:0.93 green:0.42 blue:0.18 alpha:1.0]; }
+ (NSColor *)effectAccent { return [NSColor colorWithSRGBRed:0.72 green:0.38 blue:0.16 alpha:1.0]; }
+ (NSColor *)interactionAccent { return [NSColor colorWithSRGBRed:0.88 green:0.34 blue:0.34 alpha:1.0]; }
+ (NSColor *)semanticsAccent { return [NSColor colorWithSRGBRed:0.31 green:0.56 blue:0.24 alpha:1.0]; }
+ (NSColor *)debugAccent { return NSColor.secondaryLabelColor; }

@end

@interface PVFlutterInspectorMetricView : PVDetailNumberInputView
- (void)setName:(NSString *)name value:(NSString *)value;
@end

@implementation PVFlutterInspectorMetricView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.viewStyle = PVDetailNumberInputViewStyleHorizontal;
        self.textFieldView.textField.editable = NO;
        self.textFieldView.textField.selectable = YES;
    }
    return self;
}

- (void)setName:(NSString *)name value:(NSString *)value {
    self.title = name.uppercaseString ?: @"";
    self.textFieldView.textField.stringValue = value ?: @"";
}

@end

@interface PVFlutterInspectorFieldView : PVDetailBaseView
@property(nonatomic, strong) PVFlutterInspectorFieldModel *model;
@property(nonatomic, strong) PVDetailLabel *titleLabel;
@property(nonatomic, strong) PVDetailTextFieldView *valueContainer;
@property(nonatomic, strong) PVDetailNumberInputView *numberInputView;
@property(nonatomic, strong) NSTextField *valueLabel;
@property(nonatomic, strong) NSScrollView *JSONScrollView;
@property(nonatomic, strong) NSTextView *JSONTextView;
@property(nonatomic, strong) PVDetailLabel *secondaryLabel;
@property(nonatomic, strong) PVDetailBaseView *colorSwatch;
@property(nonatomic, strong) NSButton *booleanCheckbox;
@property(nonatomic, strong) CALayer *separatorLayer;
@property(nonatomic, copy) NSArray<PVFlutterInspectorMetricView *> *metricViews;
@property(nonatomic) NSUInteger rowIndex;
- (void)ensureValueContainer;
- (void)ensureNumberInputView;
- (void)ensureValueLabel;
- (void)ensureJSONTextView;
- (void)ensureSecondaryLabel;
- (void)ensureColorSwatch;
- (void)ensureBooleanCheckbox;
@end

@implementation PVFlutterInspectorFieldView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.titleLabel = [PVDetailLabel new];
        self.titleLabel.font = [NSFont boldSystemFontOfSize:12];
        self.titleLabel.textColor = NSColor.labelColor;
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:self.titleLabel];

        self.separatorLayer = [CALayer layer];
        self.separatorLayer.backgroundColor = NSColor.clearColor.CGColor;
        [self.separatorLayer pv_inspect_removeImplicitAnimations];
        [self.layer addSublayer:self.separatorLayer];
    }
    return self;
}

- (void)ensureValueContainer {
    if (self.valueContainer) return;
    self.valueContainer = [PVDetailTextFieldView new];
    self.valueContainer.backgroundColorName = @"DashboardCardValueBGColor";
    self.valueContainer.layer.cornerRadius = DashboardCardControlCornerRadius;
    self.valueContainer.insets = NSEdgeInsetsMake(3, 6, 3, 6);
    self.valueContainer.textField.cell = [NSTextFieldCell new];
    self.valueContainer.textField.cell.focusRingType = NSFocusRingTypeNone;
    self.valueContainer.textField.cell.usesSingleLineMode = YES;
    self.valueContainer.textField.cell.lineBreakMode = NSLineBreakByTruncatingTail;
    self.valueContainer.textField.cell.scrollable = YES;
    self.valueContainer.textField.editable = NO;
    self.valueContainer.textField.selectable = YES;
    self.valueContainer.textField.bezeled = NO;
    self.valueContainer.textField.drawsBackground = NO;
    self.valueContainer.textField.textColor = [NSColor colorNamed:@"DashboardCardValueColor"];
    self.valueContainer.textField.font = NSFontMake(12);
    [self addSubview:self.valueContainer];
}

- (void)ensureNumberInputView {
    if (self.numberInputView) return;
    self.numberInputView = [PVDetailNumberInputView new];
    self.numberInputView.viewStyle = PVDetailNumberInputViewStyleHorizontal;
    self.numberInputView.textFieldView.textField.editable = NO;
    self.numberInputView.textFieldView.textField.selectable = YES;
    [self addSubview:self.numberInputView];
}

- (void)ensureValueLabel {
    if (self.valueLabel) return;
    self.valueLabel = [NSTextField wrappingLabelWithString:@""];
    self.valueLabel.textColor = [NSColor colorNamed:@"DashboardCardValueColor"];
    self.valueLabel.selectable = YES;
    self.valueLabel.editable = NO;
    self.valueLabel.bordered = NO;
    self.valueLabel.drawsBackground = NO;
    self.valueLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self addSubview:self.valueLabel];
}

- (void)ensureJSONTextView {
    if (self.JSONScrollView) return;
    self.JSONScrollView = [PVDetailHelper scrollableTextView];
    self.JSONScrollView.wantsLayer = YES;
    self.JSONScrollView.layer.cornerRadius = DashboardCardControlCornerRadius;
    self.JSONTextView = self.JSONScrollView.documentView;
    self.JSONTextView.backgroundColor = [NSColor colorNamed:@"DashboardCardValueBGColor"];
    self.JSONTextView.textColor = [NSColor colorNamed:@"DashboardCardValueColor"];
    self.JSONTextView.textContainerInset = NSMakeSize(2, 4);
    self.JSONTextView.editable = NO;
    self.JSONTextView.selectable = YES;
    [self addSubview:self.JSONScrollView];
}

- (void)ensureSecondaryLabel {
    if (self.secondaryLabel) return;
    self.secondaryLabel = [PVDetailLabel new];
    self.secondaryLabel.font = [NSFont systemFontOfSize:9 weight:NSFontWeightMedium];
    self.secondaryLabel.textColor = NSColor.secondaryLabelColor;
    self.secondaryLabel.alignment = NSTextAlignmentCenter;
    self.secondaryLabel.wantsLayer = YES;
    self.secondaryLabel.layer.cornerRadius = 5;
    self.secondaryLabel.layer.backgroundColor = [NSColor.secondaryLabelColor colorWithAlphaComponent:0.10].CGColor;
    [self addSubview:self.secondaryLabel];
}

- (void)ensureColorSwatch {
    if (self.colorSwatch) return;
    self.colorSwatch = [PVDetailBaseView new];
    self.colorSwatch.layer.cornerRadius = 3;
    self.colorSwatch.layer.borderWidth = 1;
    self.colorSwatch.layer.borderColor = [NSColor.separatorColor colorWithAlphaComponent:0.65].CGColor;
    [self addSubview:self.colorSwatch];
}

- (void)ensureBooleanCheckbox {
    if (self.booleanCheckbox) return;
    self.booleanCheckbox = [NSButton checkboxWithTitle:@"" target:nil action:nil];
    self.booleanCheckbox.enabled = NO;
    self.booleanCheckbox.font = [NSFont systemFontOfSize:11];
    [self addSubview:self.booleanCheckbox];
}

- (void)setModel:(PVFlutterInspectorFieldModel *)model {
    _model = model;
    self.titleLabel.stringValue = model.title ?: @"";
    self.titleLabel.font = model.style == PVFlutterInspectorFieldStyleInfo
        ? NSFontMake(11) : [NSFont boldSystemFontOfSize:12];
    self.titleLabel.textColor = model.style == PVFlutterInspectorFieldStyleInfo
        ? NSColor.secondaryLabelColor : NSColor.labelColor;
    if (model.style == PVFlutterInspectorFieldStyleNumber) {
        [self ensureNumberInputView];
        self.numberInputView.title = model.title ?: @"";
        self.numberInputView.textFieldView.textField.stringValue = model.value ?: @"";
    } else if (model.style == PVFlutterInspectorFieldStyleInfo) {
        [self ensureValueLabel];
        self.valueLabel.stringValue = model.value ?: @"";
        self.valueLabel.font = [NSFont monospacedSystemFontOfSize:10.5 weight:NSFontWeightRegular];
        self.valueLabel.maximumNumberOfLines = 3;
    } else if (model.style == PVFlutterInspectorFieldStyleJSON ||
               model.style == PVFlutterInspectorFieldStyleTextArea) {
        [self ensureJSONTextView];
        self.JSONTextView.string = model.value ?: @"";
        self.JSONTextView.font = model.style == PVFlutterInspectorFieldStyleTextArea
            ? NSFontMake(12) : [NSFont monospacedSystemFontOfSize:10 weight:NSFontWeightRegular];
    } else if (model.style == PVFlutterInspectorFieldStyleBoolean) {
        [self ensureBooleanCheckbox];
    } else if (model.style != PVFlutterInspectorFieldStyleRect &&
               model.style != PVFlutterInspectorFieldStyleSize) {
        [self ensureValueContainer];
        self.valueContainer.textField.stringValue = model.value ?: @"";
        self.valueContainer.textField.font = NSFontMake(12);
    }
    if (model.secondaryText.length) {
        [self ensureSecondaryLabel];
        self.secondaryLabel.stringValue = model.secondaryText;
    }
    if (model.style == PVFlutterInspectorFieldStyleColor) {
        [self ensureColorSwatch];
        self.colorSwatch.backgroundColor = model.colorValue ?: NSColor.clearColor;
    }
    if (model.style == PVFlutterInspectorFieldStyleBoolean) {
        self.booleanCheckbox.state = model.booleanValue ? NSControlStateValueOn : NSControlStateValueOff;
        self.booleanCheckbox.attributedTitle = $(model.title ?: @"")
            .textColor([NSColor colorNamed:@"DashboardCardValueColor"])
            .font(NSFontMake(13)).attrString;
    }
    [self rebuildMetrics];
}

- (void)setRowIndex:(NSUInteger)rowIndex {
    _rowIndex = rowIndex;
    self.backgroundColors = PVDetailColorsCombine(NSColor.clearColor, NSColor.clearColor);
}

- (void)rebuildMetrics {
    NSArray *names = @[];
    NSArray *values = @[];
    if (self.model.style == PVFlutterInspectorFieldStyleRect) {
        names = @[@"x", @"y", @"w", @"h"];
        CGRect rect = self.model.rectValue;
        values = @[[self compactNumber:rect.origin.x], [self compactNumber:rect.origin.y],
                   [self compactNumber:rect.size.width], [self compactNumber:rect.size.height]];
    } else if (self.model.style == PVFlutterInspectorFieldStyleSize) {
        names = @[@"w", @"h"];
        values = @[[self compactNumber:self.model.sizeValue.width],
                   [self compactNumber:self.model.sizeValue.height]];
    }
    NSMutableArray<PVFlutterInspectorMetricView *> *views = self.metricViews.mutableCopy;
    if (!views) views = [NSMutableArray arrayWithCapacity:names.count];
    [names enumerateObjectsUsingBlock:^(NSString *name, NSUInteger index, BOOL *stop) {
        PVFlutterInspectorMetricView *view = index < views.count ? views[index] : nil;
        if (!view) {
            view = [PVFlutterInspectorMetricView new];
            [self addSubview:view];
            [views addObject:view];
        }
        [view setName:name value:values[index]];
    }];
    while (views.count > names.count) {
        [views.lastObject removeFromSuperview];
        [views removeLastObject];
    }
    self.metricViews = views.copy;
}

- (NSString *)compactNumber:(CGFloat)value {
    return fabs(value - round(value)) < 0.01
        ? [NSString stringWithFormat:@"%.0f", value]
        : [NSString stringWithFormat:@"%.2f", value];
}

- (void)layout {
    [super layout];
    CGFloat width = NSWidth(self.bounds);
    CGFloat titleHeight = ceil([self.titleLabel sizeThatFits:NSMakeSize(width, CGFLOAT_MAX)].height);
    CGFloat contentY = titleHeight + DashboardAttrItemVerInterspace;
    self.separatorLayer.frame = CGRectZero;
    self.titleLabel.hidden = self.model.style == PVFlutterInspectorFieldStyleBoolean ||
                             self.model.style == PVFlutterInspectorFieldStyleNumber;
    self.titleLabel.frame = NSMakeRect(0, 0, width, titleHeight);
    self.valueContainer.hidden = YES;
    self.numberInputView.hidden = self.model.style != PVFlutterInspectorFieldStyleNumber;
    self.valueLabel.hidden = self.model.style != PVFlutterInspectorFieldStyleInfo;
    self.JSONScrollView.hidden = self.model.style != PVFlutterInspectorFieldStyleJSON &&
                                 self.model.style != PVFlutterInspectorFieldStyleTextArea;
    self.secondaryLabel.hidden = YES;
    self.colorSwatch.hidden = self.model.style != PVFlutterInspectorFieldStyleColor;
    self.booleanCheckbox.hidden = self.model.style != PVFlutterInspectorFieldStyleBoolean;
    if (self.model.style == PVFlutterInspectorFieldStyleInfo) {
        CGFloat keyWidth = MIN(72, floor(width * 0.34));
        CGFloat valueX = keyWidth + 7;
        CGFloat valueHeight = ceil([self.valueLabel sizeThatFits:
            NSMakeSize(MAX(20, width - valueX), CGFLOAT_MAX)].height);
        CGFloat rowHeight = MAX(titleHeight, valueHeight);
        self.titleLabel.frame = NSMakeRect(0, 0, keyWidth, rowHeight);
        self.valueLabel.frame = NSMakeRect(valueX, 0, MAX(20, width - valueX), rowHeight);
        return;
    }
    if (self.model.style == PVFlutterInspectorFieldStyleRect ||
        self.model.style == PVFlutterInspectorFieldStyleSize) {
        NSUInteger count = self.metricViews.count;
        NSUInteger columns = MIN((NSUInteger)2, MAX((NSUInteger)1, count));
        CGFloat metricWidth = floor((width - DashboardAttrItemHorInterspace * (columns - 1)) / columns);
        [self.metricViews enumerateObjectsUsingBlock:^(PVFlutterInspectorMetricView *view, NSUInteger index, BOOL *stop) {
            NSUInteger column = index % columns;
            NSUInteger row = index / columns;
            view.frame = NSMakeRect((metricWidth + DashboardAttrItemHorInterspace) * column,
                                    contentY + (PVDetailNumberInputHorizontalHeight + DashboardAttrItemVerInterspace) * row,
                                    metricWidth, PVDetailNumberInputHorizontalHeight);
        }];
        return;
    }
    if (self.model.style == PVFlutterInspectorFieldStyleBoolean) {
        self.booleanCheckbox.frame = self.bounds;
        return;
    }
    if (self.model.style == PVFlutterInspectorFieldStyleNumber) {
        self.numberInputView.frame = NSMakeRect(0, 0, width, PVDetailNumberInputHorizontalHeight);
        return;
    }
    if (self.model.style == PVFlutterInspectorFieldStyleJSON ||
        self.model.style == PVFlutterInspectorFieldStyleTextArea) {
        self.JSONScrollView.frame = NSMakeRect(0, contentY, width,
                                               MAX(PVDetailNumberInputHorizontalHeight,
                                                   NSHeight(self.bounds) - contentY));
        return;
    }

    self.valueContainer.hidden = NO;
    CGFloat controlHeight = self.model.style == PVFlutterInspectorFieldStyleColor
        ? 30 : PVDetailNumberInputHorizontalHeight;
    self.valueContainer.frame = NSMakeRect(0, contentY, width, controlHeight);
    self.valueContainer.textField.font = self.model.style == PVFlutterInspectorFieldStyleColor
        ? NSFontMake(13) : NSFontMake(12);
    CGFloat leftInset = 6;
    CGFloat rightInset = 6;
    if (self.model.style == PVFlutterInspectorFieldStyleColor) {
        self.colorSwatch.frame = NSMakeRect(8, contentY + floor((controlHeight - 16) / 2.0), 16, 16);
        leftInset = 30;
    }
    if (self.model.secondaryText.length) {
        CGFloat badgeWidth = MIN(88, ceil([self.model.secondaryText sizeWithAttributes:
            @{NSFontAttributeName:self.secondaryLabel.font}].width) + 13);
        self.secondaryLabel.hidden = NO;
        self.secondaryLabel.frame = NSMakeRect(MAX(leftInset, width - badgeWidth - 6),
                                               contentY + floor((controlHeight - 14) / 2.0),
                                               badgeWidth, 14);
        rightInset = badgeWidth + 12;
    }
    self.valueContainer.insets = NSEdgeInsetsMake(3, leftInset, 3, rightInset);
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    CGFloat titleHeight = ceil([self.titleLabel sizeThatFits:NSMakeSize(limitedSize.width, CGFLOAT_MAX)].height);
    CGFloat contentY = titleHeight + DashboardAttrItemVerInterspace;
    if (self.model.style == PVFlutterInspectorFieldStyleInfo) {
        CGFloat keyWidth = MIN(72, floor(limitedSize.width * 0.34));
        CGFloat valueWidth = MAX(20, limitedSize.width - keyWidth - 7);
        CGFloat valueHeight = ceil([self.valueLabel sizeThatFits:NSMakeSize(valueWidth, CGFLOAT_MAX)].height);
        limitedSize.height = MAX(titleHeight, valueHeight);
        return limitedSize;
    }
    if (self.model.style == PVFlutterInspectorFieldStyleRect ||
        self.model.style == PVFlutterInspectorFieldStyleSize) {
        NSUInteger rows = self.model.style == PVFlutterInspectorFieldStyleRect ? 2 : 1;
        limitedSize.height = contentY + rows * PVDetailNumberInputHorizontalHeight +
                             (rows - 1) * DashboardAttrItemVerInterspace;
        return limitedSize;
    }
    if (self.model.style == PVFlutterInspectorFieldStyleJSON ||
        self.model.style == PVFlutterInspectorFieldStyleTextArea) {
        CGFloat textWidth = MAX(40, limitedSize.width - self.JSONTextView.textContainerInset.width * 2);
        CGFloat maximumTextHeight = self.model.style == PVFlutterInspectorFieldStyleTextArea ? 80 : 154;
        NSRect rect = [self.model.value boundingRectWithSize:NSMakeSize(textWidth, maximumTextHeight)
                                                     options:NSStringDrawingUsesLineFragmentOrigin |
                                                             NSStringDrawingTruncatesLastVisibleLine
                                                  attributes:@{NSFontAttributeName:self.JSONTextView.font}];
        CGFloat minimumControlHeight = self.model.style == PVFlutterInspectorFieldStyleTextArea
            ? PVDetailNumberInputHorizontalHeight : 42;
        CGFloat maximumControlHeight = self.model.style == PVFlutterInspectorFieldStyleTextArea ? 80 : 170;
        limitedSize.height = contentY + MAX(minimumControlHeight,
                                            MIN(maximumControlHeight, ceil(NSHeight(rect)) + 8));
        return limitedSize;
    }
    if (self.model.style == PVFlutterInspectorFieldStyleBoolean) {
        NSSize checkboxSize = [self.booleanCheckbox sizeThatFits:limitedSize];
        limitedSize.height = checkboxSize.height + 2;
        return limitedSize;
    }
    if (self.model.style == PVFlutterInspectorFieldStyleNumber) {
        limitedSize.height = PVDetailNumberInputHorizontalHeight;
        return limitedSize;
    }
    CGFloat controlHeight = self.model.style == PVFlutterInspectorFieldStyleColor
        ? 30 : PVDetailNumberInputHorizontalHeight;
    limitedSize.height = contentY + controlHeight;
    return limitedSize;
}

@end

@interface PVFlutterInspectorSectionView : PVDetailBaseView
@property(nonatomic, strong) PVFlutterInspectorSectionModel *model;
@property(nonatomic, strong) PVDetailVisualEffectView *backgroundEffectView;
@property(nonatomic, strong) PVDetailDashboardCardTitleControl *titleControl;
@property(nonatomic, strong) PVDetailLabel *subtitleLabel;
@property(nonatomic, copy) NSArray<PVFlutterInspectorFieldView *> *fieldViews;
@property(nonatomic) BOOL collapsed;
@property(nonatomic, copy) void (^collapseDidChange)(void);
@end

@implementation PVFlutterInspectorSectionView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.layer.cornerRadius = DashboardCardCornerRadius;
        self.layer.masksToBounds = YES;
        self.backgroundEffectView = [PVDetailVisualEffectView new];
        self.backgroundEffectView.blendingMode = NSVisualEffectBlendingModeWithinWindow;
        self.backgroundEffectView.state = NSVisualEffectStateActive;
        [self addSubview:self.backgroundEffectView];

        self.titleControl = [PVDetailDashboardCardTitleControl new];
        [self.titleControl addTarget:self clickAction:@selector(toggleCollapsed)];
        self.titleControl.toolTip = @"Expand or collapse section";
        [self addSubview:self.titleControl];

        self.subtitleLabel = [PVDetailLabel new];
        self.subtitleLabel.font = [NSFont systemFontOfSize:10];
        self.subtitleLabel.textColor = NSColor.tertiaryLabelColor;
        self.subtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:self.subtitleLabel];
    }
    return self;
}

- (void)setModel:(PVFlutterInspectorSectionModel *)model {
    _model = model;
    self.titleControl.label.stringValue = model.title ?: @"";
    self.titleControl.iconImageView.image = [self iconForModel:model];
    self.subtitleLabel.stringValue = model.subtitle ?: @"";
    self.collapsed = !model.initiallyExpanded;

    NSMutableArray<PVFlutterInspectorFieldView *> *views = self.fieldViews.mutableCopy;
    if (!views) views = [NSMutableArray arrayWithCapacity:model.fields.count];
    [model.fields enumerateObjectsUsingBlock:^(PVFlutterInspectorFieldModel *field, NSUInteger index, BOOL *stop) {
        PVFlutterInspectorFieldView *view = index < views.count ? views[index] : nil;
        if (!view) {
            view = [PVFlutterInspectorFieldView new];
            [self addSubview:view];
            [views addObject:view];
        }
        view.model = field;
        view.rowIndex = index;
    }];
    while (views.count > model.fields.count) {
        [views.lastObject removeFromSuperview];
        [views removeLastObject];
    }
    self.fieldViews = views.copy;
    [self updateCollapsedState];
}

- (NSImage *)iconForModel:(PVFlutterInspectorSectionModel *)model {
    NSString *title = model.title.lowercaseString;
    if ([title containsString:@"layout"] || [title containsString:@"box model"]) {
        return NSImageMake(@"dashboard_layout");
    }
    if ([title containsString:@"paint"] || [title containsString:@"decoration"] ||
        [title containsString:@"compositing"]) {
        return NSImageMake(@"dashboard_layer");
    }
    if ([title containsString:@"interaction"] || [title containsString:@"semantics"]) {
        return NSImageMake(@"dashboard_control");
    }
    if ([title containsString:@"text"]) return NSImageMake(@"dashboard_label");
    return NSImageMake(@"dashboard_custom");
}

- (void)toggleCollapsed {
    self.collapsed = !self.collapsed;
    [self updateCollapsedState];
    if (self.collapseDidChange) self.collapseDidChange();
}

- (void)updateCollapsedState {
    self.titleControl.disclosureImageView.image = self.collapsed
        ? NSImageMake(@"icon_arrow_right") : NSImageMake(@"icon_arrow_down");
    for (PVFlutterInspectorFieldView *view in self.fieldViews) view.hidden = self.collapsed;
    self.subtitleLabel.hidden = YES;
    [self setNeedsLayout:YES];
}

- (void)layout {
    [super layout];
    CGFloat width = NSWidth(self.bounds);
    self.backgroundEffectView.frame = self.bounds;
    self.titleControl.frame = NSMakeRect(0, 0, width, 30);
    if (!self.collapsed) {
        CGFloat y = 35;
        for (PVFlutterInspectorFieldView *view in self.fieldViews) {
            CGFloat fieldWidth = MAX(0, width - PVFlutterPanelInset * 2);
            CGFloat height = [view sizeThatFits:NSMakeSize(fieldWidth, CGFLOAT_MAX)].height;
            view.frame = NSMakeRect(PVFlutterPanelInset, y, fieldWidth, height);
            y = NSMaxY(view.frame) + PVFlutterFieldSpacing;
        }
    }
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    CGFloat height = 30;
    if (!self.collapsed) {
        height = 35;
        CGFloat fieldWidth = MAX(0, limitedSize.width - PVFlutterPanelInset * 2);
        for (PVFlutterInspectorFieldView *view in self.fieldViews) {
            height += [view sizeThatFits:NSMakeSize(fieldWidth, CGFLOAT_MAX)].height;
            height += PVFlutterFieldSpacing;
        }
        if (self.fieldViews.count) height -= PVFlutterFieldSpacing;
        height += 12;
    }
    limitedSize.height = height;
    return limitedSize;
}

@end

@interface PVFlutterInspectorHeaderView : PVDetailBaseView
@property(nonatomic, strong) PVDetailVisualEffectView *backgroundEffectView;
@property(nonatomic, strong) PVDetailDashboardCardTitleControl *titleControl;
@property(nonatomic, strong) PVDetailLabel *titleLabel;
@property(nonatomic, strong) PVDetailLabel *kindLabel;
@property(nonatomic, strong) NSArray<PVDetailLabel *> *prefixLabels;
@property(nonatomic, strong) NSArray<PVDetailLabel *> *typeLabels;
@property(nonatomic, strong) PVDetailBaseView *capabilitiesBackground;
@property(nonatomic, strong) PVDetailLabel *capabilitiesLabel;
@property(nonatomic, strong) PVFlutterInspectorPresentation *presentation;
@end

@implementation PVFlutterInspectorHeaderView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.layer.cornerRadius = DashboardCardCornerRadius;
        self.layer.masksToBounds = YES;
        self.backgroundEffectView = [PVDetailVisualEffectView new];
        self.backgroundEffectView.blendingMode = NSVisualEffectBlendingModeWithinWindow;
        self.backgroundEffectView.state = NSVisualEffectStateActive;
        [self addSubview:self.backgroundEffectView];

        self.titleControl = [PVDetailDashboardCardTitleControl new];
        self.titleControl.label.stringValue = @"Flutter Widget";
        self.titleControl.iconImageView.image = NSImageMake(@"dashboard_custom");
        self.titleControl.disclosureImageView.hidden = YES;
        [self addSubview:self.titleControl];

        self.titleLabel = [PVDetailLabel new];
        self.titleLabel.font = [NSFont systemFontOfSize:13 weight:NSFontWeightSemibold];
        self.titleLabel.textColor = NSColor.labelColor;
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self addSubview:self.titleLabel];
        self.kindLabel = [PVDetailLabel new];
        self.kindLabel.font = [NSFont systemFontOfSize:10];
        self.kindLabel.textColor = NSColor.secondaryLabelColor;
        [self addSubview:self.kindLabel];

        NSMutableArray *prefixes = [NSMutableArray array];
        NSMutableArray *types = [NSMutableArray array];
        for (NSString *prefix in @[@"Element", @"Render"]) {
            PVDetailLabel *prefixLabel = [PVDetailLabel new];
            prefixLabel.stringValue = prefix;
            prefixLabel.font = [NSFont systemFontOfSize:10.5];
            prefixLabel.textColor = NSColor.secondaryLabelColor;
            [self addSubview:prefixLabel];
            [prefixes addObject:prefixLabel];
            PVDetailLabel *typeLabel = [PVDetailLabel new];
            typeLabel.font = [NSFont monospacedSystemFontOfSize:10 weight:NSFontWeightRegular];
            typeLabel.textColor = NSColor.labelColor;
            typeLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
            [self addSubview:typeLabel];
            [types addObject:typeLabel];
        }
        self.prefixLabels = prefixes.copy;
        self.typeLabels = types.copy;

        self.capabilitiesBackground = [PVDetailBaseView new];
        self.capabilitiesBackground.backgroundColorName = @"DashboardCardValueBGColor";
        self.capabilitiesBackground.layer.cornerRadius = 4;
        [self addSubview:self.capabilitiesBackground];
        self.capabilitiesLabel = [PVDetailLabel new];
        self.capabilitiesLabel.font = [NSFont systemFontOfSize:10];
        self.capabilitiesLabel.textColor = NSColor.secondaryLabelColor;
        self.capabilitiesLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.capabilitiesBackground addSubview:self.capabilitiesLabel];
    }
    return self;
}

- (void)setPresentation:(PVFlutterInspectorPresentation *)presentation {
    _presentation = presentation;
    self.titleLabel.stringValue = presentation.widgetType ?: @"Flutter Widget";
    self.kindLabel.stringValue = [NSString stringWithFormat:@"%@ widget",
                                  presentation.nodeKind.capitalizedString ?: @"Flutter"];
    self.typeLabels[0].stringValue = presentation.elementType ?: @"Unknown";
    self.typeLabels[1].stringValue = presentation.renderObjectType ?: @"Unknown";
    self.titleControl.iconImageView.image = [self iconForKind:presentation.nodeKind];
    self.capabilitiesLabel.stringValue = presentation.capabilities.count
        ? [presentation.capabilities componentsJoinedByString:@"  ·  "] : @"No capabilities";
    [self setNeedsLayout:YES];
}

- (NSImage *)iconForKind:(NSString *)kind {
    NSString *name = @"square.3.layers.3d";
    if ([kind isEqual:@"text"]) name = @"textformat";
    else if ([kind isEqual:@"image"]) name = @"photo";
    else if ([kind isEqual:@"control"]) name = @"slider.horizontal.3";
    else if ([kind isEqual:@"scroll"]) name = @"scroll";
    else if ([kind isEqual:@"spacing"] || [kind isEqual:@"layout"]) name = @"rectangle.3.group";
    return [NSImage imageWithSystemSymbolName:name accessibilityDescription:@"Flutter node"] ?: NSImageMake(@"dashboard_custom");
}

- (void)layout {
    [super layout];
    CGFloat width = NSWidth(self.bounds);
    self.backgroundEffectView.frame = self.bounds;
    self.titleControl.frame = NSMakeRect(0, 0, width, 30);
    self.titleLabel.frame = NSMakeRect(PVFlutterPanelInset, 35,
                                       MAX(0, width - PVFlutterPanelInset * 2), 18);
    self.kindLabel.frame = NSMakeRect(PVFlutterPanelInset, 53,
                                      MAX(0, width - PVFlutterPanelInset * 2), 14);
    [self.prefixLabels enumerateObjectsUsingBlock:^(PVDetailLabel *label, NSUInteger index, BOOL *stop) {
        CGFloat y = 72 + index * 19;
        label.frame = NSMakeRect(PVFlutterPanelInset, y, 48, 15);
        self.typeLabels[index].frame = NSMakeRect(58, y, MAX(0, width - 68), 15);
    }];
    self.capabilitiesBackground.frame = NSMakeRect(PVFlutterPanelInset, 112,
                                                   MAX(0, width - PVFlutterPanelInset * 2), 24);
    self.capabilitiesLabel.frame = NSInsetRect(self.capabilitiesBackground.bounds, 7, 4);
}

- (NSSize)sizeThatFits:(NSSize)limitedSize {
    limitedSize.height = 148;
    return limitedSize;
}

@end

@interface PVFlutterInspectorTabBar : PVDetailBaseView
@property(nonatomic, strong) NSSegmentedControl *segmentedControl;
@property(nonatomic) PVFlutterInspectorDomain selectedDomain;
@property(nonatomic, copy) void (^selectionDidChange)(PVFlutterInspectorDomain domain);
@end

@implementation PVFlutterInspectorTabBar

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.segmentedControl = [NSSegmentedControl segmentedControlWithLabels:@[@"Widget", @"Render", @"Debug"]
                                                                   trackingMode:NSSegmentSwitchTrackingSelectOne
                                                                         target:self
                                                                         action:@selector(selectDomain:)];
        self.segmentedControl.segmentStyle = NSSegmentStyleRounded;
        self.segmentedControl.controlSize = NSControlSizeSmall;
        self.segmentedControl.selectedSegment = 0;
        self.segmentedControl.toolTip = @"Choose Flutter inspector data";
        [self addSubview:self.segmentedControl];
    }
    return self;
}

- (void)setSelectedDomain:(PVFlutterInspectorDomain)selectedDomain {
    _selectedDomain = selectedDomain;
    self.segmentedControl.selectedSegment = selectedDomain;
}

- (void)selectDomain:(NSSegmentedControl *)sender {
    self.selectedDomain = (PVFlutterInspectorDomain)sender.selectedSegment;
    if (self.selectionDidChange) self.selectionDidChange(self.selectedDomain);
}

- (void)layout {
    [super layout];
    self.segmentedControl.frame = self.bounds;
}

@end

@interface PVDetailFlutterViewController ()
@property(nonatomic, strong) PVFlutterInspectorHeaderView *headerView;
@property(nonatomic, strong) PVFlutterInspectorTabBar *domainControl;
@property(nonatomic, strong) NSScrollView *scrollView;
@property(nonatomic, strong) PVDetailBaseView *documentView;
@property(nonatomic, strong) PVDetailLabel *emptyLabel;
@property(nonatomic, strong) PVFlutterInspectorPresentation *presentation;
@property(nonatomic, copy) NSArray<PVFlutterInspectorSectionView *> *sectionViews;
@property(nonatomic, strong) NSMapTable<PVDisplayItem *, PVFlutterInspectorPresentationCacheEntry *> *presentationCache;
@property(nonatomic, copy) NSString *detailSignature;
@property(nonatomic) NSUInteger reloadGeneration;
@property(nonatomic) PVFlutterInspectorDomain selectedDomain;
@end

@implementation PVDetailFlutterViewController

- (NSView *)makeContainerView {
    PVDetailBaseView *root = [[PVDetailBaseView alloc] initWithFrame:NSMakeRect(0, 0, PVFlutterInspectorPanelWidth, 500)];
    root.backgroundColor = NSColor.windowBackgroundColor;
    root.borderPosition = PVDetailViewBorderPositionLeft;

    self.selectedDomain = PVFlutterInspectorDomainWidget;
    self.presentationCache = [NSMapTable weakToStrongObjectsMapTable];
    self.headerView = [PVFlutterInspectorHeaderView new];

    self.domainControl = [PVFlutterInspectorTabBar new];
    self.domainControl.selectedDomain = self.selectedDomain;
    __weak typeof(self) weakSelf = self;
    self.domainControl.selectionDidChange = ^(PVFlutterInspectorDomain domain) {
        weakSelf.selectedDomain = domain;
        [weakSelf reloadSelectedDomainResetScroll:YES];
    };
    [root addSubview:self.domainControl];

    self.documentView = [PVDetailBaseView new];
    [self.documentView addSubview:self.headerView];
    self.scrollView = [NSScrollView new];
    self.scrollView.hasVerticalScroller = YES;
    self.scrollView.hasHorizontalScroller = NO;
    self.scrollView.autohidesScrollers = YES;
    self.scrollView.drawsBackground = NO;
    self.scrollView.contentView.documentView = self.documentView;
    [root addSubview:self.scrollView];

    self.emptyLabel = [PVDetailLabel new];
    self.emptyLabel.stringValue = NSLocalizedString(@"Select a Flutter widget to inspect it.", nil);
    self.emptyLabel.font = [NSFont systemFontOfSize:13];
    self.emptyLabel.textColor = NSColor.secondaryLabelColor;
    self.emptyLabel.alignment = NSTextAlignmentCenter;
    [root addSubview:self.emptyLabel];
    return root;
}

- (void)setDetail:(PVFlutterNodeDetail *)detail {
    NSString *signature = [self presentationSignatureForItem:self.displayItem detail:detail];
    if (_detail == detail && [self.detailSignature isEqualToString:signature]) return;
    _detail = detail;
    self.detailSignature = signature;
    [self scheduleReloadDetail];
}

- (void)setDisplayItem:(PVDisplayItem *)displayItem {
    PVFlutterNodeDetail *detail = displayItem.flutterDetail;
    NSString *signature = [self presentationSignatureForItem:displayItem detail:detail];
    if (_displayItem == displayItem && _detail == detail &&
        [self.detailSignature isEqualToString:signature]) {
        return;
    }
    _displayItem = displayItem;
    _detail = detail;
    self.detailSignature = signature;
    [self scheduleReloadDetail];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadDetail];
}

- (void)viewDidLayout {
    [super viewDidLayout];
    [self layoutPanel];
}

- (void)reloadDetail {
    if (!NSThread.isMainThread) {
        [self scheduleReloadDetail];
        return;
    }
    PVDisplayItem *item = self.displayItem;
    BOOL hasDetail = item.pv_isFlutterItem && (self.detail || item.flutterDetail);
    self.emptyLabel.hidden = hasDetail;
    self.headerView.hidden = !hasDetail;
    self.domainControl.hidden = !hasDetail;
    self.scrollView.hidden = !hasDetail;
    if (!hasDetail) {
        self.presentation = nil;
        [self reloadSelectedDomainResetScroll:NO];
        [self layoutPanel];
        return;
    }
    PVFlutterNodeDetail *detail = self.detail ?: item.flutterDetail;
    NSString *signature = [self presentationSignatureForItem:item detail:detail];
    PVFlutterInspectorPresentationCacheEntry *entry = [self.presentationCache objectForKey:item];
    if (![entry.signature isEqualToString:signature]) {
        entry = [PVFlutterInspectorPresentationCacheEntry new];
        entry.signature = signature;
        entry.presentation = [PVFlutterInspectorPresentationBuilder presentationForItem:item detail:detail];
        [self.presentationCache setObject:entry forKey:item];
    }
    self.presentation = entry.presentation;
    self.headerView.presentation = self.presentation;
    self.domainControl.selectedDomain = self.selectedDomain;
    [self reloadSelectedDomainResetScroll:YES];
}

- (void)reloadSelectedDomainResetScroll:(BOOL)resetScroll {
    NSArray *sectionModels = self.presentation.sectionsByDomain[@(self.selectedDomain)] ?: @[];
    NSMutableArray<PVFlutterInspectorSectionView *> *views = self.sectionViews.mutableCopy;
    if (!views) views = [NSMutableArray arrayWithCapacity:sectionModels.count];
    __weak typeof(self) weakSelf = self;
    [sectionModels enumerateObjectsUsingBlock:^(PVFlutterInspectorSectionModel *model, NSUInteger index, BOOL *stop) {
        PVFlutterInspectorSectionView *view = index < views.count ? views[index] : nil;
        if (!view) {
            view = [PVFlutterInspectorSectionView new];
            [self.documentView addSubview:view];
            [views addObject:view];
        }
        view.model = model;
        view.collapseDidChange = ^{
            [weakSelf layoutPanel];
        };
    }];
    while (views.count > sectionModels.count) {
        [views.lastObject removeFromSuperview];
        [views removeLastObject];
    }
    self.sectionViews = views.copy;
    [self layoutPanel];
    if (resetScroll && !self.scrollView.hidden) {
        [self.scrollView.contentView scrollToPoint:NSZeroPoint];
        [self.scrollView reflectScrolledClipView:self.scrollView.contentView];
    }
}

- (void)scheduleReloadDetail {
    if (!NSThread.isMainThread) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self scheduleReloadDetail]; });
        return;
    }
    if (!self.isViewLoaded) return;
    NSUInteger generation = ++self.reloadGeneration;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.016 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        if (generation != self.reloadGeneration || !self.isViewLoaded) return;
        [self reloadDetail];
    });
}

- (NSString *)presentationSignatureForItem:(PVDisplayItem *)item
                                     detail:(PVFlutterNodeDetail *)detail {
    if (!item) return @"none";
    return [NSString stringWithFormat:
            @"%p|%p|%@|%@|%@|%@|%lu|%.4f,%.4f,%.4f,%.4f|%.4f,%.4f|%lu|%.4f|%d|%d|%d|%d|%lu|%lu|%lu",
            item, detail,
            item.displayName ?: @"", item.viewClassName ?: @"", item.layerClassName ?: @"",
            item.backgroundColorText ?: @"", (unsigned long)detail.rawJSON.hash,
            item.frame.origin.x, item.frame.origin.y, item.frame.size.width, item.frame.size.height,
            item.bounds.size.width, item.bounds.size.height,
            (unsigned long)item.subitems.count, item.alpha, item.hidden,
            item.shouldCaptureImage, item.soloScreenshot != nil, item.groupScreenshot != nil,
            (unsigned long)detail.sections.count, (unsigned long)detail.layoutGroups.count,
            (unsigned long)detail.capabilities.count];
}

- (void)layoutPanel {
    CGFloat width = NSWidth(self.view.bounds);
    CGFloat height = NSHeight(self.view.bounds);
    CGFloat topInset = self.view.safeAreaInsets.top;
    self.emptyLabel.frame = NSMakeRect(24, topInset + 24,
                                       MAX(0, width - 48),
                                       MAX(0, height - topInset - 48));
    if (self.headerView.hidden) return;

    self.domainControl.frame = NSMakeRect(PVFlutterPanelInset, topInset + 10,
                                          MAX(0, width - PVFlutterPanelInset * 2), 24);
    CGFloat scrollY = NSMaxY(self.domainControl.frame) + 9;
    self.scrollView.frame = NSMakeRect(0, scrollY, width, MAX(0, height - scrollY));

    CGFloat documentWidth = MAX(0, NSWidth(self.scrollView.contentView.bounds));
    CGFloat sectionWidth = MAX(120, documentWidth - PVFlutterPanelInset * 2);
    CGFloat y = 10;
    CGFloat headerHeight = [self.headerView sizeThatFits:NSMakeSize(sectionWidth, CGFLOAT_MAX)].height;
    self.headerView.frame = NSMakeRect(PVFlutterPanelInset, y, sectionWidth, headerHeight);
    y = NSMaxY(self.headerView.frame) + PVFlutterSectionSpacing;
    for (PVFlutterInspectorSectionView *view in self.sectionViews) {
        CGFloat sectionHeight = [view sizeThatFits:NSMakeSize(sectionWidth, CGFLOAT_MAX)].height;
        view.frame = NSMakeRect(PVFlutterPanelInset, y, sectionWidth, sectionHeight);
        y = NSMaxY(view.frame) + PVFlutterSectionSpacing;
    }
    CGFloat documentHeight = MAX(NSHeight(self.scrollView.contentView.bounds), y + PVFlutterPanelInset);
    self.documentView.frame = NSMakeRect(0, 0, documentWidth, documentHeight);
}

@end
