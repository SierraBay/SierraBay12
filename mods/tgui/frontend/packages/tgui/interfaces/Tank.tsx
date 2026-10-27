import { toFixed } from 'common/math';
import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import {
  Button,
  Stack,
  LabeledControls,
  RoundGauge,
  Section,
  NumberInput,
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
  has_mask: BooleanLike;
  connected: BooleanLike;
  tankPressure: number;
  maxReleasePressure: number;
  defaultReleasePressure: number;
  releasePressure: number;
  maximumPressure: number;
};

export const Tank = (props, context) => {
  const { act, data } = useBackend<CanisterData>(context);
  const {
    tankPressure,
    maxReleasePressure,
    defaultReleasePressure,
    releasePressure,
    maximumPressure,
    has_mask,
    connected,
  } = data;

  return (
    <Window width={280} height={145}>
      <Window.Content>
        <Stack>
          <Stack.Item>
            <Section height="100px" width="100px">
              <Stack.Item textAlign="center" mt={1}>
                <RoundGauge
                  size={2.5}
                  value={tankPressure}
                  minValue={0}
                  maxValue={maximumPressure}
                  ranges={{
                    good: [0, maximumPressure * 0.66],
                    average: [maximumPressure * 0.66, maximumPressure * 0.85],
                    bad: [maximumPressure * 0.85, maximumPressure],
                  }}
                  format={formatPressure}
                />
              </Stack.Item>
              <Stack.Item color="label" textAlign="center" mt={0.75}>
                Давление
              </Stack.Item>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section height="100px">
              <LabeledControls.Item label="Регулятор" mt={0.5}>
                <Stack height={1.66}>
                  <Button
                    height={1.66}
                    icon="fast-backward"
                    disabled={releasePressure === 0}
                    tooltip="Минимум"
                    onClick={() =>
                      act('pressure', {
                        pressure: 0,
                      })
                    }
                  />
                  <NumberInput
                    animated
                    value={releasePressure}
                    width="65px"
                    unit="kPa"
                    minValue={0}
                    maxValue={maxReleasePressure}
                    onChange={(e, value) =>
                      act('pressure', {
                        pressure: value,
                      })
                    }
                  />
                  <Button
                    height={1.66}
                    icon="fast-forward"
                    disabled={releasePressure === maxReleasePressure}
                    tooltip="Максимум"
                    onClick={() =>
                      act('pressure', {
                        pressure: maxReleasePressure,
                      })
                    }
                  />
                  <Button
                    icon="undo"
                    content=""
                    disabled={releasePressure === defaultReleasePressure}
                    tooltip="Сбросить"
                    onClick={() =>
                      act('pressure', {
                        pressure: defaultReleasePressure,
                      })
                    }
                  />
                </Stack>
              </LabeledControls.Item>
              <LabeledControls.Item label="Вентиль" mt={1}>
                <Button
                  width={5}
                  my={0.3}
                  disabled={!has_mask}
                  lineHeight={2}
                  content={connected ? 'Открыт' : 'Закрыт'}
                  tooltip={!has_mask && 'Наденьте маску.'}
                  onClick={() => act('internals')}
                />
              </LabeledControls.Item>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
