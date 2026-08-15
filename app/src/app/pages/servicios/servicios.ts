import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';
import { Icon } from '../../shared/icon/icon';
import { ScrollRevealDirective } from '../../shared/scroll-reveal.directive';
import { SERVICES } from '../../shared/data/services.data';

@Component({
  selector: 'app-servicios',
  imports: [RouterLink, Icon, ScrollRevealDirective],
  templateUrl: './servicios.html',
  styleUrl: './servicios.scss',
})
export class Servicios {
  protected readonly services = SERVICES;
}
