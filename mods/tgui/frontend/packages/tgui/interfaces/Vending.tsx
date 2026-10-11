import { classes, BooleanLike } from 'common/react';
import { capitalizeAll } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import {
  Button,
  Icon,
  Section,
  Stack,
  ImageButton,
  Dimmer,
  NoticeBox,
  LabeledList,
  Input,
} from '../components';
import { Window } from '../layouts';

export type VendingData = {
  vend_ready: BooleanLike;
  message_err: BooleanLike;
  speaker: BooleanLike;
  panel: BooleanLike;
  mode: BooleanLike;
  isSilicon: BooleanLike;
  product: string;
  image: string;
  price: number;
  coin: string;
  message: string;
  products: Product[];
};

type Product = {
  key: string;
  name: string;
  price: number;
  category: number;
  ammount: number;
  image: string;
};

const CATEGORY = {
  Common: 1,
  Contaraband: 2,
  Antag: 3,
  Premium: 4,
};

export const Vending = (props, context) => {
  const { act, data } = useBackend<VendingData>(context);
  return !data.panel ? <VendingMain /> : <VendingMaint />;
};

const VendingMaint = (props, context) => {
  const { act, data } = useBackend<VendingData>(context);
  const { speaker } = data;
  return (
    <Window width={375} height={175}>
      <Window.Content>
        <Stack fill vertical>
          <NoticeBox>Панель открыта, проводится тех. обслуживание.</NoticeBox>
          <Stack.Item grow>
            <Section fill title="Параметры">
              <LabeledList>
                <LabeledList.Item
                  label="Динамик"
                  buttons={
                    <Button
                      content={speaker ? 'On' : 'Off'}
                      selected={speaker}
                      icon={speaker ? 'volume-up' : 'volume-mute'}
                      color={speaker ? '' : 'bad'}
                      onClick={() => act('togglevoice')}
                    />
                  }
                />
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const VendingMain = (props, context) => {
  const { act, data } = useBackend<VendingData>(context);
  const { coin, vend_ready, products = [] } = data;
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const filteredProducts = products.filter((product) =>
    product.name.toLowerCase().includes(searchText.toLowerCase())
  );
  return (
    <Window width={420} height={535}>
      {!vend_ready || data.mode ? <Vend /> : ''}
      <Window.Content>
        <Section
          fill
          scrollable
          title="Продукты"
          buttons={
            <>
              {coin ? (
                <Button
                  mr={1}
                  content="Достать монетку"
                  disabled={data.isSilicon}
                  tooltip="Вы не можете достать монетку."
                  onClick={() => act('remove_coin')}
                />
              ) : null}
              <Input
                width={10.5}
                placeholder="Поиск..."
                value={searchText}
                onInput={(e, value) => setSearchText(value)}
              />
            </>
          }
        >
          {filteredProducts.map((product) => (
            <ImageButton
              key={product.key}
              vertical
              m={0.5}
              image={product.image}
              imageSize={'64px'}
              disabled={product.ammount <= 0}
              color={
                product.category === CATEGORY.Contaraband
                  ? 'violet'
                  : product.category === CATEGORY.Premium
                    ? 'gold'
                    : ''
              }
              content={
                product.price > 0
                  ? `${product.price} ₸`
                  : product.category === CATEGORY.Premium
                    ? 'Coin'
                    : 'Free'
              }
              disabledContent="Empty"
              tooltip={
                <>
                  {<b>{capitalizeAll(product.name)}</b>}
                  <br />
                  <br />
                  (В наличии: <b>{product.ammount}</b>)
                </>
              }
              onClick={() => act('vend', { vend: product.key })}
            />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};

const Vend = (props, context) => {
  const { act, data } = useBackend<VendingData>(context);
  return data.mode && data.vend_ready ? (
    <Dimmer textAlign="center">
      <Stack vertical width="calc(100vw - 2rem)" height="calc(100vh - 4rem)">
        <Stack.Item>
          <NoticeBox color={data.message_err ? 'bad' : undefined}>
            {data.message_err
              ? data.message
              : 'Для оплаты, проведите картой или вставьте деньги.'}
          </NoticeBox>
        </Stack.Item>
        <Stack.Item grow minHeight={0} overflowY="auto">
          <Stack vertical align="center" justify="center" fill>
            <Stack.Item color="label">Вы покупаете</Stack.Item>
            <Stack.Item
              bold
              fontSize={1.5}
              style={{ 'overflow-wrap': 'anywhere' }}
            >
              {capitalizeAll(data.product)}
            </Stack.Item>
            <Stack.Item>
              <img
                src={`data:image/png;base64,${data.image}`}
                style={{
                  width: '140px',
                  '-ms-interpolation-mode': 'nearest-neighbor',
                }}
              />
            </Stack.Item>
            <Stack.Item color="label">К оплате</Stack.Item>
            <Stack.Item bold fontSize={2}>
              {data.price} ₸
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Button
            fluid
            lineHeight={2}
            content="Отмена"
            onClick={() => act('cancelpurchase')}
          />
        </Stack.Item>
      </Stack>
    </Dimmer>
  ) : (
    <Dimmer textAlign="center">
      <Icon name="smile" size={7} color="yellow" />
      <Stack.Item color="label" mt={5}>
        <h1>Наслаждайтесь!</h1>
      </Stack.Item>
    </Dimmer>
  );
};
