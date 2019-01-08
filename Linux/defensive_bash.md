# Bash best practices and style-guide

Just simple methods to keep the code clean.

Inspired by [progrium/bashstyle](https://github.com/progrium/bashstyle) and [Kfir Lavi post](http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/).


## Quick big rules
* All code goes in a function
* Always double quote variables
* Avoid global variables and declare them as `readonly`
* Always have a `main()` function for runnable scripts
* Always use `set -eo pipefail` : fail fast and be aware of exit codes
* Define functions as `myfunc() { ... }`, not `function myfun {...}`
* Always use `[[` instead of `[` or `test`
* Use `$( ... )` instead of backticks
* Prefer absolute paths and always qualify relative paths with `./.`
* Warnings and errors should go to `STDERR`, anything parsable should go to `STDOUT`
* Use `.sh` or `.bash` extension if file is meant to be included or sourced

## More specific rules with some example

### Global variables
* Avoid global vars
* Always UPPER_CASE naming
* Readonly declaration
* Globals that can be always use in any program :
```
readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"
```

### Other variables
* All variables should be local (they can only be used in functions)
* Always lowercase naming
* Self documenting parameters
```
fn_example() {
    local explicit_name = $1 ;
    local expName = $1 ;
}
```
* Usually use `i` for loop, so it is very important to declare it as local

### Main()
* Use always a `main()` function
* The only global command in the code is : `main` or `main "$@"`
* If script is also usable as library, call it using `[[ "$0" == "$BASH_SOURCE" ]] && main "$@"`



### Everything is a function
* Only the `main()` function and global declarations are run globaly
* Short code portion can be functions
* Define functions as `myfunc() { ... }`, not `function myfun {...}`


### Debugging
* Run with -x flag : `bash -x prog.sh`
* Debug just a small section of code using set -x and set +x
* Printing function name and its arguments `echo $FUNCNAME $@`

### Each line of code does just one thing
* Break expression with back slash `\`
* Use symbols at the start of the indented line
```
print_dir_if_not_empty() {
    local dir=$1
    is_empty $dir \
        && echo "dir is empty" \
        || echo "dir=$dir"
}
```


### Command line arguments

```
cmdline() {
    local arg=
    for arg
    do
        local delim=""
        case "$arg" in
            #translate --gnu-long-options to -g (short options)
            --config)         args="${args}-c ";;
            --pretend)        args="${args}-n ";;
            --test)           args="${args}-t ";;
            --help-config)    usage_config && exit 0;;
            --help)           args="${args}-h ";;
            --verbose)        args="${args}-v ";;
            --debug)          args="${args}-x ";;
            #pass through anything else
            *) [[ "${arg:0:1}" == "-" ]] || delim="\""
                args="${args}${delim}${arg}${delim} ";;
        esac
    done

    #Reset the positional parameters to the short options
    eval set -- $args

    while getopts "nvhxt:c:" OPTION
    do
         case $OPTION in
         v)
             readonly VERBOSE=1
             ;;
         h)
             usage
             exit 0
             ;;
         x)
             readonly DEBUG='-x'
             set -x
             ;;
         t)
             RUN_TESTS=$OPTARG
             verbose VINFO "Running tests"
             ;;
         c)
             readonly CONFIG_FILE=$OPTARG
             ;;
         n)
             readonly PRETEND=1
             ;;
        esac
    done

    if [[ $recursive_testing || -z $RUN_TESTS ]]; then
        [[ ! -f $CONFIG_FILE ]] \
            && eexit "You must provide --config file"
    fi
    return 0
}
```

### Unit Testing
* Very important in higher level languages
* Use [shunit2](https://shunit2.googlecode.com/svn/trunk/source/2.1/doc/shunit2.html) for unit testing
* Good intro to shunit2 : [shUnit2 - Bash Testing](http://www.mikewright.me/blog/2013/10/31/shunit2-bash-testing/)
* Another good ressource : [Test Driving Shell Scripts](http://code.tutsplus.com/tutorials/test-driving-shell-scripts--net-31487)

* The list of current assertions (as of version 2.1.6) :
  * `assertEquals [message] expected actual`
  * `assertSame [message] expected actual`
  * `assertNotEquals [message] expected actual`
  * `assertNotSame [message] expected actual`
  * `assertNull [message] value` # used to compare a null in bash which is a zero length string
  * `assertNotNull [message] value` # used to compare a null in bash which is a zero length string
  * `assertTrue [message] condition`
  * `assertFalse [message] condition`


* The list of current failures (do not use them for value comparisons, use assertions for this) :
  * `fail [message]`
  * `failNotEquals [message] unexpected actual`
  * `failSame [message] expected actual`
  * `failNotSame [message] unexpected actual`


* More specific functions :
  * `setUp` : run automatically before each test
  * `tearDown` run automatically after each test
  * `|| startSkipping` automatically skip after a test failure (default is to continue)
  
  ----------------------------------------------------------------------------------------------------------------------------
  
  
Bash best practices

An attempt to bring order in good advice on writing Bash scripts I collected from several sources.
General

* The principles of Clean Code apply to Bash as well
* Always use long parameter notation when available. This makes the script more readable, especially for lesser known/used commands that you don’t remember all the options for.
  # Avoid:
  rm -rf -- "${dir}"

  # Good:
  rm --recursive --force -- "${dir}"
* Don’t use:
  cd "${foo}"
  [...]
  cd ..
but
  (
    cd "${foo}"
    [...]
  )
pushd and popd may also be useful:
  pushd "${foo}"
  [...]
  popd
* Use nohup foo | cat & if foo must be started from a terminal and run in the background.
Variables

* Prefer local variables within functions over global variables
* If you need global variables, make them readonly
* Variables should always be referred to in the ${var} form (as opposed to $var.
* Variables should always be quoted, especially if their value may contain a whitespace or separator character: "${var}"
* Capitalization:     
    * Environment (exported) variables: ${ALL_CAPS}
    * Local variables: ${lower_case}
* Positional parameters of the script should be checked, those of functions should not
* Some loops happen in subprocesses, so don’t be surprised when setting variabless does nothing after them. Use stdout and greping to communicate status.
Substitution

* Always use $(cmd) for command substitution (as opposed to backquotes)
* Prepend a command with \ to override alias/builtin lookup. E.g.:
  $ \time bash -c "dnf list installed | wc -l"
  5466
  1.32user 0.12system 0:01.45elapsed 99%CPU (0avgtext+0avgdata 97596maxresident)k
  0inputs+136outputs (0major+37743minor)pagefaults 0swaps
Output and redirection

* For various reasons, printf is preferable to echo. printf gives more control over the output, it’s more portable and its behaviour is defined better.
* Print error messages on stderr. E.g., I use the following function:
  error() {
    printf "${red}!!! %s${reset}\\n" "${*}" 1>&2
  }
* Name heredoc tags with what they’re part of, like:
  cat <<HELPMSG
  usage $0 [OPTION]... [ARGUMENT]...

  HELPMSG
* Single-quote heredocs leading tag to prevent interpolation of text between them.
  cat <<'MSG'
  [...]
  MSG
* When combining a sudo command with redirection, it’s important to realize that the root permissions only apply to the command, not to the part after the redirection operator. An example where a script needs to write to a file that’s only writeable as root:
  # this won't work:
  sudo printf "..." > /root/some_file

  # this will:
  printf "..." | sudo tee /root/some_file > /dev/null
Functions

Bash can be hard to read and interpret. Using functions can greatly improve readability. Principles from Clean Code apply here.
* Apply the Single Responsibility Principle: a function does one thing.
* Don’t mix levels of abstraction
* Describe the usage of each function: number of arguments, return value, output
* Declare variables with a meaningful name for positional parameters of functions
  foo() {
    local first_arg="${1}"
    local second_arg="${2}"
    [...]
  }
* Create functions with a meaningful name for complex tests
  # Don't do this
  if [ "$#" -ge "1" ] && [ "$1" = '-h' ] || [ "$1" = '--help' ] || [ "$1" = "-?" ]; then
    usage
    exit 0
  fi

  # Do this
  help_wanted() {
    [ "$#" -ge "1" ] && [ "$1" = '-h' ] || [ "$1" = '--help' ] || [ "$1" = "-?" ]
  }

  if help_wanted "$@"; then
    usage
    exit 0
  fi
Cleanup code

An idiom for tasks that need to be done before the script ends (e.g. removing temporary files, etc.). The exit status of the script is the status of the last statement before the finish function.
finish() {
  result=$?
  # Your cleanup code here
  exit ${result}
}
trap finish EXIT ERR
Source: Aaron Maxwell, How “Exit Traps” can make your Bash scripts way more robust and reliable.
Writing robust scripts and debugging

Bash is not very easy to debug. There’s no built-in debugger like you have with other programming languages. By default, undefined variables are interpreted as empty strings, which can cause problems further down the line. A few tips that may help:
* Always check for syntax errors by running the script with bash -n myscript.sh
* Use ShellCheck and fix all warnings. This is a static code analyzer that can find a lot of common bugs in shell scripts. Integrate ShellCheck in your text editor (e.g. Syntastic plugin in Vim)
* Abort the script on errors and undbound variables. Put the following code at the beginning of each script.
  set -o errexit   # abort on nonzero exitstatus
  set -o nounset   # abort on unbound variable
  set -o pipefail  # don't hide errors within pipes
A shorter version is shown below, but writing it out makes the script more readable.
  set -euo pipefail
* Use Bash’s debug output feature. This will print each statement after applying all forms of substitution (parameter/command substitution, brace expansion, globbing, etc.)     
    * Run the script with bash -x myscript.sh
    * Put set -x at the top of the script
    * If you only want debug output in a specific section of the script, put set -x before and set +x after the section.
* Write lots of log messages to stdout or stderr so it’s easier to drill down to what part of the script contains problematic code. I have defined a few functions for logging, you can find them in my dotfiles repository.
* Use bashdb
Shell script template

An annotated template for Bash shell scripts:
For now, see https://github.com/bertvv/dotfiles/blob/master/.vim/templates/sh
Resources

* Armstrong, Paul (s.d.). Shell Style Guide. https://google.github.io/styleguide/shell.xml
* BashFAQ http://mywiki.wooledge.org/BashFAQ, BashGuide http://mywiki.wooledge.org/BashGuide
* Bash Hackers Wiki. http://wiki.bash-hackers.org/start
* Bentz, Yoann (2016). Good practices for writing shell scripts. http://www.yoone.eu/articles/2-good-practices-for-writing-shell-scripts.html
* Berkholz, Donny (2011). Bash shell-scripting libraries. https://dberkholz.com/2011/04/07/bash-shell-scripting-libraries/
* Billemont, Maarten (2017). The Bash Guide. http://guide.bash.academy/
* Brady, Pádraig (2008). Common Shell Script Mistakes. http://www.pixelbeat.org/programming/shell_script_mistakes.html
* Cooper, Mendel (2014). The Advanced Bash Scripting Guide (ABS). http://www.tldp.org/LDP/abs/html/
* Fox, Brian and Ramey, Chet (2009). bash(1) man page. http://linux.die.net/man/1/bash
* Free Software Foundation (2014). Bash Reference Manual. https://www.gnu.org/software/bash/manual/bashref.html
* Gite, Vivek (2010). Linux Shell Scripting Tutorial (LSST) v2.0. https://bash.cyberciti.biz/guide/
* Jones, M. Tim (2011). Evolution of shells in Linux: From Bourne to Bash and beyond. https://www.ibm.com/developerworks/library/l-linux-shells/
* Lavi, Kfir (2012). Defensive Bash Programming. http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming
* Maxwell, Aaron (2014). Use the Unofficial Bash Strict Mode (Unless You Looove Debugging). http://redsymbol.net/articles/unofficial-bash-strict-mode/
* Pennarun, Avery (2011). Insufficiently known POSIX shell features. http://apenwarr.ca/log/?m=201102#28
* Rousseau, Thibaut (2017). Shell Scripts Matter. https://dev.to/thiht/shell-scripts-matter
* Sheppard, Simon (s.d.). Bash Keyboard Shortcuts. http://ss64.com/bash/syntax-keyboard.html
* When to use Bash: https://hackaday.com/2017/07/21/linux-fu-better-bash-scripting/#comment-3793634
Templates

Portable shell scripts

Fun

* https://cmdchallenge.com/
This project is maintained by bertvv
Hosted on GitHub Pages — Theme by orderedlist
MeasureMeasure

### Usefull links and  good references
* Obsolete and deprecated bash syntax :
[http://wiki.bash-hackers.org/scripting/obsolete](http://wiki.bash-hackers.org/scripting/obsolete)
* Beginner mistakes [http://wiki.bash-hackers.org/scripting/newbie_traps](http://wiki.bash-hackers.org/scripting/newbie_traps)
* Advanced Bash-Scripting Guide [http://tldp.org/LDP/abs/html/](http://tldp.org/LDP/abs/html/)
* Google's Bash styleguide [http://google-styleguide.googlecode.com/svn/trunk/shell.xml](http://google-styleguide.googlecode.com/svn/trunk/shell.xml)
