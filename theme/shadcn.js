// shadcn/ui semantic tokens, mapped onto the dashboard CSS variables so
// light and dark mode keep working without a second palette.
const token = name => `rgb(var(${name}) / <alpha-value>)`;

export const shadcnColors = {
  background: token('--solid-1'),
  foreground: token('--slate-12'),
  card: token('--solid-1'),
  'card-foreground': token('--slate-12'),
  popover: token('--solid-1'),
  'popover-foreground': token('--slate-12'),
  primary: token('--brand-color'),
  'primary-foreground': '#fff',
  secondary: token('--slate-3'),
  'secondary-foreground': token('--slate-12'),
  muted: token('--slate-3'),
  'muted-foreground': token('--slate-11'),
  accent: token('--slate-3'),
  'accent-foreground': token('--slate-12'),
  destructive: token('--ruby-9'),
  'destructive-foreground': '#fff',
  border: token('--border-weak'),
  input: token('--border-strong'),
  ring: token('--brand-color'),
};
