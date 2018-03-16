#!/usr/bin/env python3
import connexion
import datetime
import logging
import sys
import os
import json
from connexion import NoContent
from swagger_parser import SwaggerParser



def getStatus():
    return {'version': '0.0.0-0'}, 200


# def myoperation():
#     return " Mock Not implemented yet", 550


### Please replacing this section with function matches your operationId
### function parameters should match the parameter in url path or query string ( don't put header or body parameters)

DB = {}
def get_databases():
    logging.info('get databases')
    return [database for database in DB.values()]


def get_database_id(id):
    logging.info('getting database %s..', id)
    database = DB.get(id)
    return database or ('Not found', 404)


def put_database_id(id, database):
    if id in DB:
        logging.info('Updating DB %s..', id)
        DB[id].update(database)
        return NoContent, 201
    else:
        logging.info('Creating DB %s..', id)
        DB[id] = database
        return NoContent, 200


def delete_database_id(id):
    if id in DB:
        logging.info('Deleting DB %s..', id)
        del DB[id]
        return NoContent, 204
    else:
        return NoContent, 404


#######
# !!!! NO Need to change below this point!!!!



#######
logging.basicConfig(level=logging.DEBUG)
# set default swagger file
try:
    swagger_file = sys.argv[-1]
except:
    swagger_file = 'swagger.yaml'
logging.info("Starting mock using %s" % os.path.abspath(swagger_file))
app = connexion.App(__name__)
app.add_api(swagger_file)
application = app.app


if __name__ == '__main__':
    logging.info("API spec is at %s" % "http://0.0.0.0:8080/{baseURL}/ui")
    app.run(port=8080, host='0.0.0.0', server='gevent')
