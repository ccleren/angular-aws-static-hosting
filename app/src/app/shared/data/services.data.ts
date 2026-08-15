import { IconName } from '../icon/icon';

export interface ServiceItem {
  icon: IconName;
  title: string;
  description: string;
}

export const SERVICES: ServiceItem[] = [
  {
    icon: 'crane',
    title: 'Obra civil',
    description:
      'Diseño y ejecución de infraestructura pública: puentes, carreteras, redes de saneamiento y urbanización integral.',
  },
  {
    icon: 'home',
    title: 'Construcción residencial',
    description:
      'Viviendas unifamiliares y promociones plurifamiliares, desde el proyecto ejecutivo hasta la entrega de llaves.',
  },
  {
    icon: 'factory',
    title: 'Construcción industrial',
    description:
      'Naves logísticas, plantas de producción e instalaciones industriales con plazos y estándares de calidad exigentes.',
  },
  {
    icon: 'hammer',
    title: 'Reformas integrales',
    description:
      'Rehabilitación y reforma de espacios residenciales y comerciales, cuidando cada detalle de acabado.',
  },
  {
    icon: 'shield',
    title: 'Gestión y seguridad',
    description:
      'Dirección de obra, control de calidad y coordinación de seguridad y salud en cada fase del proyecto.',
  },
  {
    icon: 'compass',
    title: 'Consultoría técnica',
    description:
      'Estudios de viabilidad, ingeniería estructural y asesoramiento normativo para optimizar cada inversión.',
  },
];
