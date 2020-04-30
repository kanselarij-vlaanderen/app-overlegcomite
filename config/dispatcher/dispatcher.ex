defmodule Dispatcher do
  use Matcher

  define_accept_types []

  @any %{}

  match "/mock/sessions/*path", @any do
    Proxy.forward conn, path, "http://mocklogin/sessions/"
  end
  
  match "/sessions/*path", @any do
    Proxy.forward conn, path, "http://login/sessions/"
  end
  
  
  match "/users/*path", @any do
    Proxy.forward conn, path, "http://cache/users/"
  end

  match "/identifiers/*path", @any do
    Proxy.forward conn, path, "http://cache/identifiers/"
  end

  match "/accounts/*path", @any do
    Proxy.forward conn, path, "http://cache/accounts/"
  end

  match "/account-groups/*path", @any do
    Proxy.forward conn, path, "http://cache/account-groups/"
  end

  match "/organizations/*path", @any do
    Proxy.forward conn, path, "http://cache/organizations/"
  end


  get "/files/:id/download/*path", @any do
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


  match "/documents/*path", @any do
    Proxy.forward conn, path, "http://cache/documents/"
  end

  match "/document-versions/*path", @any do
    Proxy.forward conn, path, "http://cache/document-versions/"
  end

  match "/document-types/*path", @any do
    Proxy.forward conn, path, "http://cache/document-types/"
  end


  match "/access-levels/*path", @any do
    Proxy.forward conn, path, "http://cache/access-levels/"
  end


  match "/meetings/:id/agenda/distribute/*path", @any do
    Proxy.forward conn, [], "http://distribution/meetings/" <> id <> "/agenda/distribute/"
  end

  match "/meetings/:id/notifications/distribute/*path", @any do
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


  match "/agendaitems-by-notification/search/*path", @any do
    Proxy.forward conn, path, "http://search/agendaitems-by-notification/search/"
  end

  match "/agendaitems-by-documents/search/*path", @any do
    Proxy.forward conn, path, "http://search/agendaitems-by-documents/search/"
  end

  match "_", %{ last_call: true } do
    send_resp( conn, 404, "Route not found.  See config/dispatcher.ex" )
  end

end
