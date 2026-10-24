import { BooleanLike } from 'common/react';
import { capitalize, capitalizeAll } from 'common/string';
import { useBackend, useLocalState, useSharedState } from '../backend';
import {
  Box,
  Button,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
  Input,
  Icon,
  Tabs,
  ImageButton,
  ProgressBar,
} from '../components';
import { Window } from '../layouts';

export type FabricatorData = {
  have_disk: BooleanLike;
  have_disk2: BooleanLike;
  have_reagents: BooleanLike;
  have_materials: BooleanLike;
  queue_max: number;
  reagents?: { name: string; amount: number }[];
  disk?: { name: string };
  disk2?: { name: string };
  container?: string;
  paused: BooleanLike;
  error?: string;
  material_efficiency: number;
  categories: string[];
  material_storage: Material[];
  current_build: Build;
  build_queue: Queue[];
  recipes: Recipe[];
};

type Material = {
  refundable: BooleanLike;
  name: string;
  stored: number;
  max: number;
  image: string;
  units_per_sheet: number;
};

type Build = {
  name: string;
  multiplier: number;
  progress: number;
};

type Queue = {
  name: string;
  multiplier: number;
  reference: string;
};

type Recipe = {
  can_build: BooleanLike;
  name: string;
  hidden: BooleanLike;
  category: string | string[];
  reference: string;
  image: string;
  cost: Cost[];
};

type Cost = {
  name: string;
  amount: number;
  units_per_sheet: number;
};

