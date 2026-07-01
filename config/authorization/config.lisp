;;;;;;;;;;;;;;;;;
;;; configuration
(in-package :client)
(setf *backend* "http://triplestore:8890/sparql")

(setf *log-sparql-query-roundtrip* nil)
(in-package :server)
(setf *log-incoming-requests-p* nil)

;;;;;;;;;;;;;;;;;;;
;;; delta messenger
(in-package :delta-messenger)
(add-delta-messenger "http://delta-notifier/")
(setf *log-delta-messenger-message-bus-processing* nil)

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


;;;;;;;;;;;;;;;;;;;;
;; Access queries

(defun query-for-authenticated ()
  (format nil "PREFIX org: <http://www.w3.org/ns/org#>
               PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
               SELECT ?role_uri WHERE {
                 <SESSION_ID> ext:sessionMembership / org:role ?role_uri .
               } LIMIT 1"))

(defun query-for-roles (roles)
  (format nil "PREFIX org: <http://www.w3.org/ns/org#>
               PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
               SELECT ?role_uri WHERE {
                 <SESSION_ID> ext:sessionMembership / org:role ?role_uri .
                 VALUES ?role_uri { ~{<~A>~^ ~} }
              } LIMIT 1" roles))

;;;;;;;;;;;;;;;;;;;;;;;;;
;; User roles

(defvar *admin-roles*
  '("http://kanselarij.vo.data.gift/id/gebruikersrollen/d02621f2-e4cf-4de0-9484-ce8eb69a7aea")) ;; Admin

(defvar *secretarie-roles*
  '("http://kanselarij.vo.data.gift/id/gebruikersrollen/67eda907-66db-4d68-b913-b5f2b857164a")) ;; Secretarie

(defvar *minister-roles*
  '("http://kanselarij.vo.data.gift/id/gebruikersrollen/49769e61-a5af-47ae-a207-df69b4b178bc")) ;; Minister

(defvar *regering-roles*
  '("http://kanselarij.vo.data.gift/id/gebruikersrollen/95670945-dc7a-4432-949a-41c009447a7d" ;; Kabinet medewerker
     "http://kanselarij.vo.data.gift/id/gebruikersrollen/1c85c862-ec7e-45e5-bd38-2b2f150e8a43")) ;; Adviesverlener

(defvar *overheid-roles*
  '("http://kanselarij.vo.data.gift/id/gebruikersrollen/f5b1e170-ed56-42fa-b3ac-5358c30a33e9"   ;; Overheidsorganisatie
    "http://kanselarij.vo.data.gift/id/gebruikersrollen/0da9f8ce-0f6f-4086-8db5-53e44bd6215d")) ;; Vlaams Parlement


;;;;;;;;;;;;;;;;;;
;; Always accessible read graphs for all visitors

(define-graph public ("http://mu.semte.ch/graphs/public")
  ("ext:DocumentTypeCode" -> _)
  ("ext:ToegangsniveauCode" -> _)
  ("besluit:Bestuursorgaan" -> _)
  ("org:Role" -> _)
  ("org:Organization" -> _)
  ;; Mock accounts
  ("foaf:Person" -> _)
  ("foaf:OnlineAccount" -> _)
  ("foaf:Organization" -> _)
  ("org:Membership" -> _)
  ("ext:LoginActivity" -> _))

(define-graph sessions ("http://mu.semte.ch/graphs/sessions")
  ("session:Session" -> _))

(supply-allowed-group "public")

(grant (read)
       :to public
       :for-allowed-group "public")

(grant (read)
       :to sessions
       :for-allowed-group "public")


;;;;;;;;;;;;;;;;;;
;; Accessible to all authenticated users

(define-graph system/users ("http://mu.semte.ch/graphs/system/users")
  ("foaf:OnlineAccount" -> _)
  ("foaf:Person" -> _)
  ("foaf:Organization" -> _)
  ("org:Membership" -> _)
  ("ext:LoginActivity" -> _))

(supply-allowed-group "authenticated"
  :query (query-for-authenticated))

(grant (read)
  :to system/users
  :for-allowed-group "authenticated")


;;;;;;;;;;;;;;;;;;
;; System-specific data access

(supply-allowed-group "admin-rw" ;; oc-distributor service depends on this group name
  :query (query-for-roles *admin-roles*))

(grant (read write)
  :to system/users
  :for-allowed-group "admin-rw")


(define-graph kanselarij ("http://mu.semte.ch/graphs/organizations/kanselarij")
  ("oc:Case" -> _)
  ("oc:Meeting" -> _)
  ("oc:AgendaItem" -> _)
  ("foaf:Document" -> _)
  ("ext:DocumentVersie" -> _)
  ("nfo:FileDataObject" -> _))

(supply-allowed-group "kanselarij"
  :query (query-for-roles
           (concatenate 'list
             *admin-roles*
             *secretarie-roles*)))

(grant (read)
  :to kanselarij
  :for-allowed-group "kanselarij")


(define-graph minister ("http://mu.semte.ch/graphs/organizations/minister")
  ("oc:Meeting" -> _)
  ("oc:AgendaItem" -> _)
  ("foaf:Document" -> _)
  ("ext:DocumentVersie" -> _)
  ("nfo:FileDataObject" -> _))

(supply-allowed-group "minister"
  :query (query-for-roles *minister-roles*))

(grant (read)
  :to minister
  :for-allowed-group "minister")


(define-graph intern-regering ("http://mu.semte.ch/graphs/organizations/kabinet")
  ("oc:Meeting" -> _)
  ("oc:AgendaItem" -> _)
  ("foaf:Document" -> _)
  ("ext:DocumentVersie" -> _)
  ("nfo:FileDataObject" -> _))

(supply-allowed-group "intern-regering"
  :query (query-for-roles *regering-roles*))

(grant (read)
  :to intern-regering
  :for-allowed-group "intern-regering")


(define-graph intern-overheid ("http://mu.semte.ch/graphs/organizations/administratie")
  ("oc:Meeting" -> _)
  ("oc:AgendaItem" -> _)
  ("foaf:Document" -> _)
  ("ext:DocumentVersie" -> _)
  ("nfo:FileDataObject" -> _))

(supply-allowed-group "intern-overheid"
  :query (query-for-roles *overheid-roles*))

(grant (read)
  :to intern-overheid
  :for-allowed-group "intern-overheid")
