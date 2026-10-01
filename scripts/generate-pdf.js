const fs = require('fs');
const { execSync } = require('child_process');

const markdownContent = fs.readFileSync('report.md', 'utf8');

function mdToHtml(md) {
  let html = md
    .replace(/^# (.*$)/gim, '<h1>$1</h1>')
    .replace(/^## (.*$)/gim, '<h2>$1</h2>')
    .replace(/^### (.*$)/gim, '<h3>$1</h3>')
    .replace(/^#### (.*$)/gim, '<h4>$1</h4>')
    .replace(/\*\*(.*?)\*\*/gim, '<strong>$1</strong>')
    .replace(/\*(.*?)\*/gim, '<em>$1</em>')
    .replace(/`([^`]+)`/gim, '<code>$1</code>')
    .replace(/^---$/gim, '<hr/>');

  const lines = html.split('\n');
  let inList = false;
  let result = [];

  for (let line of lines) {
    if (line.trim().startsWith('- ') || line.trim().startsWith('* ')) {
      if (!inList) {
        result.push('<ul>');
        inList = true;
      }
      result.push('<li>' + line.trim().substring(2) + '</li>');
    } else if (/^\d+\.\s/.test(line.trim())) {
      if (!inList) {
        result.push('<ol>');
        inList = true;
      }
      result.push('<li>' + line.trim().replace(/^\d+\.\s/, '') + '</li>');
    } else {
      if (inList) {
        result.push('</ul>');
        inList = false;
      }
      if (line.trim().length > 0 && !line.startsWith('<h') && !line.startsWith('<hr')) {
        result.push('<p>' + line + '</p>');
      } else {
        result.push(line);
      }
    }
  }
  if (inList) result.push('</ul>');
  return result.join('\n');
}

const bodyHtml = mdToHtml(markdownContent);

const fullHtml = `<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Báo cáo Kỹ thuật Mini-Project 3</title>
  <style>
    @page {
      size: A4;
      margin: 20mm;
    }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
      color: #1e293b;
      line-height: 1.6;
      font-size: 13.5px;
      margin: 0;
      padding: 0;
    }
    h1 {
      color: #0f172a;
      font-size: 22px;
      font-weight: 800;
      border-bottom: 2px solid #e2e8f0;
      padding-bottom: 8px;
      margin-top: 0;
    }
    h2 {
      color: #0284c7;
      font-size: 16px;
      font-weight: 700;
      margin-top: 20px;
      margin-bottom: 10px;
      border-left: 4px solid #0284c7;
      padding-left: 8px;
    }
    h3 {
      color: #334155;
      font-size: 14.5px;
      font-weight: 700;
      margin-top: 14px;
      margin-bottom: 6px;
    }
    p {
      margin: 6px 0;
      text-align: justify;
    }
    ul, ol {
      margin: 6px 0 10px 20px;
      padding: 0;
    }
    li {
      margin-bottom: 4px;
    }
    hr {
      border: none;
      border-top: 1px solid #cbd5e1;
      margin: 16px 0;
    }
    code {
      background-color: #f1f5f9;
      color: #0284c7;
      padding: 2px 6px;
      border-radius: 4px;
      font-family: Consolas, monospace;
      font-size: 12px;
    }
    strong {
      color: #0f172a;
    }
  </style>
</head>
<body>
  ${bodyHtml}
</body>
</html>`;

fs.writeFileSync('report.html', fullHtml, 'utf8');

try {
  const path = require('path');
  const edgePath = 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe';
  const htmlPath = path.resolve(__dirname, '..', 'report.html');
  const pdfPath = path.resolve(__dirname, '..', 'report.pdf');
  
  execSync(`"${edgePath}" --headless --disable-gpu --print-to-pdf="${pdfPath}" "${htmlPath}"`);
  console.log('Generated report.pdf successfully!');
} catch (e) {
  console.error('Edge PDF error:', e);
}
