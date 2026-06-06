# ==============================================================================
# @description Cleans up a colon-separated path variable (e.g. PATH).
# Removes non-existent directories, deletes duplicates and 
# automatically creates a backup of the original variable.
#
# @param $1 The name of the environment variable to be cleaned up (e.g. PATH).
#
# @return 0 on successful cleanup.
#         1 if the variable passed is empty or not set.
#
# @example repair_path "PATH"
# repair_path "LD_LIBRARY_PATH"
# ==============================================================================
repair_path() {
    local var_name="$1"
    
    # Read the original value of the variable (indirect expansion)
    local original_val="${!var_name}"
    
    [[ -z "$original_val" ]] && return 1

    # Create a backup of the original variable (e.g. PATH_backup)
    export "${var_name}_backup"="$original_val"

    # Filter out redundant and non-existent paths
    local new_path=""
    local IFS=':'
    
    for dir in $original_val; do
        # Check if the directory exists
        if [[ -d "$dir" ]]; then
            # Check if the path is NOT already included in new_path
            # (String matching is safer than `=~` if paths contain "+" or ".")
            if [[ ":$new_path:" != *":$dir:"* ]]; then
                # Appends the path. Automatically sets the colon, 
                # if new_path is no longer empty.
                new_path="${new_path:+$new_path:}$dir"
            fi
        fi
    done
    
    # Export repaired variable
    export "$var_name"="$new_path"

    return 0
}

# exportadd: Adds a path to an environment variable, ensuring uniqueness.
#
# Usage: exportadd <PATH> [VARIABLE_NAME] [Position] [--dry-run]
#
# Parameters:
#   PATH: The directory path to be added (required).
#   VARIABLE_NAME: The name of the environment variable (default: PATH).
#   Position: 'append' (to the end) or 'prepend' (to the beginning, default).
#   --dry-run: Preview changes without applying them.
#
# Description: Checks if the path exists and is not already in the variable before adding.
# Uses colon-separated paths for accurate matching.
#
# Examples:
#   exportadd /usr/local/bin  # Prepend to PATH
#   exportadd /opt/bin LD_LIBRARY_PATH append  # Append to LD_LIBRARY_PATH
#   exportadd /home/user/bin --dry-run  # Preview adding to PATH
exportadd() {
    # 1. Parameter Check
    [ -z "$1" ] && { echo "Error: Path required." >&2; return 1; }

    local target_path="$1"
    local var_name="${2:-PATH}"
    local mode="${3:-prepend}"
    local dry_run=false
    [ "$4" = "--dry-run" ] && dry_run=true

    # Variable name validation (security for eval)
    case "$var_name" in
        *[!A-Z0-9_]*|[0-9]*) echo "Error: Invalid var name." >&2; return 1 ;;
    esac

    # --- THE POSIX SOLUTION FOR INDIRECT EXPANSION ---
    # We get the value of e.g. $PATH via eval
    local current_var_value
    eval "current_var_value=\"\$$var_name\""
    # -----------------------------------------------

    # 2. Existence Check
    [ ! -d "$target_path" ] && return 0

    # 3. Duplication Check
    case ":$current_var_value:" in
        *":$target_path:"*)
            [ "$dry_run" = true ] && echo "Dry-run: Already in $var_name"
            return 0
            ;;
        *)
            if [ "$dry_run" = true ]; then
                echo "Dry-run: Would $mode '$target_path' to $var_name"
            else
                # Set value: If variable was empty, do not set a colon
                if [ -z "$current_var_value" ]; then
                    new_val="$target_path"
                elif [ "$mode" = "append" ]; then
                    new_val="$current_var_value:$target_path"
                else
                    new_val="$target_path:$current_var_value"
                fi
                # Export dynamically
                eval "export $var_name=\"\$new_val\""
            fi
            return 0
            ;;
    esac
}

# Navigation
alias l='cd ~/labor' # overwrites system l-alias, uncomment if want
alias g='cd ~/gits'
alias d='cd ~/Downloads'
alias t='cd ~/labor/tmp'

# System Management
alias suu="sudo nala update && sudo nala upgrade -y && sudo nala autoremove -y && sudo nala clean && flatpak update -y && sudo snap refresh"
alias rlb="exec zsh"

# "Firsties" – morning routines
alias los="cw && suu"
alias losj="cw && suu && jl ."
alias losc="cw && suu && code ."

# cw - change to working folder or set working folder
cw() { [[ "$1" == "." ]] && echo "$PWD" > "$HOME/.config/current_working_folder" || cd "$(cat "$HOME/.config/current_working_folder")"; }

# SHLIB lock and restore
shliblock() { [[ "$1" == "R" ]] && cp ~/.zshrc.lock ~/.zshrc || cp ~/.zshrc ~/.zshrc.lock; }

# deensync: Synchronizes the deen-lupysta repository to a target directory, excluding .git and ignore folders.
alias deensync="rsync -av --delete --exclude='.ipynb_checkpoints/' --exclude='.git/' --exclude='ignore/' \$HOME/gits/deen-lupysta/ \$HOME/labor/synced-deen-lupysta/"

