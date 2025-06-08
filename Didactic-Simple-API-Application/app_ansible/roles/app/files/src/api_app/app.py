import os
import psycopg2
from flask import Flask, request, jsonify
from datetime import datetime, date

app = Flask(__name__)

# Database connection parameters - use environment variables in production
DB_HOST = os.environ.get("DB_HOST", "localhost")
DB_NAME = os.environ.get("DB_NAME", "app_db")
DB_USER = os.environ.get("DB_USER", "app_user") 
DB_PASSWORD = os.environ.get("DB_PASSWORD", "appuser") # This could be different according to the security requirements

def get_db_connection():
    """Establishes a connection to the PostgreSQL database."""
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD
        )
        return conn
    except psycopg2.Error as e:
        app.logger.error(f"Database connection error: {e}")
        # raise exception (for prod)
        raise

@app.route('/hello/<username>', methods=['PUT'])
def upsert_user(username):
    if not username.isalpha():
        return jsonify({"error": "Username must contain only letters."}), 400

    try:
        data = request.get_json()
        if not data or 'dateOfBirth' not in data:
            return jsonify({"error": "Missing dateOfBirth in request body."}), 400
        
        dob_str = data['dateOfBirth']
        dob = datetime.strptime(dob_str, '%Y-%m-%d').date()

        if dob >= date.today():
            return jsonify({"error": "Date of birth must be a date before today."}), 400

    except ValueError:
        return jsonify({"error": "Invalid date format. Please use YYYY-MM-DD."}), 400
    except Exception as e:
        app.logger.error(f"Error processing request: {e}")
        return jsonify({"error": "Invalid request."}), 400

    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            """
            INSERT INTO users (username, date_of_birth) 
            VALUES (%s, %s)
            ON CONFLICT (username) 
            DO UPDATE SET date_of_birth = EXCLUDED.date_of_birth;
            """,
            (username, dob)
        )
        conn.commit()
    except psycopg2.Error as e:
        app.logger.error(f"Database error during user upsert: {e}")
        return jsonify({"error": "Database operation failed."}), 500
    finally:
        if 'cur' in locals() and cur:
            cur.close()
        if 'conn' in locals() and conn:
            conn.close()
            
    return '', 204

@app.route('/hello/<username>', methods=['GET'])
def get_birthday_message(username):
    dob = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT date_of_birth FROM users WHERE username = %s;", (username,))
        user_record = cur.fetchone()
        
        if user_record:
            dob = user_record[0]
        else:
            return jsonify({"error": "User not found."}), 404
            
    except psycopg2.Error as e:
        app.logger.error(f"Database error fetching user: {e}")
        return jsonify({"error": "Database operation failed."}), 500
    finally:
        if 'cur' in locals() and cur:
            cur.close()
        if 'conn' in locals() and conn:
            conn.close()

    today = date.today()

    if dob.month == today.month and dob.day == today.day:
        message = f"Hello, {username}! Happy birthday!"
    else:
        
        next_bday_year = today.year
        
        # Determine the year of the next birthday
        # This loop correctly handles Feb 29 birthdays
        year_to_check = today.year
        while True:
            try:
                potential_bday_this_year = date(year_to_check, dob.month, dob.day)
                if potential_bday_this_year >= today: # Birthday is this year and hasn't passed or is today
                    next_birthday = potential_bday_this_year
                    break
                else: # Birthday  passed 
                    year_to_check += 1
            except ValueError: # Handles  Feb 29 
                year_to_check += 1 # Check the next year
        
        days_to_birthday = (next_birthday - today).days
        day_str = "day" if days_to_birthday == 1 else "days"
        message = f"Hello, {username}! Your birthday is in {days_to_birthday} {day_str}"

    return jsonify({"message": message}), 200

if __name__ == '__main__':
    app.run(debug=True) # according to requirements
