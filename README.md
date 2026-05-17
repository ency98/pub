# pub
public files

## bootstrap

```bash
FUNC_SRC="https://raw.githubusercontent.com/ency98/pub/refs/heads/main/_func.sh"
FUNC_DEST="/tmp/_func.sh"
wget -O "$FUNC_DEST" "$FUNC_SRC"
BOOTSTRAP_SRC="https://raw.githubusercontent.com/ency98/pub/refs/heads/main/bootstrap.sh"
if [ -f "~/.zshrc" ]; then
	echo "export BOOTSTRAP_SRC=$BOOTSTRAP_SRC" >> ~/.zshrc
	echo "alias bootstrap='wget -qO- $BOOTSTRAP_SRC | bash'" >> ~/.zshrc
elif [ -f "~/.bashrc" ]; then
	echo "export BOOTSTRAP_SRC=$BOOTSTRAP_SRC" >> ~/.bashrc
	echo "alias bootstrap='wget -qO- $BOOTSTRAP_SRC | bash'" >> ~/.bashrc
fi
wget -qO- $BOOTSTRAP_SRC | bash
```

If you need to run the script again you can run:

`bootstrap`

or

`wget -qO- $BOOTSTRAP_SRC | bash`