# /usr/bin/python2.7
import psycopg2
from configparser import ConfigParser

import redis
from flask import Flask, render_template, g
import time


def ini(section, filename='config/database.ini'):
    """
    parses an .ini configuration file for the given section
    :param section: the section to parse
    :param filename: the filename to parse
    :return: dictionary containing the .ini section properties
    """

    parser = ConfigParser()
    parser.read(filename)

    conf = {}
    if parser.has_section(section):
        for i in parser.items(section):
            conf[i[0]] = i[1]
    else:
        raise Exception('section {0} not found in {1}'.format(section, filename))

    return conf


def get_postgres():
    """
    attempts to connect to postgres
    :return: a database cursor
    """

    try:
        # get postgres configuration
        config = ini('postgres')

        # try to connect to the postgres
        print('connecting to postgres...')
        return psycopg2.connect(**config)

    except (Exception, psycopg2.DatabaseError) as error:
        print('error:', error)


def get_redis():
    """
    attempts to connect to redis
    :return: a Redis connection
    """

    try:
        # get redis configuration
        config = ini('redis')

        # try to connect to redis
        print('connecting to redis...')
        return redis.Redis.from_url(**config)

    except Exception as error:
        print('error:', error)


def select_version():
    """
    attempts to query the version from postgres
    :return: the database version found
    """

    # constants
    query_str = 'select slow_version();'
    redis_key = 'slow_version'
    redis_ttl = 60

    # connect to cache
    redis_conn = get_redis()
    try:
        # read value from cache
        value = redis_conn.get(redis_key)
        if value is not None:
            return value

    except Exception as error:
        print('error:', error)

    finally:
        redis_conn.close()
        print('redis connection closed')

    # connect to database
    postgres_conn = get_postgres()
    cursor = postgres_conn.cursor()
    try:
        # read value from database
        cursor.execute(query_str)
        value = cursor.fetchone()[0]

        # set value in cache
        redis_conn.set(redis_key, value, keepttl=redis_ttl)
        return value

    except Exception as error:
        print('error:', error)

    finally:
        cursor.close()
        postgres_conn.close()
        print('postgres connection closed')


app = Flask(__name__) 


@app.before_request
def before_request():
    g.request_start_time = time.time()
    g.request_time = lambda: "%.5fs" % (time.time() - g.request_start_time)


@app.route("/")     
def index():

    config = ini('postgres')
    db_host = config['host']
    db_version = select_version()

    return render_template('index.html', db_host=db_host, db_version=db_version)


if __name__ == "__main__":        # on running python app.py
    app.run()                     # run the flask app
