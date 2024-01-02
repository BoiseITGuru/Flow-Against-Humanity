import { mdiPineTreeVariant } from '@mdi/js'
import React from 'react'
import { gradientBgChristmas } from '../../../colors'
import Button from '../../Button'
import SectionBanner from '.'

const SectionBannerPreLaunch = () => {
  return (
    <SectionBanner className={gradientBgChristmas}>
      <h1 className="text-3xl text-white mb-6">
        Mint Your FREE - LIMITED EDITION New Years 2024 <br /> Pre-Launch Deck Now!
      </h1>
      <div>
        <Button icon={mdiPineTreeVariant} label="Mint Now" roundedFull />
      </div>
    </SectionBanner>
  )
}

export default SectionBannerPreLaunch
