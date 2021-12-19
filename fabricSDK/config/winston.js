const appRoot = require('app-root-path');
const winston = require('winston');
const DailyRotateFile = require('winston-daily-rotate-file');
const { combine, timestamp, colorize, align, printf } = winston.format;

const options = {
    file: {
        level: 'debug',
        filename: `${appRoot}/../../logs/app.log`,
        handleExceptions: true,
        format: combine(
            colorize(),
            timestamp(),
            align(),
            printf((info) => {
                const {
                  timestamp, level, message, ...args
                } = info;

                const ts = timestamp.slice(0, 19).replace('T', ' ');
                return `${ts} [${level}]: ${message} ${Object.keys(args).length ? JSON.stringify(args, null, 2) : ''}`;
              })
          )
    },
    console: {
        level: 'debug',
        handleExceptions: true,
        format: combine(
            colorize(),
            timestamp(),
            align(),
            printf((info) => {
                const {
                  timestamp, level, message, ...args
                } = info;

                const ts = timestamp.slice(0, 19).replace('T', ' ');
                return `${ts} [${level}]: ${message} ${Object.keys(args).length ? JSON.stringify(args, null, 2) : ''}`;
              })
          )
    }
};

const logger = winston.createLogger({
    format: winston.format.combine(
    winston.format.splat(),
    winston.format.simple()
  ),
    exitOnError: false
});

logger.configure({
    transports: [
        new DailyRotateFile(options.file)
    ]
});

  if (process.env.NODE_ENV !== 'production') {
    logger.add(new winston.transports.Console(options.console))
  }

logger.stream = {
    write: function(message, encoding) {
        logger.info(message);
    },
};
module.exports = logger;
