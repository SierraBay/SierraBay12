import { BooleanLike } from '../../common/react';
import { useBackend } from '../backend';
import {
  Button,
  BlockQuote,
  NoticeBox,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

export type APCData = {
  locked: BooleanLike;
  hasAccess: BooleanLike;
  isOperating: BooleanLike;
  chargeMode: BooleanLike;
  coverLocked: BooleanLike;
  siliconUser: BooleanLike;
  externalPower: number;
  chargingStatus: number;
  powerCellStatus: number;
  totalLoad: number;
  totalCharging: number;
  failTime: number;
  powerChannels: PowerChannel[];
};

type PowerChannel = {
  title: string;
  powerLoad: number;
  status: number;
  topicParams: string;
};

export const APC = (props, context) => {
  const { act, data } = useBackend<APCData>(context);
  return data.failTime > 0 ? <FailWindow /> : <APCWindow />;
};

export const FailWindow = (props, context) => {
  const { act, data } = useBackend<APCData>(context);

  return (
    <Window width={475} height={160} theme="malfunction">
      <Window.Content scrollable>
        <Section
          fill
          title="SYSTEM FAILURE"
          buttons={
            <Button
              content="Reboot Now"
              icon="sync"
              color="bad"
              onClick={() => act('reboot')}
            />
          }
        >
          <Stack.Item color="red">
            I/O regulator malfunction detected! Waiting for system reboot...
          </Stack.Item>
          <Stack.Item mt={1.5}>
            <BlockQuote>
              Automatic reboot in {data.failTime} seconds...
            </BlockQuote>
          </Stack.Item>
        </Section>
      </Window.Content>
    </Window>
  );
};

export const APCWindow = (props, context) => {
  const { act, data } = useBackend<APCData>(context);
  const { locked, hasAccess, isOperating, powerChannels } = data;
  const externalPowerStatus =
    powerStatusMap[data.externalPower] || powerStatusMap[0];
  const chargingStatus =
    powerStatusMap[data.chargingStatus] || powerStatusMap[0];
  const adjustedCellChange = data.powerCellStatus / 100;
  return (
    <Window width={475} height={400} theme="hephaestus">
      <Window.Content scrollable>
        <Stack fill vertical>
          <NoticeBox>
            <Stack fill>
              <Stack.Item grow align="center">
                Состояние интерфейса:
              </Stack.Item>
              <Stack.Item>
                <Button
                  fluid
                  disabled={!hasAccess}
                  content={locked ? 'Заблокирован' : 'Разблокирован'}
                  icon={locked ? 'lock' : 'lock-open'}
                  color={data.locked ? 'good' : 'bad'}
                  onClick={() => act('toggleaccess')}
                  style={{
                    'font-style': 'normal',
                  }}
                />
              </Stack.Item>
            </Stack>
          </NoticeBox>
          <Stack.Item>
            <Section
              title="Статус питания"
              buttons={
                data.siliconUser ? (
                  <Button
                    content="Overload Lighting Circuit"
                    icon="lightbulb"
                    disabled={locked}
                    onClick={() => act('overload')}
                  />
                ) : (
                  ''
                )
              }
            >
              <LabeledList>
                <LabeledList.Item
                  label="Рубильник"
                  color={externalPowerStatus.color}
                  buttons={
                    <Button
                      icon={isOperating ? 'power-off' : 'times'}
                      content={isOperating ? 'On' : 'Off'}
                      selected={isOperating}
                      color={isOperating ? '' : 'bad'}
                      disabled={locked}
                      onClick={() => act('breaker')}
                    />
                  }
                >
                  [ {externalPowerStatus.externalPowerText} ]
                </LabeledList.Item>
                <LabeledList.Item label="Аккумулятор">
                  <ProgressBar color="good" value={adjustedCellChange} />
                </LabeledList.Item>
                <LabeledList.Item
                  label="Режим зарядки"
                  color={chargingStatus.color}
                  buttons={
                    <Button
                      icon={data.chargeMode ? 'sync' : 'times'}
                      content={data.chargeMode ? 'Auto' : 'Off'}
                      selected={data.chargeMode}
                      color={data.chargeMode ? '' : 'bad'}
                      disabled={locked}
                      onClick={() => act('cmode')}
                    />
                  }
                >
                  [ {chargingStatus.chargingText} ]
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Каналы питания">
              <LabeledList>
                {data.powerChannels.map((channel) => (
                  <LabeledList.Item
                    label={channel.title}
                    key={channel.title}
                    buttons={
                      <>
                        <Button
                          content="Auto"
                          selected={
                            channel.status === 2 || channel.status === 4
                          }
                          icon="sync"
                          disabled={locked}
                          onClick={() =>
                            act('set', { set: 2, chan: channel.title })
                          }
                        />
                        <Button
                          content="On"
                          selected={
                            channel.status === 1 || channel.status === 3
                          }
                          icon="power-off"
                          disabled={locked}
                          onClick={() =>
                            act('set', { set: 1, chan: channel.title })
                          }
                        />
                        <Button
                          content="Off"
                          selected={channel.status === 0}
                          icon="times"
                          disabled={locked}
                          onClick={() =>
                            act('set', { set: 0, chan: channel.title })
                          }
                        />
                      </>
                    }
                  >
                    <Stack.Item color={channelStatClass(channel.status)}>
                      [{channelStatus(channel.status)}] | [
                      {channelPower(channel.status)}] | {channel.powerLoad} W
                    </Stack.Item>
                  </LabeledList.Item>
                ))}
                <LabeledList.Item label="Общая нагрузка">
                  <Stack.Item>
                    {data.totalLoad} W
                    {data.totalCharging
                      ? ` (+ ${data.totalCharging}W Заряжается)`
                      : null}
                  </Stack.Item>
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill title="Прочее">
              <LabeledList>
                <LabeledList.Item
                  label="Фиксатор"
                  buttons={
                    <Button
                      content={data.coverLocked ? 'Engaged' : 'Disengaged'}
                      icon={data.coverLocked ? 'lock' : 'lock-open'}
                      color={data.coverLocked ? '' : 'bad'}
                      selected={data.coverLocked}
                      disabled={locked}
                      onClick={() => act('lock')}
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

const powerStatusMap = {
  2: {
    color: 'good',
    externalPowerText: 'External Power',
    chargingText: 'Fully Charged',
  },
  1: {
    color: 'average',
    externalPowerText: 'Low External Power',
    chargingText: 'Charging',
  },
  0: {
    color: 'bad',
    externalPowerText: 'No External Power',
    chargingText: 'Not Charging',
  },
};

const channelStatus = (channelStat) => {
  if (channelStat <= 2) {
    return 'Off';
  } else return 'On';
};

const channelPower = (channelStat) => {
  if (channelStat === 2 || channelStat === 4) {
    return 'Auto';
  }
  return 'Manual';
};

const channelStatClass = (channelStat) => {
  if (channelStat <= 2) {
    return 'bad';
  }
  return 'good';
};
