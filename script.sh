# --- IDE-like-Source-Code-Searcher-on-Shell usage ---
## gp <parts-of-file-and-directory-names> <pattern> [-i|--ignore-case] [-w|--word-regex] [--include=<files>] [--exclude=<files>] [--exclude-dir=<directories>]

# --- IDE-like-Source-Code-Searcher-on-Shell examples ---
## gp 'dirA\|dirB' 'patternA\|patternB' -i # search dirA and dirB (in your current directory by deafult) recursively for patternA or patternB (case-insensitive)
## gp . 'patternA' # search all the files and directories (in your current directory by deafult) recursively for patternA

# --- IDE-like-Source-Code-Searcher-on-Shell's configurable parameters ---
## You may temporarily modify below configurable parameters on your shell before executing the search, e.g. `GP_MAXDEPTH=2; gp x x`,
## or permanently by modifying their values in this script
GP_SOURCE_CODE_FILE_EDITOR='vim' # supported values: vim, intellij
GP_SOURCE_CODE_FILE_EDITOR_LAUNCHER_PATH='' # leave it an empty value if you use Vim
GP_NUM_OF_CTX_LINES=10 # the number of lines to show before and after matches of the keywords
GP_MAXDEPTH=1 # the depth of directories to search for <parts-of-file-and-directory-names>, e.g. 1 value to search only current directory for <parts-of-file-and-directory-names>
GP_EXCLUDE_DIR=('lib' 'libs' 'build' 'bin' '.?*')
GP_EXCLUDE=('png' 'jpeg' 'jpg' 'tif' 'tiff' 'bmp' 'gif' 'eps' 'raw' 'cr2' 'nef' 'orf' 'sr2' 'swo' 'swp' '?*~' 'lib' 'dll' 'a' 'o' 'class' 'jar')
GP_SEARCH_RESULT_FILENAME='GP_SEARCH_RESULT.txt' # the file generated to temporarily store the search result

