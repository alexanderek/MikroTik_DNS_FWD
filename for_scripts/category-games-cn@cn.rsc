:global AddressList
:global ForwardTo
/ip dns static
:if ([:len [find regexp="^.+-mihayo\\\\.akamaized\\\\.net\$"]] = 0) do={ add address-list=$AddressList forward-to=$ForwardTo comment="dnsfwd:auto:category-games-cn@cn" type=FWD regexp="^.+-mihayo\\\\.akamaized\\\\.net\$" }
