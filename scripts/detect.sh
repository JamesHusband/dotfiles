#!/bin/sh
# OS detection utilities for Dot Phials

detect_os() {
    case "$(uname -s)" in
        Linux*)
            if [ -f /etc/arch-release ]; then
                echo "arch"
            else
                echo "linux"
            fi
            ;;
        Darwin*)
            echo "darwin"
            ;;
        MINGW*|MSYS*|CYGWIN*|Windows_NT*)
            echo "windows"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

is_arch() {
    [ "$(detect_os)" = "arch" ]
}

is_darwin() {
    [ "$(detect_os)" = "darwin" ]
}

is_windows() {
    [ "$(detect_os)" = "windows" ]
}
