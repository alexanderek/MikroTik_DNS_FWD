# Define global variables
:global AddressList "example_list_a"
:global ForwardTo "example_dns_a"
:global DryRun "true"
:global VerboseLimit 0

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
  :local adopted 0
  :local wouldAdopt 0
  :local skipped 0
  :local logged 0
  :local tag ("dnsfwd:auto:" . $resource)
  :local tagNeedle ("comment=\"" . $tag . "\"")

  :local url "$baseUrl/$resource.rsc"
  :do {
    :local r [/tool fetch url=$url mode=https output=user as-value]
    :if (($r->"status")="finished") do={
      :local content ($r->"data")
      :if (([:find $content "/ip dns static"] != -1) && ([:find $content " add address-list="] != -1)) do={
        :foreach line in=[:toarray $content] do={
          :if (([:find $line " add "] != -1) && ([:find $line $tagNeedle] != -1)) do={
            :local name ""
            :local regexp ""

            :local nameKey " name="
            :local nameIdx [:find $line $nameKey]
            :if ($nameIdx != -1) do={
              :local nameStart ($nameIdx + [:len $nameKey])
              :local nameEnd -1
              :if ([:pick $line $nameStart ($nameStart + 1)] = "\"") do={
                :set nameStart ($nameStart + 1)
                :set nameEnd [:find $line "\"" $nameStart]
              } else={
                :set nameEnd [:find $line " " $nameStart]
              }
              :if ($nameEnd = -1) do={ :set nameEnd [:len $line] }
              :set name [:pick $line $nameStart $nameEnd]
            }

            :local reKey " regexp="
            :local reIdx [:find $line $reKey]
            :if ($reIdx != -1) do={
              :local reStart ($reIdx + [:len $reKey])
              :local reEnd -1
              :if ([:pick $line $reStart ($reStart + 1)] = "\"") do={
                :set reStart ($reStart + 1)
                :set reEnd [:find $line "\"" $reStart]
              } else={
                :set reEnd [:find $line " " $reStart]
              }
              :if ($reEnd = -1) do={ :set reEnd [:len $line] }
              :set regexp [:pick $line $reStart $reEnd]
            }

            :if ($name != "") do={
              :local ids [/ip dns static find where name=$name and address-list=$AddressList and type=FWD and forward-to=$ForwardTo]
              :if ([:len $ids] > 0) do={
                :foreach id in=$ids do={
                  :local comment [/ip dns static get $id comment]
                  :if ([:pick $comment 0 12] != "dnsfwd:auto:") do={
                    :if ($DryRun = "true") do={
                      :if (($VerboseLimit > 0) && ($logged < $VerboseLimit)) do={
                        :log info ("WOULD ADOPT " . $name . " -> " . $tag)
                        :set logged ($logged + 1)
                      }
                      :set wouldAdopt ($wouldAdopt + 1)
                    } else={
                      /ip dns static set $id comment=$tag
                      :if (($VerboseLimit > 0) && ($logged < $VerboseLimit)) do={
                        :log info ("ADOPTED " . $name . " -> " . $tag)
                        :set logged ($logged + 1)
                      }
                      :set adopted ($adopted + 1)
                    }
                  } else={
                    :set skipped ($skipped + 1)
                  }
                }
              } else={
                :set skipped ($skipped + 1)
              }
            }

            :if ($regexp != "") do={
              :local ids [/ip dns static find where regexp=$regexp and address-list=$AddressList and type=FWD and forward-to=$ForwardTo]
              :if ([:len $ids] > 0) do={
                :foreach id in=$ids do={
                  :local comment [/ip dns static get $id comment]
                  :if ([:pick $comment 0 12] != "dnsfwd:auto:") do={
                    :if ($DryRun = "true") do={
                      :if (($VerboseLimit > 0) && ($logged < $VerboseLimit)) do={
                        :log info ("WOULD ADOPT " . $regexp . " -> " . $tag)
                        :set logged ($logged + 1)
                      }
                      :set wouldAdopt ($wouldAdopt + 1)
                    } else={
                      /ip dns static set $id comment=$tag
                      :if (($VerboseLimit > 0) && ($logged < $VerboseLimit)) do={
                        :log info ("ADOPTED " . $regexp . " -> " . $tag)
                        :set logged ($logged + 1)
                      }
                      :set adopted ($adopted + 1)
                    }
                  } else={
                    :set skipped ($skipped + 1)
                  }
                }
              } else={
                :set skipped ($skipped + 1)
              }
            }
          }
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
          :foreach line in=[:toarray $content] do={
            :if (([:find $line " add "] != -1) && ([:find $line $tagNeedle] != -1)) do={
              :local name ""
              :local regexp ""

              :local nameKey " name="
              :local nameIdx [:find $line $nameKey]
              :if ($nameIdx != -1) do={
                :local nameStart ($nameIdx + [:len $nameKey])
                :local nameEnd -1
                :if ([:pick $line $nameStart ($nameStart + 1)] = "\"") do={
                  :set nameStart ($nameStart + 1)
                  :set nameEnd [:find $line "\"" $nameStart]
                } else={
                  :set nameEnd [:find $line " " $nameStart]
                }
                :if ($nameEnd = -1) do={ :set nameEnd [:len $line] }
                :set name [:pick $line $nameStart $nameEnd]
              }

              :local reKey " regexp="
              :local reIdx [:find $line $reKey]
              :if ($reIdx != -1) do={
                :local reStart ($reIdx + [:len $reKey])
                :local reEnd -1
                :if ([:pick $line $reStart ($reStart + 1)] = "\"") do={
                  :set reStart ($reStart + 1)
                  :set reEnd [:find $line "\"" $reStart]
                } else={
                  :set reEnd [:find $line " " $reStart]
                }
                :if ($reEnd = -1) do={ :set reEnd [:len $line] }
                :set regexp [:pick $line $reStart $reEnd]
              }

              :if ($name != "") do={
                :local ids [/ip dns static find where name=$name and address-list=$AddressList and type=FWD and forward-to=$ForwardTo]
                :if ([:len $ids] > 0) do={
                  :foreach id in=$ids do={
                    :local comment [/ip dns static get $id comment]
                    :if ([:pick $comment 0 12] != "dnsfwd:auto:") do={
                      :if ($DryRun = "true") do={
                        :if (($VerboseLimit > 0) && ($logged < $VerboseLimit)) do={
                          :log info ("WOULD ADOPT " . $name . " -> " . $tag)
                          :set logged ($logged + 1)
                        }
                        :set wouldAdopt ($wouldAdopt + 1)
                      } else={
                        /ip dns static set $id comment=$tag
                        :if (($VerboseLimit > 0) && ($logged < $VerboseLimit)) do={
                          :log info ("ADOPTED " . $name . " -> " . $tag)
                          :set logged ($logged + 1)
                        }
                        :set adopted ($adopted + 1)
                      }
                    } else={
                      :set skipped ($skipped + 1)
                    }
                  }
                } else={
                  :set skipped ($skipped + 1)
                }
              }

              :if ($regexp != "") do={
                :local ids [/ip dns static find where regexp=$regexp and address-list=$AddressList and type=FWD and forward-to=$ForwardTo]
                :if ([:len $ids] > 0) do={
                  :foreach id in=$ids do={
                    :local comment [/ip dns static get $id comment]
                    :if ([:pick $comment 0 12] != "dnsfwd:auto:") do={
                      :if ($DryRun = "true") do={
                        :if (($VerboseLimit > 0) && ($logged < $VerboseLimit)) do={
                          :log info ("WOULD ADOPT " . $regexp . " -> " . $tag)
                          :set logged ($logged + 1)
                        }
                        :set wouldAdopt ($wouldAdopt + 1)
                      } else={
                        /ip dns static set $id comment=$tag
                        :if (($VerboseLimit > 0) && ($logged < $VerboseLimit)) do={
                          :log info ("ADOPTED " . $regexp . " -> " . $tag)
                          :set logged ($logged + 1)
                        }
                        :set adopted ($adopted + 1)
                      }
                    } else={
                      :set skipped ($skipped + 1)
                    }
                  }
                } else={
                  :set skipped ($skipped + 1)
                }
              }
            }
          }
        }
      }
      :set part ($part + 1)
    } on-error {
      :set continue false
    }
  }

  :if ($DryRun = "true") do={
    :log info ("adoption summary " . $resource . ": would_adopt=" . $wouldAdopt . " skipped=" . $skipped)
  } else={
    :log info ("adoption summary " . $resource . ": adopted=" . $adopted . " skipped=" . $skipped)
  }
}
