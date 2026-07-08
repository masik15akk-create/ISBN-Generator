// isbn_generator.go
package main

import (
	"bufio"
	"fmt"
	"math/rand"
	"os"
	"regexp"
	"strconv"
	"strings"
	"time"
)

type ISBNGenerator struct{}

func (g ISBNGenerator) validateISBN10(isbn string) bool {
	re := regexp.MustCompile(`[-\s]`)
	clean := re.ReplaceAllString(isbn, "")
	if len(clean) != 10 {
		return false
	}
	matched, _ := regexp.MatchString(`^\d{9}[0-9Xx]$`, clean)
	if !matched {
		return false
	}
	total := 0
	for i, ch := range clean {
		var val int
		if ch == 'X' || ch == 'x' {
			val = 10
		} else {
			val = int(ch - '0')
		}
		total += val * (10 - i)
	}
	return total%11 == 0
}

func (g ISBNGenerator) validateISBN13(isbn string) bool {
	re := regexp.MustCompile(`[-\s]`)
	clean := re.ReplaceAllString(isbn, "")
	if len(clean) != 13 {
		return false
	}
	matched, _ := regexp.MatchString(`^\d{13}$`, clean)
	if !matched {
		return false
	}
	total := 0
	for i, ch := range clean {
		digit := int(ch - '0')
		if i%2 == 0 {
			total += digit * 1
		} else {
			total += digit * 3
		}
	}
	return total%10 == 0
}

func (g ISBNGenerator) validate(isbn string) (bool, string) {
	re := regexp.MustCompile(`[-\s]`)
	clean := re.ReplaceAllString(isbn, "")
	if len(clean) == 10 {
		return g.validateISBN10(isbn), "ISBN-10"
	} else if len(clean) == 13 {
		return g.validateISBN13(isbn), "ISBN-13"
	}
	return false, "Unknown"
}

func (g ISBNGenerator) generateISBN10(prefix string) (string, error) {
	re := regexp.MustCompile(`[-\s]`)
	clean := re.ReplaceAllString(prefix, "")
	if clean != "" {
		matched, _ := regexp.MatchString(`^\d+$`, clean)
		if !matched || len(clean) > 9 {
			return "", fmt.Errorf("prefix must be digits and up to 9 chars")
		}
		clean = clean + strings.Repeat("0", 9-len(clean))
	} else {
		clean = ""
		for i := 0; i < 9; i++ {
			clean += strconv.Itoa(rand.Intn(10))
		}
	}
	total := 0
	for i, ch := range clean {
		digit := int(ch - '0')
		total += digit * (10 - i)
	}
	check := (11 - (total % 11)) % 11
	var checkChar string
	if check == 10 {
		checkChar = "X"
	} else {
		checkChar = strconv.Itoa(check)
	}
	return clean + checkChar, nil
}

func (g ISBNGenerator) generateISBN13(prefix string) (string, error) {
	re := regexp.MustCompile(`[-\s]`)
	clean := re.ReplaceAllString(prefix, "")
	if clean != "" {
		matched, _ := regexp.MatchString(`^\d+$`, clean)
		if !matched || len(clean) > 12 {
			return "", fmt.Errorf("prefix must be digits and up to 12 chars")
		}
		clean = clean + strings.Repeat("0", 12-len(clean))
	} else {
		clean = ""
		for i := 0; i < 12; i++ {
			clean += strconv.Itoa(rand.Intn(10))
		}
	}
	total := 0
	for i, ch := range clean {
		digit := int(ch - '0')
		if i%2 == 0 {
			total += digit * 1
		} else {
			total += digit * 3
		}
	}
	check := (10 - (total % 10)) % 10
	return clean + strconv.Itoa(check), nil
}

func (g ISBNGenerator) batchGenerate(isbnType string, prefixes []string) []string {
	results := []string{}
	for _, p := range prefixes {
		p = strings.TrimSpace(p)
		if p == "" {
			continue
		}
		var isbn string
		var err error
		if isbnType == "10" {
			isbn, err = g.generateISBN10(p)
		} else {
			isbn, err = g.generateISBN13(p)
		}
		if err != nil {
			results = append(results, fmt.Sprintf("Error for '%s': %v", p, err))
		} else {
			results = append(results, isbn)
		}
	}
	return results
}

func main() {
	rand.Seed(time.Now().UnixNano())
	gen := ISBNGenerator{}
	scanner := bufio.NewScanner(os.Stdin)
	fmt.Println("=== ISBN Generator ===")
	for {
		fmt.Println("\n1. Generate ISBN-10")
		fmt.Println("2. Generate ISBN-13")
		fmt.Println("3. Validate an ISBN")
		fmt.Println("4. Batch generate from file")
		fmt.Println("5. Exit")
		fmt.Print("Choose: ")
		scanner.Scan()
		choice := strings.TrimSpace(scanner.Text())
		switch choice {
		case "1":
			fmt.Print("Enter prefix (group-publisher-title, leave blank for random): ")
			scanner.Scan()
			prefix := scanner.Text()
			isbn, err := gen.generateISBN10(prefix)
			if err != nil {
				fmt.Println("Error:", err)
			} else {
				fmt.Printf("Generated ISBN-10: %s\n", isbn)
				fmt.Printf("Check digit: %s\n", string(isbn[len(isbn)-1]))
			}
		case "2":
			fmt.Print("Enter prefix (group-publisher-title, leave blank for random): ")
			scanner.Scan()
			prefix := scanner.Text()
			isbn, err := gen.generateISBN13(prefix)
			if err != nil {
				fmt.Println("Error:", err)
			} else {
				fmt.Printf("Generated ISBN-13: %s\n", isbn)
				fmt.Printf("Check digit: %s\n", string(isbn[len(isbn)-1]))
			}
		case "3":
			fmt.Print("Enter ISBN (with or without hyphens): ")
			scanner.Scan()
			inp := scanner.Text()
			valid, typ := gen.validate(inp)
			fmt.Printf("Type: %s\n", typ)
			fmt.Printf("Valid: %v\n", valid)
		case "4":
			fmt.Print("Enter path to file with prefixes (one per line): ")
			scanner.Scan()
			fname := scanner.Text()
			data, err := os.ReadFile(fname)
			if err != nil {
				fmt.Println("Error:", err)
				break
			}
			prefixes := strings.Split(string(data), "\n")
			fmt.Print("Type (10 or 13): ")
			scanner.Scan()
			typ := strings.TrimSpace(scanner.Text())
			results := gen.batchGenerate(typ, prefixes)
			fmt.Println("\nBatch results:")
			for _, r := range results {
				fmt.Println(r)
			}
		case "5":
			fmt.Println("Goodbye!")
			return
		default:
			fmt.Println("Invalid choice.")
		}
	}
}
