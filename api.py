from flask import Flask, jsonify
import mysql.connector
from mysql.connector import Error

app = Flask(__name__)

DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'Montage#2000',
    'database': 'school_db',
    'ssl_disabled': True,  # ✅ Fix SSL error
    'auth_plugin': 'mysql_native_password'  # ✅ Fix MySQL 8.0 auth
}


def get_db_connection():
    """Create a fresh database connection each time"""
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        return conn
    except Error as e:
        print(f"Database connection failed: {e}")
        return None


@app.route('/verify/<student_id>', methods=['GET'])
def verify_student(student_id):
    try:
        # ✅ Fresh connection every request (safer)
        conn = get_db_connection()

        if conn is None:
            return jsonify({
                "status": "error",
                "message": "Database connection failed"
            }), 500

        cursor = conn.cursor(dictionary=True)

        query = """SELECT first_name, last_name, course, 
                   remaining_balance, is_eligible 
                   FROM students WHERE student_id = %s"""
        cursor.execute(query, (student_id,))
        student = cursor.fetchone()

        cursor.close()
        conn.close()

        if student:
            is_eligible = student.get('is_eligible', 0)
            allowed_status = "ALLOWED" if is_eligible == 1 else "NOT ALLOWED"

            return jsonify({
                "status": "success",
                "name": f"{student['first_name']} {student['last_name']}",
                "course": student.get('course', 'N/A'),
                "balance": float(student.get('remaining_balance', 0.0)),
                "is_eligible": is_eligible,
                "exam_status": allowed_status
            })
        else:
            return jsonify({
                "status": "error",
                "message": "UNKNOWN OR INVALID ID"
            }), 404

    except Exception as e:
        print(f"!!! CRASH DETECTED: {str(e)}")
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500


# ✅ Add a test endpoint to check if API is running
@app.route('/test', methods=['GET'])
def test():
    return jsonify({
        "status": "success",
        "message": "API is running!"
    })


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)