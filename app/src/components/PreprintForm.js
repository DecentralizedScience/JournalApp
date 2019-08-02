import React, { useState } from 'react'
import { Button } from '@aragon/ui'
import { save } from '../lib/ipfs-util'

function PreprintForm({ handler }) {
  const [preprint, setPreprint] = useState('')
  const upload = file => {
    console.log(file)
    save(file).then(hexHash => setPreprint(hexHash))
  }
  return (
    <form onSubmit={e => e.preventDefault()}>
      <input type="file" onChange={e => upload(e.target.files[0])} />
      <Button mode="secondary" onClick={() => handler(preprint)}>
        Accept for review
      </Button>
    </form>
  )
}

export default PreprintForm
