" --- LSP Konfiguration (Vim9script Style) ---

let lspOpts = #{
    \ autoHighlightDiags: v:true,
    \ diagSignErrorText: '✘',
    \ diagSignWarningText: '▲',
    \ diagSignInfoText: '»',
    \ diagSignHintText: '⚑',
    \ highlightDiagLine: v:false
    \ }

autocmd User LspSetup call LspOptionsSet(lspOpts)

let lspServers = [
    \ #{
    \   name: 'rust-analyzer',
    \   filetype: ['rust'],
    \   path: expand('~/.cargo/bin/rust-analyzer'),
    \   args: []
    \ }
    \ ]

autocmd User LspSetup call LspAddServer(lspServers)

" --- Helix-Style Keymaps ---

" Navigation (Helix nutzt 'g' Präfixe)
nnoremap gd :LspGotoDefinition<CR>
nnoremap gy :LspGotoDeclaration<CR>
nnoremap gi :LspGotoImpl<CR>
nnoremap gt :LspGotoDefinition<CR>
" Helix nutzt 'gr' für references, 'gw' gibt es in Vim oft schon, daher bleiben wir bei 'gr'
nnoremap gr :LspShowReferences<CR>

" Documentation & Signatures
nnoremap K  :LspHover<CR>
" Helix nutzt 'ctrl-k' oft für signature help im insert mode
inoremap <C-k> <cmd>LspSignatureHelp<CR>

" Diagnostics (Helix nutzt 'd' für diagnostics im Match-Mode oder '[d' / ']d')
nnoremap ]d :LspDiag next<CR>
nnoremap [d :LspDiag prev<CR>
" Helix 'space + d' zeigt Diagnostics in einem Popup
nnoremap <leader>d :LspDiag current<CR>

" Refactoring & Actions (Helix nutzt 'space + a' für code actions und 'space + r' für rename)
nnoremap <leader>a :LspCodeAction<CR>
nnoremap <leader>r :LspRename<CR>

" --- Completion ---
" In Helix ist Completion meist automatisch, in Vim nutzen wir:
autocmd FileType rust setlocal omnifunc=lsp#complete
inoremap <silent> <C-Space> <C-x><C-o>
