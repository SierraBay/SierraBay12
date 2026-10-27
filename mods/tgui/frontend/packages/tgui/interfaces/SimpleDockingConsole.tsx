import { useBackend } from '../backend';
import { Button, LabeledList, Section, Stack } from '../components';
import { Window } from '../layouts';

export type SimpleDockingConsoleData = {
  docking_status: string;
  override_enabled: boolean;
  door_state: string;
  door_lock: string;
};

export const SimpleDockingConsole = (props, context) => {
  const { act, data } = useBackend<SimpleDockingConsoleData>(context);

  return (
    <Window width="330" height="200">
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item grow>
            <Section fill title="Status">
              <Stack.Item>
                <LabeledList>
                  <LabeledList.Item label="Docking Port Status">
                    {data.docking_status === 'docked' ? (
                      data.override_enabled ? (
                        <Stack.Item>Docked - Override Enabled</Stack.Item>
                      ) : (
                        <Stack.Item>Docked</Stack.Item>
                      )
                    ) : data.docking_status === 'docking' ? (
                      data.override_enabled ? (
                        <Stack.Item>Docking - Override Enabled</Stack.Item>
                      ) : (
                        <Stack.Item>Docking</Stack.Item>
                      )
                    ) : data.docking_status === 'undocking' ? (
                      data.override_enabled ? (
                        <Stack.Item>Undocking - Override Enabled</Stack.Item>
                      ) : (
                        <Stack.Item>Undocking</Stack.Item>
                      )
                    ) : data.docking_status === 'undocked' ? (
                      data.override_enabled ? (
                        <Stack.Item>Override Enabled</Stack.Item>
                      ) : (
                        <Stack.Item>Not in use</Stack.Item>
                      )
                    ) : (
                      <Stack.Item>Error</Stack.Item>
                    )}
                  </LabeledList.Item>
                  <LabeledList.Item label="Docking Hatch">
                    {data.docking_status === 'docked' ? (
                      data.door_state === 'open' ? (
                        <Stack.Item>Open</Stack.Item>
                      ) : data.door_state === 'closed' ? (
                        <Stack.Item>Closed</Stack.Item>
                      ) : (
                        <Stack.Item>Error</Stack.Item>
                      )
                    ) : data.docking_status === 'docking' ? (
                      data.door_state === 'open' ? (
                        <Stack.Item>Open</Stack.Item>
                      ) : data.door_state === 'closed' &&
                        data.door_lock === 'locked' ? (
                        <Stack.Item>Secured</Stack.Item>
                      ) : data.door_state === 'closed' &&
                        data.door_lock === 'unlocked' ? (
                        <Stack.Item>Unsecured</Stack.Item>
                      ) : (
                        <Stack.Item>Error</Stack.Item>
                      )
                    ) : data.docking_status === 'undocking' ? (
                      data.door_state === 'open' ? (
                        <Stack.Item>Open</Stack.Item>
                      ) : data.door_state === 'closed' &&
                        data.door_lock === 'locked' ? (
                        <Stack.Item>Secured</Stack.Item>
                      ) : data.door_state === 'closed' &&
                        data.door_lock === 'unlocked' ? (
                        <Stack.Item>Unsecured</Stack.Item>
                      ) : (
                        <Stack.Item>Error</Stack.Item>
                      )
                    ) : data.docking_status === 'undocked' ? (
                      data.door_state === 'open' ? (
                        <Stack.Item>Open</Stack.Item>
                      ) : data.door_state === 'closed' &&
                        data.door_lock === 'locked' ? (
                        <Stack.Item>Secured</Stack.Item>
                      ) : data.door_state === 'closed' &&
                        data.door_lock === 'unlocked' ? (
                        <Stack.Item>Unsecured</Stack.Item>
                      ) : (
                        <Stack.Item>Error</Stack.Item>
                      )
                    ) : (
                      <Stack.Item>Error</Stack.Item>
                    )}
                  </LabeledList.Item>
                </LabeledList>
              </Stack.Item>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Controls">
              <Stack>
                <Stack.Item grow basis="0">
                  <Button
                    fluid
                    content="Force Exterior Door"
                    icon="circle-exclamation"
                    disabled={!data.override_enabled}
                    color={data.override_enabled ? 'red' : null}
                    onClick={() => act('force_door')}
                  />
                </Stack.Item>
                <Stack.Item grow basis="0">
                  <Button
                    fluid
                    content="Override"
                    icon="triangle-exclamation"
                    color={data.override_enabled ? 'red' : 'yellow'}
                    onClick={() => act('toggle_override')}
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
