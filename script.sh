# Copy and paste below code into your bashrc or zshrc file

# gp <directories-in-pwd> <pattern> [grep-pattern-option] [num-of-lines-to-show-before-and-after-matches]
# e.g. gp 'projectA\|projectB\|projectC' 'keywordA\|keywordB' -i # search through multiple related projects
# e.g. gp . keywordA # search through current directory
function gp
{
    PURPLE='\033[0;35m'
    NOCOLOR='\033[0m'
    ls | sh -c 'grep '${3}' "'${1}'"'  | xargs -o -I{} sh -c 'grep '${3:--}'rl "'${2}'" {} --exclude-dir=lib --exclude-dir=build --exclude-dir=bin --exclude-dir=.\* --exclude=\*.{png,jpeg,jpg,tif,tiff,bmp,gif,eps,raw,cr2,nef,orf,sr2}' | xargs -o -I{} sh -c 'echo -e "File: '${PURPLE}{}${NOCOLOR}'"; grep '${3}' "'${2}'" "{}" --color=always -A'${4:-20}' -B'${4:-20}'; echo; echo;'| less -r
};
function gpi { gp $1 $2 '-i' $3; };
function gpw { gp $1 $2 '-w' $3; };
function gpiw { gp $1 $2 '-iw' $3; };
