# What this looked like before the fix

Never actually applied anywhere — same pattern as exercise 05. This is what the
`request_routing_rule` block for the app listener would have looked like without
the rewrite rule set at all, which is the actual state a lot of the apps behind
the real gateway this is modeled on were in before the pen test findings:

```hcl
request_routing_rule {
  name                       = "routing-rule-app"
  rule_type                  = "Basic"
  priority                   = 100
  http_listener_name         = "listener-app-https"
  backend_address_pool_name  = "backend-pool-app"
  backend_http_settings_name = "backend-http-settings-app"
  # no rewrite_rule_set_name — whatever headers the backend app sends (or doesn't
  # send) pass straight through to the client, unmodified
}
```

## Why this matters
No rewrite rule set means the gateway is just a dumb pipe for response headers. If
the app behind it never got around to setting `Strict-Transport-Security`, doesn't
set `X-Content-Type-Options`, and the framework it runs on happily announces
`Server: Microsoft-IIS/10.0` and `X-AspNet-Version: 4.0.30319` on every response,
all of that reaches the client exactly as-is. That's not a hypothetical, it's what
an external pen test or a basic header scanner (securityheaders.com, Nikto,
whatever) picks up immediately, and it's a repeat finding precisely because it's
easy to introduce (nobody has to do anything wrong, just not do something right)
and easy to miss in review (headers aren't in the diff of a typical PR the way a
firewall rule change would be).

## What changed
Added a `rewrite_rule_set` on the gateway with two rules: one that adds the six
required security headers with sane defaults, and one that blanks out the headers
that leak framework/version info. The routing rule now references that rule set by
name, so every response through this listener gets normalized on the way out,
regardless of what the backend app actually sent.

## The honest limitation of the fix
This is covered in more depth in the README, but the short version: a rewrite rule
can set the `Content-Security-Policy` *header*, it cannot make sure the policy
inside that header is actually correct for the app, or that the app doesn't have
inline scripts that break under a strict CSP the moment it's turned on for real.
Gateway-level enforcement closes the "somebody forgot" gap, it doesn't replace an
app team actually understanding what their own CSP needs to allow.
