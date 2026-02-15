#!/usr/bin/env bash
# pwd.sh - Password manager using GnuPG symmetric encryption
# macOS-compatible version
# Based on https://github.com/drduh/pwd.sh
#set -x  # uncomment to debug
set -o errtrace
set -o nounset
set -o pipefail
umask 077
export LC_ALL="C"

now="$(date +%s)"
today="$(date +%F)"
gpg="$(command -v gpg || command -v gpg2)"
gpg_conf="${HOME}/.gnupg/gpg.conf"

# Detect OS and set clipboard defaults
if [[ "$(uname)" = "Darwin" ]] ; then
  default_clip="pbcopy"
  default_clip_args=""
  default_dest="clipboard"
else
  default_clip="xclip"
  default_clip_args=""
  default_dest="clipboard"
fi

clip="${PWDSH_CLIP:=${default_clip}}"
clip_args="${PWDSH_CLIP_ARGS:=${default_clip_args}}"
clip_dest="${PWDSH_DEST:=${default_dest}}"
clip_timeout="${PWDSH_TIME:=10}"
comment="${PWDSH_COMMENT:=}"
daily_backup="${PWDSH_DAILY:=}"
pass_copy="${PWDSH_COPY:=}"
pass_echo="${PWDSH_ECHO:=*}"
pass_len="${PWDSH_LEN:=14}"
pepper="${PWDSH_PEPPER:=}"
safe_dir="${PWDSH_SAFE:=safe}"
safe_ix="${PWDSH_INDEX:=pwd.index}"
safe_backup="${PWDSH_BACKUP:=pwd.$(hostname).${today}.tar}"
pass_chars="${PWDSH_CHARS:='[:alnum:]!?@#$%^&*();:+='}"

# Use GNU sed if available (macOS ships BSD sed)
if command -v gsed &>/dev/null ; then
  sed_cmd="gsed"
else
  sed_cmd="sed"
fi

trap cleanup EXIT INT TERM
cleanup () {
  # "Lock" files on trapped exits.

  ret=$?
  chmod -R 0000 "${pepper}" "${safe_dir}" "${safe_ix}" 2>/dev/null
  exit ${ret}
}

fail () {
  # Print an error in red and exit.

  tput setaf 1 ; printf "\nERROR: %s\n" "${1}" ; tput sgr0
  exit 1
}

warn () {
  # Print a warning in yellow.

  tput setaf 3 ; printf "\nWARNING: %s\n" "${1}" ; tput sgr0
}

generate_pepper () {
  # Generate pepper, avoid ambiguous characters.
  # Uses a macOS-compatible approach.

  warn "${pepper} created"

  local raw
  raw="$(tr -dc 'A-Z1-9' < /dev/urandom | \
    tr -d '1IOS5U' | fold -w 30 | head -1)"

  # Insert dashes every 5 characters for readability
  local formatted
  formatted="$(printf '%s' "${raw}" | \
    ${sed_cmd} 's/.\{5\}/&-/g' | ${sed_cmd} 's/-$//')"

  printf "%s" "${formatted}" | \
    tee "${pepper}" || fail "Failed to create ${pepper}"
  printf "\n"
}

get_pass () {
  # Prompt for a password.

  password=""
  prompt="  ${1}"
  printf "\n"

  while IFS= read -p "${prompt}" -r -s -n 1 char ; do
    if [[ ${char} == $'\0' ]] ; then break
    elif [[ ${char} == $'\177' ]] ; then
      if [[ -z "${password}" ]] ; then prompt=""
      else
        prompt=$'\b \b'
        password="${password%?}"
      fi
    else
      prompt="${pass_echo}"
      password+="${char}"
    fi
  done
}

decrypt () {
  # Decrypt with GPG.

  printf "%s" "${1}${pep}" | \
    ${gpg} --armor --batch --no-symkey-cache \
    --decrypt --passphrase-fd 0 "${2}" 2>/dev/null
}

encrypt () {
  # Encrypt with GPG.

  ${gpg} --armor --batch --comment "${comment}" \
    --symmetric --yes --passphrase-fd 3 \
    --output "${2}" "${3}" 3< \
    <(printf "%s" "${1}${pep}") 2>/dev/null
}

read_pass () {
  # Read a password from safe.

  if [[ ! -s "${safe_ix}" ]] ; then fail "${safe_ix} not found" ; fi

  while [[ -z "${username}" ]] ; do
    if [[ -z "${2+x}" ]] ; then read -r -p "
  Username: " username
    else username="${2}" ; fi
  done

  get_pass "Password to access ${safe_ix}: " ; printf "\n"

  spath=$(decrypt "${password}" "${safe_ix}" | \
    grep -F "${username}" | tail -1 | cut -d ":" -f2) || \
      fail "Secret not available"

  emit_pass <(decrypt "${password}" "${spath}") || \
    fail "Failed to decrypt ${spath}"
}

