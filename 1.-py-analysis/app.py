# setup and dependencies
import numpy as np
import pandas as pd
import datetime as dt

from flask import Flask, jsonify

# python sql toolkit and object relational mapper
import sqlalchemy
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from sqlalchemy import create_engine, func

#################################################
# Database Setup
#################################################

# paths and connections
db = r'C:\Users\franc\OneDrive\Documents\Education\University of Miami\Data Visualization\Repositories\Challenges\sqlalchemy-challenge\Resources\hawaii.sqlite'
engine = create_engine(f'sqlite:///{db}')
# conn = engine.connect()

# reflect an existing database into a new model
Base = automap_base()
# reflect the tables
Base.prepare(engine, reflect=True)

# save references to each table
Measurement = Base.classes.measurement
Station = Base.classes.station

# create our session (link) from Python to the DB
session = Session(engine)

#################################################
# Flask Setup
#################################################

app = Flask(__name__)

#################################################
# Flask Routes
#################################################

@app.route('/')
def welcome():
    """list all available api routes."""
    return (
        f'Available Routes:<br/>'
        f'/api/v1.0/precipitation<br/>'
        f'/api/v1.0/stations<br/>'
        f'/api/v1.0/tobs<br/>'
        f'/api/v1.0/<start_date><br/>' 
        f'/api/v1.0/<start_date>/<end_date>' 
    )

# precipitation api route
@app.route('/api/v1.0/precipitation')
def precipitation():
    # create our session (link) from python to the db
    session = Session(engine)

    """return a list of all precipitation values in the last 12 months"""
    max_date = engine.execute("SELECT max(date) FROM measurement").first()[0]
    twelve_months_ago = dt.datetime.strptime(max_date, "%Y-%m-%d") - dt.timedelta(365 + 1)

    precipitation_results = session.query(
        Measurement.date
        , Measurement.prcp).filter(
            Measurement.date > twelve_months_ago).order_by('date').all()
    
    session.close()

    precipitation = []
    for date, prcp in precipitation_results:
        prcp_dict = {}
        prcp_dict['date'] = date
        prcp_dict['prcp'] = prcp
        precipitation.append(prcp_dict)
    
    return jsonify(precipitation)

# stations api route
@app.route('/api/v1.0/stations')
def stations():
    # create our session (link) from python to the db
    session = Session(engine)

    """return a list of all precipitation values in the last 12 months"""
    station_results = session.query(Station.station).all()
    
    session.close()
    
    station_list = list(np.ravel(station_results))
    return jsonify(station_list)

# temperature api route
@app.route('/api/v1.0/tobs')
def tobs():
    # create our session (link) from python to the db
    session = Session(engine)

    """return a list of all temperature values in the last 12 months"""
    max_date = engine.execute("SELECT max(date) FROM measurement").first()[0]
    twelve_months_ago = dt.datetime.strptime(max_date, "%Y-%m-%d") - dt.timedelta(365 + 1)

    temperature_results = session.query(
        Measurement.date
        , Measurement.tobs).order_by('date').all()
    
    session.close()

    temperature_list = list(np.ravel(temperature_results))

    # temperature = []
    # for date, tobs in temperature_results:
    #     tobs_dict = {}
    #     tobs_dict['date'] = date
    #     tobs_dict['tobs'] = tobs
    #     temperature.append(tobs_dict)
    
    return jsonify(temperature_list)

# This function called `calc_temps` will accept start date and end date in the format '%Y-%m-%d'
# and return the minimum, average, and maximum temperatures for that range of dates
@app.route('/api/v1.0/<start_date>')
@app.route('/api/v1.0/<start_date>/<end_date>')
def calc_temps(start_date = None, end_date = None):
    # create our session (link) from python to the db
    session = Session(engine)

    """TMIN, TAVG, and TMAX for a list of dates.
    
    Args:
        start_date (string): A date string in the format %Y-%m-%d
        end_date (string): A date string in the format %Y-%m-%d
        
    Returns:
        TMIN, TAVE, and TMAX
    """
    if end_date is None:
        date_query =session.query(func.min(Measurement.tobs), func.avg(Measurement.tobs), func.max(Measurement.tobs)).\
            filter(Measurement.date >= start_date).all()

        session.close()
        stat_list = list(np.ravel(date_query))
        return jsonify(date_query)

    date_query = session.query(func.min(Measurement.tobs), func.avg(Measurement.tobs), func.max(Measurement.tobs)).\
            filter(Measurement.date >= start_date).filter(Measurement.date <= end_date).all()
    
    session.close()   
    stat_list = list(np.ravel(date_query))     
    return jsonify(date_query)

if __name__ == '__main__':
    app.run(debug=True)