#!/usr/bin/env node
/**
 * Validates that every skills/*\/SKILL.md has the required YAML frontmatter
 * fields: `name` (non-empty string) and `description` (non-empty string).
 *
 * Uses no external dependencies — pure Node.js.
 */

import { readdirSync, readFileSync, statSync } from "fs";
import { join } from "path";

const SKILLS_DIR = new URL("../skills", import.meta.url).pathname;
const REQUIRED_FIELDS = ["name", "description"];

/**
 * Extracts YAML frontmatter from a markdown file.
 * Returns the raw frontmatter string, or null if none found.
 */
function extractFrontmatter(content) {
  const match = content.match(/^---\r?\n([\s\S]*?)\r?\n---/);
  return match ? match[1] : null;
}

/**
 * Minimal YAML parser for simple key: value and key: >\n  ... blocks.
 * Sufficient for validating name and description fields.
 */
function parseFrontmatter(yaml) {
  const result = {};
  const lines = yaml.split(/\r?\n/);
  let i = 0;

  while (i < lines.length) {
    const line = lines[i];
    // Match "key: value" or "key: >" (block scalar)
    const keyMatch = line.match(/^(\w[\w-]*):\s*(.*)/);
    if (!keyMatch) {
      i++;
      continue;
    }

    const key = keyMatch[1];
    const rest = keyMatch[2].trim();

    if (rest === ">" || rest === "|") {
      // Block scalar: collect indented lines
      const parts = [];
      i++;
      while (i < lines.length && (lines[i].startsWith(" ") || lines[i] === "")) {
        parts.push(lines[i].trim());
        i++;
      }
      result[key] = parts.join(" ").trim();
    } else {
      result[key] = rest;
      i++;
    }
  }

  return result;
}

function validateAll() {
  let hasErrors = false;
  const results = [];

  const entries = readdirSync(SKILLS_DIR).filter((name) => {
    const fullPath = join(SKILLS_DIR, name);
    return statSync(fullPath).isDirectory() && name !== "shared";
  });

  if (entries.length === 0) {
    console.error("No skill directories found under skills/");
    process.exit(1);
  }

  for (const dir of entries) {
    const skillPath = join(SKILLS_DIR, dir, "SKILL.md");
    let content;

    try {
      content = readFileSync(skillPath, "utf8");
    } catch {
      console.error(`✗ ${dir}: SKILL.md not found`);
      hasErrors = true;
      continue;
    }

    const raw = extractFrontmatter(content);
    if (!raw) {
      console.error(`✗ ${dir}: no YAML frontmatter found`);
      hasErrors = true;
      continue;
    }

    const fields = parseFrontmatter(raw);
    const missing = REQUIRED_FIELDS.filter(
      (f) => !fields[f] || fields[f].trim() === ""
    );

    if (missing.length > 0) {
      console.error(`✗ ${dir}: missing required fields: ${missing.join(", ")}`);
      hasErrors = true;
    } else {
      results.push(`✓ ${dir} (name: "${fields.name}")`);
    }
  }

  results.forEach((r) => console.log(r));
  console.log(`\n${results.length}/${entries.length} skills passed validation.`);

  if (hasErrors) {
    process.exit(1);
  }
}

validateAll();
