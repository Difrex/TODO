#!/bin/bash

PWD=`pwd`
BIN_PATH=${HOME}/.local/bin

mkdir -p $BIN_PATH

cat > $BIN_PATH/todo << EOF
#!/bin/bash

cd $PWD
./todo.pl "\$@"
cd - >/dev/null 2>/dev/null
EOF

chmod +x $BIN_PATH/todo

echo "Please add $BIN_PATH to your \$PATH variable"
