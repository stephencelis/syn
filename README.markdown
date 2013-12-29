# syn

Syntax control for the command line.

**syn** uses OS X's natural language processing tools to tokenize and
highlight text (from standard input) that matches specified tags.

<img src='doc/demo.gif' alt='(Animated demo)'/>

Inspired by [iA Writer Pro][1].

[1]: http://writer.pro

## Install

**syn** requires OS X 10.7 or above.

``` sh
$ curl -Ls https://github.com/stephencelis/syn/releases/download/v0.2.0/syn > syn && \
  chmod 755 syn && \
  mv syn /usr/local/bin
```

Or clone/download the repository and run `make install` (**syn** uses
[CocoaPods][2], which you may need to install first).

[2]: http://cocoapods.org

## Usage

_E.g._,

``` sh
# find pesky adverbs
$ syn --adverbs < nanowrimo.txt
# highlight nouns and noun-likes
$ syn --nouns --pronouns --personal-names --place-names < nanowrimo.txt
# peruse the classics
$ curl -Ls http://www.gutenberg.org/ebooks/11231.txt.utf-8 | \
  syn -A | \
  less -r
# generate listicles
$ syn -a -ftable < moby-dick.txt | \
  cut -d ' ' -f4 | sort -f | uniq -ci | sort -nr | head -10 | tr a-z A-Z
 441 OLD
 430 OTHER
 305 SUCH
 290 GREAT
 275 LAST
 238 LITTLE
 215 SAME
 199 OWN
 199 GOOD
 191 WHITE
```

_-h_,

```
usage: syn [tags] [-f <formatter=ansi>] [-vh]
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

Configuration:
    -f, --formatter                  One of 'ansi', 'table', or 'json'

    -v, --version                    Show version
    -h, --help                       Show this screen
```

## License

**syn** is available under the MIT license. See the LICENSE file for
more information.

