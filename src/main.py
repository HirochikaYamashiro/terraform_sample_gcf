import logging
import os

import functions_framework
import google.cloud.logging

logging_client = google.cloud.logging.Client()
logging_client.setup_logging()

@functions_framework.http
def main(request):
    """HTTP Cloud Function.
    Args:
        request (flask.Request): The request object.
        <https://flask.palletsprojects.com/en/1.1.x/api/#incoming-request-data>
    Returns:
        The response text, or any set of values that can be turned into a
        Response object using `make_response`
        <https://flask.palletsprojects.com/en/1.1.x/api/#flask.make_response>.
    """
    a: str = "Hello World!\n"
    if os.environ.get('TEST_STRING'):
        a: str = os.environ.get('TEST_STRING')

    return a