generate_pass () {
  # Generate a password from urandom.

  if [[ -z "${3+x}" ]] ; then read -r -p "
  Password length (default: ${pass_len}): " length
  else length="${3}" ; fi

  if [[ "${length}" =~ ^[0-9]+$ ]] ; then
    pass_len="${length}"
  fi

  tr -dc "${pass_chars}" < /dev/urandom | \
    fold -w "${pass_len}" | head -1
}

generate_user () {
  # Generate a username.
  # Uses /usr/share/dict/words (available on both macOS and Linux).

  local dict="/usr/share/dict/words"
  if [[ ! -f "${dict}" ]] ; then
    # Fallback: random alphanumeric username
    printf "user_%s\n" \
      "$(tr -dc '[:lower:][:digit:]' < /dev/urandom | fold -w 8 | head -1)"
    return
  fi

  printf "%s%s\n" \
    "$(awk 'length > 2 && length < 12 {print(tolower($0))}' \
    "${dict}" | grep -v "'" | sort -R | head -n2 | \
    tr "\n" "_" | iconv -f utf-8 -t ascii//TRANSLIT 2>/dev/null || \
    awk 'length > 2 && length < 12 {print(tolower($0))}' \
    "${dict}" | grep -v "'" | sort -R | head -n2 | tr "\n" "_")" \
    "$(tr -dc '[:digit:]' < /dev/urandom | fold -w 4 | head -1)"
}

write_pass () {
  # Write a password and update the index.

  spath="${safe_dir}/$(tr -dc '[:lower:]' < /dev/urandom | \
    fold -w10 | head -1)"

  if [[ -n "${pass_copy}" ]] ; then
    emit_pass <(printf '%s' "${userpass}") ; fi

  get_pass "Password to access ${safe_ix}: " ; printf "\n"

  printf '%s\n' "${userpass}" | \
    encrypt "${password}" "${spath}" - || \
      fail "Failed saving ${spath}"

  ( if [[ -f "${safe_ix}" ]] ; then
      decrypt "${password}" "${safe_ix}" || return ; fi
    printf "%s@%s:%s\n" "${username}" "${now}" "${spath}") | \
    encrypt "${password}" "${safe_ix}.${now}" - && \
      mv "${safe_ix}.${now}" "${safe_ix}" || \
        fail "Failed saving ${safe_ix}.${now}"
}

list_entry () {
  # Decrypt the index to list entries.

  if [[ ! -s "${safe_ix}" ]] ; then fail "${safe_ix} not found" ; fi
  get_pass "Password to access ${safe_ix}: " ; printf "\n\n"
  decrypt "${password}" "${safe_ix}" || fail "${safe_ix} not available"
}

backup () {
  # Archive index, safe and configuration.

  if [[ ! -f "${safe_backup}" ]] ; then
    if [[ -f "${safe_ix}" && -d "${safe_dir}" ]] ; then
      cp "${gpg_conf}" "gpg.conf.${today}"
      tar cf "${safe_backup}" "${safe_dir}" "${safe_ix}" \
        "${BASH_SOURCE}" "gpg.conf.${today}" && \
          printf "\nArchived %s\n" "${safe_backup}"
      rm -f "gpg.conf.${today}"
    else fail "Nothing to archive" ; fi
  else warn "${safe_backup} exists, skipping archive" ; fi
}

emit_pass () {
  # Use clipboard or stdout and clear after timeout.

  if [[ "${clip_dest}" = "screen" ]] ; then
    printf '\n%s\n' "$(cat ${1})"
  else ${clip} < "${1}" ; fi

  printf "\n"
  while [[ "${clip_timeout}" -gt 0 ]] ; do
    printf "\r\033[K  Password on %s! Clearing in %.d" \
      "${clip_dest}" "$((clip_timeout--))" ; sleep 1
  done
  printf "\r\033[K  Clearing password from %s ..." "${clip_dest}"

  if [[ "${clip_dest}" = "screen" ]] ; then clear
  else
    printf "\n"
    if [[ "$(uname)" = "Darwin" ]] ; then
      printf "" | pbcopy
    else
      printf "" | ${clip}
    fi
  fi
}

new_entry () {
  # Prompt for username and password.

  if [[ -z "${2+x}" ]] ; then read -r -p "
  Username (Enter to generate): " username
  else username="${2}" ; fi

  if [[ -z "${username}" ]] ; then
    username=$(generate_user "$@") ; fi

  if [[ -z "${3+x}" ]] ; then
    get_pass "Password for \"${username}\" (Enter to generate): "
    userpass="${password}"
  fi

  printf "\n"
  if [[ -z "${password}" ]] ; then
    userpass=$(generate_pass "$@") ; fi
}

