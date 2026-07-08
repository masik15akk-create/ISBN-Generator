# isbn_generator.py
import random
import re
from typing import Tuple, List, Optional

class ISBNGenerator:
    @staticmethod
    def validate_isbn10(isbn: str) -> bool:
        """Validate an ISBN-10 (with or without hyphens)."""
        clean = re.sub(r'[-\s]', '', isbn)
        if len(clean) != 10:
            return False
        if not clean[:9].isdigit():
            return False
        if clean[9] not in '0123456789Xx':
            return False
        total = 0
        for i, ch in enumerate(clean):
            if ch in 'Xx':
                val = 10
            else:
                val = int(ch)
            total += val * (10 - i)
        return total % 11 == 0

    @staticmethod
    def validate_isbn13(isbn: str) -> bool:
        """Validate an ISBN-13 (with or without hyphens)."""
        clean = re.sub(r'[-\s]', '', isbn)
        if len(clean) != 13 or not clean.isdigit():
            return False
        total = 0
        for i, ch in enumerate(clean):
            digit = int(ch)
            total += digit * (1 if i % 2 == 0 else 3)
        return total % 10 == 0

    @staticmethod
    def validate(isbn: str) -> Tuple[bool, str]:
        """Detect type and validate."""
        clean = re.sub(r'[-\s]', '', isbn)
        if len(clean) == 10:
            return ISBNGenerator.validate_isbn10(isbn), 'ISBN-10'
        elif len(clean) == 13:
            return ISBNGenerator.validate_isbn13(isbn), 'ISBN-13'
        else:
            return False, 'Unknown'

    @staticmethod
    def generate_isbn10(prefix: str = '') -> str:
        """Generate a random valid ISBN-10. Prefix can be up to 9 digits (group, publisher, title)."""
        if prefix:
            clean = re.sub(r'[-\s]', '', prefix)
            if not clean.isdigit() or len(clean) > 9:
                raise ValueError("Prefix must be digits and up to 9 chars.")
            base = clean.ljust(9, '0')
        else:
            # random 9 digits (but must be valid for known groups, we just generate random)
            # For simplicity, we generate first 9 digits (group+pub+title)
            base = ''.join(str(random.randint(0, 9)) for _ in range(9))
        # compute check digit
        total = 0
        for i, ch in enumerate(base):
            total += int(ch) * (10 - i)
        check = (11 - (total % 11)) % 11
        check_char = 'X' if check == 10 else str(check)
        isbn = base + check_char
        # format with hyphens: for display we can add, but we return raw
        return isbn

    @staticmethod
    def generate_isbn13(prefix: str = '') -> str:
        """Generate a random valid ISBN-13. Prefix can be up to 12 digits (group, publisher, title)."""
        if prefix:
            clean = re.sub(r'[-\s]', '', prefix)
            if not clean.isdigit() or len(clean) > 12:
                raise ValueError("Prefix must be digits and up to 12 chars.")
            base = clean.ljust(12, '0')
        else:
            base = ''.join(str(random.randint(0, 9)) for _ in range(12))
        # compute EAN-13 check digit
        total = 0
        for i, ch in enumerate(base):
            digit = int(ch)
            total += digit * (1 if i % 2 == 0 else 3)
        check = (10 - (total % 10)) % 10
        return base + str(check)

    @staticmethod
    def batch_generate(isbn_type: str, prefixes: List[str]) -> List[str]:
        """Generate ISBNs from a list of prefixes."""
        results = []
        for p in prefixes:
            p = p.strip()
            if not p:
                continue
            try:
                if isbn_type == '10':
                    results.append(ISBNGenerator.generate_isbn10(p))
                elif isbn_type == '13':
                    results.append(ISBNGenerator.generate_isbn13(p))
                else:
                    raise ValueError("Type must be '10' or '13'.")
            except Exception as e:
                results.append(f"Error for '{p}': {e}")
        return results

def main():
    gen = ISBNGenerator()
    print("=== ISBN Generator ===")
    while True:
        print("\n1. Generate ISBN-10")
        print("2. Generate ISBN-13")
        print("3. Validate an ISBN")
        print("4. Batch generate from file")
        print("5. Exit")
        choice = input("Choose: ").strip()
        if choice == '1':
            prefix = input("Enter prefix (group-publisher-title, leave blank for random): ").strip()
            try:
                isbn = gen.generate_isbn10(prefix)
                print(f"Generated ISBN-10: {isbn}")
                print(f"Check digit: {isbn[-1]}")
            except Exception as e:
                print(f"Error: {e}")
        elif choice == '2':
            prefix = input("Enter prefix (group-publisher-title, leave blank for random): ").strip()
            try:
                isbn = gen.generate_isbn13(prefix)
                print(f"Generated ISBN-13: {isbn}")
                print(f"Check digit: {isbn[-1]}")
            except Exception as e:
                print(f"Error: {e}")
        elif choice == '3':
            inp = input("Enter ISBN (with or without hyphens): ").strip()
            valid, typ = gen.validate(inp)
            print(f"Type: {typ}")
            print(f"Valid: {valid}")
        elif choice == '4':
            fname = input("Enter path to file with prefixes (one per line): ").strip()
            try:
                with open(fname, 'r') as f:
                    prefixes = f.readlines()
                typ = input("Type (10 or 13): ").strip()
                results = gen.batch_generate(typ, prefixes)
                print("\nBatch results:")
                for r in results:
                    print(r)
            except FileNotFoundError:
                print("File not found.")
            except Exception as e:
                print(f"Error: {e}")
        elif choice == '5':
            print("Goodbye!")
            break
        else:
            print("Invalid choice.")

if __name__ == "__main__":
    main()
