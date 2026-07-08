// isbn_generator.swift
import Foundation

class ISBNGenerator {
    static func validateISBN10(_ isbn: String) -> Bool {
        let clean = isbn.replacingOccurrences(of: "[\\s-]", with: "", options: .regularExpression)
        guard clean.count == 10 else { return false }
        guard clean.range(of: #"^\d{9}[0-9Xx]$"#, options: .regularExpression) != nil else { return false }
        var total = 0
        for (i, ch) in clean.enumerated() {
            let val = (ch == "X" || ch == "x") ? 10 : Int(String(ch))!
            total += val * (10 - i)
        }
        return total % 11 == 0
    }

    static func validateISBN13(_ isbn: String) -> Bool {
        let clean = isbn.replacingOccurrences(of: "[\\s-]", with: "", options: .regularExpression)
        guard clean.count == 13 else { return false }
        guard clean.range(of: #"^\d{13}$"#, options: .regularExpression) != nil else { return false }
        var total = 0
        for (i, ch) in clean.enumerated() {
            let digit = Int(String(ch))!
            total += digit * (i % 2 == 0 ? 1 : 3)
        }
        return total % 10 == 0
    }

    static func validate(_ isbn: String) -> (valid: Bool, type: String) {
        let clean = isbn.replacingOccurrences(of: "[\\s-]", with: "", options: .regularExpression)
        if clean.count == 10 {
            return (validateISBN10(isbn), "ISBN-10")
        } else if clean.count == 13 {
            return (validateISBN13(isbn), "ISBN-13")
        } else {
            return (false, "Unknown")
        }
    }

    static func generateISBN10(_ prefix: String = "") throws -> String {
        var clean = prefix.replacingOccurrences(of: "[\\s-]", with: "", options: .regularExpression)
        if !clean.isEmpty {
            guard clean.range(of: #"^\d+$"#, options: .regularExpression) != nil, clean.count <= 9 else {
                throw NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Prefix must be digits and up to 9 chars."])
            }
            clean = clean.padding(toLength: 9, withPad: "0", startingAt: 0)
        } else {
            clean = (0..<9).map { _ in String(Int.random(in: 0...9)) }.joined()
        }
        var total = 0
        for (i, ch) in clean.enumerated() {
            total += Int(String(ch))! * (10 - i)
        }
        let check = (11 - (total % 11)) % 11
        let checkChar = check == 10 ? "X" : String(check)
        return clean + checkChar
    }

    static func generateISBN13(_ prefix: String = "") throws -> String {
        var clean = prefix.replacingOccurrences(of: "[\\s-]", with: "", options: .regularExpression)
        if !clean.isEmpty {
            guard clean.range(of: #"^\d+$"#, options: .regularExpression) != nil, clean.count <= 12 else {
                throw NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Prefix must be digits and up to 12 chars."])
            }
            clean = clean.padding(toLength: 12, withPad: "0", startingAt: 0)
        } else {
            clean = (0..<12).map { _ in String(Int.random(in: 0...9)) }.joined()
        }
        var total = 0
        for (i, ch) in clean.enumerated() {
            let digit = Int(String(ch))!
            total += digit * (i % 2 == 0 ? 1 : 3)
        }
        let check = (10 - (total % 10)) % 10
        return clean + String(check)
    }

    static func batchGenerate(type: String, prefixes: [String]) -> [String] {
        var results: [String] = []
        for p in prefixes {
            let prefix = p.trimmingCharacters(in: .whitespaces)
            if prefix.isEmpty { continue }
            do {
                let isbn = type == "10" ? try generateISBN10(prefix) : try generateISBN13(prefix)
                results.append(isbn)
            } catch {
                results.append("Error for '\(prefix)': \(error.localizedDescription)")
            }
        }
        return results
    }
}

func main() {
    print("=== ISBN Generator ===")
    while true {
        print("\n1. Generate ISBN-10")
        print("2. Generate ISBN-13")
        print("3. Validate an ISBN")
        print("4. Batch generate from file")
        print("5. Exit")
        print("Choose: ", terminator: "")
        guard let choice = readLine()?.trimmingCharacters(in: .whitespaces) else { continue }
        switch choice {
        case "1":
            print("Enter prefix (group-publisher-title, leave blank for random): ", terminator: "")
            let prefix = readLine() ?? ""
            do {
                let isbn = try ISBNGenerator.generateISBN10(prefix)
                print("Generated ISBN-10: \(isbn)")
                print("Check digit: \(isbn.suffix(1))")
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        case "2":
            print("Enter prefix (group-publisher-title, leave blank for random): ", terminator: "")
            let prefix = readLine() ?? ""
            do {
                let isbn = try ISBNGenerator.generateISBN13(prefix)
                print("Generated ISBN-13: \(isbn)")
                print("Check digit: \(isbn.suffix(1))")
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        case "3":
            print("Enter ISBN (with or without hyphens): ", terminator: "")
            let inp = readLine() ?? ""
            let (valid, type) = ISBNGenerator.validate(inp)
            print("Type: \(type)")
            print("Valid: \(valid)")
        case "4":
            print("Enter path to file with prefixes (one per line): ", terminator: "")
            guard let fname = readLine()?.trimmingCharacters(in: .whitespaces) else { break }
            let fileURL = URL(fileURLWithPath: fname)
            guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
                print("File not found or unreadable.")
                break
            }
            let prefixes = content.components(separatedBy: .newlines)
            print("Type (10 or 13): ", terminator: "")
            let typ = readLine()?.trimmingCharacters(in: .whitespaces) ?? ""
            let results = ISBNGenerator.batchGenerate(type: typ, prefixes: prefixes)
            print("\nBatch results:")
            for r in results { print(r) }
        case "5":
            print("Goodbye!")
            return
        default:
            print("Invalid choice.")
        }
    }
}

main()
