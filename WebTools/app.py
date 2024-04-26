from flask import Flask, redirect, render_template, request, flash, jsonify, send_file

app = Flask(__name__)


class Contact:
    def __init__(self, id_=None, first=None, last=None, phone=None, email=None):
        self.id = id_
        self.first = first
        self.last = last
        self.phone = phone
        self.email = email


contact1 = Contact(
    id_=1, first="John", last="Doe", phone="555-0101", email="john.doe@example.com"
)
contact2 = Contact(
    id_=2, first="Jane", last="Doe", phone="555-0102", email="jane.doe@example.com"
)
contact3 = Contact(
    id_=3, first="Jim", last="Beam", phone="555-0103", email="jim.beam@example.com"
)

# contacts_list = [contact1, contact2, contact3]

contacts_list = [
    {
        "id": 1,
        "first": "John",
        "last": "Doe",
        "phone": "555-0101",
        "email": "john.doe@example.com",
    },
    {
        "id": 2,
        "first": "Jane",
        "last": "Doe",
        "phone": "555-0102",
        "email": "jane.doe@example.com",
    },
    {
        "id": 3,
        "first": "Jim",
        "last": "Beam",
        "phone": "555-0103",
        "email": "jim.beam@example.com",
    },
]


# Root URL of website
@app.route("/")
def index():
    return redirect("/contacts")


# handler for server-side search
@app.route("/contacts")
def contacts():
    search_query = request.args.get("q")
    if search_query:
        filtered_contacts = [
            contact
            for contact in contacts_list
            if search_query.lower() in contact["first"].lower()
            or search_query.lower() in contact["last"].lower()
        ]
    else:
        filtered_contacts = contacts_list
    return render_template("index.html", contacts=filtered_contacts)


@app.route("/contacts/new", methods=["GET"])
def contacts_new_get():
    return render_template("new.html", contact={})


if __name__ == "__main__":
    app.run(debug=True)
