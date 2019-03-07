require 'byebug'
require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions

get('/') do
    slim(:index)
end

get('/register') do
    slim(:register)
end

post('/create') do
    db = SQLite3::Database.new('db/Users.db')
    db.results_as_hash = true

    hashat_password = BCrypt::Password.create(params["Password"])

    db.execute("INSERT INTO users (Username, Email, Password) VALUES(?, ?, ?)", params["Username"], params["Email"], hashat_password)

    redirect('/login')
end

get('/login') do
    slim(:login)
end

post('/login') do
    db = SQLite3::Database.new('db/Users.db')
    db.results_as_hash = true
    pass_crypt = db.execute("SELECT Password, User_Id FROM Users WHERE Username = ?",params["Username"])
    
    if (BCrypt::Password.new(pass_crypt.first["Password"]) == params["Password"]) == true
        session[:User] = params["Username"]
        session[:id] = 
    
        redirect('/blog')
    else
        redirect('/error')
    end
    
end

get('/blog') do
    db = SQLite3::Database.new('db/Users.db')
    db.results_as_hash = true
    posts = db.execute("SELECT Header, Text, Images FROM Posts where Author = ?", session[:User])
    session[:Posts] = posts

    slim(:blog)
end



get('/error') do
    slim(:error)
end