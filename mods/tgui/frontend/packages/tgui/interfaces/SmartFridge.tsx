import { BooleanLike } from 'common/react';
import { capitalizeAll } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import {
  Section,
  Button,
  NumberInput,
  Table,
  Stack,
  NoticeBox,
  Icon,
  Input,
} from '../components';
import { Window } from '../layouts';

export type FridgeData = {
  secure: BooleanLike;
  can_dry: BooleanLike;
  drying: BooleanLike;
  contents: Item[];
};

type Item = {
  display_name: string;
  vend: number;
  quantity: number;
};

export const SmartFridge = (props, context) => {
  const { act, data } = useBackend<FridgeData>(context);
  const { secure, contents } = data;

  return (
    <Window width={400} height={500}>
      <Window.Content>
        <Stack fill vertical>
          {!!secure && (
            <NoticeBox>
              Защищено: Пожалуйста, держите карту на готове.
            </NoticeBox>
          )}
          <Stack.Item grow>
            {contents?.length ? <FridgeContent /> : <FridgeEmpty />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const FridgeContent = (props, context) => {
  const { act, data } = useBackend<FridgeData>(context);
  const { can_dry, drying, contents = [] } = data;
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const filteredProducts = contents.filter((product) =>
    product.display_name.toLowerCase().includes(searchText.toLowerCase())
  );
  return (
    <Section
      fill
      scrollable
      title="Содержимое"
      buttons={
        can_dry ? (
          <Button
            icon="power-off"
            selected={drying}
            content={drying ? 'Выключить сушку' : 'Включить сушку'}
            onClick={() => act('drying')}
          />
        ) : (
          <Input
            width={13.75}
            placeholder="Поиск..."
            value={searchText}
            onInput={(e, value) => setSearchText(value)}
          />
        )
      }
    >
      <Table>
        {filteredProducts.map((product, item) => (
          <Table.Row
            key={item}
            height={2}
            backgroundColor={item % 2 === 1 && 'rgba(255, 255, 255, 0.05)'}
          >
            <Table.Cell verticalAlign="middle">
              {capitalizeAll(product.display_name)}
            </Table.Cell>
            <Table.Cell verticalAlign="middle" color="gray" collapsing>
              ({product.quantity} в запасе)
            </Table.Cell>
            <Table.Cell verticalAlign="middle" collapsing>
              <Stack>
                <Stack.Item>
                  <Button
                    icon="angle-down"
                    tooltip="Выдать одно."
                    onClick={() =>
                      act('vend', { vend: product.vend, amount: 1 })
                    }
                  />
                </Stack.Item>
                <Stack.Item ml={0.85}>
                  <NumberInput
                    width={3}
                    minValue={0}
                    value={0}
                    maxValue={product.quantity}
                    step={1}
                    stepPixelSize={3}
                    onChange={(e, value) =>
                      act('vend', { vend: product.vend, amount: value })
                    }
                  />
                </Stack.Item>
                <Stack.Item ml={0.5}>
                  <Button
                    icon="angles-down"
                    tooltip="Выдать всё."
                    tooltipPosition="bottom-end"
                    onClick={() =>
                      act('vend', {
                        vend: product.vend,
                        amount: product.quantity,
                      })
                    }
                  />
                </Stack.Item>
              </Stack>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const FridgeEmpty = (props, context) => {
  const { act, data } = useBackend<FridgeData>(context);
  return (
    <Section fill title="Содержимое">
      <Stack fill>
        <Stack.Item bold grow textAlign="center" align="center" color="average">
          <Icon.Stack mb={1}>
            <Icon
              name={data.can_dry ? 'leaf' : 'cookie-bite'}
              size={5}
              color={data.can_dry ? 'good' : 'brown'}
            />
            <Icon name="slash" size={5} color="red" />
          </Icon.Stack>
          <br />
          {data.can_dry ? 'Сушилка пустая' : 'Продукты отсутствуют'}
        </Stack.Item>
      </Stack>
    </Section>
  );
};
