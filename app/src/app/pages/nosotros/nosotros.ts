import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';
import { Icon } from '../../shared/icon/icon';
import { ScrollRevealDirective } from '../../shared/scroll-reveal.directive';
import { TEAM } from '../../shared/data/team.data';

@Component({
  selector: 'app-nosotros',
  imports: [RouterLink, Icon, ScrollRevealDirective],
  templateUrl: './nosotros.html',
  styleUrl: './nosotros.scss',
})
export class Nosotros {
  protected readonly team = TEAM;

  protected readonly milestones = [
    { year: '2003', text: 'Fundación de la empresa con el primer contrato de obra civil municipal.' },
    { year: '2009', text: 'Ampliación a construcción residencial e industrial.' },
    { year: '2015', text: 'Superamos los 100 proyectos entregados y abrimos delegación en Sevilla.' },
    { year: '2021', text: 'Certificación de gestión de calidad ISO 9001 y sistema de seguridad reforzado.' },
    { year: '2024', text: 'Más de 340 proyectos completados en toda la península.' },
  ];
}
