# 📚 ISBN Generator – Multi‑Language Edition

A professional **ISBN (International Standard Book Number) generator and validator** that creates both ISBN‑10 and ISBN‑13 identifiers, with full support for group, publisher, and title parts.

## ✨ Features
- **Generate ISBN‑10** – calculates the correct check digit (mod 11).
- **Generate ISBN‑13** – uses EAN‑13 check digit (mod 10).
- **Auto‑detect type** – guess the ISBN type from a given prefix.
- **Validate** – check if an ISBN‑10 or ISBN‑13 is valid.
- **Custom prefixes** – specify group identifier (e.g., `978` or `979` for books), publisher code, and title number.
- **Batch generation** – generate multiple ISBNs at once.
- **Random valid ISBNs** – produce fully compliant numbers with correct check digits.
- **Interactive CLI** – user‑friendly menus.

## 🗂 Languages & Files
| Language          | File                  |
|-------------------|-----------------------|
| Python            | `isbn_generator.py`   |
| JavaScript        | `isbn_generator.js`   |
| Go                | `isbn_generator.go`   |
| Ruby              | `isbn_generator.rb`   |
| C#                | `IsbnGenerator.cs`    |
| Swift             | `isbn_generator.swift`|
| Java              | `IsbnGenerator.java`  |

## 🚀 How to Run
Each file is standalone – run it with the appropriate interpreter/compiler:

| Language | Command |
|----------|---------|
| Python   | `python isbn_generator.py` |
| JavaScript | `node isbn_generator.js` |
| Go       | `go run isbn_generator.go` |
| Ruby     | `ruby isbn_generator.rb` |
| C#       | `dotnet run` (or `csc IsbnGenerator.cs`) |
| Swift    | `swift isbn_generator.swift` |
| Java     | `javac IsbnGenerator.java && java IsbnGenerator` |

## 📊 Example Session
=== ISBN Generator ===

Generate ISBN-10

Generate ISBN-13

Validate an ISBN

Batch generate

Exit
Choose: 1

Enter optional prefix (group, publisher, title) separated by hyphens, e.g., 978-0-123-456:
(leave blank for random): 0-123-456
Generated ISBN-10: 0-123-456-7
Check digit: 7

Validate? (y/n): y
Valid: true

text

## 🔧 Technical Details
- **ISBN‑10** check digit: sum of digits multiplied by 10..1, modulo 11 (X for 10).
- **ISBN‑13** check digit: EAN‑13 algorithm (alternating weights 1 and 3, mod 10).
- **Structure**: group prefix, publisher, title, check digit.

## 📁 Batch Mode
Supply a text file with one ISBN prefix per line – the program will generate the full ISBN for each.

## 🤝 Contributing
Add support for ISBN‑13 conversion from ISBN‑10, or integrate with external databases – PRs welcome!

## 📜 License
MIT – use freely.
