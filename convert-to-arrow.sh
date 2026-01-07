#!/bin/bash

# function宣言をArrow関数に変換するスクリプト

cd /Users/masakazuiwahara/Development/tempo-ai/app

count=0

for file in $(find . -name "*.tsx" -type f -path "*/app/*"); do
  if grep -q "^export default function" "$file"; then
    # ファイル名からコンポーネント名を取得
    component_name=$(grep "^export default function" "$file" | head -1 | sed 's/export default function \([A-Za-z0-9]*\).*/\1/')
    
    if [ -n "$component_name" ]; then
      # 一時ファイルに変換結果を保存
      tmpfile=$(mktemp)
      
      # export default function を const に変換
      sed "s/^export default function ${component_name}/const ${component_name} = /" "$file" > "$tmpfile"
      
      # ファイルの最後に export default を追加
      if ! grep -q "^export default ${component_name}" "$tmpfile"; then
        echo "" >> "$tmpfile"
        echo "export default ${component_name};" >> "$tmpfile"
      fi
      
      mv "$tmpfile" "$file"
      echo "✓ Converted: $file ($component_name)"
      ((count++))
    fi
  fi
done

echo ""
echo "Total converted: $count files"

