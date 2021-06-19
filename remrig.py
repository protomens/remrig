#import pymysql
import flask
import os
import pwd
import subprocess
import time
import jwt
import psutil

from subprocess import Popen
from flask import Flask, abort, request, jsonify, g, url_for
from flask_sqlalchemy import SQLAlchemy
from passlib.apps import custom_app_context as pwd_context
from flask_httpauth import HTTPBasicAuth
from itsdangerous import (TimedJSONWebSignatureSerializer
                          as Serializer, BadSignature, SignatureExpired)


from werkzeug.security import generate_password_hash, check_password_hash

# initialization
app = Flask(__name__)
DBdir = '/home/' + str(pwd.getpwuid(os.getuid())[0]) + '/dbs'
print(DBdir)
DBFile = 'sqlite:///' + DBdir + '/remrig.sqlite'
print(DBFile)
app.config['SECRET_KEY'] = '3dQr8K7L3oyjsAIFyvlAZb2kGXLEkqA+87V4Zsq9Fys='
app.config['SQLALCHEMY_DATABASE_URI'] = DBFile
app.config['SQLALCHEMY_COMMIT_ON_TEARDOWN'] = True


# extensions
db = SQLAlchemy(app)
auth = HTTPBasicAuth()



class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(32), index=True)
    password_hash = db.Column(db.String(128))

    def hash_password(self, password):
        self.password_hash = generate_password_hash(password)

    def verify_password(self, password):
        return check_password_hash(self.password_hash, password)

    def generate_auth_token(self, expires_in=600):
        return jwt.encode(
            {'id': self.id, 'exp': time.time() + expires_in},
            app.config['SECRET_KEY'], algorithm='HS256')

    @staticmethod
    def verify_auth_token(token):
        try:
            data = jwt.decode(token, app.config['SECRET_KEY'],
                              algorithms=['HS256'])
        except:
            return
        return User.query.get(data['id'])


@auth.verify_password
def verify_password(username_or_token, password):
    # first try to authenticate by token
    user = User.verify_auth_token(username_or_token)
    if not user:
        # try to authenticate with username/password
        user = User.query.filter_by(username=username_or_token).first()
        if not user or not user.verify_password(password):
            return False
    g.user = user
    return True


@app.route('/api/users', methods=['POST'])
def new_user():
    username = request.json.get('username')
    password = request.json.get('password')
    if username is None or password is None:
        abort(400)    # missing arguments
    if User.query.filter_by(username=username).first() is not None:
        abort(400)    # existing user
    user = User(username=username)
    user.hash_password(password)
    db.session.add(user)
    db.session.commit()
    return (jsonify({'username': user.username}), 201,
            {'Location': url_for('get_user', id=user.id, _external=True)})


@app.route('/api/users/<int:id>')
def get_user(id): 
    user = User.query.get(id)
    if not user:
        abort(400)
    return jsonify({'username': user.username})


@app.route('/api/token')
@auth.login_required
def get_auth_token():
    token = g.user.generate_auth_token(600)
    return jsonify({'token': token.decode('ascii'), 'duration': 600})


@app.route('/api/xmrig', methods=['GET'])
@auth.login_required
def action_xmrig():
    query_parameters = request.args
    
    action = query_parameters.get('action')
        
    if action.upper() == "START":
        if checkIfProcessRunning("xmrig"):
            return jsonify("Start")
        else:
            Popen(["sudo", "nice", "xmrig"])        
            return jsonify("Start")
    elif action.upper() == "STOP":
        Popen(["sudo",  "pkill", "-SIGTERM", "xmrig"])
        return jsonify("Stop")
    else:
        return page_not_found(404)

@app.errorhandler(404)
def page_not_found(e):
    return "<h1>404</h1><p>The resource could not be found.</p>", 404

if not os.path.exists(DBFile):
    print("DB File doesn't exist (creating)...: %s" % DBFile)
    db.create_all()  
    
def checkIfProcessRunning(processName):
    #Iterate over the all the running process
    for proc in psutil.process_iter():
        try:
            # Check if process name contains the given name string.
            if processName.lower() in proc.name().lower():
                return True
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            pass
    return False;
    
