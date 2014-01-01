// BRLOptionParser.m
//
// Copyright (c) 2013 Stephen Celis (<stephen@stephencelis.com>)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "BRLOptionParser.h"
#import <getopt.h>


typedef NS_ENUM(NSUInteger, BRLOptionArgument) {
    BRLOptionArgumentNone = no_argument,
    BRLOptionArgumentRequired = required_argument
};


@interface BRLOption : NSObject

@property (assign) BRLOptionArgument argument;
@property (assign) char * name;
@property (assign) unichar flag;
@property (strong) NSString *description;
@property (copy) id block;

+ (instancetype)optionWithName:(char *)name flag:(unichar)flag description:(NSString *)description block:(BRLOptionParserOptionBlock)block;
+ (instancetype)optionWithName:(char *)name flag:(unichar)flag description:(NSString *)description blockWithArgument:(BRLOptionParserOptionBlockWithArgument)blockWithArgument;

@end


@implementation BRLOption

+ (instancetype)optionWithName:(char *)name flag:(unichar)flag description:(NSString *)description block:(BRLOptionParserOptionBlock)block
{
    BRLOption *option = [[self alloc] initWithName:name flag:flag description:description argument:BRLOptionArgumentNone block:block];
    return option;
}

+ (instancetype)optionWithName:(char *)name flag:(unichar)flag description:(NSString *)description blockWithArgument:(BRLOptionParserOptionBlockWithArgument)blockWithArgument
{
    BRLOption *option = [[self alloc] initWithName:name flag:flag description:description argument:BRLOptionArgumentRequired block:blockWithArgument];
    return option;
}

- (instancetype)initWithName:(char *)name flag:(unichar)flag description:(NSString *)description argument:(BRLOptionArgument)argument block:(id)block
{
    if (self = [super init]) {
        self.argument = argument;
        self.name = name;
        self.flag = flag;
        self.block = block;
        self.description = description;
    }
    return self;
}

@end


@interface BRLOptionParser ()

@property NSMutableArray *options;

@end


@implementation BRLOptionParser

- (id)init
{
    if (self = [super init]) {
        [self setBanner:@"usage: %@ [options]", [[NSProcessInfo processInfo] processName]];
        self.options = [NSMutableArray array];
    }
    return self;
}

- (void)setBanner:(NSString *)banner, ...
{
    va_list args;
    va_start(args, banner);
    _banner = [[NSString alloc] initWithFormat:banner arguments:args];
    va_end(args);
    return;
}

- (void)addOption:(char *)option flag:(unichar)flag description:(NSString *)description block:(BRLOptionParserOptionBlock)block
{
    [self.options addObject:[BRLOption optionWithName:option flag:flag description:description block:block]];
}

- (void)addOption:(char *)option flag:(unichar)flag description:(NSString *)description blockWithArgument:(BRLOptionParserOptionBlockWithArgument)blockWithArgument
{
    [self.options addObject:[BRLOption optionWithName:option flag:flag description:description blockWithArgument:blockWithArgument]];
}

- (void)addOption:(char *)option flag:(unichar)flag description:(NSString *)description value:(BOOL *)value
{
    [self addOption:option flag:flag description:description block:^{
        *value = YES;
    }];
}

- (void)addOption:(char *)option flag:(unichar)flag description:(NSString *)description argument:(NSString *__strong *)argument
{
    [self addOption:option flag:flag description:description blockWithArgument:^(NSString *value) {
        *argument = value;
    }];
}

- (void)addSeparator
{
    [self addSeparator:nil];
}

- (void)addSeparator:(NSString *)separator
{
    if (separator == nil) {
        separator = @"";
    }
    [self.options addObject:separator];
}

- (BOOL)parseArgc:(int)argc argv:(const char **)argv error:(NSError *__autoreleasing *)error
{
    return [self parseArgc:argc argv:argv longOnly:NO error:error];
}

