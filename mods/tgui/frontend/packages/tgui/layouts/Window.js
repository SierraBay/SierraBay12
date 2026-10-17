/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { useDispatch } from 'common/redux';
import { decodeHtmlEntities, toTitleCase } from 'common/string';
import { Component } from 'inferno';
import { backendSuspendStart, useBackend } from '../backend';
import { Icon } from '../components';
import { UI_DISABLED, UI_INTERACTIVE, UI_UPDATE } from '../constants';
import { useDebug } from '../debug';
import { toggleKitchenSink } from '../debug/actions';
import {
  dragStartHandler,
  recallWindowGeometry,
  resizeStartHandler,
  setWindowKey,
} from '../drag';
import { createLogger } from '../logging';
import { Layout } from './Layout';

const logger = createLogger('Window');

const DEFAULT_SIZE = [400, 600];

export class Window extends Component {
  componentDidMount() {
    this.mounted = true;
    this.geometryRevision = 0;
    const { suspended } = useBackend(this.context);
    this.wasSuspended = !!suspended;
    if (!suspended) {
      logger.log('mounting');
      this.updateGeometry(true);
    }
  }

  componentDidUpdate(prevProps) {
    const { config, suspended, suspending } = useBackend(this.context);
    const resumed = this.wasSuspended && !suspended;
    this.wasSuspended = !!suspended;
    if (suspended || suspending) {
      this.geometryRevision++;
      return;
    }
    if (
      resumed ||
      config.window?.key !== this.geometryKey ||
      config.window?.scale !== this.geometryScale ||
      this.props.width !== prevProps.width ||
      this.props.height !== prevProps.height
    ) {
      this.updateGeometry(resumed);
    }
  }

  componentWillUnmount() {
    this.mounted = false;
    this.geometryRevision++;
  }

  async updateGeometry(hideBeforeRestore = false) {
    const { config, suspended, suspending } = useBackend(this.context);
    if (suspended || suspending) {
      return;
    }
    this.geometryKey = config.window?.key;
    this.geometryScale = config.window?.scale;
    const revision = ++this.geometryRevision;
    const isCurrent = () => {
      const backend = useBackend(this.context);
      return (
        this.mounted &&
        revision === this.geometryRevision &&
        !backend.suspended &&
        !backend.suspending &&
        backend.config.window?.key === config.window?.key
      );
    };
    if (hideBeforeRestore) {
      Byond.winset(Byond.windowId, { 'is-visible': false });
    }
    const options = {
      size: DEFAULT_SIZE,
      ...config.window,
    };
    if (this.props.width && this.props.height) {
      options.size = [this.props.width, this.props.height];
    }
    if (config.window?.key) {
      setWindowKey(config.window.key);
    }
    await recallWindowGeometry(options, isCurrent);
    // Apply geometry while hidden, then show on the following browser tick.
    setImmediate(() => {
      if (isCurrent()) {
        Byond.winset(Byond.windowId, { 'is-visible': true });
      }
    });
  }

  render() {
    const { theme, title, children } = this.props;
    const { config, suspended } = useBackend(this.context);
    const { debugLayout } = useDebug(this.context);
    const dispatch = useDispatch(this.context);
    const fancy = config.window?.fancy;
    // Determine when to show dimmer
    const showDimmer =
      config.user &&
      (config.user.observer
        ? config.status < UI_DISABLED
        : config.status < UI_INTERACTIVE);
    return (
      <Layout className="Window" theme={theme}>
        <TitleBar
          className="Window__titleBar"
          title={!suspended && (title || decodeHtmlEntities(config.title))}
          status={config.status}
          fancy={fancy}
          onDragStart={dragStartHandler}
          onClose={() => {
            logger.log('pressed close');
            dispatch(backendSuspendStart());
          }}
        />
        <div
          className={classes(['Window__rest', debugLayout && 'debug-layout'])}
        >
          {!suspended && children}
          {showDimmer && <div className="Window__dimmer" />}
        </div>
        {fancy && (
          <>
            <div
              className="Window__resizeHandle__e"
              onMousedown={resizeStartHandler(1, 0)}
            />
            <div
              className="Window__resizeHandle__s"
              onMousedown={resizeStartHandler(0, 1)}
            />
            <div
              className="Window__resizeHandle__se"
              onMousedown={resizeStartHandler(1, 1)}
            />
          </>
        )}
      </Layout>
    );
  }
}

const WindowContent = (props) => {
  const { className, fitted, children, ...rest } = props;
  return (
    <Layout.Content
      className={classes(['Window__content', className])}
      {...rest}
    >
      {(fitted && children) || (
        <div className="Window__contentPadding">{children}</div>
      )}
    </Layout.Content>
  );
};

Window.Content = WindowContent;

const statusToColor = (status) => {
  switch (status) {
    case UI_INTERACTIVE:
      return 'good';
    case UI_UPDATE:
      return 'average';
    case UI_DISABLED:
    default:
      return 'bad';
  }
};

const TitleBar = (props, context) => {
  const { className, title, status, fancy, onDragStart, onClose } = props;
  const dispatch = useDispatch(context);
  return (
    <div className={classes(['TitleBar', className])}>
      {(status === undefined && (
        <Icon className="TitleBar__statusIcon" name="tools" opacity={0.5} />
      )) || (
        <Icon
          className="TitleBar__statusIcon"
          color={statusToColor(status)}
          name="eye"
        />
      )}
      <div className="TitleBar__title">
        {(typeof title === 'string' &&
          title === title.toLowerCase() &&
          toTitleCase(title)) ||
          title}
      </div>
      <div
        className="TitleBar__dragZone"
        onMousedown={(e) => fancy && onDragStart(e)}
      />
      {process.env.NODE_ENV !== 'production' && (
        <div
          className="TitleBar__devBuildIndicator"
          onClick={() => dispatch(toggleKitchenSink())}
        >
          <Icon name="bug" />
        </div>
      )}
      {!!fancy && (
        <div
          className="TitleBar__close TitleBar__clickable"
          // IE8: Synthetic onClick event doesn't work on IE8.
          // IE8: Use a plain character instead of a unicode symbol.
          // eslint-disable-next-line react/no-unknown-property
          onclick={onClose}
        >
          {Byond.IS_LTE_IE8 ? 'x' : '×'}
        </div>
      )}
    </div>
  );
};
