# Define global variables
:global AddressList "example_list_b"
:global ForwardTo "example_dns_b"
:global DryRun "true"

# List of resources corresponding to RSC files
:global resources {
  "linkedin";
  "youtube";
  "meta";
  "twitter";
  "cloudflare";
  "rutracker";
  "torrent";
  "discord";
  "telegram"
}

# Base URL for RSC files
:local baseUrl "https://raw.githubusercontent.com/alexanderek/MikroTik_DNS_FWD/refs/heads/main/for_scripts"

:foreach resource in=$resources do={
  :local adopted 0
  :local skipped 0
  :local tag ("dnsfwd:auto:" . $resource)

  :local url "$baseUrl/$resource.rsc"
  :do {
    :local r [/tool fetch url=$url mode=https output=user as-value]
    :if (($r->"status")="finished") do={
      :local content ($r->"data")
      :if (([:find $content "/ip dns static"] != -1) && ([:find $content " add address-list="] != -1)) do={
        :local pos 0
        :while (true) do={
          :local idx [:find $content "name=\"" $pos]
          :if ($idx = -1) do={ :break }
          :local start ($idx + 6)
          :local end [:find $content "\"" $start]
          :if ($end = -1) do={ :break }
          :local name [:pick $content $start $end]

          :local ids [/ip dns static find where name=$name and address-list=$AddressList and type=FWD and forward-to=$ForwardTo]
          :if ([:len $ids] > 0) do={
            :foreach id in=$ids do={
              :if ($DryRun = "true") do={
                :log info ("WOULD ADOPT " . $name . " -> " . $tag)
              } else={
                /ip dns static set $id comment=$tag
                :log info ("ADOPTED " . $name . " -> " . $tag)
              }
              :set adopted ($adopted + 1)
            }
          } else={
            :set skipped ($skipped + 1)
          }

          :set pos ($end + 1)
        }

        :set pos 0
        :while (true) do={
          :local idx [:find $content "regexp=\"" $pos]
          :if ($idx = -1) do={ :break }
          :local start ($idx + 8)
          :local end [:find $content "\"" $start]
          :if ($end = -1) do={ :break }
          :local regexp [:pick $content $start $end]

          :local ids [/ip dns static find where regexp=$regexp and address-list=$AddressList and type=FWD and forward-to=$ForwardTo]
          :if ([:len $ids] > 0) do={
            :foreach id in=$ids do={
              :if ($DryRun = "true") do={
                :log info ("WOULD ADOPT " . $regexp . " -> " . $tag)
              } else={
                /ip dns static set $id comment=$tag
                :log info ("ADOPTED " . $regexp . " -> " . $tag)
              }
              :set adopted ($adopted + 1)
            }
          } else={
            :set skipped ($skipped + 1)
          }

          :set pos ($end + 1)
        }
      }
    }
  } on-error {}

  :local part 1
  :local continue true
  :while ($continue) do={
    :local url "$baseUrl/$resource_part$part.rsc"
    :do {
      :local r [/tool fetch url=$url mode=https output=user as-value]
      :if (($r->"status")="finished") do={
        :local content ($r->"data")
        :if (([:find $content "/ip dns static"] != -1) && ([:find $content " add address-list="] != -1)) do={
          :local pos 0
          :while (true) do={
            :local idx [:find $content "name=\"" $pos]
            :if ($idx = -1) do={ :break }
            :local start ($idx + 6)
            :local end [:find $content "\"" $start]
            :if ($end = -1) do={ :break }
            :local name [:pick $content $start $end]

            :local ids [/ip dns static find where name=$name and address-list=$AddressList and type=FWD and forward-to=$ForwardTo]
            :if ([:len $ids] > 0) do={
              :foreach id in=$ids do={
                :if ($DryRun = "true") do={
                  :log info ("WOULD ADOPT " . $name . " -> " . $tag)
                } else={
                  /ip dns static set $id comment=$tag
                  :log info ("ADOPTED " . $name . " -> " . $tag)
                }
                :set adopted ($adopted + 1)
              }
            } else={
              :set skipped ($skipped + 1)
            }

            :set pos ($end + 1)
          }

          :set pos 0
          :while (true) do={
            :local idx [:find $content "regexp=\"" $pos]
            :if ($idx = -1) do={ :break }
            :local start ($idx + 8)
            :local end [:find $content "\"" $start]
            :if ($end = -1) do={ :break }
            :local regexp [:pick $content $start $end]

            :local ids [/ip dns static find where regexp=$regexp and address-list=$AddressList and type=FWD and forward-to=$ForwardTo]
            :if ([:len $ids] > 0) do={
              :foreach id in=$ids do={
                :if ($DryRun = "true") do={
                  :log info ("WOULD ADOPT " . $regexp . " -> " . $tag)
                } else={
                  /ip dns static set $id comment=$tag
                  :log info ("ADOPTED " . $regexp . " -> " . $tag)
                }
                :set adopted ($adopted + 1)
              }
            } else={
              :set skipped ($skipped + 1)
            }

            :set pos ($end + 1)
          }
        }
      }
      :set part ($part + 1)
    } on-error {
      :set continue false
    }
  }

  :log info ("adoption summary " . $resource . ": adopted=" . $adopted . " skipped=" . $skipped)
}
