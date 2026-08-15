export interface TeamMember {
  name: string;
  role: string;
  initials: string;
}

export const TEAM: TeamMember[] = [
  { name: 'Marta Solano', role: 'Directora General', initials: 'MS' },
  { name: 'Javier Reyes', role: 'Director Técnico', initials: 'JR' },
  { name: 'Elena Cifuentes', role: 'Jefa de Proyectos', initials: 'EC' },
  { name: 'David Márquez', role: 'Responsable de Seguridad y Calidad', initials: 'DM' },
];
