//
//  main.m
//  syn
//
//  Created by Stephen Celis on 12/23/13.
//  Copyright (c) 2013 stephencelis. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        NSMutableSet *tags = [NSMutableSet new];

        static char const * VERSION = "0.0.1";
        static char const * OPTSTRING = "nVaANdpPciCIoHlvh";

        void (^version)() = ^{
            fprintf(stderr, "%s\n", VERSION);
            exit(EXIT_SUCCESS);
        };

        void (^usage)() = ^{
            fprintf(stderr, "usage: %s [-%s]\n", argv[0], OPTSTRING);
            exit(EXIT_FAILURE);
        };

        int ch;
        while ((ch = getopt(argc, (char **)argv, OPTSTRING)) != -1) {
            switch (ch) {
                case 'n':
                    [tags addObject:NSLinguisticTagNoun];
                    break;
                case 'V':
                    [tags addObject:NSLinguisticTagVerb];
                    break;
                case 'a':
                    [tags addObject:NSLinguisticTagAdjective];
                    break;
                case 'A':
                    [tags addObject:NSLinguisticTagAdverb];
                    break;
                case 'N':
                    [tags addObject:NSLinguisticTagPronoun];
                    break;
                case 'd':
                    [tags addObject:NSLinguisticTagDeterminer];
                    break;
                case 'p':
                    [tags addObject:NSLinguisticTagParticle];
                    break;
                case 'P':
                    [tags addObject:NSLinguisticTagPreposition];
                    break;
                case 'c':
                    [tags addObject:NSLinguisticTagConjunction];
                    break;
                case 'i':
                    [tags addObject:NSLinguisticTagInterjection];
                    break;
                case 'C':
                    [tags addObject:NSLinguisticTagClassifier];
                    break;
                case 'I':
                    [tags addObject:NSLinguisticTagIdiom];
                    break;
                case 'o':
                    [tags addObject:NSLinguisticTagOtherWord];
                    break;
                case 'H':
                    [tags addObject:NSLinguisticTagPersonalName];
                    break;
                case 'l':
                    [tags addObject:NSLinguisticTagPlaceName];
                    break;
                case 'v':
                    version();
                    break;
                case 'h':
                default:
                    usage();
            }
        }
        argc -= optind;
        argv += optind;

        if (![tags count]) {
            usage();
        }

        NSFileHandle *input = [NSFileHandle fileHandleWithStandardInput];
        NSFileHandle *output = [NSFileHandle fileHandleWithStandardOutput];

        NSData *inputData = [NSData dataWithData:[input readDataToEndOfFile]];
        NSString *inputString = [[NSString alloc] initWithData:inputData encoding:NSUTF8StringEncoding];

        NSMutableString *outputString = [inputString mutableCopy];

        NSLinguisticTaggerOptions options = NSLinguisticTaggerOmitWhitespace | NSLinguisticTaggerOmitPunctuation | NSLinguisticTaggerJoinNames;
        NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:[NSLinguisticTagger availableTagSchemesForLanguage:[[NSLocale preferredLanguages] firstObject]] options:options];

        NSString *normalizedString = [[inputString stringByReplacingOccurrencesOfString:@"\n\n" withString:@". "] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];

        tagger.string = normalizedString;

        __block NSUInteger offset = 0;
        static NSString *const imageEscape = @"\033[7m";
        static NSString *const resetEscape = @"\033[0m";
        [tagger enumerateTagsInRange:NSMakeRange(0, [inputString length]) scheme:NSLinguisticTagSchemeNameTypeOrLexicalClass options:options usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {

            if ([tags containsObject:tag]) {
                [outputString insertString:imageEscape atIndex:tokenRange.location + offset];
                offset += [imageEscape length];
                [outputString insertString:resetEscape atIndex:tokenRange.location + tokenRange.length + offset];
                offset += [resetEscape length];
            }
        }];

        [output writeData:[outputString dataUsingEncoding:NSUTF8StringEncoding]];
    }

    return EXIT_SUCCESS;
}
