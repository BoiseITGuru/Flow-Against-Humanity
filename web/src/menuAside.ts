import {
  mdiAccountCircle,
  mdiMonitor,
  mdiGithub,
  mdiLock,
  mdiAlertCircle,
  mdiSquareEditOutline,
  mdiTable,
  mdiViewList,
  mdiTelevisionGuide,
  mdiResponsive,
  mdiPalette,
  mdiVuejs,
} from '@mdi/js'
import { MenuAsideItem } from './interfaces'

const menuAside: MenuAsideItem[] = [
  {
    href: '/dashboard',
    icon: mdiMonitor,
    label: 'Dashboard',
  },
  {
    href: '/games',
    label: 'Find Games',
    icon: mdiTable,
  },
  {
    href: '/cards',
    label: 'My Cards',
    icon: mdiSquareEditOutline,
    requireSession: true,
  },
  {
    href: '/decks',
    label: 'Discover Decks',
    icon: mdiTelevisionGuide,
  },
  {
    href: '/create',
    label: 'Create Deck',
    icon: mdiResponsive,
    requireSession: true,
  },
]

export default menuAside
