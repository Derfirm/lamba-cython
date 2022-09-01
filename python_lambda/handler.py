import logging
from functools import wraps
from http import HTTPStatus

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def aws_response_wrapper(func):
    @wraps(func)
    def inner(event, context):
        try:
            result = func(event, context)
        except Exception as e:
            return create_500_response(str(e))
        assert type(result) == dict

        return create_200_response(result)

    return inner


@aws_response_wrapper
def hello_python(event, context):
    from python_m.hello import say_hello

    return {"text": say_hello()}


@aws_response_wrapper
def hello_cython(event, context):
    from cython_m.hello import say_hello

    return {"text": say_hello()}


def create_500_response(error_message):
    headers = {
        # Required for CORS support to work
        "Access-Control-Allow-Origin": "*",
        # Required for cookies, authorization headers with HTTPS
        "Access-Control-Allow-Credentials": True,
    }
    return create_aws_lambda_response(
        HTTPStatus.INTERNAL_SERVER_ERROR, {"error": error_message}, headers
    )


def create_200_response(message):
    headers = {
        # Required for CORS support to work
        "Access-Control-Allow-Origin": "*",
        # Required for cookies, authorization headers with HTTPS
        "Access-Control-Allow-Credentials": True,
    }
    return create_aws_lambda_response(HTTPStatus.OK, {"message": message}, headers)


def create_aws_lambda_response(status_code, message, headers):
    return {"statusCode": status_code, "headers": headers, "body": message}
