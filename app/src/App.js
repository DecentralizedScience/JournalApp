import React from 'react'
import { useAragonApi } from '@aragon/api-react'
import { Main } from '@aragon/ui'
import styled from 'styled-components'
import PreprintForm from './components/PreprintForm'
import PapersTable from './components/PapersTable'
import { hexToIpfs } from './lib/ipfs-util'

function App() {
  const { api, appState } = useAragonApi()
  const { papers, syncing } = appState
  const papersArray = Object.entries(papers).map(([key, value]) => ({
    ...value,
    key,
    hash: hexToIpfs(value.hash),
    link: `http://localhost:8080/ipfs/${hexToIpfs(value.hash)}`,
  }))
  const preprints = papersArray.filter(paper => paper.state === 'accepted')
  const published = papersArray.filter(paper => paper.state === 'published')

  return (
    <Main>
      {syncing && <Syncing />}
      <Title>Journal</Title>
      <PapersTable
        title="Published Papers"
        papers={published}
        action="Unpublish"
        handler={key => api.unpublish(key)}
      />
      <PapersTable
        title="Preprints"
        papers={preprints}
        action="Publish"
        handler={key => api.publish(key)}
      />
      <PreprintForm handler={hash => api.acceptForReview(hash)} />
    </Main>
  )
}

const Title = styled.h1`
  font-size: 30px;
`

const Syncing = styled.div.attrs({ children: 'Syncing…' })`
  position: absolute;
  top: 15px;
  right: 20px;
`

export default App
