# Apple System Fonts — Linux Extractor

Extract `.otf` / `.ttf` font files from Apple's official font DMGs on Linux. No macOS required.

## Download the Fonts

Apple provides these as free downloads for developers in .dmg format.

**🔗 [https://developer.apple.com/fonts/](https://developer.apple.com/fonts/)**

Download the DMGs you want (e.g. SF Pro, SF Compact, SF Mono, New York) and place them in the same directory as this script.

## Prerequisites

- **p7zip** — `sudo apt install p7zip-full` (Debian/Ubuntu) or equivalent
- **coreutils** — `sudo apt install coreutils` (provides `realpath`)

The script checks for these automatically and tells you what's missing.

## Quick Start (Start Here)

If you've never done this before and just want the fonts on your machine:

```bash
# Copy this project to your computer (save it somewhere like ~/Apple-system-fonts)
git clone https://github.com/britl37/Apple-system-fonts.git ~/Apple-system-fonts

# Go into the folder
cd ~/Apple-system-fonts

# Install what's needed (Debian/Ubuntu — adjust for your distro)
sudo apt install p7zip-full coreutils

# Put your downloaded .dmg files in this folder, then run:
chmod +x extract_fonts.sh
./extract_fonts.sh

# Install the fonts into your system
mkdir -p ~/.local/share/fonts
cp -r extracted_fonts/* ~/.local/share/fonts/
fc-cache -fv
```

> **Don't have git?** Download the ZIP from the green "Code" button at the top of this page, unzip it, and continue from the `cd` step above.

## Prerequisites

- **p7zip** — `sudo apt install p7zip-full` (Debian/Ubuntu) or equivalent
- **coreutils** — `sudo apt install coreutilities` (provides `realpath`)

The script also checks for these automatically and tells you what's missing.

## Usage

```bash
# Extract all .dmg files in the current directory
./extract_fonts.sh

# Or specify a custom output directory
./extract_fonts.sh ~/Fonts/Apple
```

Output defaults to `./extracted_fonts/` in the script's directory.

## How It Works

Apple font DMGs use a nested archive structure:

```
.dmg → .pkg → Payload → Payload~ → Library/Fonts/*.otf
```

The script walks through each layer automatically with `7z` and moves all discovered `.otf` / `.ttf` files into the output directory.

## License

The fonts are © Apple. See Apple's license terms on the download page. This script tool is MIT-licensed.
