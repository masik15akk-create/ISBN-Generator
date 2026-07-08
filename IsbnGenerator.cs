// IsbnGenerator.cs
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;

class ISBNGenerator
{
    public static bool ValidateISBN10(string isbn)
    {
        string clean = Regex.Replace(isbn, @"[-\s]", "");
        if (clean.Length != 10 || !Regex.IsMatch(clean, @"^\d{9}[0-9Xx]$"))
            return false;
        int total = 0;
        for (int i = 0; i < 10; i++)
        {
            char ch = clean[i];
            int val = (ch == 'X' || ch == 'x') ? 10 : ch - '0';
            total += val * (10 - i);
        }
        return total % 11 == 0;
    }

    public static bool ValidateISBN13(string isbn)
    {
        string clean = Regex.Replace(isbn, @"[-\s]", "");
        if (clean.Length != 13 || !Regex.IsMatch(clean, @"^\d{13}$"))
            return false;
        int total = 0;
        for (int i = 0; i < 13; i++)
        {
            int digit = clean[i] - '0';
            total += digit * (i % 2 == 0 ? 1 : 3);
        }
        return total % 10 == 0;
    }

    public static (bool valid, string type) Validate(string isbn)
    {
        string clean = Regex.Replace(isbn, @"[-\s]", "");
        if (clean.Length == 10)
            return (ValidateISBN10(isbn), "ISBN-10");
        else if (clean.Length == 13)
            return (ValidateISBN13(isbn), "ISBN-13");
        else
            return (false, "Unknown");
    }

    public static string GenerateISBN10(string prefix = "")
    {
        string clean = Regex.Replace(prefix, @"[-\s]", "");
        if (!string.IsNullOrEmpty(clean))
        {
            if (!Regex.IsMatch(clean, @"^\d+$") || clean.Length > 9)
                throw new Exception("Prefix must be digits and up to 9 chars.");
            clean = clean.PadRight(9, '0');
        }
        else
        {
            Random rand = new Random();
            clean = string.Concat(Enumerable.Range(0, 9).Select(_ => rand.Next(10).ToString()));
        }
        int total = 0;
        for (int i = 0; i < 9; i++)
        {
            total += (clean[i] - '0') * (10 - i);
        }
        int check = (11 - (total % 11)) % 11;
        string checkChar = check == 10 ? "X" : check.ToString();
        return clean + checkChar;
    }

    public static string GenerateISBN13(string prefix = "")
    {
        string clean = Regex.Replace(prefix, @"[-\s]", "");
        if (!string.IsNullOrEmpty(clean))
        {
            if (!Regex.IsMatch(clean, @"^\d+$") || clean.Length > 12)
                throw new Exception("Prefix must be digits and up to 12 chars.");
            clean = clean.PadRight(12, '0');
        }
        else
        {
            Random rand = new Random();
            clean = string.Concat(Enumerable.Range(0, 12).Select(_ => rand.Next(10).ToString()));
        }
        int total = 0;
        for (int i = 0; i < 12; i++)
        {
            int digit = clean[i] - '0';
            total += digit * (i % 2 == 0 ? 1 : 3);
        }
        int check = (10 - (total % 10)) % 10;
        return clean + check.ToString();
    }

    public static List<string> BatchGenerate(string type, string[] prefixes)
    {
        var results = new List<string>();
        foreach (var p in prefixes)
        {
            string prefix = p.Trim();
            if (string.IsNullOrEmpty(prefix)) continue;
            try
            {
                string isbn = type == "10" ? GenerateISBN10(prefix) : GenerateISBN13(prefix);
                results.Add(isbn);
            }
            catch (Exception e)
            {
                results.Add($"Error for '{prefix}': {e.Message}");
            }
        }
        return results;
    }

    static void Main()
    {
        Console.WriteLine("=== ISBN Generator ===");
        while (true)
        {
            Console.WriteLine("\n1. Generate ISBN-10");
            Console.WriteLine("2. Generate ISBN-13");
            Console.WriteLine("3. Validate an ISBN");
            Console.WriteLine("4. Batch generate from file");
            Console.WriteLine("5. Exit");
            Console.Write("Choose: ");
            string choice = Console.ReadLine()?.Trim() ?? "";
            switch (choice)
            {
                case "1":
                    Console.Write("Enter prefix (group-publisher-title, leave blank for random): ");
                    string prefix1 = Console.ReadLine()?.Trim() ?? "";
                    try
                    {
                        string isbn = GenerateISBN10(prefix1);
                        Console.WriteLine($"Generated ISBN-10: {isbn}");
                        Console.WriteLine($"Check digit: {isbn[^1]}");
                    }
                    catch (Exception e) { Console.WriteLine($"Error: {e.Message}"); }
                    break;
                case "2":
                    Console.Write("Enter prefix (group-publisher-title, leave blank for random): ");
                    string prefix2 = Console.ReadLine()?.Trim() ?? "";
                    try
                    {
                        string isbn = GenerateISBN13(prefix2);
                        Console.WriteLine($"Generated ISBN-13: {isbn}");
                        Console.WriteLine($"Check digit: {isbn[^1]}");
                    }
                    catch (Exception e) { Console.WriteLine($"Error: {e.Message}"); }
                    break;
                case "3":
                    Console.Write("Enter ISBN (with or without hyphens): ");
                    string inp = Console.ReadLine()?.Trim() ?? "";
                    var (valid, type) = Validate(inp);
                    Console.WriteLine($"Type: {type}");
                    Console.WriteLine($"Valid: {valid}");
                    break;
                case "4":
                    Console.Write("Enter path to file with prefixes (one per line): ");
                    string fname = Console.ReadLine()?.Trim() ?? "";
                    if (!File.Exists(fname))
                    {
                        Console.WriteLine("File not found.");
                        break;
                    }
                    string[] prefixes = File.ReadAllLines(fname);
                    Console.Write("Type (10 or 13): ");
                    string typ = Console.ReadLine()?.Trim() ?? "";
                    var results = BatchGenerate(typ, prefixes);
                    Console.WriteLine("\nBatch results:");
                    foreach (var r in results)
                        Console.WriteLine(r);
                    break;
                case "5":
                    Console.WriteLine("Goodbye!");
                    return;
                default:
                    Console.WriteLine("Invalid choice.");
                    break;
            }
        }
    }
}
