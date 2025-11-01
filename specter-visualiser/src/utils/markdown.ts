import { marked } from 'marked';
import TerminalRenderer from 'marked-terminal';

// Configure marked to use terminal renderer
marked.setOptions({
  // @ts-ignore - marked-terminal types
  renderer: new TerminalRenderer({
    code: (code: string) => code,
    blockquote: (quote: string) => quote,
    html: (html: string) => html,
    heading: (text: string) => text,
    hr: () => '─'.repeat(80),
    list: (body: string) => body,
    listitem: (text: string) => `  • ${text}`,
    paragraph: (text: string) => text,
    // @ts-expect-error - marked-terminal table signature mismatch
    table: (header: string, body: string) => header + body,
    tablerow: (content: string) => content,
    tablecell: (content: string) => content,
    strong: (text: string) => text,
    em: (text: string) => text,
    codespan: (code: string) => code,
    br: () => '\n',
    del: (text: string) => text,
    // @ts-expect-error - marked-terminal link signature mismatch
    link: (href: string, title: string, text: string) => text,
    // @ts-ignore - marked-terminal image signature
    image: (href: string, title: string, text: string) => text,
  }),
});

export function renderMarkdown(markdown: string): string {
  try {
    return marked(markdown) as string;
  } catch (error) {
    console.error('Error rendering markdown:', error);
    return markdown;
  }
}

export function stripMarkdown(markdown: string): string {
  return markdown
    .replace(/#{1,6}\s+/g, '') // Remove headers
    .replace(/\*\*(.+?)\*\*/g, '$1') // Remove bold
    .replace(/\*(.+?)\*/g, '$1') // Remove italic
    .replace(/`(.+?)`/g, '$1') // Remove inline code
    .replace(/\[(.+?)\]\(.+?\)/g, '$1') // Remove links
    .replace(/^\s*[-*+]\s+/gm, '• ') // Convert lists
    .trim();
}

export function truncate(text: string, maxLength: number): string {
  if (text.length <= maxLength) return text;
  return text.slice(0, maxLength - 3) + '...';
}

export function wrapText(text: string, width: number): string[] {
  const words = text.split(' ');
  const lines: string[] = [];
  let currentLine = '';

  for (const word of words) {
    if ((currentLine + word).length > width) {
      if (currentLine) lines.push(currentLine.trim());
      currentLine = word + ' ';
    } else {
      currentLine += word + ' ';
    }
  }

  if (currentLine) lines.push(currentLine.trim());
  return lines;
}

export function extractSummary(markdown: string, maxLength: number = 150): string {
  const stripped = stripMarkdown(markdown);
  const firstParagraph = stripped.split('\n\n')[0];
  return truncate(firstParagraph, maxLength);
}
