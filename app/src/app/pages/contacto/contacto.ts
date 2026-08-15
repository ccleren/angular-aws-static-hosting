import { Component, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Icon } from '../../shared/icon/icon';
import { ScrollRevealDirective } from '../../shared/scroll-reveal.directive';

@Component({
  selector: 'app-contacto',
  imports: [ReactiveFormsModule, Icon, ScrollRevealDirective],
  templateUrl: './contacto.html',
  styleUrl: './contacto.scss',
})
export class Contacto {
  private readonly fb = new FormBuilder();

  protected readonly submitted = signal(false);

  protected readonly services = [
    'Obra civil',
    'Construcción residencial',
    'Construcción industrial',
    'Reformas integrales',
    'Consultoría técnica',
  ];

  protected readonly form = this.fb.nonNullable.group({
    name: ['', [Validators.required, Validators.minLength(2)]],
    email: ['', [Validators.required, Validators.email]],
    phone: ['', [Validators.pattern(/^[+\d][\d\s-]{6,}$/)]],
    service: ['', Validators.required],
    message: ['', [Validators.required, Validators.minLength(20)]],
  });

  get f() {
    return this.form.controls;
  }

  onSubmit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    // No hay backend: esta es una demo estática. En una implementación real,
    // aquí se llamaría a un endpoint o servicio de envío de formularios.
    this.submitted.set(true);
    this.form.reset();
  }
}
