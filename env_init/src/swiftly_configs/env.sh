export SWIFTLY_HOME_DIR="/usr/local/swiftly"
export SWIFTLY_BIN_DIR="/usr/local/bin/swiftly"
if [[ ":$PATH:" != *":$SWIFTLY_BIN_DIR:"* ]]; then
   export PATH="$SWIFTLY_BIN_DIR:$PATH"
fi