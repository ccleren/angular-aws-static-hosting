import { Directive, ElementRef, OnDestroy, AfterViewInit, inject } from '@angular/core';

/**
 * Adds `.is-visible` to the host once it scrolls into the viewport.
 * Pair with the `.reveal` utility class in styles.scss.
 */
@Directive({
  selector: '[appScrollReveal]',
  host: { class: 'reveal' },
})
export class ScrollRevealDirective implements AfterViewInit, OnDestroy {
  private readonly el = inject(ElementRef<HTMLElement>);
  private observer?: IntersectionObserver;

  ngAfterViewInit(): void {
    if (typeof IntersectionObserver === 'undefined') {
      this.el.nativeElement.classList.add('is-visible');
      return;
    }

    this.observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.isIntersecting) {
            this.el.nativeElement.classList.add('is-visible');
            this.observer?.unobserve(this.el.nativeElement);
          }
        }
      },
      { threshold: 0.15, rootMargin: '0px 0px -60px 0px' },
    );

    this.observer.observe(this.el.nativeElement);
  }

  ngOnDestroy(): void {
    this.observer?.disconnect();
  }
}
