vim9script

# 1. LSP Optionen zentralisieren
# Inlay Hints und Virtual Text sind für Rust extrem wertvoll, 
# da sie abgeleitete Typen und Fehler direkt im Code anzeigen.
var lspOpts = {
    autoHighlightDiags: true,
    showDiagWithVirtualText: true, 
    showInlayHints: true,          
    diagSignErrorText: '✘',
    diagSignWarningText: '▲',
    diagSignInfoText: '»',
    diagSignHintText: '⚑',
}
autocmd User LspSetup call LspOptionsSet(lspOpts)

# 2. Rust-Analyzer registrieren
# Es ist meistens robuster, sich auf den PATH (rustup) zu verlassen, 
# statt den Pfad hart zu kodieren.
var lspServers = [{
    name: 'rust-analyzer',
    filetype: ['rust'],
    path: 'rust-analyzer', # Falls PATH nicht greift, ändere es zurück zu expand('~/.cargo/bin/rust-analyzer')
    args: []
}]
autocmd User LspSetup call LspAddServer(lspServers)

# 3. Professionelle Keybindings & Autocmds
# Alles ist in einer Augroup gekapselt, damit es beim Neuladen der vimrc nicht doppelt ausgeführt wird.
augroup RustLspConfig
    autocmd!
    
    # Omnifunc für Autocompletion
    autocmd FileType rust setlocal omnifunc=lsp#complete
    
    # Navigation
    autocmd FileType rust nnoremap <buffer> gd :LspGotoDefinition<CR>
    autocmd FileType rust nnoremap <buffer> gi :LspGotoImpl<CR>
    autocmd FileType rust nnoremap <buffer> gr :LspShowReferences<CR>
    autocmd FileType rust nnoremap <buffer> K  :LspHover<CR>
    
    # Diagnostics (Die Standards in der Vim/Neovim Community sind [d und ]d)
    autocmd FileType rust nnoremap <buffer> gl :LspDiag current<CR>
    autocmd FileType rust nnoremap <buffer> [d :LspDiag prev<CR>
    autocmd FileType rust nnoremap <buffer> ]d :LspDiag next<CR>
    
    # Code Modification & Refactoring (Must-Haves für Senior Devs)
    autocmd FileType rust nnoremap <buffer> <leader>ca :LspCodeAction<CR>
    autocmd FileType rust nnoremap <buffer> <leader>rn :LspRename<CR>
    autocmd FileType rust nnoremap <buffer> <leader>f  :LspFormat<CR>
    
    # Completion Shortcut
    autocmd FileType rust inoremap <buffer> <silent> <C-Space> <C-x><C-o>
augroup END

# 4. Auto-Format on Save (rustfmt)
# Kein manuelles Formatieren mehr. Code wird beim Speichern automatisch formatiert.
augroup RustFormatOnSave
    autocmd!
    autocmd BufWritePre *.rs :LspFormat
augroup END
