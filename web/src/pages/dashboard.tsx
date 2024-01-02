import { mdiChartPie, mdiChartTimelineVariant, mdiGithub } from '@mdi/js'
import Head from 'next/head'
import React, { useState } from 'react'
import type { ReactElement } from 'react'
import Button from '../components/Button'
import LayoutAuthenticated from '../layouts/Authenticated'
import SectionMain from '../components/Section/Main'
import SectionTitleLineWithButton from '../components/Section/TitleLineWithButton'
import SectionBannerPreLaunch from '../components/Section/Banner/PreLaunch'
import { getPageTitle } from '../config'
import SectionTitleLine from '../components/Section/TitleLine'

const Dashbaord = () => {
  return (
    <>
      <Head>
        <title>{getPageTitle('Pre-Launch')}</title>
      </Head>
      <SectionMain>
        <SectionTitleLineWithButton
          icon={mdiChartTimelineVariant}
          title="New Years 2024 Pre-Launch Deck"
          main
        >
          <Button
            href="https://github.com/BoiseITGuru/Flow-Against-Humanity"
            target="_blank"
            icon={mdiGithub}
            label="Star on GitHub"
            color="contrast"
            roundedFull
            small
          />
        </SectionTitleLineWithButton>

        <div className="my-6">
          <SectionBannerPreLaunch />
        </div>

        <SectionTitleLine icon={mdiChartPie} title="Protocal Updates" />
      </SectionMain>
    </>
  )
}

Dashbaord.getLayout = function getLayout(page: ReactElement) {
  return <LayoutAuthenticated>{page}</LayoutAuthenticated>
}

export default Dashbaord
