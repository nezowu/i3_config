"au FileType c,cpp setl com-=://
au FileType go setl com-=://
au FileType c,cpp,rust setl ts=4 sw=4 et com-=://
au FileType sh setl com-=:#
au FileType haskell setl ts=2 sw=2 et com-=:--
set laststatus=2
set statusline=%f%m%r%h%w\ %y\ enc:%{&enc}\ ff:%{&ff}\ fenc:%{&fenc}%=(ch:%3b\ hex:%2B)\ col:%2c\ line:%2l/%L\ [%2p%%] 
"hi StatusLine cterm=none ctermbg=darkgrey ctermfg=black
hi StatusLine cterm=none ctermbg=black ctermfg=darkgrey
set number
set showtabline=2
" hi TabLineFill ctermfg=lightgrey ctermbg=darkgrey
hi TabLineSel ctermfg=white ctermbg=black
hi TabLine cterm=none ctermfg=darkgrey ctermbg=black
hi TabLineFill ctermfg=black
hi LineNr ctermfg=darkgray

augroup templates
  au! 
  autocmd BufNewFile *.* silent! execute '0r ~/.vim/templates/skeleton.'.expand("<afile>:e")
augroup END

"move tab left and right
" run tab left and right
nnoremap <S-Left> :-tabm<CR>
nnoremap <S-Right> :+tabm<CR>
nnoremap <S-h> gT
nnoremap <S-l> gt

"autocomplete pair
"inoremap ' ''<Left>
inoremap " ""<Left>
"inoremap < <><Left>
"inoremap [ []<Left>
inoremap { {}<Left>
inoremap {<CR> {<CR>}<Esc>O
inoremap ( ()<Left>
inoremap (<CR> () {<CR>}<Esc>O
inoremap () () {<CR>}<Esc>O
