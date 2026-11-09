import { cva } from 'class-variance-authority';

export const sheetVariants = cva(
  'fixed z-[10000] flex flex-col gap-4 bg-background p-6 text-foreground shadow-lg outline-none',
  {
    variants: {
      side: {
        top: 'inset-x-0 top-0 border-b border-border',
        bottom: 'inset-x-0 bottom-0 border-t border-border',
        start:
          'inset-y-0 start-0 h-full w-3/4 border-e border-border sm:max-w-sm',
        end: 'inset-y-0 end-0 h-full w-3/4 border-s border-border sm:max-w-sm',
      },
    },
    defaultVariants: { side: 'end' },
  }
);
