import { Component } from 'inferno';
import { useBackend } from '../backend';
import { globalEvents } from '../events';
import { Window } from '../layouts';

type NanoData = {
  html: string;
  nanoData: unknown;
  // Window dimensions are consumed by NanoUI rather than the embedded frame.
  // eslint-disable-next-line react/no-unused-prop-types
  width: number;
  // eslint-disable-next-line react/no-unused-prop-types
  height: number;
};

type NanoWindow = {
  NanoStateManager?: unknown;
  jQuery?: unknown;
  receiveUpdateData?: (json: string) => void;
};

// TGUI supplies the title bar for embedded NanoUI documents.
const NANO_FRAME_STYLES = `<style type="text/css">
  #uiTitleWrapper { display: none !important; }
  #uiWrapper { padding-top: 0 !important; }
</style>`;

// A separate document preserves NanoUI's CSS, jQuery and template globals.
// document.write also works in BYOND's IE browser, which lacks iframe srcdoc.
export class NanoFrame extends Component<NanoData, { dragging: boolean }> {
  constructor(props: NanoData) {
    super(props);
    this.state = { dragging: false };
  }

  private frame: HTMLIFrameElement | null = null;
  private loadedHtml: string | undefined;
  private pendingData: unknown;
  private timer: ReturnType<typeof setInterval> | undefined;

  componentDidMount() {
    globalEvents.on('window-dragging', this.handleWindowDragging);
    this.syncDocument();
    this.timer = setInterval(() => this.flushData(), 50);
  }

  componentDidUpdate() {
    this.syncDocument();
  }

  componentWillUnmount() {
    globalEvents.off('window-dragging', this.handleWindowDragging);
    clearInterval(this.timer);
    this.frame = null;
    this.pendingData = undefined;
  }

  private handleWindowDragging = (dragging: boolean) => {
    this.setState({ dragging });
  };

  private syncDocument() {
    const document = this.frame?.contentDocument;
    if (!document) return;
    if (this.loadedHtml !== this.props.html) {
      this.loadedHtml = this.props.html;
      document.open();
      document.write(
        (this.props.html || '').replace(
          /<\/head>/i,
          `${NANO_FRAME_STYLES}</head>`
        )
      );
      document.close();
    }
    this.pendingData = this.props.nanoData;
    this.flushData();
  }

  private flushData() {
    const target = this.frame?.contentWindow as NanoWindow | null;
    if (
      this.pendingData === undefined ||
      !target?.NanoStateManager ||
      !target.jQuery ||
      !target.receiveUpdateData
    ) {
      return;
    }
    target.receiveUpdateData(JSON.stringify(this.pendingData));
    this.pendingData = undefined;
  }

  render() {
    return (
      <div style={{ position: 'relative', width: '100%', height: '100%' }}>
        <iframe
          title="NanoUI"
          ref={(frame) => (this.frame = frame)}
          style={{
            width: '100%',
            height: '100%',
            border: '0',
            display: 'block',
          }}
        />
        {/* Keep mouse events in the outer document during window drag/resize. */}
        {this.state.dragging && (
          <div
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '100%',
              height: '100%',
              backgroundColor: 'transparent',
              zIndex: 1,
            }}
          />
        )}
      </div>
    );
  }
}

export const NanoUI = (props, context) => {
  const { data } = useBackend<NanoData>(context);
  return (
    <Window width={data.width || 600} height={data.height || 500}>
      <Window.Content fitted>
        <NanoFrame {...data} />
      </Window.Content>
    </Window>
  );
};
