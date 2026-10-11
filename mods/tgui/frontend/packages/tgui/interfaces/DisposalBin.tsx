import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Button, LabeledList, Section, ProgressBar } from '../components';
import { Window } from '../layouts';

type Data = {
  mode: number;
  pressure: number;
  isAI: BooleanLike;
  panel_open: BooleanLike;
  flushing: BooleanLike;
};

export const DisposalBin = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { mode, pressure, isAI, panel_open, flushing } = data;
  let stateColor;
  let stateText;
  if (mode === 2) {
    stateColor = 'good';
    stateText = 'Готово';
  } else if (mode <= 0) {
    stateColor = 'bad';
    stateText = 'Выключено';
  } else if (mode === 1) {
    stateColor = 'average';
    stateText = 'Нагнетание';
  } else {
    stateColor = 'average';
    stateText = 'Простой';
  }
  return (
    <Window width={215} height={255}>
      <Window.Content>
        <Section title="Статус">
          <LabeledList>
            <LabeledList.Item label="Состояние" color={stateColor}>
              {stateText}
            </LabeledList.Item>
            <LabeledList.Item label="Давление">
              <ProgressBar
                ranges={{
                  bad: [-Infinity, 0],
                  average: [0, 99],
                  good: [99, Infinity],
                }}
                value={pressure}
                minValue={0}
                maxValue={100}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Управление">
          <LabeledList>
            <LabeledList.Item label="Спуск">
              <Button
                width={8}
                icon={flushing ? 'toggle-on' : 'toggle-off'}
                disabled={isAI || panel_open}
                content={flushing ? 'Включен' : 'Отключен'}
                color={flushing ? 'good' : 'bad'}
                onClick={() => act('flush')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Питание">
              <Button
                width={8}
                icon={mode ? 'toggle-on' : 'toggle-off'}
                disabled={mode === -1}
                content={mode ? 'Включено' : 'Отключено'}
                color={mode ? 'good' : 'bad'}
                onClick={() => act('mode')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Содержимое">
              <Button
                width={8}
                icon="sign-out-alt"
                disabled={isAI}
                content="Извлечь"
                onClick={() => act('eject')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
