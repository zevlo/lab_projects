from flask import Flask, jsonify, request
import sqlite3

app = Flask(__name__)


# Endpoint to retrieve all users
@app.route("/users", methods=["GET"])
def get_users():
    conn = sqlite3.connect("example.db")
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM users")
    users = cursor.fetchall()
    conn.close()
    return jsonify(users)


# Endpoint to retrieve a specific user by ID
@app.route("/users/<int:user_id>", methods=["GET"])
def get_user(user_id):
    conn = sqlite3.connect("example.db")
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM users WHERE id = ?", (user_id,))
    user = cursor.fetchone()
    conn.close()
    if user:
        return jsonify(user)
    else:
        return jsonify({"message": "User not found"}), 404


# Endpoint to create a new user
@app.route("/users", methods=["POST"])
def create_user():
    data = request.get_json()
    name = data["name"]
    email = data["email"]
    conn = sqlite3.connect("example.db")
    cursor = conn.cursor()
    cursor.execute("INSERT INTO users (name, email) VALUES (?, ?)", (name, email))
    conn.commit()
    conn.close()
    return jsonify({"message": "User created successfully"})


# Endpoint to update an existing user
@app.route("/users/<int:user_id>", methods=["PUT"])
def update_user(user_id):
    data = request.get_json()
    name = data["name"]
    email = data["email"]
    conn = sqlite3.connect("example.db")
    cursor = conn.cursor()
    cursor.execute(
        "UPDATE users SET name = ?, email = ? WHERE id = ?", (name, email, user_id)
    )
    conn.commit()
    conn.close()
    return jsonify({"message": "User updated successfully"})


# Endpoint to delete a user
@app.route("/users/<int:user_id>", methods=["DELETE"])
def delete_user(user_id):
    conn = sqlite3.connect("example.db")
    cursor = conn.cursor()
    cursor.execute("DELETE FROM users WHERE id = ?", (user_id,))
    conn.commit()
    conn.close()
    return jsonify({"message": "User deleted successfully"})


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=8080)
