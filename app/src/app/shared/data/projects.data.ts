export type ProjectCategory = 'Obra civil' | 'Residencial' | 'Industrial' | 'Reformas';

export interface ProjectItem {
  name: string;
  category: ProjectCategory;
  location: string;
  year: number;
  description: string;
}

export const PROJECT_CATEGORIES: ProjectCategory[] = [
  'Obra civil',
  'Residencial',
  'Industrial',
  'Reformas',
];

export const PROJECTS: ProjectItem[] = [
  {
    name: 'Puente Ribera Norte',
    category: 'Obra civil',
    location: 'Valladolid',
    year: 2024,
    description: 'Puente vehicular de 180 m sobre el río, con dos carriles y carril bici.',
  },
  {
    name: 'Residencial Mirador Verde',
    category: 'Residencial',
    location: 'Zaragoza',
    year: 2023,
    description: 'Promoción de 48 viviendas plurifamiliares con certificación energética A.',
  },
  {
    name: 'Planta Logística Aurora',
    category: 'Industrial',
    location: 'Guadalajara',
    year: 2023,
    description: 'Nave logística de 12.000 m² con sistema automatizado de almacenaje.',
  },
  {
    name: 'Rehabilitación Casa Oller',
    category: 'Reformas',
    location: 'Valencia',
    year: 2022,
    description: 'Reforma integral de vivienda histórica manteniendo la fachada protegida.',
  },
  {
    name: 'Ronda Sur Fase II',
    category: 'Obra civil',
    location: 'Murcia',
    year: 2022,
    description: 'Ampliación de 6,4 km de vía de circunvalación con tres enlaces.',
  },
  {
    name: 'Urbanización Los Alcores',
    category: 'Residencial',
    location: 'Sevilla',
    year: 2021,
    description: '32 viviendas unifamiliares con urbanización de zonas comunes y piscina.',
  },
  {
    name: 'Planta de Producción Iberia',
    category: 'Industrial',
    location: 'Toledo',
    year: 2021,
    description: 'Instalación fabril de 8.500 m² con sala limpia y oficinas anexas.',
  },
  {
    name: 'Oficinas Distrito Este',
    category: 'Reformas',
    location: 'Madrid',
    year: 2020,
    description: 'Reforma de 1.200 m² de oficinas diáfanas con criterios de eficiencia energética.',
  },
];
