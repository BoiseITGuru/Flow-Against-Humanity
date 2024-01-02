import React from 'react'
import type { ReactElement } from 'react'
import Head from 'next/head'
import Button from '../components/Button'
import Buttons from '../components/Buttons'
import CardBox from '../components/CardBox'
import SectionFullScreen from '../components/Section/FullScreen'
import LayoutGuest from '../layouts/Guest'
import { getPageTitle } from '../config'

const UnauthorizedPage = () => {
  return (
    <>
      <Head>
        <title>{getPageTitle('Error')}</title>
      </Head>

      <SectionFullScreen bg="pinkRed">
        <CardBox
          className="w-11/12 md:w-7/12 lg:w-6/12 xl:w-4/12 shadow-2xl"
          footer={
            <Buttons>
              <Button label="Setup Account" color="success" />
              <Button href="/dashboard" label="Back to dashboard" color="danger" outline />
            </Buttons>
          }
        >
          <div className="space-y-3">
            <h1 className="text-2xl">Setup Account</h1>

            <p>
              To provide the best user experience you need to set up your account before accessing
              certain features.
            </p>
          </div>
        </CardBox>
      </SectionFullScreen>
    </>
  )
}

UnauthorizedPage.authGuard = false
UnauthorizedPage.getLayout = function getLayout(page: ReactElement) {
  return <LayoutGuest>{page}</LayoutGuest>
}

export default UnauthorizedPage
