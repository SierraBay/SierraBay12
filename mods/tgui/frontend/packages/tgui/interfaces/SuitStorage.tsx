import { BooleanLike } from '../../common/react';
import { capitalizeAll } from 'common/string';
import { useBackend } from '../backend';
import {
  Button,
  Dimmer,
  NoticeBox,
  Icon,
  LabeledList,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

type SuitStorageData = {
  occupied: BooleanLike;
  panel_open: BooleanLike;
  door_open: BooleanLike;
  locked: BooleanLike;
  uv: BooleanLike;
  super_uv: BooleanLike;
  safeties: BooleanLike;
  helmet: string;
  suit: string;
  boots: string;
  tank: string;
  mask: string;
};

const noThe = (name: string) => {
  if (name.startsWith('the ')) {
    return name.slice(4);
  }
  return name;
};

export const SuitStorage = (props, context) => {
  const { act, data } = useBackend<SuitStorageData>(context);
  const { door_open, uv, panel_open } = data;
  return panel_open ? (
    <Window width={340} height={200} title="Maintenance">
      <Window.Content scrollable>
        <Stack fill vertical textAlign="center">
          <StorageMaint />
        </Stack>
      </Window.Content>
    </Window>
  ) : (
    <Window width={400} height={400} title="Suit Storage Unit">
      {!!uv && <StorageUV />}
      <Window.Content>
        <Stack fill vertical textAlign="center">
          <Stack.Item grow minHeight={0}>
            {door_open ? <StorageContent /> : <StorageLocked />}
          </Stack.Item>
          <Stack.Item>
            <StorageControl />
          </Stack.Item>
          {!!data.occupied && (
            <Stack.Item>
              <Button
                fluid
                content="Eject occupant"
                onClick={() => act('eject_guy')}
              />
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const StorageContent = (props, context) => {
  const { act, data } = useBackend<SuitStorageData>(context);
  const { helmet, suit, boots, mask, tank } = data;
  return (
    <Section fill scrollable title="Хранимые вещи">
      <Stack vertical>
        <Stack.Item>
          <Button
            fluid
            disabled={!helmet}
            content={helmet ? capitalizeAll(noThe(helmet)) : 'Шлем отсутствует'}
            onClick={() => act('dispense_helmet')}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            fluid
            disabled={!suit}
            content={suit ? capitalizeAll(noThe(suit)) : 'Риг отсутствует'}
            onClick={() => act('dispense_suit')}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            fluid
            disabled={!boots}
            content={
              boots ? capitalizeAll(noThe(boots)) : 'Ботинки отсутствуют'
            }
            onClick={() => act('dispense_boots')}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            fluid
            disabled={!mask}
            content={mask ? capitalizeAll(noThe(mask)) : 'Маска отсутствует'}
            onClick={() => act('dispense_mask')}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            fluid
            disabled={!tank}
            content={tank ? capitalizeAll(noThe(tank)) : 'Баллон отсутствует'}
            onClick={() => act('dispense_tank')}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const StorageControl = (props, context) => {
  const { act, data } = useBackend<SuitStorageData>(context);
  const { locked, door_open } = data;
  return (
    <Section>
      <Stack fill>
        <Stack.Item grow basis="33%">
          <Button
            fluid
            disabled={door_open}
            content="Дезинфекция"
            icon="radiation"
            onClick={() => act('start_UV')}
          />
        </Stack.Item>
        <Stack.Item grow basis="25%">
          <Button
            fluid
            disabled={locked}
            color={door_open ? 'bad' : 'good'}
            content={door_open ? 'Закрыть' : 'Открыть'}
            icon={door_open ? 'door-closed' : 'door-open'}
            tooltip={locked ? 'Хранилище заперто.' : ''}
            onClick={() => act('toggle_open')}
          />
        </Stack.Item>
        <Stack.Item grow basis="33%">
          <Button
            fluid
            disabled={door_open}
            content={locked ? 'Отпереть' : 'Запереть'}
            icon={locked ? 'lock-open' : 'lock'}
            onClick={() => act('toggle_lock')}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const StorageLocked = (props, context) => {
  const { act, data } = useBackend<SuitStorageData>(context);
  const { locked } = data;
  return (
    <Section fill>
      <Stack fill textAlign="center">
        <Stack.Item bold grow align="center" color="label">
          <Icon name={locked ? 'lock' : 'door-closed'} size={5} mb={3} />
          <br />
          {locked ? 'Хранилище заперто' : 'Хранилище закрыто'}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const StorageUV = () => {
  return (
    <Dimmer backgroundColor="black" opacity={0.85}>
      <Stack fill textAlign="center">
        <Stack.Item bold color="label">
          <Icon name="spinner" color="white" size={5} mb={5} spin />
          <br />
          Дезинфекция содержимого в процессе...
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

const StorageMaint = (props, context) => {
  const { act, data } = useBackend<SuitStorageData>(context);
  const { safeties, super_uv } = data;
  return (
    <>
      <NoticeBox>Панель открыта, проводится тех. обслуживание.</NoticeBox>
      <Stack.Item grow>
        <Section fill>
          <LabeledList>
            <LabeledList.Item
              label="Протокол безопасности"
              buttons={
                <Button
                  icon={safeties ? 'heart' : 'skull'}
                  content={safeties ? 'Вкл' : 'Выкл'}
                  color={safeties ? 'good' : 'bad'}
                  onClick={() => act('togglesafeties')}
                />
              }
            />
            <LabeledList.Item
              label="Интенсивность UV"
              buttons={
                <Button
                  icon={super_uv ? 'triangle-exclamation' : ''}
                  content={super_uv ? '15nm' : '185nm'}
                  color={super_uv ? 'purple' : 'pink'}
                  onClick={() => act('toggleUV')}
                />
              }
            />
          </LabeledList>
        </Section>
      </Stack.Item>
    </>
  );
};
