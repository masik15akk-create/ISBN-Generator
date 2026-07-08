// IsbnGenerator.java
import java.io.*;
import java.util.*;
import java.util.regex.*;

public class IsbnGenerator {
    public static boolean validateISBN10(String isbn) {
        String clean = isbn.replaceAll("[\\s-]", "");
        if (clean.length() != 10 || !clean.matches("\\d{9}[0-9Xx]")) return false;
        int total = 0;
        for (int i = 0; i < 10; i++) {
            char ch = clean.charAt(i);
            int val = (ch == 'X' || ch == 'x') ? 10 : ch - '0';
            total += val * (10 - i);
        }
        return total % 11 == 0;
    }

    public static boolean validateISBN13(String isbn) {
        String clean = isbn.replaceAll("[\\s-]", "");
        if (clean.length() != 13 || !clean.matches("\\d{13}")) return false;
        int total = 0;
        for (int i = 0; i < 13; i++) {
            int digit = clean.charAt(i) - '0';
            total += digit * (i % 2 == 0 ? 1 : 3);
        }
        return total % 10 == 0;
    }

    public static Object[] validate(String isbn) {
        String clean = isbn.replaceAll("[\\s-]", "");
        if (clean.length() == 10) {
            return new Object[]{validateISBN10(isbn), "ISBN-10"};
        } else if (clean.length() == 13) {
            return new Object[]{validateISBN13(isbn), "ISBN-13"};
        } else {
            return new Object[]{false, "Unknown"};
        }
    }

    public static String generateISBN10(String prefix) throws Exception {
        String clean = prefix.replaceAll("[\\s-]", "");
        if (!clean.isEmpty()) {
            if (!clean.matches("\\d+") || clean.length() > 9)
                throw new Exception("Prefix must be digits and up to 9 chars.");
            clean = String.format("%-9s", clean).replace(' ', '0');
        } else {
            Random rand = new Random();
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < 9; i++) sb.append(rand.nextInt(10));
            clean = sb.toString();
        }
        int total = 0;
        for (int i = 0; i < 9; i++) {
            total += (clean.charAt(i) - '0') * (10 - i);
        }
        int check = (11 - (total % 11)) % 11;
        String checkChar = (check == 10) ? "X" : String.valueOf(check);
        return clean + checkChar;
    }

    public static String generateISBN13(String prefix) throws Exception {
        String clean = prefix.replaceAll("[\\s-]", "");
        if (!clean.isEmpty()) {
            if (!clean.matches("\\d+") || clean.length() > 12)
                throw new Exception("Prefix must be digits and up to 12 chars.");
            clean = String.format("%-12s", clean).replace(' ', '0');
        } else {
            Random rand = new Random();
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < 12; i++) sb.append(rand.nextInt(10));
            clean = sb.toString();
        }
        int total = 0;
        for (int i = 0; i < 12; i++) {
            int digit = clean.charAt(i) - '0';
            total += digit * (i % 2 == 0 ? 1 : 3);
        }
        int check = (10 - (total % 10)) % 10;
        return clean + check;
    }

    public static List<String> batchGenerate(String type, List<String> prefixes) {
        List<String> results = new ArrayList<>();
        for (String p : prefixes) {
            String prefix = p.trim();
            if (prefix.isEmpty()) continue;
            try {
                String isbn = type.equals("10") ? generateISBN10(prefix) : generateISBN13(prefix);
                results.add(isbn);
            } catch (Exception e) {
                results.add("Error for '" + prefix + "': " + e.getMessage());
            }
        }
        return results;
    }

    public static void main(String[] args) throws Exception {
        Scanner scanner = new Scanner(System.in);
        System.out.println("=== ISBN Generator ===");
        while (true) {
            System.out.println("\n1. Generate ISBN-10");
            System.out.println("2. Generate ISBN-13");
            System.out.println("3. Validate an ISBN");
            System.out.println("4. Batch generate from file");
            System.out.println("5. Exit");
            System.out.print("Choose: ");
            String choice = scanner.nextLine().trim();
            switch (choice) {
                case "1":
                    System.out.print("Enter prefix (group-publisher-title, leave blank for random): ");
                    String prefix1 = scanner.nextLine().trim();
                    try {
                        String isbn = generateISBN10(prefix1);
                        System.out.println("Generated ISBN-10: " + isbn);
                        System.out.println("Check digit: " + isbn.charAt(isbn.length()-1));
                    } catch (Exception e) {
                        System.out.println("Error: " + e.getMessage());
                    }
                    break;
                case "2":
                    System.out.print("Enter prefix (group-publisher-title, leave blank for random): ");
                    String prefix2 = scanner.nextLine().trim();
                    try {
                        String isbn = generateISBN13(prefix2);
                        System.out.println("Generated ISBN-13: " + isbn);
                        System.out.println("Check digit: " + isbn.charAt(isbn.length()-1));
                    } catch (Exception e) {
                        System.out.println("Error: " + e.getMessage());
                    }
                    break;
                case "3":
                    System.out.print("Enter ISBN (with or without hyphens): ");
                    String inp = scanner.nextLine().trim();
                    Object[] result = validate(inp);
                    System.out.println("Type: " + result[1]);
                    System.out.println("Valid: " + result[0]);
                    break;
                case "4":
                    System.out.print("Enter path to file with prefixes (one per line): ");
                    String fname = scanner.nextLine().trim();
                    File file = new File(fname);
                    if (!file.exists()) {
                        System.out.println("File not found.");
                        break;
                    }
                    List<String> prefixes = new ArrayList<>();
                    try (BufferedReader br = new BufferedReader(new FileReader(file))) {
                        String line;
                        while ((line = br.readLine()) != null) {
                            prefixes.add(line);
                        }
                    }
                    System.out.print("Type (10 or 13): ");
                    String typ = scanner.nextLine().trim();
                    List<String> results = batchGenerate(typ, prefixes);
                    System.out.println("\nBatch results:");
                    for (String r : results) System.out.println(r);
                    break;
                case "5":
                    System.out.println("Goodbye!");
                    scanner.close();
                    return;
                default:
                    System.out.println("Invalid choice.");
            }
        }
    }
}