print_help () {
  # Print help text.

  printf """
  pwd.sh is a Bash shell script to manage passwords and other text-based secrets.

  It uses GnuPG to symmetrically (i.e., using a master password)
  encrypt and decrypt plaintext files.

  Each password is encrypted as a unique, randomly-named file in the
  'safe' directory. An encrypted index maps usernames to the respective
  password file. Both the index and password files can also be decrypted
  directly with GnuPG without this script.

  Prerequisites (macOS):
    brew install gnupg

  Run the script interactively using ./pwd.sh or symlink to a directory in PATH:
    * 'w' to write a password
    * 'r' to read a password
    * 'l' to list passwords
    * 'b' to create an archive for backup

  Options can also be passed on the command line.

  * Create a 20-character password for userName:
    ./pwd.sh w userName 20

  * Read password for userName:
    ./pwd.sh r userName

  * Passwords are stored with an epoch timestamp for revision control.
    The most recent version is copied to clipboard on read.
    To list all passwords or read a specific version of a password:
    ./pwd.sh l
    ./pwd.sh r userName@1574723625

  * Create an archive for backup:
    ./pwd.sh b

  * Restore an archive from backup:
    tar xvf pwd*tar

  Environment variables:
    PWDSH_CLIP       Clipboard command (auto-detected: pbcopy/xclip)
    PWDSH_CLIP_ARGS  Extra args for clipboard command
    PWDSH_DEST       Output destination ('clipboard' or 'screen')
    PWDSH_TIME       Seconds before clearing clipboard (default: 10)
    PWDSH_COMMENT    Unencrypted comment in GPG files
    PWDSH_DAILY      Enable daily backup on write (set to any value)
    PWDSH_COPY       Copy password before write (set to any value)
    PWDSH_ECHO       Character shown when typing (default: *)
    PWDSH_LEN        Default password length (default: 14)
    PWDSH_PEPPER     Additional secret file name
    PWDSH_SAFE       Safe directory name (default: safe)
    PWDSH_INDEX      Index file name (default: pwd.index)
    PWDSH_CHARS      Character set for password generation
"""
}

# --- Main ---

if [[ -z "${gpg}" ]] ; then
  if [[ "$(uname)" = "Darwin" ]] ; then
    fail "GnuPG is not available. Install with: brew install gnupg"
  else
    fail "GnuPG is not available"
  fi
fi

if [[ ! -f "${gpg_conf}" ]] ; then
  # Auto-create minimal gpg.conf if missing
  warn "GnuPG config not found, creating ${gpg_conf}"
  mkdir -p "${HOME}/.gnupg"
  chmod 700 "${HOME}/.gnupg"
  cat > "${gpg_conf}" <<EOF
personal-cipher-preferences AES256 AES192 AES
personal-digest-preferences SHA512 SHA384 SHA256
personal-compress-preferences ZLIB BZIP2 ZIP Uncompressed
default-preference-list SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed
cert-digest-algo SHA512
s2k-digest-algo SHA512
s2k-cipher-algo AES256
charset utf-8
no-comments
no-emit-version
no-greeting
keyid-format 0xlong
list-options show-uid-validity
verify-options show-uid-validity
with-fingerprint
require-cross-certification
no-symkey-cache
use-agent
EOF
  chmod 600 "${gpg_conf}"
fi

if [[ ! -d "${safe_dir}" ]] ; then mkdir -p "${safe_dir}" ; fi

if [[ -n "${pepper}" && ! -f "${pepper}" ]] ; then generate_pepper ; fi

chmod -R 0700 "${pepper}" "${safe_dir}" "${safe_ix}" 2>/dev/null

if [[ -f "${pepper}" ]] ; then pep="$(cat ${pepper})" ; else pep="" ; fi

if [[ -z "$(command -v ${clip})" ]] ; then
  warn "Clipboard not available, passwords will print to screen/stdout!"
  clip_dest="screen"
elif [[ -n "${clip_args}" ]] ; then
  clip+=" ${clip_args}"
fi

username=""
password=""
action=""

if [[ -n "${1+x}" ]] ; then action="${1}" ; fi

while [[ -z "${action}" ]] ; do read -r -n 1 -p "
  Read or Write (or Help for more options): " action
  printf "\n"
done

if [[ "${action}" =~ ^([rR])$ ]] ; then read_pass "$@"
elif [[ "${action}" =~ ^([wW])$ ]] ; then
  new_entry "$@"
  write_pass
  if [[ -n "${daily_backup}" ]] ; then backup ; fi
elif [[ "${action}" =~ ^([lL])$ ]] ; then list_entry
elif [[ "${action}" =~ ^([bB])$ ]] ; then backup
else print_help ; fi

tput setaf 2 ; printf "\nDone\n" ; tput sgr0
