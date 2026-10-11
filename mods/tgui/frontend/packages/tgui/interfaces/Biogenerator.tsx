import { BooleanLike } from '../../common/react';
import { capitalizeAll } from 'common/string';
import { useBackend, useSharedState } from '../backend';
import {
  Button,
  Section,
  Stack,
  Collapsible,
  Icon,
  LabeledList,
  ProgressBar,
  Dimmer,
  NumberInput,
} from '../components';
import { Window } from '../layouts';

type BiogenData = {
  processing: BooleanLike;
  storedPlants: BooleanLike;
  container: BooleanLike;
  containerContent: number;
  containerMaxContent: number;
  biomass: number;
  types: BiogenType[];
};

type BiogenType = {
  type_name: string;
  products: BiogenList[];
};

type BiogenList = {
  name: string;
  cost: number;
  product_index: number;
};

export const Biogenerator = (props, context) => {
  const { act, data } = useBackend<BiogenData>(context);
  const {
    biomass,
    container,
    containerContent,
    containerMaxContent,
    processing,
    storedPlants,
  } = data;
  return (
    <Window width={400} height={600} title="Биогенератор">
      <Window.Content>
        {!!processing && <BiogenProcessing />}
        <Stack fill vertical>
          <Stack.Item>
            <Section title="Статус">
              <LabeledList>
                <LabeledList.Item label="Биомасса">
                  {biomass} <Icon name="leaf" color="green" size={1.2} />
                </LabeledList.Item>
                <LabeledList.Item label="Ёмкость">
                  <ProgressBar
                    value={containerContent || 0}
                    maxValue={containerMaxContent || 1}
                  >
                    {container ? (
                      <Stack.Item textAlign="center">
                        {containerContent +
                          ' / ' +
                          containerMaxContent +
                          ' юнитов'}
                      </Stack.Item>
                    ) : (
                      <Stack.Item textAlign="center">
                        Ёмкость отсутствует
                      </Stack.Item>
                    )}
                  </ProgressBar>
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Управление">
              <Stack textAlign="center">
                <Stack.Item grow basis="30%">
                  <Button
                    fluid
                    icon="power-off"
                    disabled={!storedPlants}
                    content="Включить"
                    onClick={() => act('activate')}
                  />
                </Stack.Item>
                <Stack.Item grow basis="40%">
                  <Button
                    fluid
                    icon="bucket"
                    disabled={!container}
                    content="Достать контейнер"
                    onClick={() => act('detach')}
                  />
                </Stack.Item>
                <Stack.Item grow basis="30%">
                  <Button
                    fluid
                    icon="eject"
                    disabled={!storedPlants}
                    content="Извлечь"
                    onClick={() => act('eject_plants')}
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            {container ? <BiogenProducts /> : <BiogenNoBeaker />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const BiogenProducts = (props, context) => {
  const { act, data } = useBackend<BiogenData>(context);
  let [vendAmount, setVendAmount] = useSharedState(context, 'vendAmount', 1);
  return (
    <Section
      fill
      scrollable
      title="Продукты"
      buttons={
        <>
          <Stack.Item inline mr="5px" color="silver">
            Количество партии:
          </Stack.Item>
          <NumberInput
            animated
            value={vendAmount}
            width="32px"
            minValue={1}
            maxValue={10}
            stepPixelSize={10}
            onChange={(e, value) => setVendAmount(value)}
          />
        </>
      }
    >
      {data.types.map((type, typeIndex) => (
        <Collapsible key={typeIndex} title={type.type_name} open>
          {type.products.map((product, productIndex) => (
            <Stack
              key={productIndex}
              py={0.5}
              className="candystripe"
              align="center"
            >
              <Stack.Item grow basis="70%" ml={0.5}>
                {capitalizeAll(product.name)}
              </Stack.Item>
              <Stack.Item grow basis="28%" mr={1} textAlign="right">
                {product.cost * vendAmount}
                <Icon ml={1} name="leaf" color="green" size={1.2} />
              </Stack.Item>
              <Stack.Item>
                <Button
                  width={1.7}
                  icon={vendAmount > 1 ? 'angles-down' : 'angle-down'}
                  disabled={data.biomass < product.cost * vendAmount}
                  tooltip={
                    data.biomass < product.cost * vendAmount &&
                    'Не хватает биомассы для производства.'
                  }
                  tooltipPosition="bottom-end"
                  onClick={() =>
                    act('create', {
                      type: type.type_name,
                      product_index: productIndex + 1,
                      amount: vendAmount,
                    })
                  }
                />
              </Stack.Item>
            </Stack>
          ))}
        </Collapsible>
      ))}
    </Section>
  );
};

const BiogenNoBeaker = () => {
  return (
    <Section fill>
      <Stack fill bold textAlign="center">
        <Stack.Item grow fontSize={1.5} align="center" color="label">
          <Icon.Stack>
            <Icon size={5} name="bucket" color="blue" />
            <Icon size={5} name="slash" color="red" />
          </Icon.Stack>
          <br />
          Отсутствует ёмкость
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const BiogenProcessing = () => {
  return (
    <Dimmer>
      <Stack fill textAlign="center">
        <Stack.Item bold color="label">
          <Icon name="spinner" color="white" size={5} mb={5} spin />
          <br />
          Биогенератор работает...
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};
