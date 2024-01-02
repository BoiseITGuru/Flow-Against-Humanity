// ** React Imports
import { ReactNode, ReactElement, useEffect, useState } from 'react'

// ** Next Import
import { useRouter } from 'next/router'

// ** Hooks Import
import { useForge4Flow } from '@forge4flow/forge4flow-nextjs'

interface AuthGuardProps {
  children: ReactNode
  fallback: ReactElement | null
}

const AuthGuard = (props: AuthGuardProps) => {
  const { children, fallback } = props
  const auth = useForge4Flow()
  const router = useRouter()

  const [checkingSession, setCheckingSession] = useState(true)

  useEffect(
    () => {
      if (!router.isReady) {
        return
      }

      const verifySession = async () => {
        try {
          const validSession = await auth.validSession()
          if (!validSession) {
            router.replace('/401')
          }

          setCheckingSession(false)
        } finally {
        }
      }

      verifySession()
    },
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [auth.sessionToken, auth.isAuthenticated, router.route]
  )

  if (auth.isLoading || auth.isAuthenticated === false || checkingSession) {
    return fallback
  }

  return <>{children}</>
}

export default AuthGuard
