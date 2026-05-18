# pub
public files

## bootstrap

```bash
BOOTSTRAP_SRC="https://raw.githubusercontent.com/ency98/pub/refs/heads/main/bootstrap.sh"
FUNC_SRC="https://raw.githubusercontent.com/ency98/pub/refs/heads/main/_func.sh"
TEMP_DEST="/tmp"
DEST="$HOME/.scripts"
[ -f "$TEMP_DEST/_func.sh" ] && rm -f "$TEMP_DEST/_func.sh" && \
[ -f "$TEMP_DEST/bootstrap.sh" ] && rm -f "$TEMP_DEST/bootstrap.sh" && \
[ -f "$DEST/_func.sh" ] && rm -f "$DEST/_func.sh" && \
[ -f "$DEST/_functions.sh" ] && rm -f "$DEST/_functions.sh" && \
[ -f "$DEST/bootstrap.sh" ] && rm -f "$DEST/bootstrap.sh" && \
wget -O "$BOOTSTRAP_SRC" "$TEMP_DEST/bootstrap.sh" && \
wget -O "$FUNC_DEST" "$TEMP_DEST/_functions.sh" && \
[ ! -d "$DEST" ] && mkdir -p "$DEST" && \
mv -fv "$TEMP_DEST/_functions.sh" "$DEST/_functions.sh" && \
mv -fv "$TEMP_DEST/bootstrap.sh" "$DEST/bootstrap.sh" && \
chmod +x "$DEST/*.sh" && \
unset BOOTSTRAP_SRC
unset FUNC_SRC
unset TEMP_DEST
unset DEST
"~/.scripts/bootstrap.sh"
```

If you need to run the script again you can run:

`bootstrap`

or

`wget -qO- $BOOTSTRAP_SRC | bash`

wget -O "$BOOTSTRAP_DEST" "$BOOTSTRAP_SRC"
BOOTSTRAP_SRC="https://raw.githubusercontent.com/ency98/pub/refs/heads/main/bootstrap.sh"
BOOTSTRAP_DEST="/tmp/bootstrap.sh"
cd "$HOME" && mkdir -p "$HOME/.scripts" && \
rm -f "$HOME/.scripts/bootstrap.sh" "$BOOTSTRAP_DEST" && \
wget -O "$BOOTSTRAP_DEST" "$BOOTSTRAP_SRC" && \
chmod +x "$BOOTSTRAP_DEST" && \
mv -v "$BOOTSTRAP_DEST" "$HOME/.scripts/bootstrap.sh" && \
unset BOOTSTRAP_SRC && \
unset BOOTSTRAP_DEST

If you need to run the script again you can run:

after reloading your shell `bootstrap`