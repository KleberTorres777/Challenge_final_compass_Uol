from robot.api.deco import keyword
from pymongo import MongoClient
import bcrypt

client = MongoClient('mongodb+srv://klebertorres632_db_user:<45454545>@cluster0.i1dr2le.mongodb.net/?appName=Cluster0')
 
db = client['cinemadb']
print("db",db)


@keyword('Clean user from database')
def clean_user(user_email):
    users = db['users']
    tasks = db['tasks']

    u = users.find_one({'email': user_email})

    if u:  
        tasks.delete_many({'user_id': u['_id']})
        users.delete_many({'email': user_email})
        print(f"User {user_email} removed")

@keyword('Insert user in database')
def insert_user(user):
    users = db['users']
    
    # Hash da senha
    hash_pass = bcrypt.hashpw(user['password'].encode('utf-8'), bcrypt.gensalt())
    hash_pass_str = hash_pass.decode('utf-8')  # salvar como string

    # Criar documento completo
    doc = {
        'name': user['name'],
        'email': user['email'],
        'password': hash_pass_str,
        'role': 'user'  # necessário para PUT Auth Profile
    }

    users.insert_one(doc)
    print(f"User {user['email']} inserted")

@keyword('Insert admin in database')
def insert_admin(admin):
    users = db['users']
    
    # Hash da senha
    hash_pass = bcrypt.hashpw(admin['password'].encode('utf-8'), bcrypt.gensalt())
    hash_pass_str = hash_pass.decode('utf-8')  # salvar como string

    # Criar documento completo
    doc = {
        'name': admin['name'],
        'email': admin['email'],
        'password': hash_pass_str,
        'role': 'admin'  # role admin para criar filmes
    }

    users.insert_one(doc)
    print(f"Admin {admin['email']} inserted")

@keyword('Clean movie from database')
def clean_movie(movie_title):
    movies = db['movies']
    
    m = movies.find_one({'title': movie_title})
    
    if m:
        movies.delete_one({'title': movie_title})
        print(f"Movie {movie_title} removed")

@keyword('Insert movie in database')
def insert_movie(movie):
    movies = db['movies']
    
    # Criar documento completo
    doc = {
        'title': movie['title'],
        'synopsis': movie['synopsis'],
        'director': movie['director'],
        'genres': movie['genres'],
        'duration': movie['duration'],
        'classification': movie['classification'],
        'poster': movie['poster'],
        'releaseDate': movie['releaseDate']
    }
    
    movies.insert_one(doc)
    print(f"Movie {movie['title']} inserted")

@keyword('Clean theater from database')
def clean_theater(theater_name):
    theaters = db['theaters']
    
    t = theaters.find_one({'name': theater_name})
    
    if t:
        theaters.delete_one({'name': theater_name})
        print(f"Theater {theater_name} removed")

