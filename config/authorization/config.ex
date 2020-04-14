alias Acl.Accessibility.Always, as: AlwaysAccessible
alias Acl.Accessibility.ByQuery, as: AccessByQuery
alias Acl.GraphSpec.Constraint.Resource.AllPredicates, as: AllPredicates
alias Acl.GraphSpec.Constraint.Resource.NoPredicates, as: NoPredicates
alias Acl.GraphSpec.Constraint.ResourceFormat, as: ResourceFormatConstraint
alias Acl.GraphSpec.Constraint.Resource, as: ResourceConstraint
alias Acl.GraphSpec, as: GraphSpec
alias Acl.GroupSpec, as: GroupSpec
alias Acl.GroupSpec.GraphCleanup, as: GraphCleanup

defmodule Acl.UserGroups.Config do

  defp access_by_role( group_uris ) do
    %AccessByQuery{
      vars: [],
      query: "PREFIX session: <http://mu.semte.ch/vocabularies/session/>
              PREFIX foaf: <http://xmlns.com/foaf/0.1/>
              SELECT ?group_uri WHERE {
                <SESSION_ID> session:account / ^foaf:account / ^foaf:member ?group_uri .
                VALUES ?group_uri { #{group_uris} }
              } LIMIT 1"
    }
  end

  defp access_by_has_a_role() do
    %AccessByQuery{
      vars: [],
      query: "PREFIX session: <http://mu.semte.ch/vocabularies/session/>
              PREFIX foaf: <http://xmlns.com/foaf/0.1/>
              SELECT ?role WHERE {
                <SESSION_ID> session:account / ^foaf:account / ^foaf:member ?role .
              } LIMIT 1"
    }
  end

  defp fixed_code_list_types() do
    [
      "http://mu.semte.ch/vocabularies/ext/DocumentTypeCode",
      "http://mu.semte.ch/vocabularies/ext/ToegangsniveauCode",
      "http://data.vlaanderen.be/ns/besluit#Bestuursorgaan",
      "http://xmlns.com/foaf/0.1/Group"
    ]
  end

  defp account_info_types() do
    [
      "http://xmlns.com/foaf/0.1/Person",
      "http://xmlns.com/foaf/0.1/OnlineAccount"
    ]
  end

  defp agenda_related_types() do
    [
      "http://mu.semte.ch/vocabularies/ext/oc/Meeting",
      "http://mu.semte.ch/vocabularies/ext/oc/AgendaItem",
      "http://xmlns.com/foaf/0.1/Document",
      "http://mu.semte.ch/vocabularies/ext/DocumentVersie",
      "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#FileDataObject",
    ]
  end

  defp case_related_types() do
    [
      "http://mu.semte.ch/vocabularies/ext/oc/Case",
    ]
  end


  def user_groups do
    [
      # NOTE: Behavior when graph already contains more info than constraints specify, is undefined.
      # Currently, read access then isn't limited to the specified resource types
      %GroupSpec{
        name: "public",
        useage: [:read],
        access: %AlwaysAccessible{}, # TODO: Should be only for logged in users
        graphs: [
          %GraphSpec{
            graph: "http://mu.semte.ch/graphs/public",
            constraint: %ResourceConstraint{
              resource_types: fixed_code_list_types()
            }
          }
        ]
      },

      %GroupSpec{
        name: "admin-r",
        useage: [:read],
        access: access_by_role("<http://data.kanselarij.vlaanderen.be/id/group/admin>"),
        graphs: [
          %GraphSpec{
            graph: "http://mu.semte.ch/graphs/admins",
            constraint: %ResourceConstraint{
              resource_types: account_info_types()
            }
          }
        ]
      },
      
      %GroupSpec{
        name: "admin-w",
        useage: [:write,:read_for_write],
        access: access_by_role("<http://data.kanselarij.vlaanderen.be/id/group/admin>"),
        graphs: [
          %GraphSpec{
            graph: "http://mu.semte.ch/graphs/account-info", # Admins write in here, user-info-distributor service distributes to the right graphs
            constraint: %ResourceConstraint{
              resource_types: account_info_types()
            }
          }
        ]
      },
      
      %GroupSpec{
        name: "admin-rw",
        useage: [:read, :write,:read_for_write],
        access: access_by_role("<http://data.kanselarij.vlaanderen.be/id/group/admin>"),
        graphs: [
          %GraphSpec{
            graph: "http://mu.semte.ch/graphs/organizations/kanselarij",
            constraint: %ResourceConstraint{
              resource_types: agenda_related_types()
            }
          },
          %GraphSpec{
            graph: "http://mu.semte.ch/graphs/authenticated-users",
            constraint: %ResourceConstraint{
              resource_types: case_related_types()
            }
          }
        ]
      },
      
      %GroupSpec{
        name: "kanselarij",
        useage: [:read, :write,:read_for_write],
        access: access_by_role("<http://data.kanselarij.vlaanderen.be/id/group/kanselarij>"),
        graphs: [
          %GraphSpec{
            graph: "http://mu.semte.ch/graphs/organizations/kanselarij",
            constraint: %ResourceConstraint{
              resource_types: agenda_related_types() ++ account_info_types()
            }
          },
          %GraphSpec{
            graph: "http://mu.semte.ch/graphs/authenticated-users",
            constraint: %ResourceConstraint{
              resource_types: case_related_types()
            }
          }
        ]
      },
      
      %GroupSpec{
        name: "minister",
        useage: [:read],
        access: access_by_role("<http://data.kanselarij.vlaanderen.be/id/group/minister>"),
        graphs: [
          %GraphSpec{
            graph: "http://mu.semte.ch/graphs/organizations/minister",
            constraint: %ResourceConstraint{
              resource_types: agenda_related_types() ++ account_info_types()
            }
          },
          %GraphSpec{
            graph: "http://mu.semte.ch/graphs/authenticated-users",
            constraint: %ResourceConstraint{
              resource_types: case_related_types()
            }
          }
        ]
      },

      # Currently "kabinet" and "adviesverlener" have equal rights for agenda viewing. They both read from kabinet graph
      %GroupSpec{
        name: "kabinet+adviesverlener",
        useage: [:read],
        access: access_by_role("<http://data.kanselarij.vlaanderen.be/id/group/kabinet>
                                <http://data.kanselarij.vlaanderen.be/id/group/adviesverlener>"),
        graphs: [
          %GraphSpec{
            graph: "http://mu.semte.ch/graphs/organizations/kabinet",
            constraint: %ResourceConstraint{
              resource_types: agenda_related_types()
            }
          },
          %GraphSpec{
            graph: "http://mu.semte.ch/graphs/authenticated-users",
            constraint: %ResourceConstraint{
              resource_types: case_related_types()
            }
          }
        ]
      },

      %GroupSpec{
        name: "kabinet",
        useage: [:read],
        access: access_by_role("<http://data.kanselarij.vlaanderen.be/id/group/kabinet>"),
        graphs: [
          %GraphSpec{
            graph: "http://mu.semte.ch/graphs/organizations/kabinet",
            constraint: %ResourceConstraint{
              resource_types: account_info_types()
            }
          }
        ]
      },

      %GroupSpec{
        name: "adviesverlener",
        useage: [:read],
        access: access_by_role("<http://data.kanselarij.vlaanderen.be/id/group/adviesverlener>"),
        graphs: [
          %GraphSpec{
            graph: "http://mu.semte.ch/graphs/organizations/adviesverlener",
            constraint: %ResourceConstraint{
              resource_types: account_info_types()
            }
          }
        ]
      },

      # Currently "administratie" and "parlement" have equal rights for agenda viewing. They both read from administratie graph
      %GroupSpec{
        name: "administratie+parlement",
        useage: [:read],
        access: access_by_role("<http://data.kanselarij.vlaanderen.be/id/group/administratie>
                                <http://data.kanselarij.vlaanderen.be/id/group/parlement>"),
        graphs: [
          %GraphSpec{
            graph: "http://mu.semte.ch/graphs/organizations/administratie",
            constraint: %ResourceConstraint{
              resource_types: agenda_related_types()
            }
          },
          %GraphSpec{
            graph: "http://mu.semte.ch/graphs/authenticated-users",
            constraint: %ResourceConstraint{
              resource_types: case_related_types()
            }
          }
        ]
      },
      
      %GroupSpec{
        name: "administratie",
        useage: [:read],
        access: access_by_role("<http://data.kanselarij.vlaanderen.be/id/group/administratie>"),
        graphs: [
          %GraphSpec{
            graph: "http://mu.semte.ch/graphs/organizations/administratie",
            constraint: %ResourceConstraint{
              resource_types: account_info_types()
            }
          }
        ]
      },
      
      %GroupSpec{
        name: "parlement",
        useage: [:read],
        access: access_by_role("<http://data.kanselarij.vlaanderen.be/id/group/parlement>"),
        graphs: [
          %GraphSpec{
            graph: "http://mu.semte.ch/graphs/organizations/parlement",
            constraint: %ResourceConstraint{
              resource_types: account_info_types()
            }
          }
        ]
      },
      
      # // CLEANUP
      #
      %GraphCleanup{
        originating_graph: "http://mu.semte.ch/application",
        useage: [:write],
        name: "clean"
      }
    ]
  end
end
