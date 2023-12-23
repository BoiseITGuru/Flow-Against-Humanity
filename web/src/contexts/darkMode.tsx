// ** React Imports
import React, { ReactNode, ReactElement, useEffect } from 'react'

// ** Next Import
import { useRouter } from 'next/router'

import { useAppDispatch } from '../stores/hooks'
import { setDarkMode } from '../stores/darkModeSlice'

interface DarkModeProps {
  children: ReactNode
}

const DarkMode = ({ children }: DarkModeProps) => {
  const router = useRouter()
  const dispatch = useAppDispatch()

  useEffect(() => {
    if (!router.isReady) {
      return
    }

    let darkMode = localStorage.getItem('darkMode')
    if (darkMode === undefined || darkMode === null || darkMode === '1') {
      dispatch(setDarkMode(true))
    } else {
      dispatch(setDarkMode(false))
    }

    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [router.route])

  return <>{children}</>
}

export default DarkMode
