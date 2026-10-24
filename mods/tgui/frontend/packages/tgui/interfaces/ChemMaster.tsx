import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import {
  Button,
  Icon,
  ImageButton,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
  Slider,
  Stack,
} from '../components';
import { Window } from '../layouts';

type ChemMasterData = {
  blisterDosage: number;
  blisterDosageMax: number;
  blisterType: number;
  isAnalyzedBlood: BooleanLike;
  isSloppy: BooleanLike;
  container: BooleanLike;
  pillBottle: BooleanLike;
  toBeaker: BooleanLike;
  productionOptions: string;
  pillBottleContent: number;
  pillBottleMaxContent: number;
  analyzedReagent: string;
  analyzedDesc: string;
  analyzedBloodSpecies: string;
  analyzedBloodType: string;
  analyzedBloodDNA: string;
  pillDosage: number;
  pillDosageMax: number;
  pillCount: number;
  pillCountMax: number;
  bottleDosage: number;
  bottleDosageMax: number;
  pillSprite: string;
  bottleSprite: string;
  containerChemicals: Container[];
  bufferChemicals: Buffer[];
  pillSprites: PillSprite[];
  bottleSprites: BottleSprite[];
};

type Container = {
  name: string;
  desc: string;
  volume: number;
  ref: string;
};

type Buffer = {
  name: string;
  desc: string;
  volume: number;
  ref: string;
};

type PillSprite = {
  id: number;
  sprite: string;
};

type BottleSprite = {
  id: string;
  sprite: string;
};

export const ChemMaster = (props, context) => {
  const { act, data } = useBackend<ChemMasterData>(context);
  return (
    <Window
      width={700}
      height={data.productionOptions !== 'CONDIMENTS' ? 700 : 500}
    >
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item grow minHeight={16}>
            <Stack fill>
              <Stack.Item basis={'50%'}>
                <ChemMasterBeaker />
              </Stack.Item>
              <Stack.Item basis={'50%'}>
                <ChemMasterInternal />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Stack
              height={
                data.productionOptions !== 'CONDIMENTS' ? '330px' : '170px'
              }
            >
              <Stack.Item basis={'50%'}>
                <ChemMasterSprites />
              </Stack.Item>
              <Stack.Item basis={'50%'}>
                <ChemMasterActions />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ChemMasterBeaker = (props, context) => {
  const { act, data } = useBackend<ChemMasterData>(context);
  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section fill scrollable title="Ёмкость" textAlign="center">
          {data.container ? (
            <Stack fill vertical zebra textAlign="left">
              {data.containerChemicals.length > 0 ? (
                data.containerChemicals.map((reagent) => {
                  return (
                    <Stack.Item key={reagent.name} color="label">
                      <Stack fill>
                        <Stack.Item grow minWidth={0}>
                          {reagent.volume} units of {reagent.name}
                        </Stack.Item>
                        <Stack.Item>
                          <NumberInput
                            animated
                            value={0}
                            minValue={0}
                            maxValue={reagent.volume}
                            step={0.1}
                            stepPixelSize={2}
                            onChange={(e, value) =>
                              act('add', {
                                reagent: reagent.ref,
                                amount: value,
                              })
                            }
                          />
                        </Stack.Item>
                        <AnalyzeButton reagent={reagent} />
                      </Stack>
                    </Stack.Item>
                  );
                })
              ) : (
                <Stack.Item color="red" fontSize={2} bold textAlign="center">
                  Ёмкость пуста
                </Stack.Item>
              )}
            </Stack>
          ) : (
            <Empty icon="flask" color="blue" content="Ёмкость отсутствует" />
          )}
        </Section>
      </Stack.Item>
      {!!data.container && (
        <Stack.Item mt={0}>
          <Section textAlign="center">
            <Button
              fluid
              color={data.bufferChemicals.length > 0 ? 'orange' : ''}
              icon={'eject'}
              content={
                data.bufferChemicals.length > 0
                  ? 'Вынуть ёмкость и очистить буфер'
                  : 'Вынуть ёмкость'
              }
              onClick={() => act('eject')}
            />
          </Section>
        </Stack.Item>
      )}
    </Stack>
  );
};

const ChemMasterInternal = (props, context) => {
  const { act, data } = useBackend<ChemMasterData>(context);
  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section fill scrollable title="Буфер" textAlign="center">
          {data.bufferChemicals.length > 0 ? (
            <Stack fill vertical zebra textAlign="left">
              {data.bufferChemicals.map((reagent) => (
                <Stack.Item key={reagent.name} color="label">
                  <Stack fill>
                    <Stack.Item grow minWidth={0}>
                      {reagent.volume} units of {reagent.name}
                    </Stack.Item>
                    <Stack.Item>
                      <NumberInput
                        animated
                        value={0}
                        minValue={0}
                        maxValue={reagent.volume}
                        step={0.1}
                        stepPixelSize={2}
                        onChange={(e, value) =>
                          act('remove', {
                            reagent: reagent.ref,
                            amount: value,
                          })
                        }
                      />
                    </Stack.Item>
                    <AnalyzeButton reagent={reagent} />
                  </Stack>
                </Stack.Item>
              ))}
            </Stack>
          ) : (
            <Empty icon={'droplet'} content="Буфер пуст" />
          )}
        </Section>
      </Stack.Item>
      {data.bufferChemicals.length > 0 && (
        <Stack.Item mt={0}>
          <Section textAlign="center">
            <Button
              fluid
              color={data.toBeaker ? 'good' : 'bad'}
              icon={data.toBeaker ? 'flask' : 'trash'}
              content={data.toBeaker ? 'Переливать в емкость' : 'Уничтожать'}
              onClick={() => act('toggle')}
            />
          </Section>
        </Stack.Item>
      )}
    </Stack>
  );
};

