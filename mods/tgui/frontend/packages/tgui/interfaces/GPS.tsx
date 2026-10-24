import { BooleanLike } from '../../common/react';
import { useBackend } from '../backend';
import { Button, Section, Stack, Table, Icon } from '../components';
import { Window } from '../layouts';

type GPSData = {
  tracking: BooleanLike;
  can_hide_signal: BooleanLike;
  hide_signal: BooleanLike;
  local_mode: BooleanLike;
  emped: BooleanLike;
  gps_tag: string;
  area: string;
  personal_ref: string;
  curr_x: number;
  curr_y: number;
  curr_z: number;
  gps_list: GPSList[];
};

type GPSList = {
  is_special_gps_marker: BooleanLike;
  gps_ref: string;
  gps_tag: string;
  gps_area: string;
  being_tracked: string;
  coloured_square: string;
  degrees: number;
  distance: number;
  local: number;
  x: number;
  y: number;
};

export const GPS = (props, context) => {
  const { act, data } = useBackend<GPSData>(context);
  const { tracking, emped } = data;
  return (
    <Window width={400} height={550} title={'GPS - ' + data.gps_tag}>
      <Window.Content>
        <Stack fill vertical>
          {emped ? (
            <Stack.Item grow>
              <TurnedOff emp />
            </Stack.Item>
          ) : (
            <>
              <Stack.Item>
                <Controls />
              </Stack.Item>
              <Stack.Item grow>
                {tracking ? <Signals /> : <TurnedOff emp={false} />}
              </Stack.Item>
            </>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const Controls = (props, context) => {
  const { act, data } = useBackend<GPSData>(context);
  const {
    tracking,
    can_hide_signal,
    hide_signal,
    local_mode,
    gps_tag,
    area,
    curr_x,
    curr_y,
    curr_z,
  } = data;
  return (
    <Section
      fill
      title="Управление"
      buttons={
        <Stack>
          {can_hide_signal ? (
            <Stack.Item>
              <Button
                icon={!hide_signal ? 'user' : 'user-secret'}
                selected={!hide_signal}
                tooltip={
                  !hide_signal
                    ? 'Скрыть свой сигнал'
                    : 'Не скрывать свой сигнал'
                }
                onClick={() => act('hide')}
              />
            </Stack.Item>
          ) : (
            ''
          )}
          <Stack.Item>
            <Button
              icon="power-off"
              selected={tracking}
              onClick={() => act('toggle_power')}
            />
          </Stack.Item>
        </Stack>
      }
    >
      <Stack vertical align="center" mb={2}>
        <Stack.Item bold>Текущее местоположение</Stack.Item>
        <Stack.Item color={tracking ? `label` : `gray`}>
          {tracking
            ? `${area} (${curr_x}, ${curr_y}, ${curr_z})`
            : 'Устройство выключено'}
        </Stack.Item>
      </Stack>
      <Stack vertical>
        <Stack mb={1}>
          <Stack.Item width="115px" color="label" align="center">
            Имя вашего GPS:
          </Stack.Item>
          <Stack.Item grow textAlign="center">
            <Button
              fluid
              color="translucent"
              content={gps_tag}
              icon="pen"
              onClick={() => act('tag')}
            />
          </Stack.Item>
        </Stack>
        <Stack>
          <Stack.Item width="115px" color="label" align="center">
            Диапазон частот:
          </Stack.Item>
          <Stack.Item grow textAlign="center">
            <Button
              fluid
              color="translucent"
              content={local_mode ? 'Узкий' : 'Широкий'}
              icon={local_mode ? 'compress' : 'expand'}
              onClick={() => act('range')}
            />
          </Stack.Item>
        </Stack>
      </Stack>
    </Section>
  );
};

const Signals = (props, context) => {
  const { act, data } = useBackend<GPSData>(context);
  const { gps_list = [] } = data;
  return gps_list.length === 0 ? (
    <NoSignals />
  ) : (
    <Section fill scrollable title="Сигналы">
      <Table>
        {gps_list.map((signal, item) => (
          <Table.Row
            key={item}
            height={2}
            backgroundColor={
              (signal.being_tracked && 'rgba(50, 75, 255, 0.2)') ||
              (item % 2 === 0 && 'rgba(255, 255, 255, 0.05)')
            }
          >
            <Table.Cell bold verticalAlign="middle">
              <Button
                width="75px"
                ellipsis
                mt={0.3}
                color="transparent"
                textColor="label"
                content={signal.gps_tag}
                tooltip={signal.gps_tag.length > 6 ? signal.gps_tag : ''}
              />
            </Table.Cell>
            <Table.Cell verticalAlign="middle" color="grey">
              {signal.gps_area}
            </Table.Cell>
            <Table.Cell verticalAlign="middle" collapsing>
              {signal.local ? (
                <Stack.Item
                  opacity={Math.max(
                    1 - Math.min(signal.distance, 100) / 100,
                    0.5
                  )}
                >
                  <Icon
                    name={signal.distance > 0 ? 'arrow-right' : 'circle'}
                    rotation={signal.degrees - 90}
                  />
                  &nbsp;
                  {signal.distance}m
                </Stack.Item>
              ) : (
                <Stack.Item grow textAlign="center">
                  <Icon name="question" />
                </Stack.Item>
              )}
            </Table.Cell>
            <Table.Cell verticalAlign="middle" collapsing>
              ({signal.x}, {signal.y})
            </Table.Cell>
            <Table.Cell width="55px" verticalAlign="middle" collapsing>
              <Stack>
                <Stack.Item>
                  <Button
                    icon="palette"
                    disabled={!signal.being_tracked}
                    tooltip="Сменить цвет на компасе"
                    tooltipPosition="top-end"
                    onClick={() =>
                      act('track_color', {
                        track_color: signal.gps_ref,
                      })
                    }
                  />
                </Stack.Item>
                {!signal.being_tracked ? (
                  <Stack.Item>
                    <Button
                      icon="location-arrow"
                      disabled={!signal.local}
                      tooltip={
                        signal.local
                          ? 'Отслеживать'
                          : 'Вы не можете отслеживать не локальные сигналы'
                      }
                      tooltipPosition="top-end"
                      onClick={() =>
                        act('start_track', {
                          start_track: signal.gps_ref,
                        })
                      }
                    />
                  </Stack.Item>
                ) : (
                  <Stack.Item>
                    <Button
                      icon="times"
                      color="red"
                      tooltip="Прекратить отслеживать"
                      tooltipPosition="top-end"
                      onClick={() =>
                        act('stop_track', {
                          stop_track: signal.gps_ref,
                        })
                      }
                    />
                  </Stack.Item>
                )}
              </Stack>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const NoSignals = () => {
  return (
    <Section fill>
      <Stack fill bold textAlign="center">
        <Stack.Item grow fontSize={1.5} align="center" color="label">
          <Icon.Stack>
            <Icon size={5} name="tower-broadcast" color="gray" />
            <Icon size={5} name="slash" color="red" />
          </Icon.Stack>
          <br />
          Нет сигналов
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const TurnedOff = ({ emp }) => {
  return (
    <Section fill>
      <Stack fill bold textAlign="center">
        <Stack.Item grow fontSize={1.5} align="center" color="label">
          <Icon.Stack>
            <Icon
              size={5}
              name={emp ? 'tower-broadcast' : 'power-off'}
              color="gray"
            />
            <Icon size={5} name={emp ? 'slash' : ''} color="red" />
          </Icon.Stack>
          <br />
          {emp
            ? 'ОШИБКА: Устройство временно потеряло сигнал'
            : 'Устройство выключено'}
        </Stack.Item>
      </Stack>
    </Section>
  );
};
