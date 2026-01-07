#!/usr/bin/env node

/**
 * function宣言をArrow関数に変換するスクリプト
 */

const fs = require('fs');
const path = require('path');
const glob = require('glob');

// パターン: export default function ComponentName() {
// → const ComponentName = () => {
//   export default ComponentName;

function convertFile(filePath) {
  let content = fs.readFileSync(filePath, 'utf8');
  let modified = false;

  // export default function ComponentName(): ReturnType {
  const pattern = /^export default function\s+([A-Z][A-Za-z0-9]*)\s*\((.*?)\)(\s*:\s*[^{]+)?\s*{/gm;
  
  content = content.replace(pattern, (match, componentName, params, returnType) => {
    modified = true;
    const rt = returnType || '';
    return `const ${componentName} = (${params})${rt} => {`;
  });

  if (modified) {
    // ファイルの最後にexport default文を追加（既にない場合）
    if (!content.includes(`export default ${content.match(/const ([A-Z][A-Za-z0-9]*) = /)?.[1]}`)) {
      const componentName = content.match(/const ([A-Z][A-Za-z0-9]*) = /)?.[1];
      if (componentName) {
        content = content.trimEnd() + `\n\nexport default ${componentName};\n`;
      }
    }
    
    fs.writeFileSync(filePath, content, 'utf8');
    console.log(`✓ Converted: ${filePath}`);
    return true;
  }

  return false;
}

// app/ディレクトリ内の全.tsxファイルを処理
const files = glob.sync('./app/**/*.tsx');
let convertedCount = 0;

files.forEach(file => {
  if (convertFile(file)) {
    convertedCount++;
  }
});

console.log(`\nTotal converted: ${convertedCount} files`);

