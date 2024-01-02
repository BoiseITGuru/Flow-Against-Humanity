import { mdiGithub } from '@mdi/js'
import React from 'react'
import Button from '../Button'
import SectionTitleLineWithButton from './TitleLineWithButton'

type Props = {
  icon: string
  title: string
}

export default function SectionTitleLineWithGithub({ icon, title }: Props) {
  return (
    <SectionTitleLineWithButton icon={icon} title={title} main>
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
  )
}
