#!/usr/bin/env bash
#
# Bootstraps make, then hands off to `make deps` for all dependency installation.
# Reads pinned versions from scripts/versions.env.
#
# This script's only job is to ensure make is available. All actual dependency
# installation logic lives in the Makefile as platform-specific targets.
#
# Usage: ./scripts/install-deps.sh

set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PROJECT_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)

. "$SCRIPT_DIR/versions.env"

# --- Helpers ---

print_ok() {
    echo "  ✓ $1"
}

print_warn() {
    echo "  ⚠ $1"
}

print_info() {
    echo "  → $1"
}

detect_os() {
    case "$(uname -s)" in
        Linux*)          echo "linux" ;;
        Darwin*)         echo "macos" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *)               echo "unknown" ;;
    esac
}

OS=$(detect_os)

if [ "$OS" = "unknown" ]; then
    echo "Unsupported operating system. Please install dependencies manually."
    echo "See the Prerequisites section in README.md."
    exit 1
fi

# --- make bootstrap ---
#
# If make is available, hand off immediately.
# If not, attempt to install it for the current platform, then hand off.
# On Windows, automatic installation is not supported — instructions are printed.

handoff_to_make() {
    echo ""
    echo "Handing off to: make deps"
    echo ""
    LOVE_TEMPLATE_BOOTSTRAP=true exec make -f "$SCRIPT_DIR/Makefile" deps
}

install_make_linux() {
    if command -v yay > /dev/null 2>&1; then
        print_info "Installing make via yay (AUR)..."
        yay -S --noconfirm make
    elif command -v pacman > /dev/null 2>&1; then
        print_info "Installing make via pacman..."
        sudo pacman -S --noconfirm make
    else
        print_info "Installing make via apt..."
        sudo apt-get install -y make
    fi
}

install_make_macos() {
    if xcode-select -p > /dev/null 2>&1; then
        print_ok "Xcode Command Line Tools already installed (make should be available)"
    else
        print_info "Installing Xcode Command Line Tools (includes make)..."
        print_warn "This opens an interactive installer — follow the prompts, then re-run this script."
        xcode-select --install
        exit 0
    fi
}

echo ""
echo "=== make ==="

if command -v make > /dev/null 2>&1; then
    print_ok "make $(make --version 2>&1 | head -1)"
    handoff_to_make
fi

print_warn "make not found"

case "$OS" in
    linux)
        install_make_linux
        if command -v make > /dev/null 2>&1; then
            print_ok "make installed"
            handoff_to_make
        else
            echo ""
            echo "make installation failed. Install it manually, then run: ./setup.sh"
            exit 1
        fi
        ;;
    macos)
        install_make_macos
        if command -v make > /dev/null 2>&1; then
            print_ok "make installed"
            handoff_to_make
        else
            echo ""
            echo "make not yet available. Re-run this script after the Xcode installer completes."
            exit 1
        fi
        ;;
    windows)
        echo ""
        print_warn "Automatic make installation is not supported on Windows."
        print_info "Options:"
        print_info "  • Install Make for Windows: https://gnuwin32.sourceforge.net/packages/make.htm"
        print_info "  • Use WSL (Windows Subsystem for Linux) and run this script there"
        print_info "  • Install via Chocolatey: choco install make"
        echo ""
        echo "Once make is installed, run: ./setup.sh"
        exit 1
        ;;
esac
