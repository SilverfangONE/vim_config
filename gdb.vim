" In deiner .vimrc
autocmd FileType rust compiler rustc
autocmd FileType rust setlocal makeprg=cargo\ check

let g:termdebug_wide = 1
" Tastenkürzel: F5 führt cargo check aus
nnoremap <F5> :make<CR>

" --- Start: Rust Debugger Setup ---
function! StartRustDebug()
    " 1. Speichere die Datei, falls es ungespeicherte Änderungen gibt
    update

    " 2. Finde die Cargo.toml (sucht von der aktuellen Datei aus aufwärts)
    let l:cargo_toml = findfile('Cargo.toml', '.;')
    if empty(l:cargo_toml)
        echoerr "Fehler: Keine Cargo.toml gefunden! Bist du in einem Rust-Projekt?"
        return
    endif

    " 3. Extrahiere Projekt-Root und den Namen des Ordners (= Binary Name)
    let l:project_root = fnamemodify(l:cargo_toml, ':p:h')
    let l:project_name = fnamemodify(l:project_root, ':t')
    let l:binary_path = l:project_root . '/target/debug/' . l:project_name

    " 4. Projekt bauen (cargo build)
    echom "Baue Projekt... Bitte warten."
    " Temporär ins Projekt-Root wechseln, damit cargo sicher den richtigen Ordner nutzt
    let l:save_cwd = getcwd()
    execute 'lcd ' . l:project_root
    
    " Führe cargo build im Hintergrund aus und speichere das Ergebnis
    let l:build_output = system('cargo build')
    let l:build_status = v:shell_error
    
    " Zurück ins vorherige Arbeitsverzeichnis wechseln
    execute 'lcd ' . l:save_cwd

    " 5. Prüfen, ob der Build erfolgreich war
    if l:build_status != 0
        echoerr "Build fehlgeschlagen! Debugger wird nicht gestartet."
        " Optional: Du könntest hier auch l:build_output ausgeben lassen
        return
    endif

    echom "Build erfolgreich! Starte GDB..."
    
    let l:source_window = win_getid()
    " 6. Starte Termdebug mit dem korrekten Pfad
    execute 'Termdebug ' . l:binary_path
    
    call win_gotoid(l:source_window)

endfunction

" Debugger mit F6 starten (ruft die obige Funktion auf)
nnoremap <F6> :call StartRustDebug()<CR>
" --- Ende: Rust Debugger Setup ---
" --- Start: Rust Debugger Restart ---
function! RebuildAndRestartDebug()
    " 1. Speichern
    update

    " 2. Projekt-Root finden
    let l:cargo_toml = findfile('Cargo.toml', '.;')
    if empty(l:cargo_toml)
        return
    endif
    let l:project_root = fnamemodify(l:cargo_toml, ':p:h')

    " 3. Projekt bauen
    echom "Baue neue Version für Debugger..."
    let l:save_cwd = getcwd()
    execute 'lcd ' . l:project_root
    let l:build_output = system('cargo build')
    let l:build_status = v:shell_error
    execute 'lcd ' . l:save_cwd

    if l:build_status != 0
        echoerr "Build fehlgeschlagen! GDB wird nicht neu gestartet."
        return
    endif

    echom "Build erfolgreich! GDB startet neu..."

    " 4. Sende den Befehl an die laufende GDB-Instanz
    " 'set confirm off' verhindert, dass GDB fragt "Start it from the beginning? (y/n)"
    call TermDebugSendCommand('set confirm off')
    call TermDebugSendCommand('run')
    call TermDebugSendCommand('set confirm on')
endfunction

" Debugger mit F7 neu bauen und laufende GDB-Session neu starten
nnoremap <F7> :call RebuildAndRestartDebug()<CR>
" --- Ende: Rust Debugger Restart --
autocmd QuickFixCmdPost [^l]* nested cwindow
