# IDE-like Source Code Searcher on Shell for IntelliJ

Since IntelliJ doesn't allow searching multiple directories (related codebases) simultaneously, I have written a [portable script][script] on Bash and Zsh to do the job and unlike other source code searchers on shell, it also provides modern-IDE-like features such as opening the source code file from the search result.

This script currently supports Vim and IntelliJ as the editors for the source code files.

1. If you want to work completely on the shell, then choose Vim
1. If you choose to use IntelliJ, Vim will be used as the pager to show the search result and IntelliJ will be used to open the source code file from the search result.

## Table of content

1. [Why did I make it?](#why-did-i-make-it)
1. [Installation](#installation)
1. [Quick start](#quick-start)
1. [Configuration](#configuration)
1. [Usage details](#usage-details)
    1. [Shell command](#shell-command)
    1. [Vim skills for using this script](#vim-skills-for-using-this-script)
        1. [Basic](#basic)
        1. [Advanced](#advanced)
1. [Tested environment](#tested-environment)


## Why did I make it?

The code searching function of IntelliJ (Community Edition) has below limitation.

![IntelliJ's limitation in source code searching][intellij-search-limit]

This was really a pain to me since I quite often needed to search multiple related codebases siumltaneously. Therefore, I explored for the alternatives that may run on my IntelliJ's terminal to do the job. Below are some of my expectations to the source code searchers.

1. Able to search multiple directories.
1. The format of the search result is designed for source code searching, unlike `grep`.
1. Automatically ignores the build folder, library folder, .git/, .idea/ and etc.
1. IDE-like feature: _**Do not only show the lines of code that contain the keywords, but there should also be a separate window to show the list of files that contains the keywords.**_
1. IDE-like feature: _**May choose to read which file's search result from the above file list.**_
1. IDE-like feature: _**May instantly open the source code file from the search result.**_

Unfortunately, so far what I have found only met the first 3 points. Therefore, I wrote the script.

## Installation

1. Copy and paste the [script][script] into your bashrc or zshrc file, or
1. In your bashrc or zshrc file, `source` this [script][script].

## Quick start

1. Run below command on your Bash or Zsh
    1. Examples:
        ```sh
        # Search dirA and dirB (in your current directory by default) recursively for patternA or patternB
        gp 'regex-of-dirA-partial-name\|regex-of-dirB-partial-name' 'regex-of-patternA\|regex-of-patternB'

        # Search the codebases (in your current directory by default) recursively for patternA and at the same time, ignore the *test (in glob pattern) and resources directories, ignore the *.txt (in glob pattern) files
        gp 'regex-of-codebases-dir-partial-name' 'regex-of-patternA' --exclude-dir={*test, resources} --exclude=*.txt

        # Search all the files and directories (in your current directory by default) recursively for patternA (case-insensitive)
        gp . 'regex-of-patternA' -i
        ```
    1. Syntax: `gp <parts-of-file-and-directory-names> <pattern> [-i|--ignore-case] [-w|--word-regex] [--include=<files>] [--exclude=<files>] [--exclude-dir=<directories>]`
    1. Check [this](#shell-command) for the details
1. The search result will then be rendered on Vim
    1. Glance at its UI
        1. ![Demo][demo]
        1. ![The snapshot of the Vim, with explanation to its structure][vim-structure]
    1. Chooes to read which file's preview
        1. ![How to select a file to preview][select-file-to-preview]
        1. You may actually directly _**CLICK**_ on it with your mouse, instead of pressing `<Enter>`, to open the preview and _**SCROLL**_ to browse if you Vim supports this!
    1. Open the source code file from the search result
        1. ![You may navigate to the source code files to read the whole file and edit][navigate-to-file]
        1. IntelliJ or Vim will be used to load the source code file, depending on your [configuration](#configuration)
        1. Check the (7) in [this](#basic) to learn more about `\gp`
    1. Jump to the next / previous occurrence of the keywords (the `<pattern>` specified in your shell command)
        1. ![`n` to jump to the next keywords occurrence][quick-jump-to-next-keywords-occurrence]
        1. Check the (6)(iii) in [this](#basic) to learn more about `n`
    1. The last searched pattern on Vim are actually highlighted
        1. ![Your last searched pattern on Vim are actually highlighted][last-searched-pattern-highlighted]
        1. Check the (8) in [this](#basic) to learn how to turn off the highlighting
    1. Check [this](#vim-skills-for-using-this-script) to learn more about how to use Vim

## Configuration

Modify below configuration in the [script][script] if you want or need to.

```sh
MAPPED_KEY_TO_NAVIGATE_TO_FILES='<Leader>gp' # change this value if it has a conflict with your Vim setting
ENCODING='utf-8' # change this value if the encoding is not UTF-8
```

```sh
## You may temporarily modify below configurable parameters on your shell before executing the search, e.g. `GP_MAXDEPTH=2; gp x x`,
## or permanently by modifying their values in this script
GP_SOURCE_CODE_FILE_EDITOR='vim' # supported values: vim, intellij
GP_SOURCE_CODE_FILE_EDITOR_LAUNCHER_PATH='' # leave it an empty value if you use Vim
GP_NUM_OF_CTX_LINES=10 # the number of lines to show before and after matches of the keywords
GP_MAXDEPTH=1 # the depth of directories to search for <parts-of-file-and-directory-names>, e.g. 1 value to search only current directory for <parts-of-file-and-directory-names>
GP_EXCLUDE_DIR=('lib' 'libs' 'build' 'bin' '.?*')
GP_EXCLUDE=('png' 'jpeg' 'jpg' 'tif' 'tiff' 'bmp' 'gif' 'eps' 'raw' 'cr2' 'nef' 'orf' 'sr2' 'swo' 'swp' '?*~' 'lib' 'dll' 'a' 'o' 'class' 'jar')
GP_SEARCH_RESULT_FILENAME='GP_SEARCH_RESULT.txt' # the file generated to temporarily store the search result
```

Configuration for setting IntelliJ the source code file editor:
1. Check [this][intellij-launcher-tutorial] to learn more about how to set `SOURCE_CODE_FILE_EDITOR_LAUNCHER_PATH` for IntelliJ.
1. If you are a Mac user, you may need to search about how to create the IntelliJ command-line launcher in your environment.
1. Examples
    1. Windows > Git Bash
        1. `SOURCE_CODE_FILE_EDITOR_LAUNCHER_PATH='/c/Program\ Files/JetBrains/IntelliJ\ IDEA\ Community\ Edition\ 2021.3.1/bin/idea64.exe'`
    1. MacOS > Zsh
        1. `SOURCE_CODE_FILE_EDITOR_LAUNCHER_PATH='/Applications/JetBrains\ Toolbox.app/Contents/idea'`
        1. Please note that you need to firstly create your command-line launcher


## Usage details

### Shell command

```sh
gp <parts-of-file-and-directory-names> <pattern> [-i|--ignore-case] [-w|--word-regex] [--include=<files>] [--exclude=<files>] [--exclude-dir=<directories>]
```

1. `<parts-of-file-and-directory-names>`
    1. A string of regex.
    1. It defines what to search in your current working directory.
1. `<pattern>`
    1. A string of regex.
    1. It defines the pattern to search for.
1. `[-i|--ignore-case]`
    1. An option to make the `<pattern>` search case-insensitive.
1. `[-w|--word-regex]`
    1. An option to request that the `<pattern>` has to match the full (not partial) word to produce a match.
1. `[--include=<files>] [--exclude=<files>] [--exclude-dir=<directories>]`
    1. This script makes use of `grep` to do the search.
    1. The above options will be passed to `grep`.
    1. You may check your `grep` manual to learn more about these options.
    1. Please note that the behaviour of `grep` in response to these arguments varies with different shells.

### Vim skills for using this script

#### Basic

1. A brief idea about [normal mode, command mode and insert mode][vim-modes-tutorial]
1. Cursor movement
    1. One-line movement in normal mode
        1. `h` for left, `j` for downward, `k` for upward, `l` for right
    1. Page-wise movement in normal mode
        1. `<ctrl-d>` for half page downward, `<ctrl-u>` for half page upward
1. Move to another window, e.g. from the file list window to the preview window
    1. `<ctrl-w>` then `h` or `j` or `k` or `l` in normal mode to move to the surrounding window
1. Exit Vim
    1. `:qa` to leave Vim
    1. `:qa!` to leave Vim forcefully and your unsaved changes will be abandoned
1. Select a file in the file list and show its preview
    1. In the file list, move your cursor to the file and press `<Enter>`
1. Search through the previews
    1. Go to the preview window
    1. `/<regex-pattern>` to search forward, `?<regex-pattern>` backward
    1. `n` to repeat the last search, `N` the last search in a reverse order
    1. Check [this][vim-search-tutorial] for more information
1. Navigate to the souce code files that you want to learn more
    1. Go to the preview window
    1. Go to the line of code you are interested in
    1. Type `<Leader>gp` in normal mode
        1. `<Leader>` in Vim by default means `\`
        1. `<Leader>gp` means `\gp` by default
    1. Afterwards, it will bring you to that line of code
    1. If you use Vim as the source code file editor, `<ctrl-6>` in normal mode to go back to the preview
1. `:nohlsearch` (or `:noh`) to turn off the last searched pattern's highlighting

#### Advanced

1. Jump to the next or previous file's preview when you are in the preview window
    1. `{` and `}` in normal mode
1. Jump to the 1st line / the last line
    1. `gg` to the 1st line and `G` to the last line
1. Preview the next or previous file in the file list, regardless of where you are on Vim
    1. `:cnext` (or `:cn`) to preview the next file, `:cprevious` (or `:cp`) the previous file
1. Close and open the file catalouge
    1. `:cclose` (or `:ccl`) to close, `:copen` (or `:cope`) to open
1. Show multiple file previews at the same time
    1. `:vsplit` (or `:vs`) in the preview window to create a vertical split window to view the previews
    1. `:split` (or `:sp`) to make a horizontal split window
    1. `<ctrl-w>q` to close the current window
1. Make your current line at the top / center / bottom of your screen
    1. In normal mode, `zt` to make your current line at the screen top, `zz` the center, `zb` the bottom
1. Bookmark your preview
    1. In normal mode, `m` to mark and backtick to go back to that marked location
    1. Check [this][vim-mark-tutorial] for more information

## Tested environment

1. macOS Monterey version 12.0.1
    1. zsh 5.8 (x86_64-apple-darwin21.0)
    1. GNU bash, version 3.2.57(1)-release (arm64-apple-darwin21)
    1. VIM - Vi IMproved 8.2 (2019 Dec 12, compiled Sep 26 2021 21:11:52), macOS version - arm64, Included patches: 1-3458, Compiled by Homebrew
1. Git Bash
    1. GNU bash, version 4.4.23(1)-release (x86_64-pc-msys)
    1. VIM - Vi IMproved 8.2 (2019 Dec 12, compiled Sep 21 2021 16:13:20), Included patches: 1-3441, Compiled by \<https://www.msys2.org/>

[script]: <script.sh>

[demo]: <docs/demo.gif>
[intellij-search-limit]: <docs/intellij-search-limitation.png>
[last-searched-pattern-highlighted]: <docs/last-searched-pattern-highlighted.png>
[quick-jump-to-next-keywords-occurrence]: <docs/quick-jump-to-next-keywords-occurrence.png>
[navigate-to-file]: <docs/navigate-to-file.png>
[select-file-to-preview]: <docs/select-file-to-preview.png>
[vim-structure]: <docs/vim-structure.png>

[intellij-launcher-tutorial]: <https://www.jetbrains.com/help/idea/opening-files-from-command-line.html>
[vim-mark-tutorial]: <https://vim.fandom.com/wiki/Using_marks>
[vim-modes-tutorial]: <https://www.freecodecamp.org/news/vim-editor-modes-explained/>
[vim-search-tutorial]: <https://linuxize.com/post/vim-search/>
