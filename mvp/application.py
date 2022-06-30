from flask import Flask

application = Flask(__name__)

@application.route('/')
def home():
    return "Hello, world!"

@application.route('/health_check')
def healthcheck():
    return Response(status=200)

if __name__ == '__main__':
    application.run(host="0.0.0.0",debug=True)