const ChemMasterSprites = (props, context) => {
  const { act, data } = useBackend<ChemMasterData>(context);
  return (
    <Stack fill vertical textAlign="center">
      {data.productionOptions !== 'CONDIMENTS' && (
        <Stack.Item grow>
          <Section fill scrollable title="Стиль таблеток">
            {data.pillSprites.map(({ id, sprite }) => (
              <ImageButton
                key={id}
                m={0.5}
                asset
                vertical
                selected={data.pillSprite === String(id)}
                imageAsset={'chem_master32x32'}
                image={sprite}
                onClick={() => act('changePillStyle', { style: id })}
              />
            ))}
          </Section>
        </Stack.Item>
      )}
      <Stack.Item
        height={data.productionOptions !== 'CONDIMENTS' ? '85px' : '100%'}
      >
        <Section fill scrollable title="Стиль бутылок">
          {data.bottleSprites.map(({ id, sprite }) => (
            <ImageButton
              key={id}
              m={0.5}
              asset
              vertical
              selected={data.bottleSprite === id}
              imageAsset={'chem_master32x32'}
              image={sprite}
              onClick={() => act('changeBottleStyle', { style: id })}
            />
          ))}
        </Section>
      </Stack.Item>
      {!!data.pillBottle && data.productionOptions === 'CONDIMENTS' && (
        <Stack.Item textAlign="center">
          <Section fill title="Таблетница">
            <Stack fill>
              <Stack.Item grow>
                <ProgressBar
                  minValue={0}
                  maxValue={data.pillBottleMaxContent}
                  value={data.pillBottleContent}
                >
                  {data.pillBottleContent} / {data.pillBottleMaxContent}
                </ProgressBar>
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="eject"
                  tooltip={'Вынуть таблетницу'}
                  onClick={() => act('ejectPillBottle')}
                />
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      )}
    </Stack>
  );
};

