defmodule Dispatcher do
  use Matcher

  define_accept_types [
    json: [ "application/json", "application/vnd.api+json" ],
    html: [ "text/html", "application/xhtml+html"],
    css: [ "text/css" ],
    any: [ "*/*" ],
  ]

  @json_service %{ accept: [ :json ] }
  @any %{}

  ### Authentication

  match "/mock/sessions/*path", @json_service do
    Proxy.forward conn, path, "http://mock-login/sessions/"
  end

  match "/sessions/*path", @json_service do
    Proxy.forward conn, path, "http://login/sessions/"
  end

  match "/users/*path", @json_service do
    Proxy.forward conn, path, "http://cache/users/"
  end

  get "/accounts/*path", @json_service do
    Proxy.forward conn, path, "http://cache/accounts/"
  end

  match "/user-organizations/*path", @json_service do
    Proxy.forward conn, path, "http://cache/user-organizations/"
  end

  match "/memberships/*path", @json_service do
    Proxy.forward conn, path, "http://cache/memberships/"
  end

  get "/login-activities/*path", @json_service do
    Proxy.forward conn, path, "http://cache/login-activities/"
  end

  ### Files

  get "/files/:id/download", @any do
    Proxy.forward conn, [], "http://range-file/files/" <> id <> "/download/"
  end

  post "/files/*path", @any do
    Proxy.forward conn, path, "http://file/files/"
  end

  delete "/files/*path", @any do
    Proxy.forward conn, path, "http://file/files/"
  end

  match "/files/*path", @any do
    Proxy.forward conn, path, "http://cache/files/"
  end

  ### Regular resources and cache

  match "/documents/*path", @any do
    Proxy.forward conn, path, "http://cache/documents/"
  end

  match "/document-versions/*path", @any do
    Proxy.forward conn, path, "http://cache/document-versions/"
  end

  get "/document-types/*path", @any do
    Proxy.forward conn, path, "http://cache/document-types/"
  end

  get "/roles/*path", @json_service do
    Proxy.forward conn, path, "http://cache/roles/"
  end

  get "/access-levels/*path", @any do
    Proxy.forward conn, path, "http://cache/access-levels/"
  end


  match "/meetings/:id/agenda/distribute", @any do
    Proxy.forward conn, [], "http://distribution/meetings/" <> id <> "/agenda/distribute/"
  end

  match "/meetings/:id/notifications/distribute", @any do
    Proxy.forward conn, [], "http://distribution/meetings/" <> id <> "/notifications/distribute/"
  end


  match "/meetings/*path", @any do
    Proxy.forward conn, path, "http://cache/meetings/"
  end

  match "/agendaitems/*path", @any do
    Proxy.forward conn, path, "http://cache/agendaitems/"
  end

  match "/cases/*path", @any do
    Proxy.forward conn, path, "http://cache/cases/"
  end


  match "/government-bodies/*path", @any do
    Proxy.forward conn, path, "http://cache/government-bodies/"
  end


  match "/agendaitems-by-notification/search", @any do
    Proxy.forward conn, [], "http://search/agendaitems-by-notification/search/"
  end

  match "/agendaitems-by-documents/search", @any do
    Proxy.forward conn, [], "http://search/agendaitems-by-documents/search/"
  end

  match "/_", %{ last_call: true } do
    send_resp( conn, 404, "Route not found.  See config/dispatcher.ex" )
  end

end
