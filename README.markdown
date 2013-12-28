# syn

Syntax control for the command line.

**syn** uses OS X's natural language processing tools to tokenize and
highlight text (from standard input) that matches specified tags.

<img src='doc/demo.gif' alt='(Animated demo)' height='386' width='590'/>

Inspired by [iA Writer Pro][1].

[1]: http://writer.pro

## Usage

```
usage: syn [tags] [-vh]
Tags:
    -n, --nouns                      Match nouns
    -V, --verbs                      Match verbs
    -a, --adjectives                 Match adjectives
    -A, --adverbs                    Match adverbs
    -N, --pronouns                   Match pronouns
    -d, --determiners                Match determiners
    -p, --particles                  Match particles
    -P, --prepositions               Match prepositions
    -1, --numbers                    Match numbers
    -c, --conjunctions               Match conjunctions
    -i, --interjections              Match interjections
    -C, --classifiers                Match classifiers
    -I, --idioms                     Match idioms
    -H, --personal-names             Match personal (human) names
    -l, --place-names                Match place names (locations)

    -v, --version                    Show version
    -h, --help                       Show this screen
```

## Install

Clone or download the repository, run `pod install` (**syn** uses
[CocoaPods][2]), and build from Xcode.

[2]: http://cocoapods.org

## License

**syn** is available under the MIT license. See the LICENSE file for
more information.

