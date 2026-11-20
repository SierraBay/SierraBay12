import { useBackend } from '../backend';
import {
  Button,
  BlockQuote,
  Section,
  StyleableSection,
  Stack,
} from '../components';
import { Window } from '../layouts';

type CreditsData = {
  credits: Credit[];
};

type Credit = {
  name: string;
  coders: string[];
  mappers: string[];
  spriters: string[];
  ui_designers: string[];
  special: string[];
  linkContributors: string;
};

export const Credits = (props, context) => {
  const { act, data } = useBackend<CreditsData>(context);

  const renderContributors = (title: string, contributors: string[]) => (
    <StyleableSection
      title={title}
      titleStyle={{ 'border-bottom-color': '#1c71b1' }}
      style={{
        'text-align': 'center',
        'font-size': '1.15em',
        'background-color': '#191919',
        'border-radius': '0.5em',
        'border': '0.1em solid #333333',
        'margin-top': '0.5em',
      }}
    >
      {contributors.map((contributor, index) => (
        <Stack key={index} inline>
          {contributor}
          {index !== contributors.length - 1 && <>,&nbsp;</>}
        </Stack>
      ))}
    </StyleableSection>
  );

  return (
    <Window width={500} height={700} theme="nologo">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section>
              <Stack fill vertical textAlign="center">
                <Stack.Item fontSize={2.5} bold>
                  Sierra SS13
                </Stack.Item>
                <Stack.Item>
                  <Stack>
                    {['GitHub', 'Wiki', 'Discord'].map((content, index) => (
                      <Stack.Item grow key={index}>
                        <Button
                          fluid
                          bold
                          color="blue"
                          content={content}
                          onClick={() => act(`open${content}`)}
                        />
                      </Stack.Item>
                    ))}
                  </Stack>
                </Stack.Item>
                <Stack.Item mt={2}>
                  <BlockQuote color="gray">
                    Разработка - сложная и часто наблагодарная работа,
                    заставляющая человека испытывать стресс от различных
                    факторов: от непринятия его работы сообществом до споров о
                    том, как ему делать свою работу. Однако, без этих людей ни
                    один проект не может нормально существовать. Здесь мы
                    выражаем нашу благодарность каждому разработчику, что
                    помогал проекту стать лучше в плане написания кода,
                    проектирования карт или рисования спрайтов.
                  </BlockQuote>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Divider />
          <Stack.Item grow>
            <Section fill scrollable>
              {data &&
                data.credits &&
                data.credits.map((credit, index) => (
                  <StyleableSection
                    key={index}
                    title={
                      <Stack>
                        <Stack.Item grow fontSize={1.5}>
                          {credit.name}
                        </Stack.Item>
                        {credit.linkContributors && (
                          <Stack.Item>
                            <Button
                              fluid
                              color={'blue'}
                              content={'Контрибьюторы'}
                              onClick={() =>
                                act('openContributors', {
                                  buildPage: credit.linkContributors,
                                  buildName: credit.name,
                                })
                              }
                            />
                          </Stack.Item>
                        )}
                      </Stack>
                    }
                    titleStyle={{
                      'border-bottom-color': '#1c71b1',
                    }}
                    style={{
                      'background-color': '#222222',
                      'margin-bottom': '1em',
                      'border-radius': '0.5em',
                      'border': '0.1em solid #333333',
                    }}
                  >
                    {credit.coders &&
                      renderContributors('Кодеры', credit.coders)}
                    {credit.mappers &&
                      renderContributors('Мапперы', credit.mappers)}
                    {credit.spriters &&
                      renderContributors('Спрайтеры', credit.spriters)}
                    {credit.ui_designers &&
                      renderContributors(
                        'UI/UX Дизайнеры',
                        credit.ui_designers
                      )}
                    {credit.special && (
                      <Stack.Item>
                        {renderContributors(
                          'Отдельная благодарность',
                          credit.special
                        )}
                      </Stack.Item>
                    )}
                  </StyleableSection>
                ))}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
