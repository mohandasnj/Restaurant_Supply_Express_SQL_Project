from flask import Flask, render_template, request
from sqlalchemy import *
from helpers import *

app = Flask(__name__)

url = "mysql+pymysql://root:password@localhost:3306/restaurant_db"
engine = create_engine(url)
conn = engine.raw_connection()
cursor = conn.cursor()


@app.route('/')
def index():  # put application's code here
    cmds = parseSQL('sql/initialize.sql')
    for c in cmds:
        engine.execute(text(c))

    procedures = parseSQL('sql/procedures.sql')
    for p in procedures:
        engine.execute(text(p))
    print('success')

    return render_template('home.html')

@app.route('/add', methods = ['GET','POST'])
def add():
    return render_template('add.html')

@app.route('/misc', methods = ['GET','POST'])
def misc():
    return render_template('misc.html')

@app.route('/remove', methods = ['GET','POST'])
def remove():
    return render_template('remove.html')

@app.route('/view', methods = ['GET','POST'])
def view():
    return render_template('view.html')

@app.route('/home', methods = ['GET','POST'])
def home():
    return render_template('home.html')

@app.route('/reset', methods = ['GET','POST'])
def reset():
    cmds = parseSQL('sql/initialize.sql')
    for c in cmds:
        engine.execute(c)

    procedures = parseSQL('sql/procedures.sql')
    for p in procedures:
        engine.execute(text(p))
    print('success')

    return render_template('home.html')



@app.route('/add_owner', methods = ['GET', 'POST'])
def add_owner():
    params = {'ipUser': request.form['user'],
              'ipFirst': request.form['fname'],
              'ipLast': request.form['lname'],
              'ipAddr': request.form['address'],
              'ipBirth': request.form['birthdate']
              }

    query = text("CALL add_owner(:ipUser, :ipFirst, :ipLast, :ipAddr, :ipBirth)").execution_options(autocommit=True)
    engine.execute(query, params)
    print('success')
    return render_template('add.html')

@app.route('/add_employee', methods = ['GET', 'POST'])
def add_employee():
    params = {'ipUser': request.form['user'],
              'ipFirst': request.form['fname'],
              'ipLast': request.form['lname'],
              'ipAddr': request.form['address'],
              'ipBirth': request.form['birthdate'],
              'ipTax': request.form['taxid'],
              'ipHire': request.form['hiredate'],
              'ipExperience': request.form['experience'],
              'ipSalary': request.form['salary']
              }

    query = text("CALL add_employee(:ipUser, :ipFirst, :ipLast, :ipAddr, :ipBirth, :ipTax, :ipHire, :ipExperience, :ipSalary)").execution_options(autocommit=True)
    engine.execute(query, params)
    # engine.execute(text(f"insert ignore into users values ('{user}', '{fName}', '{lName}', '{address}', {birthdate});"))
    # engine.execute(text(f"insert ignore into employees values ('{user}', '{taxid}', '{hiredate}', '{experience}', '{salary}');"))
    print('success')
    return render_template('add.html')

@app.route('/add_pilot_role', methods = ['GET', 'POST'])
def add_pilot_role():
    params = {'ipUser': request.form['user'],
                'ipLicense': request.form['licenseID'],
                'ipExperience': request.form['experience']
                }
    query = text("CALL add_pilot_role(:ipUser, :ipLicense, :ipExperience)").execution_options(autocommit=True)
    engine.execute(query, params)
    print('success')
    return render_template('add.html')

@app.route('/add_worker_role', methods = ['GET', 'POST'])
def add_worker_role():
    params = {'ipUser': request.form['user']}
    query = text("CALL add_worker_role(:ipUser)").execution_options(autocommit=True)
    engine.execute(query, params)
    print('success')
    return render_template('add.html')

@app.route('/add_ingredient', methods = ['GET', 'POST'])
def add_ingredient():
    params = {'ipBarcode': request.form['barcode'],
                'ipName': request.form['name'],
                'ipWeight': request.form['weight']
                }
    query = text("CALL add_ingredient(:ipBarcode, :ipName, :ipWeight)").execution_options(autocommit=True)
    engine.execute(query, params)
    print('success')
    return render_template('add.html')

