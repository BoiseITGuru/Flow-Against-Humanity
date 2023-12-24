import React from 'react'
import type { ReactElement } from 'react'
import Head from 'next/head'
import Button from '../components/Button'
import CardBox from '../components/CardBox'
import SectionFullScreen from '../components/Section/FullScreen'
import LayoutGuest from '../layouts/Guest'
import { getPageTitle } from '../config'

const ErrorPage = () => {
  return (
    <>
      <Head>
        <title>{getPageTitle('Error')}</title>
      </Head>

      <SectionFullScreen bg="pinkRed">
        <CardBox
          className="w-11/12 md:w-7/12 lg:w-6/12 xl:w-4/12 shadow-2xl"
          footer={<Button href="/dashboard" label="Back to Home" color="success" />}
        >
          <div className="space-y-3">
            <h1 className="text-2xl">You are not authorized! 🔐</h1>

            <p>You don&prime;t have permission to access this page. Go Home!</p>
          </div>
        </CardBox>
      </SectionFullScreen>
    </>
  )
}

ErrorPage.authGuard = false
ErrorPage.getLayout = function getLayout(page: ReactElement) {
  return <LayoutGuest>{page}</LayoutGuest>
}

export default ErrorPage
