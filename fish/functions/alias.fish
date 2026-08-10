function j
    just $argv
end

function hx
    helix $argv
end

function t
    tmux $argv
end

function ta
    tmux a
end

function gm
    git commit -m $argv
end

function cg
    cargo $argv
end

function mkcd --description "Create a directory and immediately cd into it"
    mkdir -p $argv[1] && cd $argv[1]
end

function extract --description "Expand compressed archives accurately"
    if test (count $argv) -eq 0
        echo "Usage: extract <file>"
        return 1
    end
    if test -f $argv[1]
        switch $argv[1]
            case '*.tar.bz2' '*.tbz2'
                tar xjf $argv[1]
            case '*.tar.gz' '*.tgz'
                tar xzf $argv[1]
            case '*.bz2'
                bunzip2 $argv[1]
            case '*.rar'
                unrar x $argv[1]
            case '*.gz'
                gunzip $argv[1]
            case '*.tar'
                tar xf $argv[1]
            case '*.zip'
                unzip $argv[1]
            case '*'
                echo "Unknown file type: '$argv[1]'"
        end
    else
        echo "'$argv[1]' is not a valid file"
    end
end


function pclean -d "Interactively purge build directories permanently using fzf (all pre-selected)"
    set -l project_root "$HOME/Projects"

    # 1. Enforce execution boundary
    if not string match -q "$project_root*" (pwd)
        echo "Error: 'pclean' can only be executed inside $project_root" >&2
        return 1
    end

    # 2. Verify fzf dependency
    if not type -q fzf
        echo "Error: 'fzf' is required but not installed." >&2
        return 1
    end

    # 3. Merge default targets with custom arguments ($argv)
    set -l targets target node_modules dist .next .turbo $argv

    set -l find_expr
    for dir in $targets
        if test (count $find_expr) -gt 0
            set -a find_expr -o
        end
        set -a find_expr -name $dir
    end

    echo "Scanning for build directories..."

    # 4. Search and store matches
    set -l matches (find . -mindepth 1 \( $find_expr \) -type d -prune 2>/dev/null)

    if test (count $matches) -eq 0
        echo "No build directories found matching: $targets"
        return 0
    end

    # 5. Interactive multi-selection with ALL items pre-selected on open
    set -l selected (string split \n -- $matches | \
        fzf --multi \
            --prompt="Select directories to PURGE > " \
            --header="ENTER: confirm delete | TAB: toggle | CTRL-D: deselect all | CTRL-A: select all" \
            --bind="start:select-all,ctrl-a:select-all,ctrl-d:deselect-all" \
            --preview="
                echo '=== Disk Space Usage ==='
                du -sh {} 2>/dev/null
                echo ''
                echo '=== Contents ==='
                ls -la {} 2>/dev/null | head -n 12
            " \
            --preview-window=right:45% \
            --height=75% \
            --layout=reverse \
            --border)

    if test (count $selected) -eq 0
        echo "No directories selected. Aborting."
        return 0
    end

    # 6. Execute permanent removal using 'command rm' to bypass custom wrapper
    echo "Permanently deleting selected directories..."
    for dir in $selected
        command rm -rf "$dir"
        and echo "Deleted: $dir"
    end
end


function gstart
    set branch_name $argv[1]
    if test -z "$branch_name"
        echo "Error: Please specify a branch name. Usage: gstart <branch-name>"
        return 1
    end

    git checkout main
    git pull origin main
    git checkout -b $branch_name
end


function gsync
    set current_branch (git branch --show-current)
    if test "$current_branch" = "main"
        echo "You are already on main. Running git pull..."
        git pull origin main
        return
    end

    git fetch origin main
    if git rebase origin/main
        echo "Success: $current_branch is now rebased onto main (Linear History)."
    else
        echo "Error: Conflict detected. Please resolve conflicts and run 'git rebase --continue'."
    end
end

function gdone
    set branch_name (git branch --show-current)
    
    if test "$branch_name" = "main"
        echo "Updating main..."
        git pull origin main
        return
    end

    git checkout main
    git pull origin main
    
    if git branch -d $branch_name
        echo "Success: Branch '$branch_name' deleted locally."
    else
        echo "Warning: Branch '$branch_name' not fully merged. Use 'git branch -D' to force delete."
    end
end

# eza functions
function ls; eza -al --color=always --group-directories-first --icons --git $argv; end
function la; eza -a --color=always --group-directories-first --icons --git $argv; end
function ll; eza -l --color=always --group-directories-first --icons $argv; end
function lt; eza -aT --color=always --group-directories-first --icons -I "node_modules|cache|.git|dist|.turbo|.tanstack" $argv; end
function l.; eza -a $argv | grep -e '^\.'; end

function fe -d "Fuzzy search files and list with eza"
    fd --type f --strip-cwd-prefix --hidden --exclude .git | fzf --preview 'eza -l --color=always --icons {}'
end

function z; __zoxide_z $argv; end
function zi; __zoxide_zi $argv; end


# --- Rust & sccache Configuration (Fish version) ---

function setup-rust-sccache
    if type -q sccache
        set -gx RUSTC_WRAPPER (type -p sccache)
        set -gx SCCACHE_DIR "$HOME/.cache/sccache"
        set -gx SCCACHE_CACHE_SIZE "5G"

        if not test -d "$SCCACHE_DIR"
            mkdir -p "$SCCACHE_DIR"
        end

        set -l CARGO_CONFIG "$HOME/.cargo/config.toml"
        if not test -d "$HOME/.cargo"
            mkdir -p "$HOME/.cargo"
        end

        if not test -f "$CARGO_CONFIG"; or not grep -q "rustc-wrapper" "$CARGO_CONFIG"
            echo "🔧 Configuring Cargo to use sccache..."
            printf "\n[build]\nrustc-wrapper = \"%s\"\n" (type -p sccache) >> "$CARGO_CONFIG"
            echo "✅ Cargo config updated."
        end
    else
        echo "⚠️ sccache not found. Install it via: cargo install sccache"
    end
end

# setup-rust-sccache

# --- Rclone Sync Functions ---

function rust-cache-pull
    set -l cache_zip "/tmp/sccache_backup.7z"

    echo "🔄 Downloading zipped cache from cloud..."
    rclone copy "gdrive:rust_cache/sccache_backup.7z" "/tmp/" --progress

    if test -f $cache_zip
        echo "📂 Unzipping cache to $SCCACHE_DIR..."

        command rm -rf "$SCCACHE_DIR/*"
        7z x $cache_zip -o"$SCCACHE_DIR" -y >/dev/null

        echo "✅ Pull and Install complete."
        command rm -f $cache_zip
    else
        echo "❌ Error: Cache file not found on cloud."
    end
end

function rust-cache-push
    set -l cache_zip "/tmp/sccache_backup.7z"

    if mountpoint -q "$SCCACHE_DIR"
        echo "⚠️ Found rclone mount. Unmounting..."
        fusermount -u "$SCCACHE_DIR"; or sudo umount -l "$SCCACHE_DIR"
    end

    echo "🛑 Stopping sccache server..."
    sccache --stop-server >/dev/null 2>&1

    echo "📦 Compressing cache with 7z..."

    command rm -f $cache_zip
    7z a $cache_zip "$SCCACHE_DIR/*" -mx1

    echo "🚀 Uploading zipped cache to cloud..."
    rclone copy $cache_zip "gdrive:rust_cache/" --progress

    echo "✅ Push complete. sccache is safely stored."
    
    sccache --start-server >/dev/null 2>&1
end

abbr -a rs-stat 'sccache --show-stats'

# function __auto_load_env --on-variable PWD --description 'Auto load .env file on directory change'
#     if test -f .env
#         string match -r -v '^\s*#|^\s*$' < .env | while read -l line
#             if string match -r '^([^=]+)=(.*)$' -- $line > /dev/null
#                 set -l key (string replace -r '=.*$' '' -- $line | string trim)
#                 set -l value (string replace -r '^[^=]+=' '' -- $line | string trim -c '"\'')
#
#                 set -gx $key $value
#             end
#         end
#     end
# end
#
# function __auto_load_just_completions --on-variable PWD --description 'Dynamic just completions on directory change'
#     if type -q just
#         if test -f justfile; or test -f Justfile
#             just --completions fish | source
#         end
#     end
# end

function rm --description "Safely move files to trash using gio trash"
    # Silently absorb common rm flags (-r, -f, -v, -i, -d, --recursive, --force)
    argparse 'r/recursive' 'f/force' 'v/verbose' 'i' 'd/dir' -- $argv 2>/dev/null

    # $argv now contains ONLY the file/directory paths with flags removed
    if test (count $argv) -gt 0
        gio trash $argv
    else
        echo "rm: missing operand" >&2
        return 1
    end
end

function trash-restore -d "Interactively restore items from ~/.local/share/Trash to original paths"
    set -l trash_dir "$HOME/.local/share/Trash"
    set -l files_dir "$trash_dir/files"
    set -l info_dir "$trash_dir/info"

    if not test -d "$files_dir"
        echo "Error: Trash directory ($files_dir) not found." >&2
        return 1
    end

    if not type -q fzf
        echo "Error: 'fzf' is required but not installed." >&2
        return 1
    end

    # Export TRASH_INFO_DIR for subshell visibility
    set -x TRASH_INFO_DIR "$info_dir"

    # Select items using native Fish syntax inside fzf preview
    set -l selected (find "$files_dir" -mindepth 1 -maxdepth 1 2>/dev/null | \
        fzf --multi \
            --prompt="Select items to restore > " \
            --header="TAB: toggle | CTRL-A: select all | ENTER: restore" \
            --bind="ctrl-a:select-all" \
            --preview='
                set item {}
                set name (basename $item)
                set info_file "$TRASH_INFO_DIR/$name.trashinfo"
                if test -f $info_file
                    echo "=== Original Path ==="
                    grep -E "^Path=" $info_file | cut -d= -f2-
                    echo ""
                    echo "=== Deletion Date ==="
                    grep -E "^DeletionDate=" $info_file | cut -d= -f2-
                    echo ""
                end
                echo "=== Contents ==="
                ls -la $item 2>/dev/null
            ' \
            --preview-window=right:50% \
            --height=75% \
            --layout=reverse \
            --border)

    if test (count $selected) -eq 0
        echo "No items selected. Aborting."
        return 0
    end

    for item in $selected
        set -l name (basename "$item")
        set -l info_file "$info_dir/$name.trashinfo"
        set -l target_path

        # Parse original Path from .trashinfo metadata
        if test -f "$info_file"
            set -l raw_path (grep -E '^Path=' "$info_file" | cut -d= -f2-)
            if test -n "$raw_path"
                set target_path (string unescape --style=url "$raw_path")
            end
        end

        # Fallback to current working directory if metadata is missing
        if test -z "$target_path"
            set target_path "(pwd)/$name"
        end

        # Recreate parent directory structure if missing
        set -l dest_dir (dirname "$target_path")
        mkdir -p "$dest_dir"

        # Restore file and remove metadata using command rm
        if mv -v "$item" "$target_path"
            test -f "$info_file"; and command rm -f "$info_file"
        end
    end
end

function trash-clean -d "Interactively select and permanently delete items from Trash using fzf"
    set -l trash_dir "$HOME/.local/share/Trash"
    set -l files_dir "$trash_dir/files"
    set -l info_dir "$trash_dir/info"

    if not test -d "$files_dir"
        echo "Error: Trash directory ($files_dir) not found." >&2
        return 1
    end

    if not type -q fzf
        echo "Error: 'fzf' is required but not installed." >&2
        return 1
    end

    # Find items in Trash
    set -l matches (find "$files_dir" -mindepth 1 -maxdepth 1 2>/dev/null)

    if test (count $matches) -eq 0
        echo "Trash is already empty."
        return 0
    end

    # Export for POSIX subshell in fzf preview
    set -x TRASH_INFO_DIR "$info_dir"

    # Select items to permanently delete (All pre-selected on launch)
    set -l selected (string split \n -- $matches | \
        fzf --multi \
            --prompt="Select items to PURGE permanently > " \
            --header="ENTER: confirm purge | TAB: toggle | CTRL-D: deselect all | CTRL-A: select all" \
            --bind="start:select-all,ctrl-a:select-all,ctrl-d:deselect-all" \
            --preview='
                FILE="{}"
                NAME=$(basename "$FILE")
                INFO="$TRASH_INFO_DIR/$NAME.trashinfo"
                echo "=== Size ==="
                du -sh "$FILE" 2>/dev/null
                echo ""
                if [ -f "$INFO" ]; then
                    echo "=== Original Location ==="
                    grep -E "^Path=" "$INFO" | cut -d= -f2-
                    echo ""
                    echo "=== Trashed Date ==="
                    grep -E "^DeletionDate=" "$INFO" | cut -d= -f2-
                    echo ""
                fi
                echo "=== Contents ==="
                ls -la "$FILE" 2>/dev/null | head -n 10
            ' \
            --preview-window=right:50% \
            --height=75% \
            --layout=reverse \
            --border)

    if test (count $selected) -eq 0
        echo "No items selected. Aborting."
        return 0
    end

    echo "Permanently deleting selected items..."
    for item in $selected
        set -l name (basename "$item")
        set -l info_file "$info_dir/$name.trashinfo"

        # 1. Permanently remove the actual file/folder
        command rm -rf "$item"

        # 2. Permanently remove matching .trashinfo metadata
        if test -f "$info_file"
            command rm -f "$info_file"
        end

        echo "Purged: $name"
    end
end
