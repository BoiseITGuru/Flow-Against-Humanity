import React from 'react'
import Script from 'next/script'
import type { AppProps } from 'next/app'
import type { ReactElement, ReactNode } from 'react'
import type { NextPage } from 'next'
import Head from 'next/head'
import { store } from '../stores/store'
import { Provider } from 'react-redux'
import DarkMode from '../contexts/darkMode'
import { Forge4FlowProvider } from '@forge4flow/forge4flow-nextjs'
import AuthGuard from '../components/Auth/AuthGuard'
import GuestGuard from '../components/Auth/GuestGuard'
import Spinner from '../components/Spinner'
import '../css/main.css'
import '../flow/config.js'

export type NextPageWithLayout<P = Record<string, unknown>, IP = P> = NextPage<P, IP> & {
  authGuard: boolean
  guestGuard: boolean
  getLayout?: (page: ReactElement) => ReactNode
}

type AppPropsWithLayout = AppProps & {
  Component: NextPageWithLayout
}

type GuardProps = {
  authGuard: boolean
  guestGuard: boolean
  children: ReactNode
}

const Guard = ({ children, authGuard, guestGuard }: GuardProps) => {
  if (guestGuard) {
    return <GuestGuard fallback={<Spinner />}>{children}</GuestGuard>
  } else if (!guestGuard && !authGuard) {
    return <>{children}</>
  } else {
    return <AuthGuard fallback={<Spinner />}>{children}</AuthGuard>
  }
}

function MyApp({ Component, pageProps }: AppPropsWithLayout) {
  // Use the layout defined at the page level, if available
  const getLayout = Component.getLayout || ((page) => page)

  const title = `Flow Against Humanity`

  const description = 'FAH - A web3 card game for horrible people'

  const url = 'https://fah.boiseitguru.com'

  //TODO: fix SEO image
  const image = `https://static.justboil.me/templates/one/repo-tailwind-react.png`

  const imageWidth = '1920'

  const imageHeight = '960'

  const authGuard = Component.authGuard ?? false
  const guestGuard = Component.guestGuard ?? false

  return (
    <Forge4FlowProvider endpoint={'http://localhost:8200'} clientKey="someKey">
      <Provider store={store}>
        {getLayout(
          <>
            <Guard authGuard={authGuard} guestGuard={guestGuard}>
              <DarkMode>
                <Head>
                  <meta name="description" content={description} />

                  <meta property="og:url" content={url} />
                  <meta property="og:site_name" content="JustBoil.me" />
                  <meta property="og:title" content={title} />
                  <meta property="og:description" content={description} />
                  <meta property="og:image" content={image} />
                  <meta property="og:image:type" content="image/png" />
                  <meta property="og:image:width" content={imageWidth} />
                  <meta property="og:image:height" content={imageHeight} />

                  <link rel="icon" href="/favicon.png" />
                </Head>

                <Script
                  src="https://www.googletagmanager.com/gtag/js?id=UA-130795909-1"
                  strategy="afterInteractive"
                />

                <Script id="google-analytics" strategy="afterInteractive">
                  {`
                window.dataLayer = window.dataLayer || [];
                function gtag(){dataLayer.push(arguments);}
                gtag('js', new Date());
                gtag('config', 'UA-130795909-1');
              `}
                </Script>

                <Component {...pageProps} />
              </DarkMode>
            </Guard>
          </>
        )}
      </Provider>
    </Forge4FlowProvider>
  )
}

export default MyApp
