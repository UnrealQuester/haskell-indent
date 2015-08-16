if exists('b:did_indent') || &cp || version < 700
    finish
endif
let b:did_indent = 1

setlocal indentexpr=HaskellGetIndent(v:lnum)
setlocal indentkeys=!^F,o,O,=where,0<Bar>

fun! HaskellGetIndent(lnum)
    let currentLine = getline(a:lnum)
    let lnum = a:lnum - 1

    " start of the file, do not indent
    if lnum == 0
        return 0
    endif

    let previousLine = getline(lnum)
    let currentIndent = indent(lnum)

    " empty line
    if previousLine =~# '^\s*$'
        return 0
    endif

    " no indenting is done in comments in case they match haskell syntax
    if synIDattr(synIDtrans(synID(lnum, currentIndent + 1, 1)), 'name')
                \ =~# '\%(Comment\|String\)$'
        return currentIndent
    endif

    " class or instance
    if previousLine =~# '^class\>\|^instance\>'
        return currentIndent + &shiftwidth
    endif

    " unmatched [
    if previousLine =~# '\[[^\]]*$'
        return match(previousLine, '\[')
    endif

    " unmatched {
    if previousLine =~# '{[^}]*$'
        return match(previousLine, '{')
    endif

    " unmatched (
    if previousLine =~# '([^)]*$'
        return match(previousLine, '(')
    endif

    " data declaration, start below the equals sign
    " in case the user wants to create a sum type
    " across multiple lines
    if previousLine =~# '^data\>.*=.*'
        return match(previousLine, '=')
    endif

    " case
    if previousLine =~# '\<case\>.*\<of$'
        return currentIndent + &shiftwidth
    endif

    " keep previous indentation level if no rule matches
    return -1
endfun
