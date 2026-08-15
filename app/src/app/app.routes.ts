import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    loadComponent: () => import('./pages/home/home').then((m) => m.Home),
    title: 'Construcciones Nexus | Ingeniería y construcción',
  },
  {
    path: 'servicios',
    loadComponent: () => import('./pages/servicios/servicios').then((m) => m.Servicios),
    title: 'Servicios | Construcciones Nexus',
  },
  {
    path: 'proyectos',
    loadComponent: () => import('./pages/proyectos/proyectos').then((m) => m.Proyectos),
    title: 'Proyectos | Construcciones Nexus',
  },
  {
    path: 'nosotros',
    loadComponent: () => import('./pages/nosotros/nosotros').then((m) => m.Nosotros),
    title: 'Nosotros | Construcciones Nexus',
  },
  {
    path: 'contacto',
    loadComponent: () => import('./pages/contacto/contacto').then((m) => m.Contacto),
    title: 'Contacto | Construcciones Nexus',
  },
  { path: '**', redirectTo: '' },
];