export const Fabricator = (props, context) => {
  const { act, data } = useBackend<FabricatorData>(context);
  return (
    <Window width={780} height={650}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section title="Controls">
              {!!data.have_disk && (
                <Button
                  onClick={() => act('disk')}
                  content={
                    data.disk ? `Eject ${data.disk.name}` : 'Insert disk'
                  }
                />
              )}
              {!!data.have_disk2 && (
                <Button
                  onClick={() => act('disk2')}
                  content={
                    data.disk2
                      ? `Eject ${data.disk2.name}`
                      : 'Insert second disk'
                  }
                />
              )}
              {!!data.have_reagents && (
                <Button content="Beaker" onClick={() => act('container')} />
              )}
              {!!data.have_materials && (
                <Button
                  content="Insert materials"
                  onClick={() => act('insert')}
                />
              )}
              <Button
                content={data.paused ? 'Resume' : 'Pause'}
                onClick={() => act('pause')}
              />
              <Button content="Abort" onClick={() => act('abort_print')} />
              {!!data.error && <NoticeBox danger>{data.error}</NoticeBox>}
              {data.reagents?.map((reagent) => (
                <Box inline mr={1} key={reagent.name}>
                  {reagent.name}: {reagent.amount}u
                </Box>
              ))}
            </Section>
          </Stack.Item>
          <Stack.Item grow minHeight={0}>
            <Stack fill>
              <Stack.Item basis="25%" minWidth={0}>
                <Stack fill vertical>
                  <Stack.Item grow>
                    <FabCategories />
                  </Stack.Item>
                  <Stack.Item m={0}>
                    <FabFilters />
                  </Stack.Item>
                  <Stack.Item textAlign="center">
                    <NoticeBox color="blue">
                      Результаты поиска зависят от выбранной категории
                    </NoticeBox>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item basis="50%" minWidth={0}>
                <FabDesigns />
              </Stack.Item>
              <Stack.Item basis="25%" minWidth={0}>
                <Stack fill vertical>
                  <Stack.Item grow basis={0} minHeight={0}>
                    <FabResources />
                  </Stack.Item>
                  <Stack.Item grow basis={0} minHeight={0}>
                    <FabQueue />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const FabCategories = (props, context) => {
  const { act, data } = useBackend<FabricatorData>(context);
  const [tab, setTab] = useSharedState(context, 'tab', 'All');
  return (
    <Section fill scrollable title="Категории">
      <Tabs vertical textAlign="center">
        <Tabs.Tab
          height={3}
          selected={'All' === tab}
          onClick={() => setTab('All')}
        >
          All
        </Tabs.Tab>
        {data.categories.map((category) => (
          <Tabs.Tab
            mt={1}
            height={3}
            color="blue"
            selected={category === tab}
            key={category}
            onClick={() => setTab(category)}
          >
            {category}
          </Tabs.Tab>
        ))}
      </Tabs>
    </Section>
  );
};

const FabFilters = (props, context) => {
  const { act, data } = useBackend<FabricatorData>(context);
  const [tab, setTab] = useSharedState(context, 'tab', 'All');
  const [hideUnavailable, setHideUnavailable] = useSharedState(
    context,
    'hideUnavailable',
    false
  );
  const [compactMode, setCompactMode] = useSharedState(
    context,
    'compactMode',
    false
  );
  return (
    <Section>
      <Button.Checkbox
        fluid
        checked={compactMode}
        content={'Компактный режим'}
        onClick={() => setCompactMode(!compactMode)}
      />
      <Button.Checkbox
        fluid
        checked={hideUnavailable}
        content={'Скрыть недоступное'}
        onClick={() => setHideUnavailable(!hideUnavailable)}
      />
    </Section>
  );
};

const FabDesigns = (props, context) => {
  const { act, data } = useBackend<FabricatorData>(context);
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [tab] = useSharedState(context, 'tab', 'All');
  const [hideUnavailable] = useSharedState(context, 'hideUnavailable', false);
  const [compactMode] = useSharedState(context, 'compactMode', false);
  const [multiplier, setMultiplier] = useLocalState(context, 'multiplier', 1);

  const filteredRecipes = data.recipes
    .filter(
      (recipe) =>
        (tab === 'All' ||
          (Array.isArray(recipe.category)
            ? recipe.category.includes(tab)
            : recipe.category === tab)) &&
        recipe.name.toLowerCase().includes(searchText.toLowerCase())
    )
    .sort((a, b) => a.name.localeCompare(b.name));

  const getRequiredResources = (recipe) => {
    const requiredResources = recipe.cost.map(
      (cost) => `${capitalize(cost.name)} x${cost.amount}`
    );
    return requiredResources.join(' | ');
  };

  const checkResourcesAvailability = (recipe) => {
    if (!recipe.can_build) {
      return false;
    }
    for (const cost of recipe.cost) {
      const material = data.material_storage.find(
        (mat) => mat.name === cost.name
      );
      if (!material || material.stored < cost.amount) {
        return false;
      }
    }
    return true;
  };

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Box inline mr={1}>
          Print quantity
        </Box>
        <NumberInput
          value={multiplier}
          minValue={1}
          maxValue={data.queue_max || 24}
          step={1}
          width="50px"
          onChange={(e, value) => setMultiplier(value)}
        />
        <Input
          mt={0.75}
          width="100%"
          placeholder="Поиск рецептов..."
          value={searchText}
          onInput={(e, value) => setSearchText(value)}
        />
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title={`Рецепты - ${tab}`} textAlign="center">
          {filteredRecipes.map((recipe) =>
            hideUnavailable && !checkResourcesAvailability(recipe) ? null : (
              <ImageButton
                bold={compactMode ? true : false}
                image={recipe.image}
                imageSize={compactMode ? '32px' : '64px'}
                key={recipe.reference}
                title={compactMode ? '' : capitalizeAll(recipe.name)}
                content={
                  compactMode
                    ? capitalizeAll(recipe.name)
                    : getRequiredResources(recipe)
                }
                tooltip={compactMode ? getRequiredResources(recipe) : ''}
                color={recipe.hidden && 'brown'}
                disabled={!checkResourcesAvailability(recipe)}
                onClick={() =>
                  act('make', { make: recipe.reference, multiplier })
                }
              />
            )
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const FabResources = (props, context) => {
  const { act, data } = useBackend<FabricatorData>(context);
  const { material_storage } = data;
  return (
    <Section fill scrollable title="Ресурсы">
      {material_storage.map((material) => (
        <ImageButton
          image={material.image}
          imageSize={'58px'}
          mb={0}
          height="57px"
          key={material.name}
          title={capitalizeAll(material.name)}
          selected={material.stored === material.max}
          content={
            <ProgressBar
              color="grey"
              value={material.stored}
              minValue={0}
              maxValue={material.max}
            >
              {material.stored}
            </ProgressBar>
          }
          disabled={!material.refundable || !material.stored}
          onClick={() => act('eject_mat', { eject_mat: material.name })}
        />
      ))}
    </Section>
  );
};

const FabQueue = (props, context) => {
  const { act, data } = useBackend<FabricatorData>(context);
  const { current_build } = data;
  return (
    <Section fill scrollable title="Очередь">
      {current_build || data.build_queue.length > 0 ? (
        <Stack vertical>
          <Stack.Item>
            {current_build && (
              <ProgressBar
                value={current_build.progress}
                minValue={0}
                maxValue={100}
              >
                <Box textAlign="center">
                  {capitalizeAll(current_build.name)}
                </Box>
              </ProgressBar>
            )}
          </Stack.Item>
          <Stack.Divider />
          {data.build_queue.map((item, index) => (
            <Stack.Item key={index}>
              <Stack>
                <Stack.Item grow>
                  <Box textAlign="center">{capitalizeAll(item.name)}</Box>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="arrow-up"
                    disabled={index === 0}
                    onClick={() => act('move_up_queue', { index: index + 1 })}
                  />
                  <Button
                    icon="arrow-down"
                    disabled={index === data.build_queue.length - 1}
                    onClick={() => act('move_down_queue', { index: index + 1 })}
                  />
                  <Button
                    icon="times"
                    color="red"
                    onClick={() => act('cancel', { cancel: item.reference })}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          ))}
        </Stack>
      ) : (
        <Stack fill bold textAlign="center">
          <Stack.Item grow fontSize={1.25} align="center" color="label">
            <Icon.Stack mb={-5}>
              <Icon size={4} name="bars" color="gray" />
              <Icon size={4} name="slash" color="red" />
            </Icon.Stack>
            <br />
            Очередь пуста
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
};
