import { Component, input } from '@angular/core';

export type IconName =
  | 'crane'
  | 'home'
  | 'factory'
  | 'hammer'
  | 'shield'
  | 'compass'
  | 'menu'
  | 'close'
  | 'arrow-right'
  | 'check'
  | 'map-pin'
  | 'phone'
  | 'mail';

/** Minimal dependency-free stroke-icon set (no external icon library required). */
@Component({
  selector: 'app-icon',
  template: `
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="1.8"
      stroke-linecap="round"
      stroke-linejoin="round"
      [attr.width]="size()"
      [attr.height]="size()"
      aria-hidden="true"
    >
      @switch (name()) {
        @case ('crane') {
          <path d="M4 21h11M6 21V7l10-4v6M16 9v12M9 9v5M9 9h7" />
          <circle cx="9" cy="6" r="0" />
        }
        @case ('home') {
          <path d="M3 10.5 12 3l9 7.5" />
          <path d="M5 9.5V20a1 1 0 0 0 1 1h4v-6h4v6h4a1 1 0 0 0 1-1V9.5" />
        }
        @case ('factory') {
          <path d="M3 21V11l6 4v-4l6 4V7l6 4v10z" />
          <path d="M3 21h18" />
        }
        @case ('hammer') {
          <path
            d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 1 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94z"
          />
        }
        @case ('shield') {
          <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
        }
        @case ('compass') {
          <circle cx="12" cy="12" r="9" />
          <path d="m16.24 7.76-2.12 6.36-6.36 2.12 2.12-6.36z" />
        }
        @case ('menu') {
          <path d="M3 6h18M3 12h18M3 18h18" />
        }
        @case ('close') {
          <path d="M18 6 6 18M6 6l12 12" />
        }
        @case ('arrow-right') {
          <path d="M5 12h14M13 6l6 6-6 6" />
        }
        @case ('check') {
          <path d="M20 6 9 17l-5-5" />
        }
        @case ('map-pin') {
          <path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0z" />
          <circle cx="12" cy="10" r="3" />
        }
        @case ('phone') {
          <path
            d="M22 16.9v3a2 2 0 0 1-2.2 2 19.8 19.8 0 0 1-8.6-3 19.5 19.5 0 0 1-6-6 19.8 19.8 0 0 1-3-8.7A2 2 0 0 1 4.1 2h3a2 2 0 0 1 2 1.7c.1 1 .3 2 .7 3a2 2 0 0 1-.5 2.1L8 10a16 16 0 0 0 6 6l1.2-1.3a2 2 0 0 1 2.1-.5c1 .4 2 .6 3 .7a2 2 0 0 1 1.7 2z"
          />
        }
        @case ('mail') {
          <path d="M4 5h16a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V6a1 1 0 0 1 1-1z" />
          <path d="m3 6 9 7 9-7" />
        }
      }
    </svg>
  `,
  host: { class: 'app-icon' },
})
export class Icon {
  readonly name = input.required<IconName>();
  readonly size = input(22);
}
