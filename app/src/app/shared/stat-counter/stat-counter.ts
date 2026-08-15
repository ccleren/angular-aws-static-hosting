import {
  Component,
  ElementRef,
  AfterViewInit,
  OnDestroy,
  inject,
  input,
  signal,
} from '@angular/core';

@Component({
  selector: 'app-stat-counter',
  template: `
    <span class="stat-counter__value">{{ display() }}{{ suffix() }}</span>
    <span class="stat-counter__label">{{ label() }}</span>
  `,
  styleUrl: './stat-counter.scss',
  host: { class: 'stat-counter' },
})
export class StatCounter implements AfterViewInit, OnDestroy {
  readonly target = input.required<number>();
  readonly label = input.required<string>();
  readonly suffix = input('');
  readonly duration = input(1600);

  protected readonly display = signal(0);

  private readonly el = inject(ElementRef<HTMLElement>);
  private observer?: IntersectionObserver;
  private frame?: number;

  ngAfterViewInit(): void {
    if (typeof IntersectionObserver === 'undefined') {
      this.display.set(this.target());
      return;
    }

    this.observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.isIntersecting) {
            this.animate();
            this.observer?.unobserve(this.el.nativeElement);
          }
        }
      },
      { threshold: 0.4 },
    );
    this.observer.observe(this.el.nativeElement);
  }

  ngOnDestroy(): void {
    this.observer?.disconnect();
    if (this.frame) cancelAnimationFrame(this.frame);
  }

  private animate(): void {
    const start = performance.now();
    const to = this.target();
    const dur = this.duration();

    const step = (now: number) => {
      const progress = Math.min((now - start) / dur, 1);
      const eased = 1 - Math.pow(1 - progress, 3);
      this.display.set(Math.round(to * eased));

      if (progress < 1) {
        this.frame = requestAnimationFrame(step);
      }
    };

    this.frame = requestAnimationFrame(step);
  }
}
