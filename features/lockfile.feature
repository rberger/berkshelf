Feature: Berksfile.lock
  As a user
  I want my versions to be locked even when I don't specify versions in my Berksfile
  So when I share my repository, all other developers get the same versions that I did when I installed.

  Scenario: Writing the Berksfile.lock
    Given I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'ntp', '1.1.8'
      """
    When I successfully run `berks install`
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
        "sha":"23150cfe61b7b86882013c8664883058560b899d",
        "sources":{
          "ntp":{
            "constraint":"= 1.1.8",
            "locked_version":"1.1.8"
          }
        }
      }
      """

  Scenario: Installing a cookbook with dependencies
  Given I write to "Berksfile" with:
    """
    site :opscode
    cookbook 'database', '1.3.12'
    """
  When I successfully run `berks install`
  Then the file "Berksfile.lock" should contain JSON:
    """
    {
      "sha":"4efd21c0060d2a827a9258a72fa38c78fbd06d1a",
      "sources":{
        "database":{
          "constraint":"= 1.3.12",
          "locked_version":"1.3.12"
        },
        "mysql":{
          "constraint":">= 1.3.0",
          "locked_version":"3.0.0"
        },
        "openssl":{
          "locked_version":"1.0.2"
        },
        "build-essential":{
          "locked_version":"1.4.0"
        },
        "postgresql":{
          "constraint":">= 1.0.0",
          "locked_version":"2.4.0"
        },
        "apt":{
          "locked_version":"1.9.2"
        },
        "aws":{
          "locked_version":"0.100.6"
        },
        "xfs":{
          "locked_version":"1.1.0"
        }
      }
    }
    """

  Scenario: Writing the Berksfile.lock with a pessimistic lock
    Given I write to "Berksfile" with:
      """
      site :opscode
      cookbook 'ntp', '~> 1.1.0'
      """
    And I write to "Berksfile.lock" with:
      """
      {
        "sha":"f11aa63004577ab13f1476c16a35e2e3ff9266aa",
        "sources":{
          "ntp":{
            "constraint":"~> 1.1.0",
            "locked_version":"1.1.8"
          }
        }
      }
      """
    When I successfully run `berks install`
    Then the file "Berksfile.lock" should contain JSON:
      """
      {
        "sha":"7403c97a9321beb8060dde3fdc8702ad1b623f4b",
        "sources":{
          "ntp":{
            "constraint":"~> 1.1.0",
            "locked_version":"1.1.8"
          }
        }
      }
      """

  Scenario: Updating with a Berksfile.lock with pessimistic lock
  Given I write to "Berksfile" with:
    """
    site :opscode
    cookbook 'ntp', '~> 1.3.0'
    """
  And I write to "Berksfile.lock" with:
    """
    {
      "sha":"3dced4fcd9c3f72b68e746190aaa1140bdc6cc3d",
      "sources":{
        "ntp":{
          "constraint":"~> 1.3.0",
          "locked_version":"1.3.0"
        }
      }
    }
    """
  When I successfully run `berks update ntp`
  Then the file "Berksfile.lock" should contain JSON:
    """
    {
      "sha":"3dced4fcd9c3f72b68e746190aaa1140bdc6cc3d",
      "sources":{
        "ntp":{
          "constraint":"~> 1.3.0",
          "locked_version":"1.3.2"
        }
      }
    }
    """

  Scenario: Updating with a Berksfile.lock with hard lock
  Given I write to "Berksfile" with:
    """
    site :opscode
    cookbook 'ntp', '1.3.0'
    """
  And I write to "Berksfile.lock" with:
    """
    {
      "sha":"7d07c22eca03bf6da5aaf38ae81cb9a8a439c692",
      "sources":{
        "ntp":{
          "constraint":"= 1.3.0",
          "locked_version":"1.3.0"
        }
      }
    }
    """
  When I successfully run `berks update ntp`
  Then the file "Berksfile.lock" should contain JSON:
    """
    {
      "sha":"7d07c22eca03bf6da5aaf38ae81cb9a8a439c692",
      "sources":{
        "ntp":{
          "constraint":"= 1.3.0",
          "locked_version":"1.3.0"
        }
      }
    }
    """

  Scenario: Updating a Berksfile.lock with a git location
  Given I write to "Berksfile" with:
    """
    site :opscode
    cookbook 'sudo', git: 'git://github.com/opscode-cookbooks/sudo.git', ref: 'f7ada1e95'
    """
  When I successfully run `berks install`
  Then the file "Berksfile.lock" should contain JSON:
    """
    {
      "sha": "d8fff7d2d491eb5ad9b15edfdf0a8a4da513f33a",
      "sources":{
        "sudo":{
          "git":"git://github.com/opscode-cookbooks/sudo.git",
          "ref":"f7ada1e95",
          "locked_version":"2.0.4"
        }
      }
    }
    """

  Scenario: Updating a Berksfile.lock with a git location
  Given I write to "Berksfile" with:
    """
    site :opscode
    cookbook 'sudo', github: 'opscode-cookbooks/sudo', ref: 'f7ada1e95'
    """
  When I successfully run `berks install`
  Then the file "Berksfile.lock" should contain JSON:
    """
    {
      "sha": "3232c5ae6f54aee3efc5fdcfce69249a2526822b",
      "sources":{
        "sudo":{
          "git":"git://github.com/opscode-cookbooks/sudo.git",
          "ref":"f7ada1e95",
          "locked_version":"2.0.4"
        }
      }
    }
    """

  Scenario: Updating a Berksfile.lock with a path location
  Given I write to "Berksfile" with:
    """
    site :opscode
    cookbook 'fake', path: './fake'
    """
  And a cookbook named "fake"
  When I successfully run `berks install`
  Then the file "Berksfile.lock" should contain JSON:
    """
    {
      "sha": "42a13f91f1ba19ce8c6776fe267e74510dee27ce",
      "sources":{
        "fake":{
          "path":"./fake",
          "locked_version":"0.0.0"
        }
      }
    }
    """

  Scenario: Updating a Berksfile.lock with a different site location
  Given pending we have a reliable non-opscode site to test
  # Given I write to "Berksfile" with:
  #   """
  #   cookbook 'fake', site: 'example.com'
  #   """
  # When I successfully run `berks install`
  # Then the file "Berksfile.lock" should contain JSON:
  #   """
  #   {
  #     "sha": "3232c5ae6f54aee3efc5fdcfce69249a2526822b",
  #     "sources":{
  #       "sudo":{
  #         "site":"opscode",
  #         "locked_version":"2.0.4"
  #       }
  #     }
  #   }
  #   """

  Scenario: Installing when the locked version is no longer satisfied
  Given I write to "Berksfile" with:
    """
    site :opscode
    cookbook 'ntp', '1.1.8'
    """
  And I successfully run `berks install`
  And I write to "Berksfile" with:
    """
    site :opscode
    cookbook 'ntp', '~> 1.3.0'
    """
  When I run `berks install`
  Then the output should contain:
    """
    Berkshelf could not find compatible versions for cookbook 'ntp':
      In Berksfile:
        ntp (1.1.8)

      In Berksfile.lock:
        ntp (~> 1.3.0)

    Try running `berks update ntp, which will try to find  'ntp' matching '~> 1.3.0'.
    """
  And the CLI should exit with the status code for error "OutdatedCookbookSource"
