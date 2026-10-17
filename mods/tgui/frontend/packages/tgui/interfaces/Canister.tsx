import { toFixed } from 'common/math';
import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Stack,
  Icon,
  Knob,
  LabeledControls,
  RoundGauge,
  Section,
  Tooltip,
} from '../components';
import { formatSiUnit } from '../format';
import { Window } from '../layouts';

const formatPressure = (value: number) => {
  if (value < 10000) {
    return toFixed(value) + ' kPa';
  }
  return formatSiUnit(value * 1000, 1, 'Pa');
};

type CanisterData = {
  portConnected: BooleanLike;
  valveOpen: BooleanLike;
  canLabel: BooleanLike;
  hasHoldingTank: BooleanLike;
  name: string;
  tankPressure: number;
  maximumPressure: number;
  minReleasePressure: number;
  releasePressure: number;
  maxReleasePressure: number;
  holdingTank: HoldingTank;
};

type HoldingTank = {
  name: string;
  tankPressure: number;
};

export const Canister = (props, context) => {
  const { act, data } = useBackend<CanisterData>(context);
  const {
    valveOpen,
    tankPressure,
    maximumPressure,
    minReleasePressure,
    releasePressure,
    maxReleasePressure,
    portConnected,
    hasHoldingTank,
    holdingTank,
  } = data;

  return (
    <Window width={245} height={405}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section
              title="Статус"
              buttons={
                !!data.canLabel && (
                  <Button
                    icon="pencil-alt"
                    content="Перекрасить"
                    onClick={() => act('relabel')}
                  />
                )
              }
            >
              <LabeledControls>
                <LabeledControls.Item label="Порт">
                  <Tooltip
                    content={portConnected ? 'Подключено' : 'Отключено'}
                    position="top"
                  >
                    <Box position="relative">
                      <Icon
                        size={1.5}
                        name={portConnected ? 'plug' : 'times'}
                        color={portConnected ? 'good' : 'bad'}
                      />
                    </Box>
                  </Tooltip>
                </LabeledControls.Item>
                <LabeledControls.Item minWidth="66px" label="Давление">
                  <RoundGauge
                    size={1.75}
                    value={tankPressure}
                    minValue={0}
                    maxValue={maximumPressure}
                    alertAfter={maximumPressure * 0.85}
                    ranges={{
                      good: [0, maximumPressure * 0.66],
                      average: [maximumPressure * 0.66, maximumPressure * 0.85],
                      bad: [maximumPressure * 0.85, maximumPressure],
                    }}
                    format={formatPressure}
                  />
                </LabeledControls.Item>
                <LabeledControls.Item mr={1} label="Вентиль">
                  <Button
                    my={0.5}
                    width="50px"
                    lineHeight={2}
                    fontSize="11px"
                    color={
                      valveOpen ? (hasHoldingTank ? 'caution' : 'danger') : null
                    }
                    content={valveOpen ? 'Открыт' : 'Закрыт'}
                    onClick={() => act('toggle')}
                  />
                </LabeledControls.Item>
              </LabeledControls>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Управление">
              <Stack textAlign="center">
                <Stack.Item grow basis="20%">
                  <Button
                    fluid
                    lineHeight={4}
                    fontSize={1.5}
                    color="transparent"
                    icon="undo"
                    onClick={() =>
                      act('pressure', {
                        pressure: 'reset',
                      })
                    }
                  />
                </Stack.Item>
                <Stack.Item grow basis="50%">
                  <LabeledControls.Item label="Регулятор">
                    <Knob
                      size={2}
                      color={!!valveOpen && 'yellow'}
                      value={releasePressure}
                      unit="kPa"
                      minValue={minReleasePressure}
                      maxValue={maxReleasePressure}
                      step={5}
                      stepPixelSize={1}
                      onDrag={(e, value) =>
                        act('pressure', {
                          pressure: value,
                        })
                      }
                    />
                  </LabeledControls.Item>
                </Stack.Item>
                <Stack.Item grow basis="20%">
                  <Button
                    fluid
                    lineHeight={4}
                    fontSize={1.5}
                    color="transparent"
                    icon="fast-forward"
                    onClick={() =>
                      act('pressure', {
                        pressure: maxReleasePressure,
                      })
                    }
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              fill
              title="Баллон"
              buttons={
                <Button
                  icon="eject"
                  disabled={!hasHoldingTank}
                  color={valveOpen && 'danger'}
                  content="Извлечь"
                  onClick={() => act('remove_tank')}
                />
              }
            >
              {hasHoldingTank ? (
                <LabeledControls.Item label={holdingTank.name}>
                  <RoundGauge
                    value={holdingTank.tankPressure}
                    minValue={0}
                    maxValue={maxReleasePressure}
                    ranges={{
                      good: [0, maxReleasePressure / 3],
                      average: [
                        maxReleasePressure / 3,
                        maxReleasePressure / 1.4,
                      ],
                      bad: [
                        maxReleasePressure / 1.4,
                        maxReleasePressure / 1.03,
                      ],
                    }}
                    format={formatPressure}
                    size={2.5}
                  />
                </LabeledControls.Item>
              ) : (
                <Stack fill bold textAlign="center">
                  <Stack.Item grow align="center" color="label">
                    <Icon.Stack mb={-5} mt={1}>
                      <Icon size={3.5} name="tg-air-tank" color="blue" />
                      <Icon size={3} name="slash" color="red" rotation={6} />
                    </Icon.Stack>
                    <br />
                    Баллон отсутствует
                  </Stack.Item>
                </Stack>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
