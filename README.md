# Apple System Fonts — Linux Extractor

Extract `.otf` / `.ttf` font files from Apple's official font DMGs on Linux. No macOS required.

## Download the Fonts

Apple provides these as free downloads for developers. You need an Apple ID (free tier is fine).

**🔗 [https://developer.apple.com/fonts/](https://developer.apple.com/fonts/)**

Download the DMGs you want (e.g. SF Pro, SF Compact, SF Mono, New York) and place them in the same directory as this script.

## Prerequisites

- **p7zip** — `sudo apt install p7zip-full` (Debian/Ubuntu) or equivalent
- **coreutils** — `sudo apt install coreutils` (provides `realpath`)

The script checks for these automatically and tells you what's missing.

## Usage

```bash
# Make executable (first time only)
chmod +x extract_fonts.sh

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
