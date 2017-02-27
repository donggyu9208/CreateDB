import sqlite3;

conn = sqlite3.connect('C:\Users\DongGyu\Desktop\Programming\Python\Research\\practice - Copy - Copy.db');
cur = conn.cursor();

#Make Tables

cur.executescript('''
    DROP TABLE IF EXISTS Age;
    DROP TABLE IF EXISTS Driver;
    DROP TABLE IF EXISTS Event;
    DROP TABLE IF EXISTS Event_Properties;
    DROP TABLE IF EXISTS Gender;
    DROP TABLE IF EXISTS Move;
    DROP TABLE IF EXISTS Turn;
    
    CREATE TABLE IF NOT EXISTS "Age" ( 
        'id'                    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
        'age_group'             TEXT NOT NULL UNIQUE);
    
    CREATE TABLE IF NOT EXISTS "Gender" (
        'id'                    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
        'gender_type'           TEXT NOT NULL UNIQUE);
        
    CREATE TABLE IF NOT EXISTS "Move" (
        'id'                    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
        'moving_type'           TEXT NOT NULL UNIQUE);
        
    CREATE TABLE IF NOT EXISTS "Turn" (
        'id'                    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
        'turn_direction'        TEXT NOT NULL UNIQUE);
        
    CREATE TABLE IF NOT EXISTS "Traffic_Control_Device" (
        'id'                    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
        'sign'                  TEXT NOT NULL UNIQUE);
        
    CREATE TABLE IF NOT EXISTS "Driver" (
        'id'                    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
        'driver_number'         INTEGER NOT NULL UNIQUE, 
        'age_id'                INTEGER NOT NULL,
        'gender_id'             INTEGER NOT NULL);
        
    CREATE TABLE IF NOT EXISTS "Speed" (
        'id'                    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
        'speed_limit_before'    INTEGER NOT NULL,
        'speed_limit_after'     INTEGER NOT NULL,
        UNIQUE(speed_limit_before, speed_limit_after));
    
    CREATE TABLE IF NOT EXISTS "Event_Properties" ( 
        'id'                    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
        'event_number'          INTEGER NOT NULL,
        'driver_id'             INTEGER NOT NULL,
        'turn_id'               INTEGER NOT NULL,
        'tcd_id'                INTEGER NOT NULL,
        'speed_id'              INTEGER NOT NULL,
        'move_id'               INTEGER NOT NULL);
        
    CREATE TABLE IF NOT EXISTS "Event" (
        'event_id'              INTEGER NOT NULL,
        'distance'              INTEGER NOT NULL, 
        'velocity'              REAL NOT NULL);
''');
        
# INSERT FEATURES
cur.executescript('''
    INSERT OR IGNORE INTO 'Age'
    ('id',  'age_group') 
    VALUES 
    (1,     'young'),
    (2,     'adult'),
    (3,     'senior');
    
    INSERT OR IGNORE INTO 'Gender'
    ('id',  'gender') 
    VALUES 
    (0,     'female'),
    (1,     'male');
    
    INSERT OR IGNORE INTO 'Traffic_Control_Device'
    ('id',  'sign')
    VALUES
    (1,     'stop light'),
    (2,     'stop sign');
    
    INSERT OR IGNORE INTO 'Move'
    ('id',  'moving_type') VALUES
    (1,     'travelling through'),
    (2,     'rolling stop'),
    (3,     'complete stop');
    
    INSERT OR IGNORE INTO 'Turn' 
    ('id',  'turn_direction') VALUES
    (0,     'no turn'),
    (1,     'left turn');
''');
conn.commit();

# Access the file
# [ Event_ID|DriverID|turn|tcd|sl_app|sl_trav|move|ag|male|d|v ]
# Event_ID  -> event id number
# driver_ID -> driver identification number
# turn      -> 0 = no turn, 1 = left turn
# tcd       -> traffic control device (1 =  stop light, 2 = stop sign)
# sl_app    -> speed limit on road before intersection
# sl_trav   -> speed limit on road after intersection 
# move      -> movement catagory (1 = travelling through, 2 = rolling stop, 3 = complete stop)
# ag        -> age group (1 = young, 2 = adult, 3 = senior)
# male      -> gender (1=male, 0 = female)
# d         -> distance from minimum speed in d (- during approach)		
# v         -> velocity in m/s 

#myFile = open('C:\Users\DongGyu\Desktop\Programming\Python\Research\TEST(OneData).txt', 'r');
#myFile = open('C:\Users\DongGyu\Desktop\Programming\Python\Research\TEST(OneEventID).txt', 'r');
#myFile = open('C:\Users\DongGyu\Desktop\Programming\Python\Research\TEST(TwoEventID).txt', 'r');
myFile = open('C:\Users\DongGyu\Desktop\Programming\Python\Research\OUTPUT_shift_D1.txt', 'r');
#myFile = open('C:\Users\DongGyu\Desktop\Programming\Python\Research\TEST(MoreEventID).txt', 'r');
#myFile = open('C:\Users\DongGyu\Desktop\Programming\Python\Research\TEST(56983).txt', 'r');
#myFile = open('C:\Users\DongGyu\Desktop\Programming\Python\Research\Test56983.txt', 'r');


firstline = True;
firstline = myFile.readline();

event_number = 0;
event_id = 0;

for line in myFile:
    line = line.rstrip();
    list = line.split('|');
    
    if event_number != int(list[0]):
        event_id        = event_id + 1;
        event_number    = int(list[0]);
        driver_number   = int(list[1]);
        turn_id         = int(list[2]);
        tcd_id          = int(list[3]);
        sl_before       = int(list[4]);
        sl_after        = int(list[5]);
        move_id         = int(list[6]);
        age_id          = int(list[7]);
        gender_id       = int(list[8]);
        
        # INSERT Driver Table
        cur.execute('''
        INSERT OR IGNORE INTO 'Driver' 
        ('driver_number', 'age_id', 'gender_id') 
        VALUES
        (?, ?, ?)
        ''', 
        (driver_number, age_id, gender_id));
        
        cur.execute('''
        SELECT id FROM Driver WHERE driver_number = ?
        ''',
        (driver_number, ));
        driver_id = cur.fetchone()[0];
        
        # INSERT Speed Table
        cur.execute('''
        INSERT OR IGNORE INTO 'Speed' 
        ('speed_limit_before', 'speed_limit_after') 
        VALUES
        (?, ?)
        ''', 
        (sl_before, sl_after));
        
        cur.execute('''
        SELECT id FROM Speed WHERE 
        speed_limit_before = ?
        AND
        speed_limit_after =?
        ''',
        (sl_before, sl_after));
        speed_id = cur.fetchone()[0];
        
        # INSERT Event_Properties Table
        cur.execute('''
        INSERT OR IGNORE INTO 'Event_Properties' 
        ('event_number', 'driver_id', 'turn_id', 'tcd_id', 'speed_id', 'move_id') 
        VALUES
        (?, ?, ?, ?, ?, ?)
        ''', 
        (event_number, driver_id, turn_id, tcd_id, speed_id, move_id));
        
        cur.execute('''
        SELECT id FROM Event_Properties WHERE 
        event_number = ?
        ''',
        (event_number, ));
        event_id = cur.fetchone()[0];
        
    d = int(list[9]);
    v = float(list[10]);
    cur.execute('''
    INSERT OR REPLACE INTO 'Event' 
    ('event_id', 'distance', 'velocity') 
    VALUES
    (?, ?, ?)
    ''', 
    (event_id, d, v));
conn.commit();