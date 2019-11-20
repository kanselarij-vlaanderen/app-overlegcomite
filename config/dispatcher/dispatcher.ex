defmodule Dispatcher do
  use Plug.Router

  def start(_argv) do
    port = 80
    IO.puts "Starting Plug with Cowboy on port #{port}"
    Plug.Adapters.Cowboy.http __MODULE__, [], port: port
    :timer.sleep(:infinity)
  end

  plug Plug.Logger
  plug :match
  plug :dispatch

  match "/mock/sessions/*path" do
    Proxy.forward conn, path, "http://mocklogin/sessions/"
  end
  
  match "/sessions/*path" do
    Proxy.forward conn, path, "http://login/sessions/"
  end
  
  
  match "/users/*path" do
    Proxy.forward conn, path, "http://cache/users/"
  end

  match "/accounts/*path" do
    Proxy.forward conn, path, "http://cache/accounts/"
  end

  match "/account-groups/*path" do
    Proxy.forward conn, path, "http://cache/account-groups/"
  end


  get "/files/:id/download" do
    Proxy.forward conn, [], "http://file/files/" <> id <> "/download"
  end

  post "/files/*path" do
    Proxy.forward conn, path, "http://file/files/"
  end

  delete "/files/*path" do
    Proxy.forward conn, path, "http://file/files/"
  end

  match "/files/*path" do
    Proxy.forward conn, path, "http://cache/files/"
  end


  match "/documents/*path" do
    Proxy.forward conn, path, "http://cache/documents/"
  end

  match "/document-versions/*path" do
    Proxy.forward conn, path, "http://cache/document-versions/"
  end

  match "/document-types/*path" do
    Proxy.forward conn, path, "http://cache/document-types/"
  end


  match "/access-levels/*path" do
    Proxy.forward conn, path, "http://cache/access-levels/"
  end


  match "/meetings/*path" do
    Proxy.forward conn, path, "http://cache/meetings/"
  end

  match "/agendaitems/*path" do
    Proxy.forward conn, path, "http://cache/agendaitems/"
  end

  match "/cases/*path" do
    Proxy.forward conn, path, "http://cache/cases/"
  end


  match "/government-bodies/*path" do
    Proxy.forward conn, path, "http://cache/government-bodies/"
  end


  match _ do
    send_resp( conn, 404, "Route not found.  See config/dispatcher.ex" )
  end

end
