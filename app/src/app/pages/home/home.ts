import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';
import { Icon } from '../../shared/icon/icon';
import { StatCounter } from '../../shared/stat-counter/stat-counter';
import { ScrollRevealDirective } from '../../shared/scroll-reveal.directive';
import { SERVICES } from '../../shared/data/services.data';

@Component({
  selector: 'app-home',
  imports: [RouterLink, Icon, StatCounter, ScrollRevealDirective],
  templateUrl: './home.html',
  styleUrl: './home.scss',
})
export class Home {
  protected readonly featuredServices = SERVICES.slice(0, 3);

  protected readonly stats = [
    { target: 22, suffix: '+', label: 'Años de experiencia' },
    { target: 340, suffix: '', label: 'Proyectos completados' },
    { target: 120, suffix: '', label: 'Clientes satisfechos' },
    { target: 98, suffix: '%', label: 'Entregas en plazo' },
  ];

  protected readonly pillars = [
    { icon: 'shield' as const, title: 'Seguridad ante todo', text: 'Cero incidentes graves en los últimos 5 años de operación.' },
    { icon: 'compass' as const, title: 'Ingeniería de precisión', text: 'Equipo técnico propio en cada fase, de diseño a entrega.' },
    { icon: 'check' as const, title: 'Cumplimiento de plazos', text: 'Metodología de control que garantiza fechas comprometidas.' },
  ];
}
