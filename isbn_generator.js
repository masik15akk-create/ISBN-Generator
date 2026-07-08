// isbn_generator.js
const readline = require('readline');
const fs = require('fs');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

function ask(question) {
    return new Promise(resolve => rl.question(question, resolve));
}

class ISBNGenerator {
    static validateISBN10(isbn) {
        const clean = isbn.replace(/[-\s]/g, '');
        if (clean.length !== 10) return false;
        if (!/^\d{9}[0-9Xx]$/.test(clean)) return false;
        let total = 0;
        for (let i = 0; i < 10; i++) {
            const ch = clean[i];
            const val = (ch === 'X' || ch === 'x') ? 10 : parseInt(ch);
            total += val * (10 - i);
        }
        return total % 11 === 0;
    }

    static validateISBN13(isbn) {
        const clean = isbn.replace(/[-\s]/g, '');
        if (clean.length !== 13 || !/^\d{13}$/.test(clean)) return false;
        let total = 0;
        for (let i = 0; i < 13; i++) {
            const digit = parseInt(clean[i]);
            total += digit * (i % 2 === 0 ? 1 : 3);
        }
        return total % 10 === 0;
    }

    static validate(isbn) {
        const clean = isbn.replace(/[-\s]/g, '');
        if (clean.length === 10) {
            return { valid: this.validateISBN10(isbn), type: 'ISBN-10' };
        } else if (clean.length === 13) {
            return { valid: this.validateISBN13(isbn), type: 'ISBN-13' };
        } else {
            return { valid: false, type: 'Unknown' };
        }
    }

    static generateISBN10(prefix = '') {
        let clean = prefix.replace(/[-\s]/g, '');
        if (clean) {
            if (!/^\d+$/.test(clean) || clean.length > 9) {
                throw new Error("Prefix must be digits and up to 9 chars.");
            }
            clean = clean.padEnd(9, '0');
        } else {
            clean = '';
            for (let i = 0; i < 9; i++) {
                clean += Math.floor(Math.random() * 10);
            }
        }
        let total = 0;
        for (let i = 0; i < 9; i++) {
            total += parseInt(clean[i]) * (10 - i);
        }
        const check = (11 - (total % 11)) % 11;
        const checkChar = check === 10 ? 'X' : String(check);
        return clean + checkChar;
    }

    static generateISBN13(prefix = '') {
        let clean = prefix.replace(/[-\s]/g, '');
        if (clean) {
            if (!/^\d+$/.test(clean) || clean.length > 12) {
                throw new Error("Prefix must be digits and up to 12 chars.");
            }
            clean = clean.padEnd(12, '0');
        } else {
            clean = '';
            for (let i = 0; i < 12; i++) {
                clean += Math.floor(Math.random() * 10);
            }
        }
        let total = 0;
        for (let i = 0; i < 12; i++) {
            const digit = parseInt(clean[i]);
            total += digit * (i % 2 === 0 ? 1 : 3);
        }
        const check = (10 - (total % 10)) % 10;
        return clean + String(check);
    }

    static batchGenerate(type, prefixes) {
        const results = [];
        for (const p of prefixes) {
            const prefix = p.trim();
            if (!prefix) continue;
            try {
                const isbn = type === '10' ? this.generateISBN10(prefix) : this.generateISBN13(prefix);
                results.push(isbn);
            } catch (e) {
                results.push(`Error for '${prefix}': ${e.message}`);
            }
        }
        return results;
    }
}

async function main() {
    console.log("=== ISBN Generator ===");
    while (true) {
        console.log("\n1. Generate ISBN-10");
        console.log("2. Generate ISBN-13");
        console.log("3. Validate an ISBN");
        console.log("4. Batch generate from file");
        console.log("5. Exit");
        const choice = await ask("Choose: ");
        switch (choice.trim()) {
            case '1': {
                const prefix = await ask("Enter prefix (group-publisher-title, leave blank for random): ");
                try {
                    const isbn = ISBNGenerator.generateISBN10(prefix);
                    console.log(`Generated ISBN-10: ${isbn}`);
                    console.log(`Check digit: ${isbn.slice(-1)}`);
                } catch (e) {
                    console.log(`Error: ${e.message}`);
                }
                break;
            }
            case '2': {
                const prefix = await ask("Enter prefix (group-publisher-title, leave blank for random): ");
                try {
                    const isbn = ISBNGenerator.generateISBN13(prefix);
                    console.log(`Generated ISBN-13: ${isbn}`);
                    console.log(`Check digit: ${isbn.slice(-1)}`);
                } catch (e) {
                    console.log(`Error: ${e.message}`);
                }
                break;
            }
            case '3': {
                const inp = await ask("Enter ISBN (with or without hyphens): ");
                const result = ISBNGenerator.validate(inp);
                console.log(`Type: ${result.type}`);
                console.log(`Valid: ${result.valid}`);
                break;
            }
            case '4': {
                const fname = await ask("Enter path to file with prefixes (one per line): ");
                try {
                    const data = fs.readFileSync(fname, 'utf8');
                    const prefixes = data.split('\n');
                    const typ = await ask("Type (10 or 13): ");
                    const results = ISBNGenerator.batchGenerate(typ.trim(), prefixes);
                    console.log("\nBatch results:");
                    for (const r of results) {
                        console.log(r);
                    }
                } catch (e) {
                    console.log(`Error: ${e.message}`);
                }
                break;
            }
            case '5':
                console.log("Goodbye!");
                rl.close();
                return;
            default:
                console.log("Invalid choice.");
        }
    }
}

main().catch(console.error);
