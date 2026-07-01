;;;;;;;;;;;;;;;;;
;;; configuration
(in-package :client)
(setf *backend* "http://triplestore:8890/sparql")

(setf *log-sparql-query-roundtrip* t)
(in-package :server)
(setf *log-incoming-requests-p* t)

;;;;;;;;;;;;;;;;;;;
;;; delta messenger
(in-package :delta-messenger)

(add-delta-logger)
(add-delta-messenger "http://delta-notifier/")

;;;;;;;;;;;;;;;;;
;;; access rights
(in-package :acl)

(define-prefixes
  :session "http://mu.semte.ch/vocabularies/session/"
  :oc "http://mu.semte.ch/vocabularies/ext/oc/"
  :besluit "http://data.vlaanderen.be/ns/besluit#"
  :foaf "http://xmlns.com/foaf/0.1/"
  :adms "http://www.w3.org/ns/adms#"
  :org "http://www.w3.org/ns/org#"
  :nfo "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#"
  :ext "http://mu.semte.ch/vocabularies/ext/")

(defun access-by-role-query (group-uris)
  (format nil "PREFIX session: <http://mu.semte.ch/vocabularies/session/>
              PREFIX foaf: <http://xmlns.com/foaf/0.1/>
              SELECT ?group_uri WHERE {
                <SESSION_ID> session:account / ^foaf:account / ^foaf:member ?group_uri .
                VALUES ?group_uri { ~a }
              } LIMIT 1"
              group-uris))

(supply-allowed-group "public")

(supply-allowed-group "admin-rw"
  :query (access-by-role-query "<http://data.kanselarij.vlaanderen.be/id/group/admin>"))
(supply-allowed-group "kanselarij"
  :query (access-by-role-query "<http://data.kanselarij.vlaanderen.be/id/group/kanselarij>"))
(supply-allowed-group "minister"
  :query (access-by-role-query "<http://data.kanselarij.vlaanderen.be/id/group/minister>"))
(supply-allowed-group "kabinet"
  :query (access-by-role-query "<http://data.kanselarij.vlaanderen.be/id/group/kabinet>"))
(supply-allowed-group "adviesverlener"
  :query (access-by-role-query "<http://data.kanselarij.vlaanderen.be/id/group/adviesverlener>"))
