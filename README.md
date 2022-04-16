# IDE-like Source Code Searcher on Shell

This is a [portable script][script] on Bash and Zsh which provides a modern-IDE-like source code searching function.

## Table of content

1. [Why did I make it?](#why-did-i-make-it)
1. [Installation](#installation)
1. [Quick start](#quick-start)
1. [Usage details](#usage-details)
    1. [Shell command](#shell-command)
    1. [Vim skills for using this script](#vim-skills-for-using-this-script)
        1. [Basic](#basic)
        1. [Advanced](#advanced)
1. [Configuration](#configuration)
1. [Tested environment](#tested-environment)


## Why did I make it?

I coded on IntelliJ because my company had customization on it. However, IntelliJ (Community Edition) has below limitation.

![IntelliJ's limitation in source code searching][intellij-search-limit]

This was really a pain to me. Therefore, I explored for the alternatives that may run on my IntelliJ's terminal to do the job. Below are some of my expectations to the source code searchers.

1. Able to search multiple directories.
1. The format of the search result is designed for source code searching, unlike `grep`.
1. Automatically ignores the build folder, library folder, .git/, .idea/ and etc.
1. IDE-like feature: _**Do not only show the lines of code that contain the keywords, but there should also be a separate window to show the list of files that contains the keywords.**_
1. IDE-like feature: _**When I "click" on the file in the file list, it will bring me to that file or its search result.**_
1. IDE-like feature: _**When I "click" on the line of code where the keyword is found, it will bring me to that file and that line of code.**_

Unfortunately, so far what I have found only met the first 3 points. Therefore, I wrote the script.

## Installation

1. Copy and paste the [script][script] into your bashrc or zshrc file, or
1. In your bashrc or zshrc file, `source` this [script][script].

## Quick start

1. Run below command on your Bash or Zsh.
    1. Examples:
        ```sh
        # Search dirA and dirB (in your current directory by default) recursively for patternA or patternB (case-insensitive)
        gp 'dirA\|dirB' 'patternA\|patternB' -i

        # Search all the files and directories (in your current directory by default) recursively for patternA
        gp . 'patternA'
        ```
    1. Syntax: `gp <parts-of-file-and-directory-names> <pattern> [-i|--ignore-case] [-w|--word-regex] [--include=<files>] [--exclude=<files>] [--exclude-dir=<directories>]`
    1. Check [this](#shell-command) for the details.
1. The search result will then be rendered on Vim.
    1. Demo:
        ![Demo][demo]
        ![The snapshot of the Vim, with explanation to its structure][vim-structure]
        ![How to select a file to preview][select-file-to-preview]
        ![You may navigate to the source code file to read the whole file and edit][navigate-to-file]
    1. Check [this](#vim-skills-for-using-this-script) to learn more about what you may do on Vim.


## Usage details

### Shell command

```sh
gp <parts-of-file-and-directory-names> <pattern> [-i|--ignore-case] [-w|--word-regex] [--include=<files>] [--exclude=<files>] [--exclude-dir=<directories>]
```

1. `<names-of-files-and-directories>`
    1. A string of regex.
    1. It defines what to search in your current working directory.
1. `<pattern>`
    1. A string of regex.
    1. It defines the pattern to search for.
1. `[-i|--ignore-case]`
    1. An option to make the search case-insensitive.
1. `[-w|--word-regex]`
    1. An option to request that the <pattern> has to match the full word to produce a match.
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
    1. Check [this][vim-search-tutorial] for more information
1. Navigate to the file that you want to learn more
    1. Go to the preview window
    1. Go to the line of code you are interested in
    1. Type `<Leader>gp` in normal mode
        1. `<Leader>` in Vim by default means `\`
        1. `<Leader>gp` means `\gp` by default
    1. Afterwards, it will bring you to that line of code and have it placed at the center of your screen
    1. `<ctrl-6>` in normal mode to go back to the preview

#### Advanced

1. Go to the next or previous file preview when you are in the preview window
    1. `{` and `}` in normal mode
1. Preview the next or previous file in the file list, regardless of where you are
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

## Configuration

Open the [script][script] and modify below configuration if you want or need to.

```sh
## You may temporarily modify below configurable parameters on your shell before executing the search, or permanently by modifying their values in this script.
### e.g. GP_MAXDEPTH=2; gp x x;
GP_NUM_OF_CTX_LINES=10 # the number of lines to show before and after matches
GP_MAXDEPTH=1 # the depth of directories to search for <parts-of-file-and-directory-names>, e.g. 1 value to search only current directory for <parts-of-file-and-directory-names>
GP_EXCLUDE_DIR=('lib' 'libs' 'build' 'bin' '.?*')
GP_EXCLUDE=('png' 'jpeg' 'jpg' 'tif' 'tiff' 'bmp' 'gif' 'eps' 'raw' 'cr2' 'nef' 'orf' 'sr2' 'swo' 'swp' '?*~' 'lib' 'dll' 'a' 'o' 'class' 'jar')
GP_SEARCH_RESULT_FILENAME='GP_SEARCH_RESULT.txt' # the file generated to temporarily store the search result
```

```sh
MAPPED_KEY_TO_NAVIGATE_TO_FILES='<Leader>gp' # change this value if it has a conflict with your Vim setting
ENCODING='utf-8' # change this value if the encoding is not UTF-8
```

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
[navigate-to-file]: <docs/navigate-to-file.png>
[select-file-to-preview]: <docs/select-file-to-preview.png>
[vim-structure]: <docs/vim-structure.png>

[vim-mark-tutorial]: <https://vim.fandom.com/wiki/Using_marks>
[vim-modes-tutorial]: <https://www.freecodecamp.org/news/vim-editor-modes-explained/>
[vim-search-tutorial]: <https://linuxize.com/post/vim-search/>
