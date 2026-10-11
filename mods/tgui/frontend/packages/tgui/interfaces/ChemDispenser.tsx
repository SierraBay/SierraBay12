import { BooleanLike } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import {
  Button,
  Icon,
  ProgressBar,
  Section,
  Slider,
  Stack,
} from '../components';
import { Window } from '../layouts';

type ChemData = {
  isBeakerLoaded: BooleanLike;
  drinkingGlass: BooleanLike;
  beakerContents: Beaker[];
  chemicals: Chemical[];
  amount: number;
  beakerCurrentVolume: number;
  beakerMaxVolume: number;
};

type Beaker = {
  name: string;
  volume: number;
};

type Chemical = {
  label: string;
  amount: number;
  capacity: number;
};

export const ChemDispenser = (props, context) => {
  const { act, data } = useBackend<ChemData>(context);
  return (
    <Window width={420} height={620}>
      <Window.Content>
        <Stack fill vertical>
          <ChemAmount />
          <ChemReagents />
          <ChemBeaker />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ChemAmount = (props, context) => {
  const { act, data } = useBackend<ChemData>(context);
  const amounts = [1, 2, 5, 10, 20, 30, 40, 50];
  return (
    <Stack.Item>
      <Section fill title={'Количество'}>
        <Stack>
          {amounts.map((num) => (
            <Stack.Item key={num} grow textAlign="center">
              <Button
                fluid
                selected={data.amount === num}
                content={num}
                icon={'gear'}
                onClick={() => act('amount', { amount: num })}
              />
            </Stack.Item>
          ))}
        </Stack>
        <Slider
          mt={1}
          animated
          value={data.amount}
          fillValue={data.amount}
          minValue={1}
          maxValue={120}
          onChange={(e, value) => act('amount', { amount: value })}
        />
      </Section>
    </Stack.Item>
  );
};

const ChemReagents = (props, context) => {
  const { act, data } = useBackend<ChemData>(context);
  const [cartStat, setCartStat] = useLocalState(context, 'cartStat', false);
  return (
    <Stack.Item grow basis={0} minHeight={10}>
      <Section
        fill
        scrollable
        title={'Реагенты'}
        buttons={
          <Button.Checkbox
            checked={cartStat}
            disabled={data.chemicals.length === 0}
            content={'Статус картриджей'}
            onClick={() => setCartStat(!cartStat)}
          />
        }
      >
        {data.chemicals.length > 0 ? (
          data.chemicals.map((reagent) =>
            cartStat ? (
              <ProgressBar
                key={reagent.label}
                m={0.3}
                width={10}
                height={1.66}
                fontSize={0.8}
                value={reagent.amount}
                minValue={0}
                maxValue={reagent.capacity}
                ranges={{
                  good: [reagent.capacity * 0.6, Infinity],
                  average: [reagent.capacity * 0.2, reagent.capacity * 0.6],
                  bad: [-Infinity, reagent.capacity * 0.2],
                }}
                tooltip={`${reagent.amount} / ${reagent.capacity}u`}
              >
                {reagent.label}
              </ProgressBar>
            ) : (
              <Button
                key={reagent.label}
                m={0.3}
                width={10}
                height={1.66}
                fontSize={0.9}
                content={reagent.label}
                tooltip={<>Остаток: {reagent.amount}u</>}
                onClick={() => act('dispense', { dispense: reagent.label })}
              />
            )
          )
        ) : (
          <Stack fill bold textAlign="center">
            <Stack.Item grow fontSize={1.25} align="center" color="label" m={3}>
              <Icon.Stack>
                <Icon size={5} name={'droplet'} color="blue" />
                <Icon size={5} name={'slash'} color="red" />
              </Icon.Stack>
              <br />
              {'Нет картриджей'}
            </Stack.Item>
          </Stack>
        )}
      </Section>
    </Stack.Item>
  );
};

const ChemBeaker = (props, context) => {
  const { act, data } = useBackend<ChemData>(context);
  return (
    <Stack.Item grow basis={0} minHeight={10}>
      <Section
        fill
        scrollable
        title={'Ёмкость'}
        buttons={
          <Stack>
            {!!data.beakerMaxVolume && (
              <Stack.Item>
                <ProgressBar
                  width={10}
                  value={data.beakerCurrentVolume}
                  maxValue={data.beakerMaxVolume}
                  ranges={{
                    bad: [data.beakerMaxVolume, Infinity],
                  }}
                >
                  {data.beakerCurrentVolume || 0} / {data.beakerMaxVolume || 0}
                </ProgressBar>
              </Stack.Item>
            )}
            <Stack.Item>
              <Button
                content={'Вынуть ёмкость'}
                icon={'flask'}
                disabled={!data.isBeakerLoaded}
                onClick={() => act('flush')}
              />
            </Stack.Item>
          </Stack>
        }
      >
        {data.isBeakerLoaded && data.beakerContents.length > 0 ? (
          <Stack vertical zebra>
            {data.beakerContents.map((reagent) => (
              <Stack.Item key={reagent.name} color="label" fontSize={1.1}>
                {reagent.volume} units of {reagent.name}
              </Stack.Item>
            ))}
          </Stack>
        ) : (
          <ChemBeakerStat />
        )}
      </Section>
    </Stack.Item>
  );
};

const ChemBeakerStat = (props, context) => {
  const { act, data } = useBackend<ChemData>(context);
  return (
    <Stack fill bold textAlign="center">
      <Stack.Item grow fontSize={1.25} align="center" color="label">
        <Icon.Stack>
          <Icon size={5} name="flask" color="blue" />
          <Icon
            size={5}
            name={data.isBeakerLoaded ? '' : 'slash'}
            color="red"
          />
        </Icon.Stack>
        <br />
        {data.isBeakerLoaded ? 'Ёмкость пуста' : 'Отсутствует ёмкость'}
      </Stack.Item>
    </Stack>
  );
};