- (BOOL)parseArgc:(int)argc argv:(const char **)argv longOnly:(BOOL)longOnly error:(NSError *__autoreleasing *)error
{
    NSMapTable *mapTable = NSCreateMapTable(NSIntegerMapKeyCallBacks, NSNonRetainedObjectMapValueCallBacks, [self.options count]);

    NSUInteger i = 0;
    NSUInteger c = 0;

    struct option * long_options = malloc(([self.options count] + 1) * sizeof(struct option));
    char * short_options = malloc((([self.options count] * 2) + 1) * sizeof(char));

    for (id each in self.options) {
        if (![each isKindOfClass:[BRLOption class]]) {
            continue;
        }
        BRLOption *option = each;
        if (option.name) {
            NSMapInsert(mapTable, (const void *)option.name, (__bridge void *)option);
            long_options[i++] = (struct option){option.name, option.argument, NULL, option.flag};
        }
        if (option.flag) {
            NSMapInsert(mapTable, (const void *)(NSUInteger)option.flag, (__bridge void *)option);
            short_options[c++] = option.flag;
            if (option.argument == BRLOptionArgumentRequired) {
                short_options[c++] = ':';
            };
        }
    }
    long_options[i] = (struct option){0, 0, 0, 0};
    short_options[c] = '\0';

    int ch = 0;
    int long_options_index = 0;

    opterr = 0;

    int (* getopt_long_method)(int, char * const *, const char *, const struct option *, int *);
    getopt_long_method = longOnly ? &getopt_long_only : &getopt_long;

    int cached_optind = optind;
    while ((ch = getopt_long_method(argc, (char **)argv, short_options, long_options, &long_options_index)) != -1) {
        @try {
            BRLOption *option = nil;

            switch (ch) {
                case '?': {
                    if (error) {
                        // I wish this could be done more cleanly, but getopt doesn't appear to expose the current failing option as originally input.
                        NSString *arg = [NSString stringWithUTF8String:argv[cached_optind]];
                        if ([arg hasPrefix:@"--"]) {
                            arg = [[arg componentsSeparatedByString:@"="] firstObject];
                        } else if (optopt) {
                            arg = [NSString stringWithFormat:@"-%c", optopt];
                        }

                        if (optopt) {
                            option = (__bridge BRLOption *)NSMapGet(mapTable, (const void *)(NSUInteger)optopt);
                        }

                        if (option && option.argument == BRLOptionArgumentRequired) {
                            *error = [NSError errorWithDomain:BRLOptionParserErrorDomain code:BRLOptionParserErrorCodeRequired userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"option `%@' requires an argument", arg]}];
                        } else {
                            *error = [NSError errorWithDomain:BRLOptionParserErrorDomain code:BRLOptionParserErrorCodeUnrecognized userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"unrecognized option `%@'", arg]}];
                        }
                    }
                    return NO;
                    break;
                }
                case ':':

                    break;
                case 0:
                    option = (__bridge BRLOption *)NSMapGet(mapTable, (const void *)long_options[long_options_index].name);
                    break;
                default: {
                    option = (__bridge BRLOption *)NSMapGet(mapTable, (const void *)(NSUInteger)ch);
                    break;
                }
            }

            if (option.argument == BRLOptionArgumentRequired) {
                BRLOptionParserOptionBlockWithArgument block = option.block;
                block([NSString stringWithUTF8String:optarg]);
            } else {
                BRLOptionParserOptionBlock block = option.block;
                block();
            }
        } @finally {
            cached_optind = optind;
        }
    }

    return YES;
}

- (NSString *)description
{
    NSMutableString *(^trimLine)(NSMutableString *) = ^NSMutableString *(NSMutableString *line) {
        NSRange range = [line rangeOfCharacterFromSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet] options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            line = [[line substringToIndex:range.location + 1] mutableCopy];
        }
        return line;
    };

    NSMutableArray *description = [NSMutableArray arrayWithObject:self.banner];
    for (id each in self.options) {
        NSMutableString *line = [NSMutableString string];
        if ([each isKindOfClass:[BRLOption class]]) {
            BRLOption *option = each;
            [line appendString:@"    "];
            if (option.flag) {
                [line appendFormat:@"-%c", option.flag];
                [line appendString:option.name ? @", " : @"  "];
            } else {
                [line appendString:@"    "];
            }
            if (option.name) {
                [line appendFormat:@"--%-24s   ", option.name];
            } else {
                [line appendString:@"                             "];
            }
            if ([line length] > 37) {
                line = trimLine(line);
                [line appendString:@"\n                                     "];
            }
            if (option.description) {
                [line appendString:option.description];
            }
            line = trimLine(line);
        } else {
            [line appendFormat:@"%@", each];
        }
        [description addObject:line];
    }
    return [[description componentsJoinedByString:@"\n"] stringByAppendingString:@"\n"];
}

@end
