import React from 'react'
import { MenuAsideItem } from '../../interfaces'
import AsideMenuItem from './Item'
import { FeatureProtectedComponent } from '@forge4flow/forge4flow-nextjs'

// ** Hooks Import
import { useForge4Flow } from '@forge4flow/forge4flow-nextjs'

type Props = {
  menu: MenuAsideItem[]
  isDropdownList?: boolean
  className?: string
}

export default function AsideMenuList({ menu, isDropdownList = false, className = '' }: Props) {
  const auth = useForge4Flow()

  return (
    <ul className={className}>
      {menu
        .filter(
          (item) =>
            item.requireSession === undefined ||
            !item.requireSession ||
            (item.requireSession && auth.isAuthenticated)
        )
        .map((filteredItem, index) =>
          'requireFeature' in filteredItem ? (
            <FeatureProtectedComponent key={index} featureId={filteredItem.requireFeature}>
              <AsideMenuItem item={filteredItem} isDropdownList={isDropdownList} />
            </FeatureProtectedComponent>
          ) : (
            <AsideMenuItem key={index} item={filteredItem} isDropdownList={isDropdownList} />
          )
        )}
    </ul>
  )
}
