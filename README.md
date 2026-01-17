# MikroTik DNS FWD (Auto-managed)

This repository provides an **automated, safe and idempotent** way to manage
`/ip dns static` **FWD rules** on MikroTik RouterOS.

It is designed for setups where DNS forwarding is used to steer traffic
(e.g. via different VPNs) based on domain names.

---

## 🔧 What this project does

* Generates RouterOS-compatible `.rsc` files with DNS `type=FWD` rules
* Domains are collected and merged from:

  * [https://iplist.opencck.org](https://iplist.opencck.org)
  * [https://github.com/MetaCubeX/meta-rules-dat](https://github.com/MetaCubeX/meta-rules-dat) (geosite)
* GitHub Actions **regenerates lists automatically**
* MikroTik loads these lists via a **thin loader script**
* Existing **manual DNS rules are never touched**

---

## 🧠 Key concepts

### 1. Source of truth = GitHub

All domain lists are generated in GitHub and stored in `for_scripts/*.rsc`.

RouterOS **never generates domains**, it only downloads and applies them.

---

### 2. Namespacing: `dnsfwd:auto:*`

All automatically managed rules use comments like:

```routeros
dnsfwd:auto:<resource>
```

Examples:

* `dnsfwd:auto:openai`
* `dnsfwd:auto:tiktok`

This namespace allows:

* safe cleanup
* precise sync
* coexistence with manual rules

Anything **without** this prefix is considered **manual and protected**.

---

### 3. Manual rules are sacred 🛡️

You can safely add your own rules, for example:

```routeros
/ip dns static add \
  name=manual.example \
  type=FWD \
  forward-to=dns_example \
  address-list=dnsfwd_example \
  comment="MANUAL_DO_NOT_TOUCH"
```

These rules will **never** be removed or modified by this system.

---

## 🔄 SyncMode

The loader script supports two modes:

### `SyncMode="add"` (default, safest)

* Only adds missing entries
* Never deletes anything
* Ideal for first deployment or cautious setups

### `SyncMode="sync"`

* Removes **only** entries with:

  * `comment=dnsfwd:auto:<resource>`
  * within the current `AddressList`
* Then applies the freshly downloaded list
* Manual rules are preserved

This gives **true reconciliation** without risk.

---

## 🌍 Multiple regions / forwarders

Typical use case:

* Region A domains → Forwarder A → `dns_example_a`
* Region B domains → Forwarder B → `dns_example_b`

This is handled by running **two independent loader scripts** with different parameters.

---

## 🧾 Prebuilt loader scripts

Located in `routeros/`:

* `loader_eu.rsc`
* `loader_ru.rsc`

These are **examples**. Copy/rename and adjust to your environment.

They differ **only** by:

* `AddressList`
* `ForwardTo`

---

## ▶️ Example loader (excerpt)

```routeros
:global AddressList "dnsfwd_example"
:global ForwardTo "dns_example"
:global SyncMode "sync"

:local baseUrl "https://raw.githubusercontent.com/alexanderek/MikroTik_DNS_FWD/refs/heads/main/for_scripts"
```

---

## ⏱️ Scheduler example

```routeros
/system scheduler
add name=dnsfwd-a interval=1d on-event="/system/script/run loader_example_a"
add name=dnsfwd-b interval=1d on-event="/system/script/run loader_example_b"
```

---

## 🤖 GitHub Actions

* Automatically regenerates `for_scripts/*.rsc`
* Cleans previous artifacts
* Validates output
* Prevents concurrent runs (`concurrency`)
* Safely rebases before pushing to `main`

The workflow is **fully autonomous** and requires no manual intervention.

---

## ✅ Design goals

* ✅ Idempotent
* ✅ Safe for production
* ✅ Manual rules preserved
* ✅ Predictable sync
* ✅ Minimal RouterOS logic
* ✅ GitHub as single source of truth

---

## ⚠️ Notes

* Some `fetch` 404 logs are expected due to `partN` probing
* These are harmless and can be filtered via RouterOS logging if desired

---

## 📌 TL;DR

GitHub generates → MikroTik downloads →
`dnsfwd:auto:*` is managed → everything else is yours.

Safe. Boring. Reliable.

---
