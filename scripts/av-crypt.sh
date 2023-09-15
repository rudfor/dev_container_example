#!/usr/bin/env bash
# generated using ChatGPT verified by Rudolf
#
# encrypt/decrypt all files that match the vault folder structure:
#     <scope>/<hostname>/vault
#
# Function to display help instructions
function display_help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  -e, --encrypt   Encrypt files using ansible-vault (default if no option is provided)."
  echo "  -d, --decrypt   Decrypt files using ansible-vault."
  echo "  -r, --restore   Restore files to git original."
  echo "  -h, --help      Display this help and exit."
  exit 0
}

# Default action (encrypt)
action="encrypt"
verbose=true

# Parse command-line options using getopt
TEMP=$(getopt -o edhrv --long encrypt,decrypt,restore,help,verbose -n "$0" -- "$@")
eval set -- "$TEMP"

# Handle command-line options
while true; do
  case "$1" in
    -e | --encrypt)
      action="encrypt"
      shift ;;
    -d | --decrypt)
      action="decrypt"
      shift ;;
    -r | --restore)
      action="restore"
      shift ;;
    -v | --verbose)
      verbose=true
      shift ;;
    -h | --help)
      display_help ;;
    --)
      shift
      break ;;
    *)
      echo "Invalid option: $1"
      display_help ;;
  esac
done

# Generic location for vault files.
# <XXXXX_vars>/<hostname>/vault/* {XXXXX => host_vars and group_vars}
source_directory="*/*/vault/*"  # Replace with the path to the folder containing the files to encrypt/decrypt

# Environment location for vault files.
# environment/<environment>/<XXXXX_vars>/<hostname>/vault/* {XXXXX => host_vars and group_vars}
source_env_directory="environment/*/*/*/vault/*"  # Replace with the path to the folder containing the files to encrypt/decrypt

function process_files() {
  local action=$1       # encrypt or decrypt
  local source_dir=$2   # search path
  if [ "$verbose" = true ]; then
    echo "process_files: actrion $action, source_dir $source_dir"
  fi

  # Use arrays to store the list of files found
  IFS= readarray -d '' files < <(find $source_dir -type f -print0)
  if [ "$action" = "restore" ]; then
    for file in "${files[@]}"; do
      git restore "$file"
      if [ "$verbose" = true ]; then
        echo "$action $file"
      fi
    done
  else
    for file in "${files[@]}"; do
      ansible-vault "$action" "$file"
      if [ "$verbose" = true ]; then
        echo "$action $file"
      fi
    done
  fi
}

# Perform the encryption or decryption based on the argument provided
if [ "$1" = "decrypt" ]; then
  # decrypt_files
  process_files "decrypt" "$source_directory"
  process_files "decrypt" "$source_env_directory"
  echo "Decryption completed."
elif [ "$1" = "restore" ]; then
  # decrypt_files
  process_files "restore" "$source_directory"
  process_files "restore" "$source_env_directory"
  echo "Restore completed."
else
  # encrypt_files
  process_files "encrypt" "$source_directory"
  process_files "encrypt" "$source_env_directory"
  echo "Encryption completed."
fi
