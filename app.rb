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
    pass = db.execute("SELECT Password FROM users WHERE Username = ?",params["Username"])
    
    if (BCrypt::Password.new(pass.first["Password"]) == params["Password"]) == true
        session[:username] = params[:username]
        redirect('/blog')
    else
        redirect('/error')
    end
    
end

get('/blog') do
    slim(:index)
end

get('/error') do
    slim(:error)
end