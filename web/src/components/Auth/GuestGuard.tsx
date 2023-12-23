// ** React Imports
import { ReactNode, ReactElement, useEffect } from 'react'

// ** Next Import
import { useRouter } from 'next/router'

// ** Hooks Import
import { useForge4Flow } from '@forge4flow/forge4flow-nextjs'

interface GuestGuardProps {
  children: ReactNode
  fallback: ReactElement | null
}

const GuestGuard = (props: GuestGuardProps) => {
  const { children, fallback } = props
  const auth = useForge4Flow()
  const router = useRouter()

  useEffect(() => {
    if (!router.isReady) {
      return
    }

    const verifySession = async () => {
      const validSession = await auth.validSession()
      if (validSession) {
        router.push('/dashboard')
      }
    }

    verifySession()

    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [auth.sessionToken, auth.isAuthenticated, router.route])

  if (auth.isLoading || (!auth.isLoading && auth.isAuthenticated)) {
    return fallback
  }

  return <>{children}</>
}

export default GuestGuard
