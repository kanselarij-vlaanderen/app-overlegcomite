defmodule Dispatcher do
  use Matcher

  define_accept_types [
    json: [ "application/json", "application/vnd.api+json" ],
    html: [ "text/html", "application/xhtml+html"],
    css: [ "text/css" ],
    any: [ "*/*" ],
  ]

  define_layers [ :frontend, :api, :not_found ]

  @frontend %{ accept: [ :any ], layer: :frontend }
  @json_service %{ accept: [ :json ], layer: :api }
  @not_found %{ accept: [ :any ], layer: :not_found }

  ### Frontend

  get "/assets/*path", @frontend do
    Proxy.forward conn, path, "http://frontend/assets/"
  end

  get "/@appuniversum/*path", @frontend do
    Proxy.forward conn, path, "http://frontend/@appuniversum/"
  end


  ### Authentication

  match "/mock/sessions/*path", @json_service do
    Proxy.forward conn, path, "http://mock-login/sessions/"
  end

  match "/sessions/*path", @json_service do
    Proxy.forward conn, path, "http://login/sessions/"
  end

  get "/users/*path", @json_service do
    Proxy.forward conn, path, "http://cache/users/"
  end

  get "/accounts/*path", @json_service do
    Proxy.forward conn, path, "http://cache/accounts/"
  end

  get "/user-organizations/*path", @json_service do
    Proxy.forward conn, path, "http://cache/user-organizations/"
  end

  get "/memberships/*path", @json_service do
    Proxy.forward conn, path, "http://cache/memberships/"
  end

  get "/login-activities/*path", @json_service do
    Proxy.forward conn, path, "http://cache/login-activities/"
  end


  ### Data distribution

  match "/meetings/:id/agenda/distribute", @json_service do
    Proxy.forward conn, [], "http://distribution/meetings/" <> id <> "/agenda/distribute/"
  end

  match "/meetings/:id/notifications/distribute", @json_service do
    Proxy.forward conn, [], "http://distribution/meetings/" <> id <> "/notifications/distribute/"
  end


  ### Search

  match "/agendaitems-by-notification/search", @json_service do
    Proxy.forward conn, [], "http://search/agendaitems-by-notification/search/"
  end

  match "/agendaitems-by-documents/search", @json_service do
    Proxy.forward conn, [], "http://search/agendaitems-by-documents/search/"
  end


  ### Files

  get "/files/:id/download", %{ accept: [ :any ], layer: :api } do
    Proxy.forward conn, [], "http://range-file/files/" <> id <> "/download/"
  end

  post "/files/*path", %{ accept: [ :any ], layer: :api } do
    Proxy.forward conn, path, "http://file/files/"
  end

  delete "/files/*path", %{ accept: [ :any ], layer: :api } do
    Proxy.forward conn, path, "http://file/files/"
  end

  match "/files/*path", @json_service do
    Proxy.forward conn, path, "http://cache/files/"
  end


  ### Regular resources and cache

  match "/documents/*path", @json_service do
    Proxy.forward conn, path, "http://cache/documents/"
  end

  match "/document-versions/*path", @json_service do
    Proxy.forward conn, path, "http://cache/document-versions/"
  end

  match "/meetings/*path", @json_service do
    Proxy.forward conn, path, "http://cache/meetings/"
  end

  match "/agendaitems/*path", @json_service do
    Proxy.forward conn, path, "http://cache/agendaitems/"
  end

  match "/cases/*path", @json_service do
    Proxy.forward conn, path, "http://cache/cases/"
  end

  get "/document-types/*path", @json_service do
    Proxy.forward conn, path, "http://cache/document-types/"
  end

  get "/roles/*path", @json_service do
    Proxy.forward conn, path, "http://cache/roles/"
  end

  get "/access-levels/*path", @json_service do
    Proxy.forward conn, path, "http://cache/access-levels/"
  end

  get "/government-bodies/*path", @json_service do
    Proxy.forward conn, path, "http://cache/government-bodies/"
  end


  ### Fallback

  get "/*_path", %{ layer: :api, accept: %{ html: true } } do
    Proxy.forward conn, [], "http://frontend/index.html"
  end

  match "/*_path", %{ layer: :not_found, accept: %{ json: true } } do
    send_resp( conn, 404, "{ \"error\": { \"code\": 404, \"message\": \"Route not found.  See config/dispatcher.ex\" } }" )
  end

  match "/*_path", @not_found do
    send_resp( conn, 404, "Route not found. See config/dispatcher.ex" )
  end

end
