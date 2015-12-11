require 'cuba'
require "cuba/safe"
require 'mote'
require 'mote/render'

Cuba.use Rack::Session::Cookie, :secret => "93af688e7075cb563cd8a960d8067e137ea58bd1c72be19a9cf52c9d5e9d72641161ad8929f233f23aef29620c504bdd3870dadc355aa0e2e851d676a15dbb1e"

# Session 存储
Cuba.use Rack::Session::Pool
Cuba.plugin Mote::Render
Cuba.plugin Cuba::Safe

# Provices specific modules
Dir["./routes/**/*.rb"].each  { |rb| require rb }
Dir["./models/**/*.rb"].each  { |rb| require rb }


# View path
Cuba.settings[:mote][:views] = "views/"

# Static files path
Cuba.use Rack::Static,
  root: "public",
  urls: ["/js", "/css", "/img"]

Cuba.define do
  on root do
    render("home", title: "首页")
  end

  on 'lngs' do
    run Lngs
  end

  on 'lnds' do
    run Lnds
  end

  on 'lnds_man' do
    run LndsMan
  end
  
  on 'bjds' do
    run Bjds
  end

  on 'bjgs' do
    run Bjgs
  end

  # use Rack::Insight::App
end