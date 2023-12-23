import React from 'react'
import { MenuNavBarItem } from '../../interfaces'
import NavBarItem from './Item'
import Button from '../Button'
import Buttons from '../Buttons'

// ** Next Imports
import { useRouter } from 'next/router'

// ** Hooks Import
import { useForge4Flow } from '@forge4flow/forge4flow-nextjs'

type Props = {
  menu: MenuNavBarItem[]
}

export default function NavBarMenuList({ menu }: Props) {
  const router = useRouter()
  const auth = useForge4Flow()

  const handleLogin = async () => {
    const login = await auth.authenticate()

    if (login) {
      router.push('/dashboard')
    }
  }

  return (
    <>
      {menu.map((item, index) => {
        // Render NavBarItem if requireSession is undefined or false
        // OR if requireSession is true and user is authenticated
        if (
          item.requireSession === undefined ||
          !item.requireSession ||
          (item.requireSession && auth.isAuthenticated)
        ) {
          return <NavBarItem key={index} item={item} />
        }
        return null // If conditions are not met, return null
      })}

      {!auth.isAuthenticated && ( // Render button only when user is not authenticated
        <Buttons>
          <Button
            color="success"
            label="Connect Wallet"
            onClick={handleLogin}
            small={true}
            roundedFull={true}
          />
        </Buttons>
      )}
    </>
  )
}
