#!/bin/bash

# List of files to convert
files=(
  "app/(main)/breathe.tsx"
  "app/(main)/rhythm.tsx"
  "app/(main)/action-detail.tsx"
  "app/(main)/energy-detail.tsx"
  "app/(main)/health-detail.tsx"
  "app/(main)/insight-detail.tsx"
  "app/(main)/insights.tsx"
  "app/(main)/recovery-detail.tsx"
  "app/(main)/rhythm-detail.tsx"
  "app/(main)/settings.tsx"
  "app/(main)/sleep-detail.tsx"
  "app/(main)/_layout.tsx"
  "app/(onboarding)/basic-info.tsx"
  "app/(onboarding)/bedtime.tsx"
  "app/(onboarding)/chronotype.tsx"
  "app/(onboarding)/complete.tsx"
  "app/(onboarding)/healthkit.tsx"
  "app/(onboarding)/index.tsx"
  "app/(onboarding)/lifestyle.tsx"
  "app/(onboarding)/location.tsx"
  "app/(onboarding)/nickname.tsx"
  "app/(onboarding)/_layout.tsx"
  "app/_layout.tsx"
  "app/index.tsx"
)

for file in "${files[@]}"; do
  if [ -f "$file" ]; then
    echo "Converting $file..."
    
    # Extract function name
    func_name=$(grep -o "export default function [A-Za-z]*" "$file" | sed 's/export default function //')
    
    if [ -n "$func_name" ]; then
      # Step 1: Change function declaration to arrow function
      sed -i '' "s/export default function ${func_name}/const ${func_name} = /" "$file"
      
      # Step 2: Change ): Type { to ): Type => {
      sed -i '' "s/\(const ${func_name} = ([^)]*)\): \([A-Za-z.<>]*\) {/\1: \2 => {/" "$file"
      
      # Step 3: Add export default at the end (before last line if it's just })
      # Find the last closing brace and add export before it
      echo "" >> "$file"
      echo "export default ${func_name};" >> "$file"
      
      echo "  ✓ Converted ${func_name}"
    fi
  fi
done

echo "Done!"
