import React, { useState } from 'react'
import { useAragonApi } from '@aragon/api-react'
import { Main, SidePanel, IconPlus } from '@aragon/ui'
import PreprintForm from './components/PreprintForm'
import PapersTable from './components/PapersTable'
import { hexToIpfs } from './lib/ipfs-util'
import AppLayout from './components/AppLayout'
import EmptyState from './screens/EmptyState'

function App() {
  const { api, appState } = useAragonApi()
  const { papers, isSyncing } = appState
  const papersArray = Object.entries(papers).map(([key, value]) => ({
    ...value,
    key,
    hash: hexToIpfs(value.hash),
    link: `http://localhost:8080/ipfs/${hexToIpfs(value.hash)}`,
  }))
  const preprints = papersArray.filter(paper => paper.state === 'accepted')
  const published = papersArray.filter(paper => paper.state === 'published')

  const [sidepanelOpened, setSidePanelOpened] = useState(false)
  return (
    <Main assetsUrl="./aragon-ui">
      <div css="min-width: 320px">
        <AppLayout
          title="Journal"
          mainButton={{
            label: 'Accept for review',
            icon: <IconPlus />,
            onClick: () => setSidePanelOpened(true),
          }}
          smallViewPadding={0}
        >
          {papersArray.length > 0 ? (
            <div>
              <PapersTable
                title="Published Papers"
                papers={published}
                action="Unpublish"
                handler={key => api.unpublish(key).toPromise()}
              />
              <PapersTable
                title="Accepted for review"
                papers={preprints}
                action="Publish"
                handler={key => api.publish(key).toPromise()}
              />
            </div>
          ) : (
            !isSyncing && (
              <EmptyState onActivate={() => setSidePanelOpened(true)} />
            )
          )}
        </AppLayout>
        <SidePanel
          title="Accept for review paper"
          opened={sidepanelOpened}
          onClose={() => setSidePanelOpened(false)}
        >
          <PreprintForm
            handler={hash => api.acceptForReview(hash).toPromise()}
          />
        </SidePanel>
      </div>
    </Main>
  )
}

export default App