const ChemMasterActions = (props, context) => {
  const { act, data } = useBackend<ChemMasterData>(context);
  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section fill title="Изготовление" textAlign="center">
          <LabeledList>
            <LabeledList.Item label={'Дозировка бутылки'}>
              <Slider
                value={data.bottleDosage}
                minValue={1}
                maxValue={data.bottleDosageMax}
                onChange={(e, value) =>
                  act('bottleDosage', { newDosage: value })
                }
              />
            </LabeledList.Item>
            {data.productionOptions !== 'CONDIMENTS' && (
              <>
                <LabeledList.Item label={'Дозировка таблетки'}>
                  <Slider
                    value={data.pillDosage}
                    minValue={0.1}
                    maxValue={data.pillDosageMax}
                    onChange={(e, value) =>
                      act('pillDosage', { newDosage: value })
                    }
                  />
                </LabeledList.Item>
                <LabeledList.Item label={'Количество таблеток'}>
                  <Slider
                    value={data.pillCount}
                    minValue={1}
                    maxValue={data.pillCountMax}
                    onChange={(e, value) =>
                      act('pillCount', { pillCount: value })
                    }
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Blister dosage">
                  <Slider
                    value={data.blisterDosage}
                    minValue={0.1}
                    maxValue={data.blisterDosageMax}
                    onChange={(e, value) =>
                      act('blisterDosage', { newDosage: value })
                    }
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Blister slots">
                  {[2, 4, 6].map((slots) => (
                    <Button
                      key={slots}
                      selected={data.blisterType === slots}
                      onClick={() => act('blisterType', { slots })}
                    >
                      {slots}
                    </Button>
                  ))}
                </LabeledList.Item>
              </>
            )}
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item mt={0}>
        <Section textAlign={'center'}>
          <Stack>
            {data.productionOptions !== 'CONDIMENTS' && (
              <Stack.Item grow>
                <Button
                  fluid
                  disabled={data.bufferChemicals.length === 0}
                  content={
                    data.pillCount > 1 ? 'Сделать таблетки' : 'Сделать таблетку'
                  }
                  onClick={() => act('createPill')}
                />
              </Stack.Item>
            )}
            <Stack.Item grow>
              <Button
                fluid
                disabled={data.bufferChemicals.length === 0}
                content={'Сделать бутылку'}
                onClick={() => act('createBottle')}
              />
            </Stack.Item>
          </Stack>
          {data.productionOptions !== 'CONDIMENTS' && (
            <Button
              fluid
              mt={1}
              content="Make blister"
              disabled={data.bufferChemicals.length === 0}
              onClick={() => act('createBlister')}
            />
          )}
          <Stack.Item grow mt={1}>
            <Button
              fluid
              content={
                'Режим очистки: ' + (data.isSloppy ? 'Быстрый' : 'Тщательный')
              }
              onClick={() => act('toggleSloppy')}
            />
          </Stack.Item>
        </Section>
      </Stack.Item>
      {!!data.pillBottle && data.productionOptions !== 'CONDIMENTS' && (
        <Stack.Item textAlign="center">
          <Section fill title="Таблетница">
            <Button
              content="Dissolve pill"
              onClick={() => act('dissolve_pill')}
            />
            <Button
              content="Fill buffer"
              onClick={() => act('dissolve_until_full')}
            />
            <Stack fill>
              <Stack.Item grow>
                <ProgressBar
                  minValue={0}
                  maxValue={data.pillBottleMaxContent}
                  value={data.pillBottleContent}
                >
                  {data.pillBottleContent} / {data.pillBottleMaxContent}
                </ProgressBar>
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="eject"
                  tooltip={'Вынуть таблетницу'}
                  onClick={() => act('ejectPillBottle')}
                />
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      )}
    </Stack>
  );
};

const Empty = ({ icon, color = '', content = '' }) => {
  return (
    <Stack fill bold textAlign="center">
      <Stack.Item grow fontSize={1.25} align="center" color="label">
        <Icon.Stack>
          <Icon size={5} name={icon} color={color} />
          <Icon size={5} name="slash" color="red" />
        </Icon.Stack>
        <br />
        {content}
      </Stack.Item>
    </Stack>
  );
};

const AnalyzeButton = ({ reagent }, context) => {
  const { act, data } = useBackend<ChemMasterData>(context);
  const analyzed = data.analyzedReagent === reagent.name;
  return (
    <Stack.Item ml={0.25}>
      <Button
        selected={analyzed}
        icon={analyzed ? 'magnifying-glass-chart' : 'magnifying-glass'}
        tooltip={
          analyzed ? (
            <>
              <h4>Анализ - {reagent.name}</h4>
              <br />
              {data.analyzedDesc}
              {!!data.isAnalyzedBlood && (
                <>
                  <br />
                  <br />
                  {data.analyzedBloodSpecies}
                  <br />
                  {data.analyzedBloodType}
                  <br />
                  {data.analyzedBloodDNA}
                </>
              )}
            </>
          ) : (
            'Анализировать'
          )
        }
        onClick={() => act('analyze', { name: reagent.ref })}
      />
    </Stack.Item>
  );
};
