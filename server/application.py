from flask import Flask, render_template, redirect, url_for, session,Response
from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField, EmailField
from wtforms.validators import InputRequired


application = Flask(__name__)
application.config['SECRET_KEY'] = 'some_random_secret'
application.config['STATIC_FOLDER'] = 'templates'

class SignUpForm(FlaskForm):
    first_name = StringField('First Name', validators=[InputRequired()])
    last_name = StringField('Last Name', validators=[InputRequired()])
    email = EmailField('Enter your email', validators=[InputRequired()])
    submit = SubmitField('Submit')


@application.route('/', methods=['GET', 'POST'])
def index():
    form = SignUpForm()
    if form.validate_on_submit():
        session['first_name'] = form.first_name.data
        session['last_name'] = form.last_name.data
        session['email'] = form.email.data
        return redirect(url_for("home"))
    return render_template('index.html', form=form)

@application.route('/home')
def home():
    return render_template('home.html')

@application.route('/health_check')
def healthcheck():
    return Response(status=200)

if __name__ == '__main__':
    application.run(host="0.0.0.0",debug=True)