@app.route('/add_drone', methods = ['GET', 'POST'])
def add_drone():
    params = {'ipId': request.form['id'],
              'ipTag': request.form['tag'],
              'ipFuel': request.form['fuel'],
              'ipCapacity': request.form['capacity'],
              'ipSales': request.form['sales'],
              'ipFlownBy': request.form['flown_by']
                }
    query = text("CALL add_drone(:ipId, :ipTag, :ipFuel, :ipCapacity, :ipSales, :ipFlownBy)")\
        .execution_options(autocommit=True)
    engine.execute(query, params)
    print('success')
    return render_template('add.html')

@app.route('/add_restaurant', methods = ['GET', 'POST'])
def add_restaurant():
    params = {'ipName': request.form['name'],
              'ipRating': request.form['rating'],
              'ipSpent': request.form['spent'],
              'ipLocation': request.form['location'],
                }
    query = text("CALL add_restaurant(:ipName, :ipRating, :ipSpent, :ipLocation)").execution_options(autocommit=True)
    engine.execute(query, params)
    print('success')
    return render_template('add.html')

@app.route('/add_service', methods = ['GET', 'POST'])
def add_service():
    params = {'ipId': request.form['id'],
              'ipName': request.form['name'],
              'ipBase': request.form['base'],
              'ipManager': request.form['manager']
              }
    query = text("CALL add_service(:ipId, :ipName, :ipBase, :ipManager)").execution_options(autocommit=True)
    engine.execute(query, params)
    print('success')
    return render_template('add.html')

@app.route('/add_location', methods = ['GET', 'POST'])
def add_location():
    params = {
        'ipLabel': request.form['label'],
        'ipX': request.form['x'],
        'ipY': request.form['y'],
        'ipSpace': request.form['space']
    }
    query = text("CALL add_location(:ipLabel, :ipX, :ipY, :ipSpace)").execution_options(autocommit=True)
    engine.execute(query, params)
    print('success')
    return render_template('add.html')

@app.route('/start_funding', methods = ['GET', 'POST'])
def start_funding():
    params = {
        'ipOwner': request.form['owner'],
        'ipLongName': request.form['longName']
    }
    query = text("CALL start_funding(:ipOwner, :ipLongName)").execution_options(autocommit=True)
    engine.execute(query, params)
    print('success')
    return render_template('misc.html')

@app.route('/hire_employee', methods = ['GET', 'POST'])
def hire_employee():
    params = {
        'ipUsername': request.form['username'],
        'ipID': request.form['id']
    }
    query = text("CALL hire_employee(:ipUsername, :ipID)").execution_options(autocommit=True)
    engine.execute(query, params)
    print('success')
    return render_template('misc.html')

@app.route('/fire_employee', methods = ['GET', 'POST'])
def fire_employee():
    params = {
        'ipUsername': request.form['username'],
        'ipID': request.form['id']
    }
    query = text("CALL fire_employee(:ipUsername, :ipID)").execution_options(autocommit=True)
    engine.execute(query, params)
    print('success')
    return render_template('misc.html')

@app.route('/manage_service', methods = ['GET', 'POST'])
def manage_service():
    params = {
        'ipUsername': request.form['username'],
        'ipID': request.form['id']
    }
    query = text("CALL manage_service(:ipUsername, :ipID)").execution_options(autocommit=True)
    engine.execute(query, params)
    print('success')
    return render_template('misc.html')

@app.route('/takeover_drone', methods = ['GET', 'POST'])
def takeover_drone():
    params = {
        'ipUsername': request.form['username'],
        'ipID': request.form['id'],
        'ipTag': request.form['tag']
    }
    query = text("CALL takeover_drone(:ipUsername, :ipID, :ipTag)").execution_options(autocommit=True)
    engine.execute(query, params)
    print('success')
    return render_template('misc.html')

@app.route('/join_swarm', methods = ['GET', 'POST'])
def join_swarm():
    params = {
        'ipID': request.form['id'],
        'ipTag': request.form['tag'],
        'ipSwarm': request.form['sTag']
    }
    query = text("CALL join_swarm(:ipID, :ipTag, :ipSwarm)").execution_options(autocommit=True)
    engine.execute(query, params)
    print('success')
    return render_template('misc.html')

@app.route('/leave_swarm', methods = ['GET', 'POST'])
def leave_swarm():
    params = {
        'ipID': request.form['id'],
        'ipTag': request.form['tag'],
    }
    query = text("CALL leave_swarm(:ipID, :ipTag)").execution_options(autocommit=True)
    engine.execute(query, params)
    print('success')
    return render_template('misc.html')

