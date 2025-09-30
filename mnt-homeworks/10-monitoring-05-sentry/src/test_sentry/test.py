import sentry_sdk
from sentry_sdk import logger as sentry_logger
import logging
from sentry_sdk import init
from sentry_sdk.integrations.logging import LoggingIntegration

sentry_logging = LoggingIntegration(
    level=logging.INFO,      # какие логи захватывать
    event_level=logging.ERROR # какие отправлять в Issues
)
sentry_sdk.init(
    dsn="https://e15e406ed8bb48c37432fd6e25883315@o4510107220705280.ingest.us.sentry.io/4510107433435136",
    # Add data like request headers and IP for users,
    # see https://docs.sentry.io/platforms/python/data-management/data-collected/ for more info
    integrations=[sentry_logging],
    send_default_pii=True,
    enable_logs=True,
)

class MyCustomError(Exception):
    pass

def run_test():
    # division_by_zero = 1 / 0
    # raise MyCustomError(f"Hello it new error for Sentry!")
    # for i in 4:
    try:
        division_by_zero = 1 / 0
    except Exception as e:
        sentry_sdk.capture_exception(e)

    sentry_logger.error(
        'Loger',
        attributes={
            'payment.provider': 'stripe',
            'payment.method': 'credit_card',
            'payment.currency': 'USD',
            'user.subscription_tier': 'premium'
        }
    )

    logger = logging.getLogger(__name__)

    # Отправится в Sentry Logs
    logger.info("Это информационное сообщение")

    # Отправится в Issues
    logger.error("Это сообщение уровня ERROR")


if __name__ == "__main__":
    run_test()