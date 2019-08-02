import React from 'react'
import {
  Button,
  Table,
  TableHeader,
  TableRow,
  TableCell,
  Text,
  SafeLink,
} from '@aragon/ui'
import styled from 'styled-components'

function PapersTable({ title, papers, action, handler }) {
  return (
    papers.length > 0 && (
      <Table
        header={
          <TableRow>
            <TableHeader title={title} />
          </TableRow>
        }
      >
        {papers.map(({ key, hash, link }) => (
          <TableRow key={key}>
            <TableCell2>
              <Text>#{key}</Text>
            </TableCell2>
            <TableCell6>
              <SafeLink href={link} target="_blank">
                {hash}
              </SafeLink>
            </TableCell6>
            <TableCell2>
              <Text>February</Text>
            </TableCell2>
            <TableCell2>
              <Button mode="secondary" onClick={() => handler(key)}>
                {action}
              </Button>
            </TableCell2>
          </TableRow>
        ))}
      </Table>
    )
  )
}

const TableCell2 = styled(TableCell)`
  width: 16.66666666%;
`

const TableCell6 = styled(TableCell)`
  width: 50%;
`

export default PapersTable
