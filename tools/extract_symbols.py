# extract_symbols.py
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "cxxfilt",
# ]
# ///

import subprocess
import sys
import re
import platform
import argparse
import cxxfilt  # for demangling C++ symbols

class SymbolExtractor:
    def __init__(self, ignore_cpp=False):
        self.ignore_cpp = ignore_cpp

    def is_cpp_symbol(self, symbol):
        """Check if a symbol is a C++ mangled name"""
        # Common C++ mangling patterns
        cpp_patterns = [
            r'^_Z',      # GNU/Clang C++ mangling
            r'\?\?',     # MSVC C++ mangling
            r'__Z',      # Another common C++ mangling prefix
        ]

        return any(re.match(pattern, symbol) for pattern in cpp_patterns)

    def try_demangle(self, symbol):
        """Attempt to demangle a symbol, return None if it's not a C++ symbol"""
        try:
            demangled = cxxfilt.demangle(symbol)
            # If demangled is different from the original, it's a C++ symbol
            return demangled if demangled != symbol else None
        except:
            return None

    def filter_symbol(self, symbol):
        """Return True if symbol should be included"""
        if not self.ignore_cpp:
            return True

        # Try to identify C++ symbols
        if self.is_cpp_symbol(symbol):
            return False

        # Additional check using demangling
        if self.try_demangle(symbol):
            return False

        return True

    def get_symbols_unix(self, library_path):
        try:
            # Use nm to list symbols
            result = subprocess.run(['nm', '-g', library_path],
                                    capture_output=True, text=True)

            symbols = set()
            for line in result.stdout.splitlines():
                # Look for lines with T, W (text/weak), D, B (data/bss) symbols
                match = re.search(r'[0-9a-fA-F]+ [TWDB] (\w+)', line)
                if match:
                    symbol = match.group(1)
                    if self.filter_symbol(symbol):
                        symbols.add(symbol)

            return sorted(list(symbols))
        except subprocess.CalledProcessError as e:
            print(f"Error running nm: {e}", file=sys.stderr)
            return []

    def get_symbols_windows(self, library_path):
        try:
            # Use dumpbin to list symbols
            result = subprocess.run(['dumpbin', '/SYMBOLS', library_path],
                                    capture_output=True, text=True)

            symbols = set()
            for line in result.stdout.splitlines():
                # Adjust this pattern based on dumpbin output format
                match = re.search(r'External\s+\|\s+(\w+)', line)
                if match:
                    symbol = match.group(1)
                    if self.filter_symbol(symbol):
                        symbols.add(symbol)

            return sorted(list(symbols))
        except subprocess.CalledProcessError as e:
            print(f"Error running dumpbin: {e}", file=sys.stderr)
            return []

def save_symbols(symbols, output_file):
    with open(output_file, 'w') as f:
        for symbol in symbols:
            f.write(f"{symbol}\n")

def parse_arguments():
    parser = argparse.ArgumentParser(description='Extract symbols from a static library')
    parser.add_argument('library_path', help='Path to the static library')
    parser.add_argument('output_file', help='Path to the output file')
    parser.add_argument('--ignore-cpp', action='store_true',
                        help='Ignore C++ symbols (identified by name mangling)')
    parser.add_argument('--verbose', '-v', action='store_true',
                        help='Print verbose information about processed symbols')
    return parser.parse_args()

def main():
    args = parse_arguments()

    extractor = SymbolExtractor(ignore_cpp=args.ignore_cpp)

    if platform.system() == 'Windows':
        symbols = extractor.get_symbols_windows(args.library_path)
    else:
        symbols = extractor.get_symbols_unix(args.library_path)

    if args.verbose:
        print(f"Processing library: {args.library_path}")
        total_symbols = len(symbols)
        print(f"Found {total_symbols} symbols after filtering")

        # Print some sample symbols
        if symbols:
            print("\nSample symbols:")
            for symbol in symbols[:5]:
                print(f"  {symbol}")
            if len(symbols) > 5:
                print("  ...")

    save_symbols(symbols, args.output_file)
    print(f"Saved {len(symbols)} symbols to {args.output_file}")

if __name__ == "__main__":
    main()