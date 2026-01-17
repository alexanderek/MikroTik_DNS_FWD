# Define global variables
:global AddressList "example_list_a"
:global ForwardTo "example_dns_a"
:global SyncMode "add"

# List of resources corresponding to RSC files
:global resources {
  "openai";
  "google-gemini";
  "claude";
  "xai";
  "notion";
  "netflix";
  "twitch";
  "intel";
  "canva";
  "spotify";
  "tidal";
  "tiktok";
  "atlassian";
  "deepl";
  "slack";
  "ubiquiti";
  "cisco";
  "xbox";
  "playstation"
}

# Base URL for RSC files
:local baseUrl "https://raw.githubusercontent.com/alexanderek/MikroTik_DNS_FWD/refs/heads/main/for_scripts"

:foreach resource in=$resources do={
  :local cleaned false
  :local url "$baseUrl/$resource.rsc"
  :do {
    :local r [/tool fetch url=$url mode=https output=user as-value]
    :if (($r->"status")="finished") do={
      :local content ($r->"data")
      :if (([:find $content "/ip dns static"] != -1) && ([:find $content " add address-list="] != -1)) do={
        :if (($SyncMode = "sync") && (!$cleaned)) do={
          :local tag ("dnsfwd:auto:" . $resource)
          /ip dns static remove [find comment=$tag address-list=$AddressList]
          :set cleaned true
        }
        :local s [:parse $content]
        $s
        :log info "$resource.rsc loading completed"
        :put "$resource.rsc loading completed"
      } else={
        :log warning "$resource.rsc validation failed"
        :put "$resource.rsc validation failed"
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
          :if (($SyncMode = "sync") && (!$cleaned)) do={
            :local tag ("dnsfwd:auto:" . $resource)
            /ip dns static remove [find comment=$tag address-list=$AddressList]
            :set cleaned true
          }
          :local s [:parse $content]
          $s
          :log info "$resource.rsc part$part loading completed"
          :put "$resource.rsc part$part loading completed"
        } else={
          :log warning "$resource.rsc part$part validation failed"
          :put "$resource.rsc part$part validation failed"
        }
      }
      :set part ($part + 1)
    } on-error {
      :set continue false
    }
  }
}
