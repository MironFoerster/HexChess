#!/bin/sh
echo -ne '\033c\033]0;HexChess\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/test_server.pck" "$@"
