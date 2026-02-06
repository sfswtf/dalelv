#!/usr/bin/env node

/**
 * Script to generate favicon files from existing favicon.png
 * 
 * This script uses ImageMagick (convert command) to resize the favicon
 * to different sizes required for various platforms.
 * 
 * Requirements:
 * - ImageMagick installed (brew install imagemagick on macOS)
 * 
 * Usage:
 * node generate-favicons.js
 */

import { execSync } from 'child_process';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const inputFile = path.join(__dirname, 'public', 'favicon.png');
const outputDir = path.join(__dirname, 'public');

const isWindows = process.platform === 'win32';
const magickCmd = isWindows ? 'magick' : 'convert';

// Check if ImageMagick is installed (ImageMagick 7 uses "magick", older uses "convert")
function checkImageMagick() {
  try {
    execSync(`${magickCmd} -version`, { stdio: 'ignore' });
    return true;
  } catch {
    if (!isWindows) {
      try {
        execSync('convert -version', { stdio: 'ignore' });
        return true;
      } catch {}
    }
  }
  return false;
}
if (!checkImageMagick()) {
  console.error('❌ ImageMagick not found. Please install it first:');
  console.error('   macOS: brew install imagemagick');
  console.error('   Linux: sudo apt-get install imagemagick');
  console.error('   Windows: winget install ImageMagick.ImageMagick');
  process.exit(1);
}

// Check if input file exists
if (!fs.existsSync(inputFile)) {
  console.error(`❌ Input file not found: ${inputFile}`);
  process.exit(1);
}

console.log('🎨 Generating favicon files...\n');

const sizes = [
  { name: 'favicon-16x16.png', size: '16x16' },
  { name: 'favicon-32x32.png', size: '32x32' },
  { name: 'apple-touch-icon.png', size: '180x180' },
];

sizes.forEach(({ name, size }) => {
  const outputFile = path.join(outputDir, name);
  try {
    // ImageMagick 7: "magick in -resize ... out"; older: "convert in -resize ... out"
    const cmd = isWindows
      ? `magick "${inputFile}" -resize ${size} -background transparent -gravity center -extent ${size} "${outputFile}"`
      : `convert "${inputFile}" -resize ${size} -background transparent -gravity center -extent ${size} "${outputFile}"`;
    execSync(cmd, { stdio: 'inherit' });
    console.log(`✅ Generated: ${name}`);
  } catch (error) {
    console.error(`❌ Failed to generate ${name}:`, error.message);
  }
});

console.log('\n✨ Done! Favicon files generated in public/ directory.');
console.log('\n📝 Next steps:');
console.log('   1. Review the generated files');
console.log('   2. If needed, manually adjust using an image editor');
console.log('   3. Commit the new favicon files to git');

