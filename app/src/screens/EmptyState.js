import React from 'react'
import styled from 'styled-components'
import { EmptyStateCard } from '@aragon/ui'
import emptyIcon from '../assets/empty-card-icon.svg'

const EmptyState = ({ onActivate }) => (
  <Main>
    <EmptyStateCard
      icon={<img src={emptyIcon} alt="" />}
      title="There are no accepted for review papers yet"
      text="Upload a paper to get started."
      actionText="Add paper"
      onActivate={onActivate}
    />
  </Main>
)

const Main = styled.div`
  display: flex;
  align-items: center;
  justify-content: center;
  flex-grow: 1;
  padding: 20px 0;
`

export default EmptyState
