#!/usr/bin/env python3
"""
CodeRabbit未修正コメント抽出スクリプト
"""

import json
import re
from pathlib import Path

# 修正済みの項目
RESOLVED_ISSUES = {
    'health.ts': 'health.ts分割完了 (547行 → 4ファイル)',
    'Timeframe': 'Timeframe型重複削除完了',
    'PrimaryButton': 'PrimaryButton未使用import削除完了',
    'mockData.ts': 'mockData.ts分割完了 (918行 → 6ファイル)',
    'healthStore.ts': 'healthStore.ts分割完了 (503行 → 3ファイル)',
}

def extract_issues_from_body(body):
    """コメント本文から個別の問題を抽出"""
    issues = []
    
    # マークダウンのセクションやリストアイテムで分割
    lines = body.split('\n')
    current_issue = []
    in_details = False
    
    for line in lines:
        # <details>タグの処理
        if '<details>' in line:
            in_details = True
        if '</details>' in line:
            in_details = False
            continue
            
        # 新しい問題の開始を検出
        if line.startswith('###') or line.startswith('##') or (line.startswith('-') and not in_details):
            if current_issue:
                issue_text = '\n'.join(current_issue)
                # 修正済みかチェック
                is_resolved = any(key in issue_text for key in RESOLVED_ISSUES.keys())
                if not is_resolved:
                    issues.append(issue_text)
            current_issue = [line]
        elif current_issue:
            current_issue.append(line)
    
    # 最後の問題を追加
    if current_issue:
        issue_text = '\n'.join(current_issue)
        is_resolved = any(key in issue_text for key in RESOLVED_ISSUES.keys())
        if not is_resolved:
            issues.append(issue_text)
    
    return issues

def main():
    # インラインコメント読み込み
    inline_path = Path('docs/reviews/pr-59-coderabbit-inline-comments.json')
    review_path = Path('docs/reviews/pr-59-review-comments.json')
    
    all_issues = {
        'critical': [],
        'major': [],
        'minor': [],
        'suggestions': []
    }
    
    # インラインコメント処理
    if inline_path.exists():
        with open(inline_path) as f:
            for line in f:
                try:
                    comment = json.loads(line.strip())
                    body = comment.get('body', '')
                    path = comment.get('path', 'unknown')
                    
                    # 修正済みチェック
                    if any(key in body or key in path for key in RESOLVED_ISSUES.keys()):
                        continue
                    
                    # 重要度判定
                    if '🔴 Critical' in body or 'Critical:' in body:
                        all_issues['critical'].append({
                            'type': 'inline',
                            'file': path,
                            'line': comment.get('line'),
                            'body': body[:500]
                        })
                    elif '🟠 Major' in body or '⚠️' in body:
                        all_issues['major'].append({
                            'type': 'inline',
                            'file': path,
                            'line': comment.get('line'),
                            'body': body[:300]
                        })
                    elif '🟡 Minor' in body:
                        all_issues['minor'].append({
                            'type': 'inline',
                            'file': path,
                            'body': body[:200]
                        })
                    else:
                        all_issues['suggestions'].append({
                            'type': 'inline',
                            'file': path,
                            'body': body[:200]
                        })
                except:
                    pass
    
    # レビューコメント処理
    if review_path.exists():
        with open(review_path) as f:
            for line in f:
                try:
                    comment = json.loads(line.strip())
                    body = comment.get('body', '')
                    
                    # 大きなレビューコメントから個別問題を抽出
                    issues = extract_issues_from_body(body)
                    
                    for issue in issues:
                        if '🔴' in issue or 'Critical' in issue:
                            all_issues['critical'].append({
                                'type': 'review',
                                'body': issue[:500]
                            })
                        elif '🟠' in issue or '⚠️' in issue:
                            all_issues['major'].append({
                                'type': 'review',
                                'body': issue[:300]
                            })
                        elif '🟡' in issue:
                            all_issues['minor'].append({
                                'type': 'review',
                                'body': issue[:200]
                            })
                except:
                    pass
    
    # マークダウン出力
    output = []
    output.append('# CodeRabbit PR #59 - 未修正コメント一覧')
    output.append('\n**抽出日**: 2026-01-07')
    output.append(f'**総未修正件数**: {sum(len(v) for v in all_issues.values())}件\n')
    output.append('---\n')
    
    output.append('## ✅ 修正済み項目\n')
    for key, desc in RESOLVED_ISSUES.items():
        output.append(f'- ✅ {desc}')
    output.append('\n---\n')
    
    output.append('## 📊 未修正サマリー\n')
    output.append(f'- 🔴 **Critical**: {len(all_issues["critical"])}件')
    output.append(f'- 🟠 **Major**: {len(all_issues["major"])}件')
    output.append(f'- 🟡 **Minor**: {len(all_issues["minor"])}件')
    output.append(f'- 💡 **Suggestions**: {len(all_issues["suggestions"])}件')
    output.append(f'- **合計**: {sum(len(v) for v in all_issues.values())}件\n')
    output.append('---\n')
    
    # Critical
    if all_issues['critical']:
        output.append(f'\n## 🔴 Critical Issues ({len(all_issues["critical"])} 件)\n')
        for i, issue in enumerate(all_issues['critical'], 1):
            output.append(f'\n### {i}. {issue.get("file", "General")}')
            if 'line' in issue and issue['line']:
                output.append(f'   **Line**: {issue["line"]}')
            output.append(f'\n```\n{issue["body"]}\n```\n')
    
    # Major
    if all_issues['major']:
        output.append(f'\n## 🟠 Major Issues ({len(all_issues["major"])} 件)\n')
        for i, issue in enumerate(all_issues['major'][:50], 1):
            output.append(f'\n### {i}. {issue.get("file", "General")}')
            output.append(f'\n```\n{issue["body"]}\n```\n')
    
    # Minor
    if all_issues['minor']:
        output.append(f'\n## 🟡 Minor Issues ({len(all_issues["minor"])} 件)\n')
        for i, issue in enumerate(all_issues['minor'][:30], 1):
            file = issue.get("file", "General")
            output.append(f'- {file}: {issue["body"][:100]}...')
    
    # Suggestions
    if all_issues['suggestions']:
        output.append(f'\n## 💡 Suggestions ({len(all_issues["suggestions"])} 件)\n')
        files_count = {}
        for issue in all_issues['suggestions']:
            file = issue.get("file", "General")
            files_count[file] = files_count.get(file, 0) + 1
        for file, count in sorted(files_count.items()):
            output.append(f'- {file}: {count}件')
    
    # ファイルに書き出し
    output_text = '\n'.join(output)
    with open('docs/reviews/pr-59-unresolved-issues.md', 'w', encoding='utf-8') as f:
        f.write(output_text)
    
    print(f'✅ 未修正コメント抽出完了')
    print(f'   Critical: {len(all_issues["critical"])}件')
    print(f'   Major: {len(all_issues["major"])}件')
    print(f'   Minor: {len(all_issues["minor"])}件')
    print(f'   Suggestions: {len(all_issues["suggestions"])}件')
    print(f'   合計: {sum(len(v) for v in all_issues.values())}件')
    print(f'\n📄 出力: docs/reviews/pr-59-unresolved-issues.md')

if __name__ == '__main__':
    main()

