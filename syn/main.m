// main.m
// syn
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

#import <Foundation/Foundation.h>

#import <BRLOptionParser/BRLOptionParser.h>

#import "SYNProcessor.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool {

        // constants

        NSString *processName = [[NSProcessInfo processInfo] processName];
        static NSString *const VERSION = @"0.0.1";

        // configuration

        NSMutableSet *tags = [NSMutableSet new];
        NSString *format = SYNTerminalFormat;

        // std{in,out,err}

        NSFileHandle *standardInput = [NSFileHandle fileHandleWithStandardInput];
        NSFileHandle *standardOutput = [NSFileHandle fileHandleWithStandardOutput];
        NSFileHandle *standardError = [NSFileHandle fileHandleWithStandardError];

        // options

        BRLOptionParser *optionParser = [BRLOptionParser new];

        [optionParser setBanner:@"usage: %@ [tags] [-f <formatter=term>] [-vh]", processName];

        BRLOptionParserOptionBlock (^add)(NSString *) = ^(NSString *tag) {
            return ^{ [tags addObject:tag]; };
        };

        [optionParser addSeparator:@"Tags:"];
        [optionParser addOption:"nouns" flag:'n' description:@"Match nouns" block:add(NSLinguisticTagNoun)];
        [optionParser addOption:"verbs" flag:'V' description:@"Match verbs" block:add(NSLinguisticTagVerb)];
        [optionParser addOption:"adjectives" flag:'a' description:@"Match adjectives" block:add(NSLinguisticTagAdjective)];
        [optionParser addOption:"adverbs" flag:'A' description:@"Match adverbs" block:add(NSLinguisticTagAdverb)];
        [optionParser addOption:"pronouns" flag:'N' description:@"Match pronouns" block:add(NSLinguisticTagPronoun)];
        [optionParser addOption:"determiners" flag:'d' description:@"Match determiners" block:add(NSLinguisticTagDeterminer)];
        [optionParser addOption:"particles" flag:'p' description:@"Match particles" block:add(NSLinguisticTagParticle)];
        [optionParser addOption:"prepositions" flag:'P' description:@"Match prepositions" block:add(NSLinguisticTagPreposition)];
        [optionParser addOption:"numbers" flag:'1' description:@"Match numbers" block:add(NSLinguisticTagNumber)];
        [optionParser addOption:"conjunctions" flag:'c' description:@"Match conjunctions" block:add(NSLinguisticTagConjunction)];
        [optionParser addOption:"interjections" flag:'i' description:@"Match interjections" block:add(NSLinguisticTagInterjection)];
        [optionParser addOption:"classifiers" flag:'C' description:@"Match classifiers" block:add(NSLinguisticTagClassifier)];
        [optionParser addOption:"idioms" flag:'I' description:@"Match idioms" block:add(NSLinguisticTagIdiom)];

        [optionParser addOption:"personal-names" flag:'H' description:@"Match personal (human) names" block:add(NSLinguisticTagPersonalName)];
        [optionParser addOption:"place-names" flag:'l' description:@"Match place names (locations)" block:add(NSLinguisticTagPlaceName)];

        [optionParser addSeparator];
        [optionParser addSeparator:@"Configuration:"];
        [optionParser addOption:"formatter" flag:'f' description:@"One of 'term' or 'json'" argument:&format];

        [optionParser addSeparator];
        [optionParser addOption:"version" flag:'v' description:@"Show version" block:^{
            [standardOutput writeData:[[NSString stringWithFormat:@"%@\n", VERSION] dataUsingEncoding:NSUTF8StringEncoding]];
            exit(EXIT_SUCCESS);
        }];
        __weak typeof(optionParser) weakOptionParser = optionParser;
        [optionParser addOption:"help" flag:'h' description:@"Show this screen" block:^{
            [standardOutput writeData:[[weakOptionParser description] dataUsingEncoding:NSUTF8StringEncoding]];
            exit(EXIT_SUCCESS);
        }];

        NSError *error = nil;
        [optionParser parse:&error];
        if (error) {
            [standardError writeData:[[NSString stringWithFormat:@"%@: %@\n", processName, [error localizedDescription]] dataUsingEncoding:NSUTF8StringEncoding]];
            exit(EXIT_FAILURE);
        }

        // at least one tag required

        if (![tags count]) {
            [standardError writeData:[[NSString stringWithFormat:@"%@: at least one tag required\n", processName] dataUsingEncoding:NSUTF8StringEncoding]];
            [standardError writeData:[[NSString stringWithFormat:@"%@\n", optionParser.banner] dataUsingEncoding:NSUTF8StringEncoding]];
            exit(EXIT_FAILURE);
        }

        // invalid format

        SYNProcessor *processor = [[SYNProcessor alloc] initWithFormat:format];
        if (processor == nil) {
            [standardError writeData:[[NSString stringWithFormat:@"%@: invalid format `%@'\n", processName, format] dataUsingEncoding:NSUTF8StringEncoding]];
            [standardError writeData:[[NSString stringWithFormat:@"%@\n", optionParser.banner] dataUsingEncoding:NSUTF8StringEncoding]];
            exit(EXIT_FAILURE);
        }

        // read input

        NSData *inputData = [NSData dataWithData:[standardInput readDataToEndOfFile]];
        NSString *inputString = [[NSString alloc] initWithData:inputData encoding:NSUTF8StringEncoding];

        // format output

        NSString *outputString = [processor process:inputString tags:tags];

        [standardOutput writeData:[outputString dataUsingEncoding:NSUTF8StringEncoding]];
    }

    return EXIT_SUCCESS;
}
