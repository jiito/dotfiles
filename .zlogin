# Use keychain to keep ssh-agent information available in a file
keychain "$HOME/.ssh/id_rsa" >/dev/null
. "$HOME/.keychain/${HOST}-sh" >/dev/null
