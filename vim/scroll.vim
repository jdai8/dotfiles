let g:scroll_mode_on = 0
function! ScrollModeToggle()
    if g:scroll_mode_on
        call ScrollModeOff()
        let g:scroll_mode_on = 0
    else
        call ScrollModeOn()
        let g:scroll_mode_on = 1
    endif
endfunction

function! ScrollModeOn()
    :set ro
    normal M
    :vs %
    :wincmd l
    normal 
    :set scrollbind
    :wincmd h
    :set scrollbind
    :nnoremap j 
    :nnoremap k 
endfunction

function! ScrollModeOff()
    :set noro
    :set noscrollbind
    :wincmd l
    :set noscrollbind
    :wincmd h
    :nunmap j
    :nunmap k
endfunction
