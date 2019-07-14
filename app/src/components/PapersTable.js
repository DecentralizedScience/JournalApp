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

function PapersTable({ title, papers, action, handler }) {
  return (
    <Table
      header={
        <TableRow>
          <TableHeader title={title} />
        </TableRow>
      }
    >
      {papers.map(({ key, hash, link }) => (
        <TableRow key={key}>
          <TableCell>
            <Text>#{key}</Text>
          </TableCell>
          <TableCell>
            <SafeLink href={link} target="_blank">
              {hash}
            </SafeLink>
          </TableCell>
          <TableCell>
            <Text>February</Text>
          </TableCell>
          <TableCell>
            <Button mode="secondary" onClick={() => handler(key)}>
              {action}
            </Button>
          </TableCell>
        </TableRow>
      ))}
    </Table>
  )
}

export default PapersTable
