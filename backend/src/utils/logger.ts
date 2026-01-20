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
const isProduction = process.env.NODE_ENV === 'production';

const shouldLog = (level: LogLevel): boolean => {
  return logLevelPriority[level] >= logLevelPriority[currentLogLevel];
};

/**
 * Format log message for console output (development)
 */
const formatConsoleMessage = (level: LogLevel, message: string, meta?: unknown): string => {
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

/**
 * Format log message as JSON (production - structured logging)
 */
const formatJsonMessage = (level: LogLevel, message: string, meta?: unknown): string => {
  const logEntry = {
    timestamp: new Date().toISOString(),
    level: level.toUpperCase(),
    message,
    ...(meta !== undefined && {
      meta: meta instanceof Error
        ? { name: meta.name, message: meta.message, stack: meta.stack }
        : meta,
    }),
    service: 'bagour-delivery-api',
    environment: process.env.NODE_ENV || 'development',
  };

  return JSON.stringify(logEntry);
};

/**
 * Format message based on environment
 */
const formatMessage = (level: LogLevel, message: string, meta?: unknown): string => {
  return isProduction
    ? formatJsonMessage(level, message, meta)
    : formatConsoleMessage(level, message, meta);
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

  /**
   * Log HTTP request (useful for custom logging middleware)
   */
  http: (req: { method: string; url: string; ip?: string }, res: { statusCode: number }, duration: number): void => {
    if (shouldLog('info')) {
      const logData = {
        method: req.method,
        url: req.url,
        status: res.statusCode,
        duration: `${duration}ms`,
        ip: req.ip,
      };
      console.log(formatMessage('info', 'HTTP Request', logData));
    }
  },
};

export default logger;
