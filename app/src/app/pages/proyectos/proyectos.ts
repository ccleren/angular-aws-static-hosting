import { Component, computed, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { Icon } from '../../shared/icon/icon';
import { ScrollRevealDirective } from '../../shared/scroll-reveal.directive';
import { PROJECT_CATEGORIES, PROJECTS, ProjectCategory } from '../../shared/data/projects.data';

type Filter = ProjectCategory | 'Todos';

@Component({
  selector: 'app-proyectos',
  imports: [RouterLink, Icon, ScrollRevealDirective],
  templateUrl: './proyectos.html',
  styleUrl: './proyectos.scss',
})
export class Proyectos {
  protected readonly categories: Filter[] = ['Todos', ...PROJECT_CATEGORIES];
  protected readonly activeFilter = signal<Filter>('Todos');

  protected readonly filteredProjects = computed(() => {
    const filter = this.activeFilter();
    return filter === 'Todos' ? PROJECTS : PROJECTS.filter((p) => p.category === filter);
  });

  setFilter(filter: Filter): void {
    this.activeFilter.set(filter);
  }
}
