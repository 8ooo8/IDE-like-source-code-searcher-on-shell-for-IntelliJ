# Source Code Searcher

This script provides handy functions to search through your source code. This is particularly useful when you need to jump in to update huge codebase(s) that you do not know. This may help you quickly identify which parts of code need an update with a more readable search result.

Note that this short script was intentionally made to be more adaptable to different working environment.
1. Written in Bash, which is commonly available in our working environment.
1. `less` was used instead of `more`.
1. `grep` was used, which basically is available in a Bash shell.

## Usage

![Demo][demo]

```sh
# gp <directories-in-pwd> <pattern> [grep-pattern-option] [num-of-lines-to-show-before-and-after-matches]
```

This script searches through the designated directories for the pattern you are looking for. Afterwards, it will print the search result onto the console. 

The console output begins with the file path in purple color, followed by the file content that matches your keywords. By default, it displays the 20 lines before and after the keywords so that users may quickly identify from context that whether this part of code is in their interest. For a better readability, the keywords are highlighted with red color and the console output is passed to `less`. Moreover, it automatically ignores .*/ (including .git/) , build/, bin/ and the image files.

## Installation

Copy and paste the [script][script] into your bashrc or zshrc file.

## Tested environment

1. zsh 5.8 (x86_64-apple-darwin21.0)
1. GNU bash, version 4.4.23(1)-release (x86_64-pc-msys)

[script]: <script.sh>
[demo]: <docs/demo.gif>
