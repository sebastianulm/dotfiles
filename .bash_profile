
function findtrtop {
        candidate=`pwd`
        while true; do
                if [[ -e "$candidate/GNUmaster" &&  -e "$candidate/tr" && -e "$candidate/Crawlers" ]]; then
                        trtop $candidate
                break;
                else
                nextcandidate=${candidate%/*}
                        if [[ "v$nextcandidate" == "v$candidate" || "v$nextcandidate" == "v" ]]; then
                break;
                        fi
                candidate=$nextcandidate;
                fi
        done
}

function trtop
{
        if (( $# == 1 )); then
                oldscripts=$TRTOP/scripts
                export TRTOP=$1
                export PATH=${PATH//:$oldscripts}:$TRTOP/scripts
        else
                echo $TRTOP
        fi
}

# svn diff -B, then copies to ~/Deskop/patches/BRANCHNAME_revision
function trdiff
{
    svn_branch=`svn branch 2>/dev/null | sed -e 's/.*/&/'`
    bug_number=0

    if [[ "$svn_branch" == "MAINLINE" || "$svn_branch" == "PRERELEASE" || "$svn_branch" == "PRODUCTION" ]]; then
        echo "taking MAINLINE/PRERELEASE/PRODUCTION diff"
        if (( $# == 1 )); then
            svn_branch=$1
            bug_number=$1
            svn diff > diffs.txt || return $?
        else
            echo "usage: trdiff <bug number>"
            return 1
        fi
    else
        svn diff -B
    fi

    original_dest="${HOME}/Desktop/patches/${svn_branch}"

    destfile=$original_dest
    revisions=1

    while [ -f "$destfile" ]; do
        destfile="${original_dest}_${revisions}"
        revisions=$[revisions + 1]
    done

    echo "copying diffs.txt to $destfile"
    cp diffs.txt $destfile
    push_patches

    # Gets username/pw from SVNTR login
    decoded=`echo $SVNTR_AUTH | base64 -d`
    auth=(${decoded//:/ })
    username="${auth[0]}@tripadvisor.com"
    tabugz="bugz -b https://bugs.tripadvisor.com/ -u \"$username\" -p \"${auth[1]}\""

    # Attach the patch to a bug automatically & update bug status
    if [[ "$bug_number" -gt 60000 ]]; then
## TODO: error-ing out, something about xml.parsers

        echo "Uploading diff to bugzilla & grabbing bug (NOT)"
#        $tabugz attach --patch -t 'proposed fix' -d "auto-attaching $destfile" $bug_number $destfile
#        $tabugz modify -s ASSIGNED -a "$username" $bug_number
    fi
}

export ACK_OPTIONS='--type-set m4=.m4 --type-set vm=.vm --type-set as=.as3 --invert-file-match -G ^(data|langs)/|site/(js[23]|css2?)/.*-(c|gen)\.(js|css)'

export PATH=$PATH:~/bin/

alias apt-get='sudo apt-get'

export WHTOP='/home/nathan/warehouse'

# Conveniences for switching the environment for the clusters
alias uc_prod=". $WHTOP/clusters/prod/config/env.bash $WHTOP/clusters/prod"
alias uc_adhoc=". $WHTOP/clusters/adhoc/config/env.bash $WHTOP/clusters/adhoc"

if [ -f ~/.tripadvisor ]; then
    export PROMPT_COMMAND="findtrtop; $PROMPT_COMMAND"
fi

if [ -f ~/.bash_specific ]; then
    source ~/.bash_specific
fi

if [[ !("$PROMPT_COMMAND" =~ "findtrtop") ]];
    then    
    export PROMPT_COMMAND="findtrtop; $PROMPT_COMMAND"
fi

# Point back to my macbook
function xtomac()
{
    export DISPLAY=nmerritt.dhcp.tripadvisor.com:0
}

function geo()
{
    local config="$TRTOP/config/hosts/$(hostname -s).ini"
    sed -i 's/^LOCATIONSTORE_ROOT_ID=[0-9]\+$/LOCATIONSTORE_ROOT_ID='$1'/' $config
    local magictmp=$(mktemp)
    make -C $TRTOP tree_setup >> "$magictmp" 2>&1
    local ret="$?"
    if [[ $ret != 0 ]]; then
        echo "Something broked!"
        cat "$magictmp"
    fi
    rm $magictmp
    return $ret
}

function mass_root()
{
    geo 28942
}


alias top='htop'
alias trown='pushd .;cd $TRTOP;sudo chown -f -R nathan _build lib data scripts .triprc .subversion svntr.log /tmp/svntr.log RUNMODE /usr/local/tripadvisor/locales /usr/local/tripadvisor/fbrs;popd'
alias df='df -h'
alias du='du -h'

function gotr()
{
    cd $TRTOP
}

function gojs()
{
    cd $TRTOP/site/js3/src/
}

function gov()
{
    cd $TRTOP/site/velocity_redesign/
}

function goja()
{
    cd $TRTOP/tr/com/TripResearch/
}

function gocss()
{
    cd $TRTOP/site/css2/
}

function gos()
{
    cd $TRTOP/site/
}

function mcss()
{
    make -C $TRTOP/site/css2/ && tfc && tfv
}

function golog()
{
    ssh nmdev screen -r log ## TODO not quite right
}

function tfv()
{
    echo "tweak flush velocity"
    tweak flush velocity
}

function tfj ()
{
    echo "tweak flush js3"
    tweak flush js3
}

function tfc()
{
    echo "tweak flush css2"
    tweak flush css2
}

function spatch()
{
    patch -p0 --dry-run < "$1"
    cmd="patch -p0 < $1"
    echo "Everything OK? patch? [Y/n]"
    read answer
    if [$answer -eq "y"]; then
        echo `$cmd`
    elif [$answer -eq ""]; then
        echo `$cmd`
    else
        echo "Aborting"
    fi
}

function trcat()
{
    if [[ -z "${1##[:space:]*}" ]];
    then
        echo "Usage: trcat <full file path> <branch to replace from (optional)>"
        return
    fi

    if [[ -z "$2" ]];
    then
        BRANCH="mainline"
    else
        BRANCH="$2"
    fi

    echo "Running: svntr cat //${BRANCH}/${1} > ${TRTOP}/${1}"
    svntr cat //${BRANCH}/${1} > ${TRTOP}/${1}
}

function rdt() ## Rapid develop tweak
{
    if [ -z "$2" ];
    then
        target="localhost"
    else
        target="$2"
    fi

    params=("JS_CONCAT" "JS_COMPRESS" "CSS_CONCAT" "CSS_COMPRESS")
    for i in "${params[@]}"
    do
        echo "tweak feature $1 $i"
        tweak feature $1 $i
    done
}

## Functions to help with logging
function taerror()
{
    tail -f /etc/httpd-MAINLINE/logs/tripadvisor.log | grep -i error
}

function talog()
{
    tail -f /etc/httpd-MAINLINE/logs/tripadvisor.log
}

function svn_conflicts()
{
    svn st | grep "^\w*C"
}

function svn_rm_nonworking()
{
    svn st –no-ignore |grep -e ^\? -e ^I | awk ‘{print $2}’| xargs -r rm -r
}

function get_patches()
{
    rsync -are ssh gnm-dev.dhcp.tripadvisor.com:~/Desktop/patches/ ~/Desktop/patches/
}

function push_patches()
{
    rsync -are ssh ~/Desktop/patches/ nmerritt.local:~/Desktop/patches/
}

function selenium_mobile()
{
    echo "Add mobile tests as a suite you dummy!"
}

function selenium_tablet()
{
    $TRTOP/scripts/pythontr.sh $TRTOP/tests/selenium/run-tests -t tablet
}

# Run both
function selenium_all()
{
    selenium_mobile
    selenium_tablet
}

function trunit
{
    javatr.sh org.junit.runner.JUnitCore com.TripResearch.${1}
}

if [ "$PS1" ]; then
    # don't put duplicate lines in the history. See bash(1) for more options
    export HISTCONTROL=ignoredups

    alias ln='ln -s'
    alias hln='ln'

    # colors
    NONE="\[\033[0m\]"
    GREEN="\[\033[0;32m\]"
    RED="\[\033[0;31m\]"
    BLD_BLK="\[\033[1;30m\]"
    YELLOW="\[\033[00;33m\]"
    BLACK="\[\033[0;30m\]"
    PINK="\[\033[00;35m\]"
    BLUE="\[\033[00;34m\]"
    BLUEb="\[\033[01;34m\]"
    CYAN="\[\033[00;36m\]"
    BOLD=''

    # bash 3.0 and line-wrapping compatible version:
    # gives the following (where smiley indicates last cmd sucessfully ran)
    #
    # [HH:MM AM/PM] user@host: $PWD
    # :-) / 8-( [current branch (if any)] $

    parse_git_branch="\`git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \[\1\]/' \`"
    parse_svn_branch="\`svn branch 2>/dev/null | sed -e 's/.*/\[&\]/' \`"

    happy="\"${GREEN}:-)${NONE}\""
    sad="\"${RED}8-(${NONE}\""

    smiley="\`if [ \$? -eq 0 ]; then echo -ne ${happy}; else echo -ne ${sad}; fi\`"
    BRANCHES="echo -ne ${PINK}${parse_svn_branch}${parse_git_branch}${NONE}"

    PS1="${BOLD}[\@]${NONE} ${YELLOW}\u${NONE}@${GREEN}\h${NONE} `${BRANCHES}` ${BLUE}\w/${NONE} \n ${smiley} \$ "

fi

if [ -f /opt/local/etc/bash_completion ]; then
    source /opt/local/etc/bash_completion
fi
