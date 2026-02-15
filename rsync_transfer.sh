#!/bin/bash
# Usage:
#   ./rsync_transfer.sh <host> upload <local_file> <remote_path>
#   ./rsync_transfer.sh <host> download <remote_file> <local_path>
#
# Example:
#   ./rsync_transfer.sh docpanel upload ./test.txt /home/ujjwal/data/
#   ./rsync_transfer.sh docpanel download /home/ujjwal/data/output.log ./output.log

host=$1
action=$2
src=$3
dest=$4

if [[ -z "$host" || -z "$action" || -z "$src" || -z "$dest" ]]; then
  echo "Usage:"
  echo "  $0 <host> upload <local_file> <remote_path>"
  echo "  $0 <host> download <remote_file> <local_path>"
  exit 1
fi

# ensure ~/.ssh/config has the host entry (optional check)
if ! grep -q "Host $host" ~/.ssh/config; then
  echo "Error: Host '$host' not found in ~/.ssh/config"
  exit 1
fi

case "$action" in
  upload)
    echo "Uploading '$src' → '$dest' on $host ..."
    rsync -avz --progress "$src" "${host}:${dest}"
    ;;
  download)
    echo "Downloading '$src' → '$dest' from $host ..."
    rsync -avz --progress "${host}:${src}" "$dest"
    ;;
  *)
    echo "Unknown action: $action (use 'upload' or 'download')"
    exit 1
    ;;
esac

echo "✅ Transfer complete."
