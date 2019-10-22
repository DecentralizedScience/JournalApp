import '@babel/polyfill'
import Aragon, { events } from '@aragon/api'

const app = new Aragon()

app.store(async (state, { event, returnValues }) => {
  let nextState

  // Initial state
  if (state == null) {
    nextState = { papers: {} }
  }

  switch (event) {
    case 'AcceptForReview': {
      const { paper, hash } = returnValues
      console.log('accept', paper, hash)
      nextState = {
        papers: {
          ...state.papers,
          [paper]: { hash, state: 'accepted' },
        },
      }
      break
    }
    case 'Publish': {
      const { paper } = returnValues
      console.log('publish', paper)
      nextState = {
        papers: {
          ...state.papers,
          [paper]: { ...state.papers[paper], state: 'published' },
        },
      }
      break
    }
    case 'Unpublish': {
      const { paper } = returnValues
      nextState = {
        papers: {
          ...state.papers,
          [paper]: { ...state.papers[paper], state: 'unpublshed' },
        },
      }
      break
    }
    case events.SYNC_STATUS_SYNCING:
      nextState = { ...nextState, isSyncing: true }
      break
    case events.SYNC_STATUS_SYNCED:
      nextState = { ...nextState, isSyncing: false }
      break
    default:
      nextState = state
  }

  return nextState
})
