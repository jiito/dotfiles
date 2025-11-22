# Use keychain to keep ssh-agent information available in a file
keychain "$HOME/.ssh/id_rsa"
. "$HOME/.keychain/${HOST}-sh"
