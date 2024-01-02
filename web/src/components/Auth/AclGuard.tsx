// ** React Imports
import { ReactNode, ReactElement, useEffect, useState } from 'react'

// ** Next Import
import { useRouter } from 'next/router'

// ** Hooks Import
import { useForge4Flow } from '@forge4flow/forge4flow-nextjs'

export interface AclObject {
  requiredPermission?: string
  requiredFeature?: string
  redirectUrl?: string
}

interface AclGuardProps {
  children: ReactNode
  fallback: ReactElement | null
  aclObject?: AclObject
}

const AclGuard = ({ children, fallback, aclObject }: AclGuardProps) => {
  const auth = useForge4Flow()
  const router = useRouter()

  const [checkingACL, setCheckingACL] = useState(true)

  useEffect(
    () => {
      if (!router.isReady) {
        return
      }

      if (!aclObject) {
        setCheckingACL(false)
        return
      }

      const verifyACL = async () => {
        try {
          if (aclObject.requiredPermission) {
            const hasPerm = await auth.hasPermission({ permissionId: aclObject.requiredPermission })
            if (!hasPerm) {
              router.replace(aclObject.redirectUrl ? aclObject.redirectUrl : '/401')
            }
          }

          if (aclObject.requiredFeature) {
            const hasFeature = await auth.hasFeature({ featureId: aclObject.requiredFeature })
            if (!hasFeature) {
              router.replace(aclObject.redirectUrl ? aclObject.redirectUrl : '/401')
            }
          }

          setCheckingACL(false)
        } catch (error) {
          // TODO: Fix Error Handling
          console.log(error)
          router.replace('/401')
        }
      }

      verifyACL()
    },
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [auth.sessionToken, auth.isAuthenticated, router.route]
  )

  if (auth.isLoading || checkingACL) {
    return fallback
  }

  return <>{children}</>
}

export default AclGuard
