import firebase_admin
from firebase_admin import credentials
from firebase_admin import db
import sys

cred_obj = credentials.Certificate('cred.json')
default_app = firebase_admin.initialize_app(cred_obj, {
	    'databaseURL': 'https://congklak-online-55fab-default-rtdb.asia-southeast1.firebasedatabase.app'
	})


ref = db.reference("room/")
room_id = sys.argv[1]
room_ref = ref.child(room_id)
room_ref.delete()