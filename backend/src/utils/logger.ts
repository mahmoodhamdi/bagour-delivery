import dayjs from 'dayjs';

type LogLevel = 'debug' | 'info' | 'warn' | 'error';

const colors = {
  reset: '\x1b[0m',
  debug: '\x1b[36m', // Cyan
  info: '\x1b[32m', // Green
  warn: '\x1b[33m', // Yellow
  error: '\x1b[31m', // Red
};

const logLevelPriority: Record<LogLevel, number> = {
  debug: 0,
  info: 1,
  warn: 2,
  error: 3,
};

const currentLogLevel: LogLevel = (process.env.LOG_LEVEL as LogLevel) || 'debug';

const shouldLog = (level: LogLevel): boolean => {
  return logLevelPriority[level] >= logLevelPriority[currentLogLevel];
};

const formatMessage = (level: LogLevel, message: string, meta?: unknown): string => {
  const timestamp = dayjs().format('YYYY-MM-DD HH:mm:ss');
  const color = colors[level];
  const reset = colors.reset;
  const levelStr = level.toUpperCase().padEnd(5);

  let formattedMessage = `${color}[${timestamp}] [${levelStr}]${reset} ${message}`;

  if (meta !== undefined) {
    formattedMessage += ` ${JSON.stringify(meta)}`;
  }

  return formattedMessage;
};

export const logger = {
  debug: (message: string, meta?: unknown): void => {
    if (shouldLog('debug')) {
      console.log(formatMessage('debug', message, meta));
    }
  },

  info: (message: string, meta?: unknown): void => {
    if (shouldLog('info')) {
      console.log(formatMessage('info', message, meta));
    }
  },

  warn: (message: string, meta?: unknown): void => {
    if (shouldLog('warn')) {
      console.warn(formatMessage('warn', message, meta));
    }
  },

  error: (message: string, meta?: unknown): void => {
    if (shouldLog('error')) {
      console.error(formatMessage('error', message, meta));
    }
  },
};

export default logger;