(supply-allowed-group "kabinet-adviesverlener"
  :query (access-by-role-query
    "<http://data.kanselarij.vlaanderen.be/id/group/kabinet>
    <http://data.kanselarij.vlaanderen.be/id/group/adviesverlener>"))
(supply-allowed-group "administratie"
  :query (access-by-role-query "<http://data.kanselarij.vlaanderen.be/id/group/administratie>"))
(supply-allowed-group "parlement"
  :query (access-by-role-query "<http://data.kanselarij.vlaanderen.be/id/group/parlement>"))
(supply-allowed-group "administratie-parlement"
  :query (access-by-role-query
    "<http://data.kanselarij.vlaanderen.be/id/group/administratie>
    <http://data.kanselarij.vlaanderen.be/id/group/parlement>"))
(supply-allowed-group "user"
  :query (access-by-role-query "<http://data.kanselarij.vlaanderen.be/id/group/user>"))

(define-graph public ("http://mu.semte.ch/graphs/public")
  ;; Fixed code list types
  ("ext:DocumentTypeCode" -> _)
  ("ext:ToegangsniveauCode" -> _)
  ("besluit:Bestuursorgaan" -> _)
  ("foaf:Group" -> _)
  ("org:Organization" -> _)
  ;; Account info types
  ("foaf:Person" -> _)
  ("foaf:OnlineAccount" -> _)
  ("adms:Identifier" -> _)
  ;; ideally only writes on "http://xmlns.com/foaf/0.1/member" predicate
  ("foaf:Group" -> _))

(define-graph admin-user-info ("http://mu.semte.ch/graphs/account-info")
  ("foaf:Person" -> _)
  ("foaf:OnlineAccount" -> _)
  ("adms:Identifier" -> _)
  ;; ideally only writes on "http://xmlns.com/foaf/0.1/member" predicate
  ("foaf:Group" -> _))

(define-graph authenticated-users-case ("http://mu.semte.ch/graphs/authenticated-users")
    ("oc:Case" -> _))

(define-graph kanselarij-agenda ("http://mu.semte.ch/graphs/organizations/kanselarij")
  ("oc:Meeting" -> _)
  ("oc:AgendaItem" -> _)
  ("foaf:Document" -> _)
  ("ext:DocumentVersie" -> _)
  ("nfo:FileDataObject" -> _))
(define-graph kanselarij-account-info ("http://mu.semte.ch/graphs/organizations/kanselarij")
  ("foaf:Person" -> _)
  ("foaf:OnlineAccount" -> _)
  ("adms:Identifier" -> _)
  ;; ideally only writes on "http://xmlns.com/foaf/0.1/member" predicate
  ("foaf:Group" -> _))

(define-graph minister-agenda ("http://mu.semte.ch/graphs/organizations/minister")
  ("oc:Meeting" -> _)
  ("oc:AgendaItem" -> _)
  ("foaf:Document" -> _)
  ("ext:DocumentVersie" -> _)
  ("nfo:FileDataObject" -> _))
(define-graph minister-account-info ("http://mu.semte.ch/graphs/organizations/minister")
  ("foaf:Person" -> _)
  ("foaf:OnlineAccount" -> _)
  ("adms:Identifier" -> _)
  ;; ideally only writes on "http://xmlns.com/foaf/0.1/member" predicate
  ("foaf:Group" -> _))

(define-graph kabinet-agenda ("http://mu.semte.ch/graphs/organizations/kabinet")
  ("oc:Meeting" -> _)
  ("oc:AgendaItem" -> _)
  ("foaf:Document" -> _)
  ("ext:DocumentVersie" -> _)
  ("nfo:FileDataObject" -> _))
(define-graph kabinet-account-info ("http://mu.semte.ch/graphs/organizations/kabinet")
  ("foaf:Person" -> _)
  ("foaf:OnlineAccount" -> _)
  ("adms:Identifier" -> _)
  ;; ideally only writes on "http://xmlns.com/foaf/0.1/member" predicate
  ("foaf:Group" -> _))

(define-graph adviesverlener-account-info ("http://mu.semte.ch/graphs/organizations/adviesverlener")
  ("foaf:Person" -> _)
  ("foaf:OnlineAccount" -> _)
  ("adms:Identifier" -> _)
  ;; ideally only writes on "http://xmlns.com/foaf/0.1/member" predicate
  ("foaf:Group" -> _))

(define-graph administratie-agenda ("http://mu.semte.ch/graphs/organizations/administratie")
  ("oc:Meeting" -> _)
  ("oc:AgendaItem" -> _)
  ("foaf:Document" -> _)
  ("ext:DocumentVersie" -> _)
  ("nfo:FileDataObject" -> _))

(define-graph administratie-account-info ("http://mu.semte.ch/graphs/organizations/administratie")
  ("foaf:Person" -> _)
  ("foaf:OnlineAccount" -> _)
  ("adms:Identifier" -> _)
  ;; ideally only writes on "http://xmlns.com/foaf/0.1/member" predicate
  ("foaf:Group" -> _))

(define-graph parlement-account-info ("http://mu.semte.ch/graphs/organizations/parlement")
  ("foaf:Person" -> _)
  ("foaf:OnlineAccount" -> _)
  ("adms:Identifier" -> _)
  ;; ideally only writes on "http://xmlns.com/foaf/0.1/member" predicate
  ("foaf:Group" -> _))

(define-graph user-account-info ("http://mu.semte.ch/graphs/organizations/user")
  ("foaf:Person" -> _)
  ("foaf:OnlineAccount" -> _)
  ("adms:Identifier" -> _)
  ;; ideally only writes on "http://xmlns.com/foaf/0.1/member" predicate
  ("foaf:Group" -> _))

(grant (read)
  :to-graph public
  :for-allowed-group "public")

(grant (read write)
  :to-graph (
    admin-user-info
    authenticated-users-case
    kanselarij-agenda)
  :for-allowed-group "admin-rw")

(grant (read write)
  :to-graph (
    kanselarij-agenda
    kanselarij-account-info
    authenticated-users-case)
  :for-allowed-group "kanselarij")

(grant (read)
  :to-graph (
    minister-agenda
    minister-account-info
    authenticated-users-case)
  :for-allowed-group "minister")

(grant (read)
  :to-graph (
    kabinet-agenda
    authenticated-users-case)
  :for-allowed-group "kabinet-adviesverlener")

(grant (read)
  :to-graph (
    kabinet-account-info)
  :for-allowed-group "kabinet")

(grant (read)
  :to-graph (
    adviesverlener-account-info)
  :for-allowed-group "adviesverlener")

(grant (read)
  :to-graph (
    administratie-agenda
    authenticated-users-case)
  :for-allowed-group "administratie-parlement")

(grant (read)
  :to-graph (
    administratie-account-info)
  :for-allowed-group "administratie")

(grant (read)
  :to-graph (
    parlement-account-info)
  :for-allowed-group "parlement")

(grant (read)
  :to-graph (
    user-account-info)
  :for-allowed-group "user")
