#!/bin/bash

# React.FC削除後のコンポーネントに型引数と戻り値型を追加

cd /Users/masakazuiwahara/Development/tempo-ai/app/src/components

# パターン1: export const Component = ({ ... }) => {
# → export const Component = ({ ... }: Props): React.ReactElement => {
for file in *.tsx; do
  if [ -f "$file" ]; then
    # Props型定義があるか確認
    if grep -q "interface.*Props" "$file" || grep -q "type.*Props" "$file"; then
      PROPS_NAME=$(grep -o "interface [A-Z][A-Za-z]*Props" "$file" | head -1 | awk '{print $2}')
      if [ -z "$PROPS_NAME" ]; then
        PROPS_NAME=$(grep -o "type [A-Z][A-Za-z]*Props" "$file" | head -1 | awk '{print $2}')
      fi
      
      if [ -n "$PROPS_NAME" ]; then
        # React.FCが削除されたコンポーネントを検出して型を追加
        sed -i '' "s/export const \([A-Z][A-Za-z]*\)= (/export const \1 = (/g" "$file"
        sed -i '' "s/) => {/): React.ReactElement => {/g" "$file"
      fi
    fi
  fi
done

echo "Component type fixes applied"