# --- IDE-like-Source-Code-Searcher-on-Shell ---
function gp
{
    MAPPED_KEY_TO_NAVIGATE_TO_FILES='<Leader>gp' # change this value if it has a conflict with your Vim setting
    ENCODING='utf-8' # change this value if the encoding is not UTF-8

    extraArgumentsToGrep="${@:3}"

    # Commands to pass to Vim, the pager/editor to be used for the search result
    ## Highlight the filepaths, patterns and line numbers in Vim
    patternSearchVimRegex="${2}"
    
    ### Perform a full word search for the pattern highlighting if the arugment -w or --word-regexp is present
    wordRegexArgument=$(printf "%s\n" "${@:3}" | grep '\-w\|\-\-word-regex')
    patternSearchVimRegex=$([ ! -z "${wordRegexArgument}" ] && printf "\\<\\(${patternSearchVimRegex}\\)\\>" || printf "${patternSearchVimRegex}")
    
    ### Perform a case-insensitive search for the pattern highlighting if the arugment -i or --ignore-case is present
    ignoreCaseArgument=$(printf "%s\n" "${@:3}" | grep '\-i\|\-\-ignore-case')
    if [[ ! -z "${ignoreCaseArgument}" ]]; then
        patternSearchVimRegex="\\c${patternSearchVimRegex}"
    fi
    
    ### The finalized highlight commands
    highlightFilepath=':syntax match filepath /\m^File: \zs.*/ | :highlight filepath ctermfg=DarkMagenta guifg=#870087'
    highlightPattern=':syntax match pattern /\m'${patternSearchVimRegex}'/ | :highlight pattern ctermfg=Red guifg=#ff0000' # please note that ${2} is also passed to Vim's regex engine
    highlightLineNum=':syntax match linenum /\m^\d\+\ze[-:]/ | :highlight linenum ctermfg=DarkCyan guifg=#00af87'
    
    ## Add mapped keys to navigate to the files listed in the search result
    getFilepath="let filepath = getline(search('\\m^File: .\\+', 'bn'))[6:]"
    getLineNum="let lineNum = substitute(getline('.'), '\\m^\\d\\+\\zs.*', '', '')"
    mapKeyToNavigateToFiles="noremap <silent> ${MAPPED_KEY_TO_NAVIGATE_TO_FILES} :${getFilepath}<CR>:${getLineNum}<CR>"
    if [[ "${GP_SOURCE_CODE_FILE_EDITOR}" = 'vim' ]]; then
        editFile="execute('edit ' .fnameescape(filepath))"
        goToLine="execute('keepj normal! ' .lineNum .'G')"
        setCurrentLineScreenCenter="execute('normal! zz')"
        unsetReadonly='setlocal noreadonly'
        mapKeyToNavigateToFiles="${mapKeyToNavigateToFiles}:${getLineNum}<CR>:${editFile}<CR>:${goToLine}<CR>:${setCurrentLineScreenCenter}<CR>:${unsetReadonly}<CR>"
    elif [[ "${GP_SOURCE_CODE_FILE_EDITOR}" = 'intellij' ]]; then
        openFileAtSpecificLine="call system('${GP_SOURCE_CODE_FILE_EDITOR_LAUNCHER_PATH} --line ' .lineNum .' \"' .getcwd() .'/' .filepath .'\"')"
        mapKeyToNavigateToFiles="${mapKeyToNavigateToFiles}:${openFileAtSpecificLine}<CR>"
    fi
    
    ## Create a catalogue of the files whose content matches the specified pattern
    createFilesCatalogue='silent! vimgrep /\m^File: .\+/ %'
    showFilesCatalogue='copen'
    setupFilesCatalogue="${createFilesCatalogue} | ${showFilesCatalogue}"
    
    ## Set cursorline in Vim to let users clearly know which line they are currently on
    setCursorline='setlocal cursorline'
    
    ## Set syntax highlighting on in Vim for an improved readability of the source code files
    setSyntaxHighlight='syntax on'

    ## Set hidden to not to abandon the unloaded buffers
    ## so that the color highlighting for the previews will not disappear after the navigation to the source code file
    setHidden='set hidden'
    
    ## Set to display line numbers in Vim
    setLineNum='set number'
    
    ## Set encoding to UTF-8 in Vim
    setUTF8='setlocal fileencoding=utf-8'
    
    ## Disable the folding in Vim to ensure the search result is not folded
    unfoldAll='setlocal foldlevel=99 | setlocal foldlevelstart=99'
    
    # Search and show the result in Vim
    ## Check if xargs accepts -S option to specify the replsize
    $(printf 'dummy' | xargs -S 1 -I{} >/dev/null 2>/dev/null)
    xargsAcceptS=$?
    
    ## Excluded files and directories
    excludedFileExtensions='{'$(IFS=","; echo "${GP_EXCLUDE[*]}")'}'
    excludedDir='{'$(IFS=","; echo "${GP_EXCLUDE_DIR[*]}")'}'
    
    ## Command to get the files whose content matches the specified pattern
    getFilesWithMatchesCmd='grep -rl "'${2}'" "{}" --exclude-dir='${excludedDir}' --exclude="*."'"${excludedFileExtensions} --exclude='${GP_SEARCH_RESULT_FILENAME}' ${extraArgumentsToGrep}"
    
    ## Command to search and print
    searchAndPrintCmd='printf "File: {}\n"; grep -nh "'${2}'" "{}" -A'${GP_NUM_OF_CTX_LINES}' -B'${GP_NUM_OF_CTX_LINES}' --exclude-dir='${excludedDir}' --exclude="*."'"${excludedFileExtensions} --exclude='${GP_SEARCH_RESULT_FILENAME}' ${extraArgumentsToGrep};"' printf "\n\n\n";'
    
    ## Start searching and show the search result on Vim
    sh -c "find . -maxdepth ${GP_MAXDEPTH}" | grep "${1}" | cut -c 3- | \
        xargs -o -I{} sh -c "${getFilesWithMatchesCmd}" | \
            if [[ "${xargsAcceptS}" -eq 0 ]]; then \
                xargs -S 10000 -o -I{} sh -c "${searchAndPrintCmd}" > "${GP_SEARCH_RESULT_FILENAME}"; \
            else \
                xargs -o -I{} sh -c "${searchAndPrintCmd}" > "${GP_SEARCH_RESULT_FILENAME}"; \
        fi
    
    view "${GP_SEARCH_RESULT_FILENAME}" -c "${setHidden} | ${setUTF8} | ${unfoldAll} | ${setCursorline} | ${setLineNum} | ${setSyntaxHighlight} | ${highlightFilepath} | ${highlightPattern} | ${highlightLineNum} | ${mapKeyToNavigateToFiles} | ${setupFilesCatalogue}"
    rm -f "${GP_SEARCH_RESULT_FILENAME}"
};
function gpi { gp ${1} ${2} "-i ${@:3}"; };
function gpw { gp ${1} ${2} "-w ${@:3}"; };
function gpiw { gp ${1} ${2} "-i -w ${@:3}"; };
