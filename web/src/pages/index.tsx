import { ReactElement, useEffect } from 'react'
import { useRouter } from 'next/router'
import LayoutGuest from '../layouts/Guest'
import Spinner from '../components/Spinner'

const Home = () => {
  const router = useRouter()

  useEffect(() => {
    if (router.route === '/') {
      router.push('/dashboard')
    }
  }, [router])

  return (
    <>
      <Spinner />
    </>
  )
}

Home.getLayout = function getLayout(page: ReactElement) {
  return <LayoutGuest>{page}</LayoutGuest>
}

Home.guestGuard = true
export default Home
