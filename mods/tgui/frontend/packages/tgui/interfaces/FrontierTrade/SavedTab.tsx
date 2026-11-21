import { useBackend } from '../../backend';
import {
  Box,
  Button,
  NoticeBox,
  Section,
  Stack,
  Table,
} from '../../components';
import { FrontierTradeData } from './types';

export interface SavedTabProps {
  onLoaded: () => void;
}

export const SavedTab = (props: SavedTabProps, context) => {
  const { act, data } = useBackend<FrontierTradeData>(context);
  const { onLoaded } = props;
  const { saved = [], currency } = data;

  return (
    <Section fill scrollable title="Saved Carts">
      <NoticeBox info>
        Saved carts retain item quantities. Availability and current vendor
        prices are validated again at checkout. Use Load to replace your current
        cart, or Add to Cart to merge quantities.
      </NoticeBox>
      {saved.length === 0 ? (
        <NoticeBox>No saved carts yet.</NoticeBox>
      ) : (
        <Table>
          <Table.Row header>
            <Table.Cell>Name & Manifest</Table.Cell>
            <Table.Cell textAlign="right">Items</Table.Cell>
            <Table.Cell textAlign="right">Total Units</Table.Cell>
            <Table.Cell textAlign="right">Est. Cost</Table.Cell>
            <Table.Cell textAlign="right">Actions</Table.Cell>
          </Table.Row>
          {saved.map((entry) => (
            <Table.Row key={entry.id} className="candystripe">
              <Table.Cell>
                <Box bold>{entry.name}</Box>
                {entry.items && entry.items.length > 0 && (
                  <Box fontSize="11px" color="label">
                    {entry.items
                      .map(
                        (it) =>
                          `${it.quantity}x ${it.name}${
                            it.stock < it.quantity
                              ? ` (${it.stock} in stock)`
                              : ''
                          }`
                      )
                      .join(', ')}
                  </Box>
                )}
              </Table.Cell>
              <Table.Cell textAlign="right">{entry.item_count}</Table.Cell>
              <Table.Cell textAlign="right">{entry.total_units}</Table.Cell>
              <Table.Cell textAlign="right">
                {entry.estimated_cost !== undefined
                  ? `${entry.estimated_cost} ${currency}`
                  : '—'}
              </Table.Cell>
              <Table.Cell textAlign="right">
                <Stack justify="flex-end">
                  <Stack.Item>
                    <Button
                      compact
                      icon="upload"
                      content="Load"
                      tooltip="Replace current cart with this saved cart"
                      onClick={() => {
                        act('load_saved', { id: entry.id });
                        onLoaded();
                      }}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      compact
                      icon="cart-plus"
                      content="Merge"
                      tooltip="Add items from this saved cart into your current cart"
                      onClick={() => {
                        act('load_saved', { id: entry.id, merge: true });
                        onLoaded();
                      }}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      compact
                      color="bad"
                      icon="trash"
                      content="Delete"
                      onClick={() => act('delete_saved', { id: entry.id })}
                    />
                  </Stack.Item>
                </Stack>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};
