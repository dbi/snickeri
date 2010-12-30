require 'rubygems'
require 'sinatra'

get '/' do
  erb :index
end

get '/crop' do
  begin
    require "devil"
    erb :crop
  rescue LoadError => err
    redirect '/'
  end
end

post '/crop' do
  begin
    require "devil"
    
    if params[:file]
      data = params[:file]
      filename = File.join("public", "crop", data[:filename])

      ::Devil.with_image(data[:tempfile].path) do |img|

        if img.height > img.width
          img.resize2(480, 640)
        else
          img.resize2(640, 480)
        end

        img.save("public/crop/image.jpg")
      end
    end

    if params[:y] != ""
      ::Devil.with_image("public/crop/image.jpg") do |img|
        w = params[:w].to_i
        h = params[:h].to_i
        x = params[:x].to_i
        y = img.height - params[:y].to_i - h

        img.crop(x, y, w, h)
        img.resize(150, 150)
        img.save("public/crop/thumb.jpg")
      end
    end

    erb :crop
  rescue LoadError => err
    redirect '/'
  end
end