@app.route('/load_drone', methods = ['GET', 'POST'])
def load_drone():
    params = {
        'ipID': request.form['id'],
        'ipTag': request.form['tag'],
        'ipBarcode': request.form['barcode'],
        'ipPackages': request.form['packages'],
        'ipPrice': request.form['price']
    }
    query = text("CALL load_drone(:ipID, :ipTag, :ipBarcode, :ipPackages, :ipPrice)").execution_options(autocommit=True)
    engine.execute(query, params)
    print('success')
    return render_template('misc.html')

@app.route('/refuel_drone', methods = ['GET', 'POST'])
def refuel_drone():
    params = {
        'ipID': request.form['id'],
        'ipTag': request.form['tag'],
        'ipFuel': request.form['fuel']
    }
    query = text("CALL refuel_drone(:ipID, :ipTag, :ipFuel)").execution_options(autocommit=True)
    engine.execute(query, params)
    print('success')
    return render_template('misc.html')

@app.route('/fly_drone', methods = ['GET', 'POST'])
def fly_drone():
    params = {
        'ipID': request.form['id'],
        'ipTag': request.form['tag'],
        'ipDestination': request.form['destination']
    }
    query = text("CALL fly_drone(:ipID, :ipTag, :ipDestination)").execution_options(autocommit=True)
    engine.execute(query, params)
    print('success')
    return render_template('misc.html')

@app.route('/purchase_ingredient', methods = ['GET', 'POST'])
def purchase_ingredient():
    params = {
        'ipLongName': request.form['longName'],
        'ipID': request.form['id'],
        'ipTag': request.form['tag'],
        'ipBarcode': request.form['barcode'],
        'ipQuantity': request.form['quantity']
    }
    query = text("CALL purchase_ingredient(:ipLongName, :ipID, :ipTag, :ipBarcode, :ipQuantity)")\
        .execution_options(autocommit=True)
    engine.execute(query, params)
    print('success')
    return render_template('misc.html')


@app.route('/remove_ingredient', methods = ['GET', 'POST'])
def remove_ingredient():
    params = {
        'ipBarcode': request.form['barcode']
    }
    query = text("CALL remove_ingredient(:ipBarcode)").execution_options(autocommit=True)
    engine.execute(query, params)
    print('success')
    return render_template('remove.html')

@app.route('/remove_drone', methods = ['GET', 'POST'])
def remove_drone():
    params = {
        'ipId': request.form['id'],
        'ipTag': request.form['tag']
    }
    query = text("CALL remove_drone(:ipId, :ipTag)").execution_options(autocommit=True)
    engine.execute(query, params)
    print('success')
    return render_template('remove.html')

@app.route('/remove_pilot_role', methods = ['GET', 'POST'])
def remove_pilot_role():
    params = {
        'ipUsername': request.form['user']
    }
    query = text("CALL remove_pilot_role(:ipUsername)").execution_options(autocommit=True)
    engine.execute(query, params)
    print('success')
    return render_template('remove.html')

@app.route('/owner_view', methods = ['GET', 'POST'])
def owner_view():
    view = text("SELECT * FROM display_owner_view;")
    res = engine.execute(view)
    resList = [r for r in res]
    return render_template('view.html', owners = resList)

@app.route('/employee_view', methods = ['GET', 'POST'])
def employee_view():
    view = text("SELECT * FROM display_employee_view;")
    res = engine.execute(view)
    resList = [r for r in res]
    return render_template('view.html', employees = resList)

@app.route('/pilot_view', methods = ['GET', 'POST'])
def pilot_view():
    view = text("SELECT * FROM display_pilot_view;")
    res = engine.execute(view)
    resList = [r for r in res]
    return render_template('view.html', pilots = resList)

@app.route('/location_view', methods = ['GET', 'POST'])
def location_view():
    view = text("SELECT * FROM display_location_view;")
    res = engine.execute(view)
    resList = [r for r in res]
    return render_template('view.html', locations = resList)

@app.route('/ingredient_view', methods = ['GET', 'POST'])
def ingredient_view():
    view = text("SELECT * FROM display_ingredient_view;")
    res = engine.execute(view)
    resList = [r for r in res]
    return render_template('view.html', ingredients = resList)

@app.route('/service_view', methods = ['GET', 'POST'])
def service_view():
    view = text("SELECT * FROM display_service_view;")
    res = engine.execute(view)
    resList = [r for r in res]
    return render_template('view.html', services = resList)

if __name__ == '__main__':
    app.run()