import '@babel/polyfill'
import { of } from 'rxjs'
import AragonApi from '@aragon/api'

const INITIALIZATION_TRIGGER = Symbol('INITIALIZATION_TRIGGER')

const api = new AragonApi()

api.store(
  async (state, event) => {
    let newState

    switch (event.event) {
      case INITIALIZATION_TRIGGER: {
        newState = { papers: {} }
        break
      }
      case 'AcceptForReview': {
        const { paper, hash } = event.returnValues
        console.log('accept', paper, hash)
        newState = {
          papers: {
            ...state.papers,
            [paper]: { hash, state: 'accepted' },
          },
        }
        break
      }
      case 'Publish': {
        const { paper } = event.returnValues
        console.log('publish', paper)
        newState = {
          papers: {
            ...state.papers,
            [paper]: { ...state.papers[paper], state: 'published' },
          },
        }
        break
      }
      case 'Unpublish': {
        const { paper } = event.returnValues
        newState = {
          papers: {
            ...state.papers,
            [paper]: { ...state.papers[paper], state: 'unpublshed' },
          },
        }
        break
      }
      default:
        newState = state
    }

    return newState
  },
  [
    // Always initialize the store with our own home-made event
    of({ event: INITIALIZATION_TRIGGER }),
  ]
)
