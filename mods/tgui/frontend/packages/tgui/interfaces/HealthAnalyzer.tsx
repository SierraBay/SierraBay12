import { useBackend } from '../backend';
import { Box, Button, Section, Stack } from '../components';
import { Window } from '../layouts';
import { sanitizeText } from '../sanitize';

type HealthAnalyzerData = {
  scan_title?: string;
  has_scan: boolean;
  scan_results: string[];
  reagent_results: string[];
};

// Scan lines are server generated html (spans with scan_* classes / colors).
const ALLOWED_TAGS = ['b', 'i', 'u', 'span', 'font', 'br'];

const ScanLines = (props: { lines: string[]; empty: string }) => {
  const { lines, empty } = props;
  if (!lines?.length) {
    return <Box color="label">{empty}</Box>;
  }
  return (
    <Stack vertical>
      {lines.map((line, i) => (
        <Stack.Item key={i}>
          <Box
            className="HealthAnalyzer__line"
            dangerouslySetInnerHTML={{
              __html: sanitizeText(line, ALLOWED_TAGS, []),
            }}
          />
        </Stack.Item>
      ))}
    </Stack>
  );
};

export const HealthAnalyzer = (props, context) => {
  const { act, data } = useBackend<HealthAnalyzerData>(context);
  const { scan_title, has_scan, scan_results, reagent_results } = data;

  return (
    <Window width={520} height={620}>
      <Window.Content scrollable>
        <Section
          title={scan_title || 'Health Analyzer'}
          buttons={
            <>
              <Button
                icon="print"
                disabled={!has_scan}
                onClick={() => act('print')}
              >
                Print
              </Button>
              <Button
                icon="trash"
                disabled={!has_scan}
                onClick={() => act('clear')}
              >
                Clear scan
              </Button>
            </>
          }
        >
          <ScanLines lines={scan_results} empty="No scan data." />
        </Section>
        {!!has_scan && (
          <Section title="Reagent Scan">
            <ScanLines lines={reagent_results} empty="No results." />
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
