require 'byebug'
require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions

# configure do
#
# end

# before do
#
# end


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

    db.execute("INSERT INTO Users Username, Email, Password VALUES(?, ?, ?)", params["Username"], params["Email"], hashat_password)

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
    
        redirect('/blog')
    else
        redirect('/error')
    end
    
end

get('/error') do
    slim(:error)
end

get('/blog') do
    db = SQLite3::Database.new('db/Users.db')
    db.results_as_hash = true

    posts = db.execute("SELECT Header, Text, Images, Post_ID FROM Posts WHERE Author = ?", session[:User])

    slim(:blog, locals:{blog:posts})
end

get('/new_entry') do 
    slim(:entry)
end

post('/new_entry') do
    db = SQLite3::Database.new('db/Users.db')
    db.results_as_hash = true

    db.execute("INSERT INTO Posts (Header, Text, Images, Author) VALUES(?, ?, ?, ?)", params["Title"], params["Body"], params["Img"], session[:User])

    redirect('/blog')
end

get('/edit/:id') do 
    db = SQLite3::Database.new('db/Users.db')
    db.results_as_hash = true
    byebug
    edit_post = db.execute("SELECT Header, Text, Images, Post_ID FROM Posts WHERE Post_ID = ?", params[:id])
    slim(:edit, locals:{blog:edit_post})
end

post('/edit/:id') do
    db = SQLite3::Database.new('db/Users.db')
    db.results_as_hash = true

    db.execute("UPDATE Posts WHERE Post_ID = ?", params[:id])
    redirect('/blog')
end

post('/delete/:id') do
    db = SQLite3::Database.new('db/Users.db')
    db.results_as_hash = true

    db.execute("DELETE FROM Posts WHERE Post_ID = ?", params[:id])
    redirect('/blog')
end

