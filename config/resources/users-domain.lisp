(define-resource user ()
  :class (s-prefix "foaf:Person")
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/gebruikers/")
  :properties `((:first-name            :string   ,(s-prefix "foaf:firstName"))
                (:last-name             :string   ,(s-prefix "foaf:familyName"))
                (:email-link            :url      ,(s-prefix "foaf:mbox")))
  :has-one `((account                   :via      ,(s-prefix "foaf:account")
                                        :as "account")
  :has-many `((membership               :via      ,(s-prefix "org:member")
                                        :inverse t
                                        :as "memberships"))
            )
  :on-path "users"
)

(define-resource account ()
  :class (s-prefix "foaf:OnlineAccount")
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/accounts/")
  :properties `((:provider    :uri ,(s-prefix "foaf:accountServiceHomepage"))
                (:account-name :string ,(s-prefix "foaf:accountName")))
  :has-one `((user            :via ,(s-prefix "foaf:account")
                              :inverse t
                              :as "user"))
  :on-path "accounts"
)

(define-resource membership ()
  :class (s-prefix "org:Membership")
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/lidmaatchap/")
  :properties ()
  :has-one `((user        :via ,(s-prefix "org:member")
                          :as "member")
            (organization :via ,(s-prefix "org:organization")
                          :as "organization"))
  :on-path "memberships"
)

(define-resource organization ()
  :class (s-prefix "foaf:Organization")
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/organisatie/")
  :properties ((:name :string ,(s-prefix "skos:prefLabel")))
  :has-many `((membership :via ,(s-prefix "org:organization")
                          :as "memberships"))
)
